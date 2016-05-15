//
//  TuneExerciseViewController.swift
//  FirstStage
//
//  Created by David S Reich on 14/05/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//

import UIKit
import AVFoundation

class TuneExerciseViewController: UIViewController, SSSyControls, SSUTempo, SSNoteHandler {

    @IBOutlet weak var ssScrollView: SSScrollView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var countOffLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var gateView: UIView!

    var exerciseName = ""
    
    let mxmlService = MusicXMLService()
    let amplitudeThreshold = NSUserDefaults.standardUserDefaults().doubleForKey(Constants.Settings.AmplitudeThreshold)
    let timingThreshold = NSUserDefaults.standardUserDefaults().doubleForKey(Constants.Settings.TimingThreshold)
    let tempoBPM = NSUserDefaults.standardUserDefaults().integerForKey(Constants.Settings.BPS)
    let showNoteMarkers = NSUserDefaults.standardUserDefaults().boolForKey(Constants.Settings.ShowNoteMarkers)
//    var beatDuration = 60.0 / NSUserDefaults.standardUserDefaults().doubleForKey(Constants.Settings.BPS)    //seconds
    
    var score: SSScore?
    var showingSinglePart = false // is set when a single part is being displayed
    var showingSinglePartIndex: Int32 = 0
    var	showingParts = [NSNumber]()
    var layOptions = SSLayoutOptions()  // set of options for layout
    var playData: SSPData?
    var synth: SSSynth?
    var instrumentId = [UInt32]()
    var metronomeInstrumentId: UInt32 = 0
    var cursorBarIndex = Int32(0)
    let kDefaultMagnification: Float = 1.5
    
    // 3 metronome ticks are currently supported (tickpitch = 0, 1 or 2):
    //    static const sscore_sy_synthesizedinstrumentinfo kTick1Info = {"Tick1", 0, 1.0};
    var kTick1Info = sscore_sy_synthesizedinstrumentinfo(instrument_name: ("Tick1" as NSString).UTF8String, tickpitch: Int32(0), volume: Float(1.0), voice: sscore_sy_tick1, dummy: (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
    
    let kfAnim = CAKeyframeAnimation()
    var exerciseDuration = 0.0
    var animHorzOffset = 0.0
    var animValues = [Double]()
    var animKeyTimes = [Double]()
    var playingAnimation = false

    // analysis - timing
    // all calculations in NSDate().timeIntervalSinceDate(startTime)
    // if insideNote then a sound before thresholdEndTime => note hit!
    // if insideRest then a NO-sound before thresholdEndTime => rest hit!
    // if insideNote a sound after thresholdEndTime ==> nothing -- will be useful later for duration
    // if insideRest a sound after threshold
    var startTime : NSDate = NSDate()
    var thresholdEndTime = 0.0
    var insideNote = false
    var insideRest = false

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gateView.hidden = true
        showingSinglePart = false // is set when a single part is being displayed
        cursorBarIndex = 0
        title = "Rhythm"
        loadFile(exerciseName)
        countOffLabel.text = ""
    }

    override func viewWillDisappear(animated: Bool) {
        stopPlaying()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playButtonTapped(sender: UIButton) {
        if playButton.currentTitle == "Start Playing" {
            playButton.setTitle("Stop", forState: UIControlState.Normal)
            playScore()
        } else {
            stopPlaying()
        }
    }

    func loadFile(scoreFile: String) {
        playButton.setTitle("Start Playing", forState: UIControlState.Normal)
        playingAnimation = false
        
        let scoreWidth = getScoreLength(scoreFile)
        //        let scoreWidth = Double(view.frame.width)
        print("scoreWidth = \(scoreWidth)")
        
        ssScrollView.xmlScoreWidth = scoreWidth
        ssScrollView.xmlScoreWidth = 0
        if let filePath = NSBundle.mainBundle().pathForResource("XML Tunes/" + scoreFile, ofType: "xml") {
            ssScrollView.abortBackgroundProcessing({self.loadTheFile(filePath, scoreWidth: scoreWidth)})
        } else {
            print("Couldn't make path??? for ", scoreFile)
            return
            //            throw NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: [ NSFilePathErrorKey : fileName ])
        }
        
    }
    
    func loadTheFile(filePath: String, scoreWidth: Double) {
        ssScrollView.clearAll()
        score = nil
        showingParts.removeAll()
        cursorBarIndex = 0
        let loadOptions = SSLoadOptions(key: sscore_libkey)
        loadOptions.checkxml = true
        let errP = UnsafeMutablePointer<sscore_loaderror>.alloc(1)
        
        print("filePath: \(filePath)")
        print("loadOptions: \(loadOptions)")
        print("errP: \(errP)")
        
        if let score0 = SSScore(XMLFile: filePath, options: loadOptions, error: errP) {
            score = score0
            //				titleLabel.text = [filePath lastPathComponent];
            let numParts = score!.numParts
            for _ in 0..<numParts {
                showingParts.append(NSNumber(bool: true)) // display all parts
            }
            
            showingSinglePart = false;
            layOptions.hidePartNames = true
            layOptions.hideBarNumbers = true
            //            sysssScrollView.frame.size.width = CGFloat(scoreWidth * 2.28)
            //            ssScrollView.setupScore(score, openParts: showingParts, mag: kDefaultMagnification, opt: layOptions)
            ssScrollView.setupScore(score, openParts: showingParts, mag: kDefaultMagnification, opt: layOptions, completion: getPlayData)
        }
        else
        {
            var err: sscore_loaderror
            err = errP.memory
            switch err.err {
            case sscore_OutOfMemoryError:
                print("out of memory")
            case sscore_XMLValidationError:
                print("XML validation error line:%d col:%d %s", err.line, err.col, err.text);
            case sscore_NoBarsInFileError:
                print("No bars in file error")
            case sscore_NoPartsError:
                print("NoParts Error")
            case sscore_UnknownError:
                print("Unknown error")
            default:
                print("Other error")
            }
        }
    }
    
    func getScoreLength(scoreFile: String) -> Double {
        var width = 0.0
        
        do {
            let exercise = try mxmlService.loadExercise(scoreFile + ".xml")
            for bar in exercise.measures {
                width += bar.width
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return 0.0
        } catch let error {
            print(error)
            return 0.0
        }
        
        return width
    }
    
    
    func playScore() {
        ssScrollView.contentOffset = CGPointZero
        ssScrollView.scrollEnabled = false
        playingAnimation = false
        countOffLabel.hidden = true;
        
        guard score != nil else { return }
        playData = SSPData.createPlayDataFromScore(score, tempo: self)
        guard playData != nil else { return }
        
        if synth != nil && (synth?.isPlaying)! {
            synth?.reset()
        } else {
            if synth == nil {
                if let synth0 = SSSynth.createSynth(self, score: score) {
                    synth = synth0
                    instrumentId.removeAll()
                    
                    instrumentId.append((synth?.addSampledInstrument(pianoSampleInfo))!)
                    instrumentId.append((synth?.addSampledInstrument(trumpetSampleInfo))!)
                    
                    metronomeInstrumentId = (synth?.addSynthesizedInstrument(&kTick1Info))!
                }
            }
            
            guard synth != nil else {
                print("No licence for synth");
                return
            }
            
            // start playing if not playing
            if setupAudioSession() {
                print("setupAudioSession == true")
                playData?.clearLoop()
                
                guard playData != nil else {
                    print("No playData");
                    return
                }
                
                #if DEBUG
                    // display notes to play in console
                    displayNotes(playData!)
                #endif
                // setup bar change notification to set threshold - or move cursor
                var cursorAnimationTime_ms = Int32(timingThreshold * 1000)
                
                if showNoteMarkers {
                    let cursorAnimationTime = CATransaction.animationDuration()
                    cursorAnimationTime_ms = Int32(cursorAnimationTime * 1000)
                }

                synth?.setNoteHandler(self, delay: -cursorAnimationTime_ms)

                //                synth?.setBarChangeHandler(BarChangeHandler(vc: self), delay: -cursorAnimationTime_ms)
                //                synth?.setBarChangeHandler(BarChangeHandler(vc: self, anim: anim), delay: 0)
                synth?.setEndHandler(EndHandler(vc: self), delay: 0)
                synth?.setBeatHandler(BeatHandler(vc: self), delay: 0)
                
                var err = synth?.setup(playData)
                if err == sscore_NoError {
                    let delayInSeconds = UInt64(2)
                    let startTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * NSEC_PER_SEC))
                    err = synth?.startAt(startTime, bar: cursorBarIndex, countIn: true)
                    
                }
                
                if err == sscore_UnlicensedFunctionError {
                    print("synth license expired!")
                } else if err != sscore_NoError {
                    print("synth failed to start: \(err)")
                }
            }
        }
    }
    
    func stopPlaying () {
        gateView.hidden = true

        if (synth != nil && synth!.isPlaying)
        {
            synth?.reset()
            countOffLabel.hidden = true;
            clearAudioSession()
        }
        
        if playingAnimation {
            playingAnimation = false
            ssScrollView.layer.removeAnimationForKey("move")
        }

        playButton.setTitle("Start Playing", forState: UIControlState.Normal)
        ssScrollView.hideCursor()
        ssScrollView.scrollEnabled = true
    }
    
    //build arrays for CAKeyframeAnimation of UIScrollView (base class of SSScrollView)
    //maybe also collect breath marks?
    func getPlayData() {
        guard score != nil else { return }
        
        playData = SSPData.createPlayDataFromScore(score, tempo: self)
        guard playData != nil else { return }
        
        animValues.removeAll()
        animKeyTimes.removeAll()
        
        exerciseDuration = 0
        animHorzOffset = 0
        var firstNote = true
        var thisNoteXPos: Double = 0
        var barsDuration_ms = 0
        var exerciseDuration_ms = 0
        
        for bar in (playData?.bars)! {
            exerciseDuration_ms += Int(bar.duration_ms)
        }
        
        exerciseDuration = Double(exerciseDuration_ms) / 1000.0
        
        //        var lastBarIndex = Int32(0)
        for bar in (playData?.bars)! {
            //we just have one part
            let part = bar.part(0)
            for note in part.notes {
                let graceNote = (note.grace == sscore_pd_grace_no) ? "note" : "grace"
                //                print("part 0 \(graceNote) pitch:\(note.midiPitch) startbar:\(note.startBarIndex) start:\(note.start)ms duration:\(note.duration)ms at x=\(noteXPos(note))")
                
                thisNoteXPos = Double(noteXPos(note))
                
                if firstNote {
                    animHorzOffset = thisNoteXPos
                    print("animHorxOffset= \(animHorzOffset)")
                    firstNote = false
                }
                
                animValues.append(thisNoteXPos - animHorzOffset)
                animKeyTimes.append(Double(barsDuration_ms + note.start) / Double(exerciseDuration_ms))
            }
            
            barsDuration_ms += Int(bar.duration_ms)
            //            lastBarIndex = bar.index
        }
        
        //move to end of last bar
        animValues.append(Double(ssScrollView.frame.width))
        animKeyTimes.append(1.0)
        
        
        kfAnim.keyPath = "bounds.origin.x"
        //        kfAnim.keyPath = "position.x"
        kfAnim.values = animValues
        kfAnim.keyTimes = animKeyTimes
        kfAnim.duration = exerciseDuration
        kfAnim.additive = true
    }
    
    
    //MARK: SSSyControls protocol
    func partEnabled(partIndex: Int32) -> Bool {
        return true;
    }
    
    func partInstrument(partIndex: Int32) -> UInt32 {
        if (kNumSampledInstruments > 1) {
            return instrumentId[1]
        }
        return instrumentId[0] // we can return any other instrument here
    }
    
    func partVolume(partIndex: Int32) -> Float {
        return 1.0
    }
    
    func metronomeEnabled() -> Bool {
        return true
    }
    
    func metronomeInstrument() -> UInt32 {
        return metronomeInstrumentId
    }
    
    func metronomeVolume() -> Float {
        return 1.0
    }
    
    //@end
    
    //MARK: SSUTempo protocol
    func bpm() -> Int32 {
        //the limit() calls are probably not needed.  tempo should be constrained when it is set.
        //        print("bpm: \(limit(Float(tempoBPM), min: Float(kMinTempo), max: Float(kMaxTempo)))")
        print("tempoBPM = \(tempoBPM)")
        return Int32(tempoBPM)
    }
    
    func tempoScaling() -> Float {
        let tempo = score!.tempoAtStart
        let tBPM = Float(tempoBPM) / Float(tempo().bpm)
        //the limit() calls are probably not needed.  tempo should be constrained when it is set.
        //        print("tempoScaling: \(limit(tBPM, min: Float(kMinTempoScaling), max: Float(kMaxTempoScaling)))")
        print("tempoAtStart // tBPM = \(tempo().bpm) // \(tBPM)")
        return tBPM
    }
    //@end
    
    //MARK: SSNoteHandler protocol
    func endNote(note: SSPDPartNote!) {
        //do nothing
    }
    
    func startNotes(notes: [AnyObject]!) {
        assert(notes.count > 0)
        if !playingAnimation {
            gateView.frame.origin.x = CGFloat(animHorzOffset - 12.0)
            gateView.hidden = false
            print("addAnimation!")
            print("anim.values: \(kfAnim.values)")
            print("keyTimes: \(kfAnim.keyTimes)")
            print("anim.duration: \(kfAnim.duration)")
            ssScrollView.layer.addAnimation(kfAnim, forKey: "move")
            playingAnimation = true
        }

        if !showNoteMarkers {
        } else {
            moveNoteCursor(notes)
        }
    }
    //@end
    
    func noteXPos(note: SSPDNote) -> Float {
        let system = ssScrollView.systemContainingBarIndex(note.startBarIndex)
        guard system != nil else { return 0 }
        
        let comps = system.componentsForItem(note.item_h)
        for comp in comps {
            if (comp.type == sscore_comp_notehead || comp.type == sscore_comp_rest) {
                return Float(comp.rect.origin.x + comp.rect.size.width / 2)
            }
        }
        
        return 0
    }
    
    func setNoteThresholdState(notes: NSArray) {
        // normally this will not need to iterate over the whole chord, but will exit as soon as it has a valid xpos
        // modified for analysis threshold and state

        for note in notes as! [SSPDPartNote] {
            // priority given to notes over rests, but ignore cross-bar tied notes
            if note.note.midiPitch > 0 && note.note.start >= 0 {
                let xpos = noteXPos(note.note)
                // noteXPos returns 0 if the note isn't found in the layout (it might be in a part which is not shown)
                if xpos > 0 {
                    if let realNote = note.note {
                    }
                    
                    return // abandon iteration
                }
            }
        }
        
        for note in notes as! [SSPDPartNote] {
            if note.note.midiPitch == 0 {   //rest
                let xpos = noteXPos(note.note)
                // noteXPos returns 0 if the note isn't found in the layout (it might be in a part which is not shown)
                if xpos > 0 {
                    return // abandon iteration
                }
            }
        }
    }

    func moveNoteCursor(notes: NSArray) {
        // normally this will not need to iterate over the whole chord, but will exit as soon as it has a valid xpos
        for note in notes as! [SSPDPartNote] {
            // priority given to notes over rests, but ignore cross-bar tied notes
            if note.note.midiPitch > 0 && note.note.start >= 0 {
                let xpos = noteXPos(note.note)
                // noteXPos returns 0 if the note isn't found in the layout (it might be in a part which is not shown)
                if xpos > 0 {
                    ssScrollView.setCursorAtXpos(xpos, barIndex: note.note.startBarIndex, scroll: ScrollType_e.scroll_bar)
                    return // abandon iteration
                }
            }
        }
        
        for note in notes as! [SSPDPartNote] {
            if note.note.midiPitch == 0 {   //rest
                let xpos = noteXPos(note.note)
                // noteXPos returns 0 if the note isn't found in the layout (it might be in a part which is not shown)
                if xpos > 0 {
                    ssScrollView.setCursorAtXpos(xpos, barIndex: note.note.startBarIndex, scroll: ScrollType_e.scroll_bar)
                    return // abandon iteration
                }
            }
        }
    }
    
    //MARK -Audio Session Route Change Notification
    
    func handleRouteChange(notification: NSNotification) {
        let reasonValue = notification.userInfo?[AVAudioSessionRouteChangeReasonKey]?.unsignedIntegerValue
        //AVAudioSessionRouteDescription *routeDescription = [notification.userInfo valueForKey:AVAudioSessionRouteChangePreviousRouteKey];
        
        if reasonValue == AVAudioSessionRouteChangeReason.OldDeviceUnavailable.rawValue {
            if synth != nil && synth!.isPlaying {
                synth?.reset()
            }
        }
        print("Audio route change: \(reasonValue)")
    }
    
    func handleInterruption(n: NSNotification) {
        print("Audio interruption")
        guard let why =
            n.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt
            else {return}
        guard let type = AVAudioSessionInterruptionType(rawValue: why)
            else {return}
        if type == .Began {
            print("interruption began:\n\(n.userInfo!)")
        } else {
            print("interruption ended:\n\(n.userInfo!)")
            guard let opt = n.userInfo![AVAudioSessionInterruptionOptionKey] as? UInt else {return}
            let opts = AVAudioSessionInterruptionOptions(rawValue: opt)
            if opts.contains(.ShouldResume) {
                print("should resume")
            } else {
                print("not should resume")
            }
        }
    }
    
    func setupAudioSession() -> Bool {
        // Configure the audio session
        let sessionInstance = AVAudioSession.sharedInstance()
        
        // our default category -- we change this for conversion and playback appropriately
        do {
            try sessionInstance.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error as NSError {
            print(error.localizedDescription)
            guard error.code == 0 else { return false }
        } catch let error {
            print(error)
            return false
        }
        
        //        let bufferDuration = NSTimeInterval.init(floatLiteral: 0.005)
        let bufferDuration = NSTimeInterval.init(floatLiteral: 0.5)
        do {
            try sessionInstance.setPreferredIOBufferDuration(bufferDuration)
        } catch let error as NSError {
            print(error.localizedDescription)
            guard error.code == 0 else { return false }
        } catch let error {
            print(error)
            return false
        }
        
        let hwSampleRate = 44100.0;
        do {
            try sessionInstance.setPreferredSampleRate(hwSampleRate)
        } catch let error as NSError {
            print(error.localizedDescription)
            guard error.code == 0 else { return false }
        } catch let error {
            print(error)
            return false
        }
        
        // add interruption handler
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleInterruption), name: AVAudioSessionInterruptionNotification, object: sessionInstance)
        
        // we don't do anything special in the route change notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSessionRouteChangeNotification, object: sessionInstance)
        
        // activate the audio session
        do {
            try sessionInstance.setActive(true)
        } catch let error as NSError {
            print(error.localizedDescription)
            guard error.code == 0 else { return false }
        } catch let error {
            print(error)
            return false
        }
        
        return true
    }
    
    func clearAudioSession() {
        let sessionInstance = AVAudioSession.sharedInstance()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        do {
            try sessionInstance.setActive(false)
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch let error {
            print(error)
        }
    }
    
    class BeatHandler: SSEventHandler {
        let svc: TuneExerciseViewController
        
        init(vc: TuneExerciseViewController) {
            svc = vc
        }
        
        @objc func event(index: Int32, countIn isCountIn: Bool) {
            svc.countOffLabel.hidden = !isCountIn;
            if isCountIn {
                svc.countOffLabel.text = "\(index + 1)"
            }
        }
    }
    
    class EndHandler: SSEventHandler {
        let svc: TuneExerciseViewController
        
        init(vc: TuneExerciseViewController) {
            svc = vc
        }
        
        @objc func event(index: Int32, countIn isCountIn: Bool) {
            svc.countOffLabel.hidden = true
            svc.cursorBarIndex = 0
            svc.stopPlaying()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
