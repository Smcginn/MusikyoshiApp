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
    @IBOutlet weak var metronomeView: VisualMetronomeView!

    var exerciseName = ""
    var isTune = false
    
    let mxmlService = MusicXMLService()
    let amplitudeThreshold = NSUserDefaults.standardUserDefaults().doubleForKey(Constants.Settings.AmplitudeThreshold)
    let timingThreshold = NSUserDefaults.standardUserDefaults().doubleForKey(Constants.Settings.TimingThreshold)
    let tempoBPM = NSUserDefaults.standardUserDefaults().integerForKey(Constants.Settings.BPM)
    let transpositionOffset = NSUserDefaults.standardUserDefaults().integerForKey(Constants.Settings.Transposition)
    let frequencyThreshold = NSUserDefaults.standardUserDefaults().floatForKey(Constants.Settings.FrequencyThreshold)
    let showNoteMarkers = NSUserDefaults.standardUserDefaults().boolForKey(Constants.Settings.ShowNoteMarkers)
    
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

    var metronomeOn = false
    var beatsPerMeasure = 0
    var tickPlayer: AVAudioPlayer?
    
    // 3 metronome ticks are currently supported (tickpitch = 0, 1 or 2):
    //    static const sscore_sy_synthesizedinstrumentinfo kTick1Info = {"Tick1", 0, 1.0};
    var kTick1Info = sscore_sy_synthesizedinstrumentinfo(instrument_name: ("Tick1" as NSString).UTF8String, tickpitch: Int32(0), volume: Float(1.0), voice: sscore_sy_tick1, dummy: (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
    
    let kfAnim = CAKeyframeAnimation()
    var exerciseDuration = 0.0
    var animHorzOffset = 0.0
    var animValues = [Double]()
    var animKeyTimes = [Double]()
    var playingAnimation = false

    var analysisTimer: NSTimer?
    var startTime : NSDate = NSDate()
    var thresholdEndTime = 0.0
    var frequencyThresholdPercent = Float(0.0)
    var targetPitch = Float(0.0)
    var lowPitchThreshold = Float(0.0)
    var highPitchThreshold = Float(0.0)
    let minPitch = NoteService.getLowestFrequency()
    let maxPitch = NoteService.getHighestFrequency()
    var soundSampleRate = 0.01
    var insideNote = false
    var insideRest = false
    var foundSound = false
    var missedSound = false
    var lateSound = false
    var pitchMatched = false
    var pitchLow = false
    var pitchHigh = false
    var pitchMatchedLate = false
    var pitchLowLate = false
    var pitchHighLate = false
    var noteResultValues: [NoteAnalysis.NoteResult: Int] = [:]
    var analysisStarted = false

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gateView.hidden = true
        showingSinglePart = false // is set when a single part is being displayed
        cursorBarIndex = 0
        if isTune {
            title = "Tune"
            infoLabel.text = "Play the notes"
        } else {
            title = "Rhythm"
            infoLabel.text = "Clap at the beginning of each note and count the beats"
        }

        loadFile("XML Tunes/" + exerciseName)
        countOffLabel.text = ""

        frequencyThresholdPercent = 1.0 + frequencyThreshold
        setupSounds()
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
        
        if let filePath = NSBundle.mainBundle().pathForResource(scoreFile, ofType: "xml") {
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
            ssScrollView.optimalSingleSystem = true
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
        if isTune {
            infoLabel.text = "Play the notes"
        } else {
            infoLabel.text = "Clap at the beginning of each note and count the beats"
        }
        ssScrollView.contentOffset = CGPointZero
        ssScrollView.scrollEnabled = false
        playingAnimation = false
        countOffLabel.hidden = true;
//        metronomeOn = true

        noteResultValues.removeAll()
        
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
            if AVAudioSessionManager.sharedInstance.setupAudioSession() {
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
        metronomeView.setBeat(-1)
        stopAnalysisTimer()

        gateView.hidden = true

        if (synth != nil && synth!.isPlaying)
        {
            synth?.reset()
            countOffLabel.hidden = true;
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

        dispatch_async(dispatch_get_main_queue(),{
            if let numBeats = self.score?.actualBeatsForBar(1) {
                self.beatsPerMeasure = Int(numBeats.numbeats)
                self.metronomeView.numBeats = self.beatsPerMeasure
                self.metronomeView.rebuildMetronome()
            }
        });

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
        
        for bar in (playData?.bars)! {
            //we just have one part
            let part = bar.part(0)
            for note in part.notes {
//                let graceNote = (note.grace == sscore_pd_grace_no) ? "note" : "grace"
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
    
    //MARK: Analysis
    
    func startAnalysisTimer() {
        //don't start twice
        guard !analysisStarted else { return }
        analysisStarted = true

        startTime = NSDate()

        AudioKitManager.sharedInstance.start()
        print("starting analysis timer")
        analysisTimer = NSTimer.scheduledTimerWithTimeInterval(soundSampleRate, target: self, selector: #selector(TuneExerciseViewController.analyzePerformance), userInfo: nil, repeats: true)
    }
    
    func stopAnalysisTimer() {
        //don't stop twice
        guard analysisStarted else { return }
        analysisStarted = false

        if analysisTimer != nil {
            analysisTimer?.invalidate()
            analysisTimer = nil;
        }
        
        AudioKitManager.sharedInstance.stop()
    }
    
    // analysis - timing
    // all calculations in NSDate().timeIntervalSinceDate(startTime)
    // if insideNote then a sound before thresholdEndTime => note match
    // if insideNote no sound and reach thresholdEndTime ==> note miss
    // if insideNote a sound after thresholdEndTime ==> note late
    // if insideNote after thresholdEndTime any additional sound ==> note late repeat
    
    // if insideRest then a sound before thresholdEndTime => rest miss
    // if insideRest then a NO-sound and reach thresholdEndTime => rest match
    // if insideRest a sound after threshold ==> rest late miss
    // if insideRest after thresholdEndTime any additional sound ==> rest late miss repeat

    // analysis - pitch
    // only care about pitch insideNote
    // if pitch before thresholdEndTime compare to low/high thresholds and set to pitchlow, pitchhigh, or pitchmatch
    // if pitch after thresholdEndTime compare to low/high thresholds and set to pitchlowlate, pitchhighlate, or pitchmatchlate

    func analyzePerformance() {
        guard insideNote || insideRest else { return }

        let inThreshold = NSDate().timeIntervalSinceDate(startTime) < thresholdEndTime
        let amplitude = AudioKitManager.sharedInstance.amplitude()
        let frequency = AudioKitManager.sharedInstance.frequency()
        print("amplitude / freq = \(amplitude) / \(frequency)")

//        let hasSound = amplitude > 0.01 && (minPitch...maxPitch ~= frequency)
        let hasSound = amplitude > 0.1 && (minPitch...maxPitch ~= frequency)

        var result = NoteAnalysis.NoteResult.NoResult
        
        if insideNote {
            // if insideNote then a sound before thresholdEndTime => note match
            // if insideNote no sound and reach thresholdEndTime ==> note miss
            // if insideNote a sound after thresholdEndTime ==> note late
            // if insideNote after thresholdEndTime any additional sound ==> note late repeat
            if hasSound && inThreshold {
                //if we already found a sound in threshold don't count it twice
                guard !foundSound else { return }
                foundSound = true
                result = NoteAnalysis.NoteResult.NoteRhythmMatch
            } else if !hasSound && !inThreshold {
                //if we already missed the threshold don't count it twice
                guard !missedSound && !foundSound else { return }
                missedSound = true
                result = NoteAnalysis.NoteResult.NoteRhythmMiss
            } else if hasSound && !inThreshold  && !lateSound {
                //cannot be late if we have not missed
    //yes we can on longer notes - one clap on time and then a second one later -- fix this later
                guard missedSound else { return }
                lateSound = true
                result = NoteAnalysis.NoteResult.NoteRhythmLate
//            } else if hasSound && !inThreshold  && lateSound {
//                //cannot repeat if we haven't already been late
//                result = NoteAnalysis.NoteResult.NoteRhythmLateRepeat
            }

            if isTune && hasSound {
                //if we have a rhythm result save it first
                if result != NoteAnalysis.NoteResult.NoResult {
                    if let count = noteResultValues[result] {
                        noteResultValues[result] = count + 1
                        print("result: \(amplitude) - \(result) \(count + 1)")
                    } else {
                        noteResultValues[result] = 1
                        print("result: \(amplitude) - \(result) 1")
                    }

                    result = NoteAnalysis.NoteResult.NoResult
                }

                var freqMatch = false
                var freqLow = false
                var freqHigh = false
                
                if isTune {
                    if frequency < lowPitchThreshold {
                        freqLow = true
                    } else if frequency > highPitchThreshold {
                        freqHigh = true
                    } else {
                        freqMatch = true
                    }
                }

                print("freq ... low \(freqLow) high \(freqHigh) match \(freqMatch)")
                if inThreshold {
                    if freqLow {
                        guard !pitchLow else { return }
                        pitchLow = true
                        result = NoteAnalysis.NoteResult.PitchLow
                    } else if freqHigh {
                        guard !pitchHigh else { return }
                        pitchHigh = true
                        result = NoteAnalysis.NoteResult.PitchHigh
                    } else if freqMatch {
                        guard !pitchMatched else { return }
                        pitchMatched = true
                        result = NoteAnalysis.NoteResult.PitchMatch
                    }
                } else {
                    if freqLow {
                        guard !pitchLowLate else { return }
                        pitchLowLate = true
                        result = NoteAnalysis.NoteResult.PitchLowLate
                    } else if freqHigh {
                        guard !pitchHighLate else { return }
                        pitchHighLate = true
                        result = NoteAnalysis.NoteResult.PitchHighLate
                    } else if freqMatch {
                        guard !pitchMatchedLate else { return }
                        pitchMatchedLate = true
                        result = NoteAnalysis.NoteResult.PitchMatchLate
                    }
                }
            }
        } else if insideRest {
            // if insideRest then a sound before thresholdEndTime => rest miss
            // if insideRest then a NO-sound and reach thresholdEndTime => rest match
            // if insideRest a sound after threshold ==> rest late miss
            // if insideRest after thresholdEndTime any additional sound ==> rest late miss repeat
            if hasSound && inThreshold {
                //if we already found a sound in threshold don't count it twice
                guard !foundSound else { return }
                foundSound = true
                result = NoteAnalysis.NoteResult.RestMiss
            } else if !hasSound && !inThreshold {
                //if we already missed the threshold don't count it twice
                guard !missedSound && !foundSound else { return }
                missedSound = true
                result = NoteAnalysis.NoteResult.RestMatch
            } else if hasSound && !inThreshold  && !lateSound {
                //cannot be late if we have not missed
                guard missedSound else { return }
                lateSound = true
                result = NoteAnalysis.NoteResult.RestLateMiss
//            } else if hasSound && !inThreshold  && lateSound {
//                //cannot repeat if we haven't already been late
//                result = NoteAnalysis.NoteResult.RestLateMissRepeat
            }
        }

        guard result != NoteAnalysis.NoteResult.NoResult else { return }
        if let count = noteResultValues[result] {
            noteResultValues[result] = count + 1
            print("result: \(amplitude) - \(result) \(count + 1)")
        } else {
            noteResultValues[result] = 1
            print("result: \(amplitude) - \(result) 1")
        }
    }
    
//    func showResult(isCorrect: Bool)
//    {
//        let bn = beatNotes[analyzeTime]
//        playHead.frame.origin.x = CGFloat(bn.xPos + animHorzOffset)
//        
//        if bn.length == .Whole
//        {
//            playHead.frame.size.width = 17
//        }
//        else
//        {
//            playHead.frame.size.width = 12
//        }
//        
//        if isCorrect
//        {
//            playHead.backgroundColor = UIColor.greenColor()
//        }
//        else
//        {
//            playHead.backgroundColor = UIColor.redColor()
//        }
//        
//        playHead.alpha = 0.6
//        UIView.animateWithDuration(0.2, animations: {
//            self.playHead.alpha = 0
//        })
//    }

    func showScore() {
        var scoreString = "You got"

        if isTune {
            if let numResults = noteResultValues[NoteAnalysis.NoteResult.PitchMatch] {
                if numResults != 0 {
                    scoreString = scoreString + ": PitchMatch - \(numResults)"
                }
            }
            
            if let numResults = noteResultValues[NoteAnalysis.NoteResult.PitchLow] {
                if numResults != 0 {
                    scoreString = scoreString + ": PitchLow - \(numResults)"
                }
            }
            
            if let numResults = noteResultValues[NoteAnalysis.NoteResult.PitchHigh] {
                if numResults != 0 {
                    scoreString = scoreString + ": PitchHigh - \(numResults)"
                }
            }
            
            if let numResults = noteResultValues[NoteAnalysis.NoteResult.PitchMatchLate] {
                if numResults != 0 {
                    scoreString = scoreString + ": PitchMatchLate - \(numResults)"
                }
            }
            
            if let numResults = noteResultValues[NoteAnalysis.NoteResult.PitchLowLate] {
                if numResults != 0 {
                    scoreString = scoreString + ": PitchLowLate - \(numResults)"
                }
            }
            
            if let numResults = noteResultValues[NoteAnalysis.NoteResult.PitchHighLate] {
                if numResults != 0 {
                    scoreString = scoreString + ": PitchHighLate - \(numResults)"
                }
            }
        }

        if let numResults = noteResultValues[NoteAnalysis.NoteResult.NoteRhythmMatch] {
            if numResults != 0 {
                scoreString = scoreString + ": NoteRhythmMatch - \(numResults)"
            }
        }

        if let numResults = noteResultValues[NoteAnalysis.NoteResult.NoteRhythmMiss] {
            if numResults != 0 {
                scoreString = scoreString + ": NoteRhythmMiss - \(numResults)"
            }
        }

        if let numResults = noteResultValues[NoteAnalysis.NoteResult.NoteRhythmLate] {
            if numResults != 0 {
                scoreString = scoreString + ": NoteRhythmLate - \(numResults)"
            }
        }

        if let numResults = noteResultValues[NoteAnalysis.NoteResult.NoteRhythmLateRepeat] {
            if numResults != 0 {
                scoreString = scoreString + ": NoteRhythmLateRepeat - \(numResults)"
            }
        }

        if let numResults = noteResultValues[NoteAnalysis.NoteResult.RestMatch] {
            if numResults != 0 {
                scoreString = scoreString + ": RestMatch - \(numResults)"
            }
        }

        if let numResults = noteResultValues[NoteAnalysis.NoteResult.RestMiss] {
            if numResults != 0 {
                scoreString = scoreString + ": RestMiss - \(numResults)"
            }
        }

        if let numResults = noteResultValues[NoteAnalysis.NoteResult.RestLateMiss] {
            if numResults != 0 {
                scoreString = scoreString + ": RestLateMiss - \(numResults)"
            }
        }

        if let numResults = noteResultValues[NoteAnalysis.NoteResult.RestLateMissRepeat] {
            if numResults != 0 {
                scoreString = scoreString + ": RestLateMissRepeat - \(numResults)"
            }
        }

        infoLabel.text = scoreString

//        var numberCorrect = 0
//        
//        for sb in scoringBeats {
//            if sb != nil && sb! {
//                numberCorrect++
//            }
//        }
//        
//        if numberCorrect == 0 {
//            infoLbl.text = "Hmm, we didn't hear anything. Try clapping louder next time."
//        } else if numberCorrect < scoringBeats.count {
//            infoLbl.text = "Almost! You got \(numberCorrect) out of \(scoringBeats.count)"
//        } else {
//            infoLbl.text = "Congrats! You got them all :)"
//        }
    }

    //MARK: SSSyControls protocol
    func partEnabled(partIndex: Int32) -> Bool {
        return true;
    }
    
    func partInstrument(partIndex: Int32) -> UInt32 {
        guard showNoteMarkers else { return 0 }
        
        if (kNumSampledInstruments > 1) {
            return instrumentId[1]
        }
        return instrumentId[0] // we can return any other instrument here
    }
    
    func partVolume(partIndex: Int32) -> Float {
        if showNoteMarkers {
            return 1.0
        } else {
            return 0.0
        }
    }
    
    func metronomeEnabled() -> Bool {
        return metronomeOn
    }
    
    func metronomeInstrument() -> UInt32 {
        return metronomeInstrumentId
    }
    
    func metronomeVolume() -> Float {
        if !metronomeOn {
            return 0
        }
        return 1.5
//        return 1.0
//        return 0.50
    }
    
    //@end
    
    //MARK: SSUTempo protocol
    func bpm() -> Int32 {
//        print("tempoBPM = \(tempoBPM)")
        return Int32(tempoBPM)
    }
    
    func tempoScaling() -> Float {
        let tempo = score!.tempoAtStart
        let tBPM = Float(tempoBPM) / Float(tempo().bpm)
//        print("tempoAtStart // tBPM = \(tempo().bpm) // \(tBPM)")
        return tBPM
    }
    //@end
    
    //MARK: SSNoteHandler protocol
    func endNote(note: SSPDPartNote!) {
        if note.note.midiPitch > 0 {
            insideNote = false
        } else {
            insideRest = false
        }
    }
    
    func startNotes(notes: [AnyObject]!) {
        assert(notes.count > 0)
        if !playingAnimation {
            gateView.frame.origin.x = CGFloat(animHorzOffset - 12.0)
            gateView.hidden = false
            print("addAnimation!")
//            print("anim.values: \(kfAnim.values)")
//            print("keyTimes: \(kfAnim.keyTimes)")
            print("anim.duration: \(kfAnim.duration)")
            ssScrollView.layer.addAnimation(kfAnim, forKey: "move")
            playingAnimation = true
        }

        if !showNoteMarkers {
            setNoteThresholdState(notes)
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

    //this only makes sense if setNoteHandler() delay is -timingThreshold
    func setNoteThresholdState(notes: NSArray) {
        // normally this will not need to iterate over the whole chord, but will exit as soon as it has a valid xpos
        // modified for analysis threshold and state

        for note in notes as! [SSPDPartNote] {
            // priority given to notes over rests, but ignore cross-bar tied notes
            if note.note.midiPitch > 0 && note.note.start >= 0 {
                let xpos = noteXPos(note.note)
                // noteXPos returns 0 if the note isn't found in the layout (it might be in a part which is not shown)
                if xpos > 0 {
                    insideNote = true
                    insideRest = false
                    foundSound = false
                    missedSound = false
                    lateSound = false

                    thresholdEndTime = NSDate().timeIntervalSinceDate(startTime) + timingThreshold * 2

                    if isTune {
                        //do all this here so we don't have to do it everytime analyzePerformance is called.
                        pitchMatched = false
                        pitchLow = false
                        pitchHigh = false
                        pitchMatchedLate = false
                        pitchLowLate = false
                        pitchHighLate = false
                        //midiPitch from SeeScore has already had the -2 offset applied from the XML file
//                        if let freq = NoteService.getNote(Int(note.note.midiPitch) + transpositionOffset)?.frequency {
                        if let freq = NoteService.getNote(Int(note.note.midiPitch))?.frequency {
                            targetPitch = freq
                            lowPitchThreshold = freq / frequencyThresholdPercent
                            highPitchThreshold = freq * frequencyThresholdPercent
                        }
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
                    insideNote = false
                    insideRest = true
                    foundSound = false
                    missedSound = false
                    lateSound = false

                    thresholdEndTime = NSDate().timeIntervalSinceDate(startTime) + timingThreshold * 2

                    if isTune {
                        //do all this here so we don't have to do it everytime analyzePerformance is called.
                        pitchMatched = false
                        pitchLow = false
                        pitchHigh = false
                        pitchMatchedLate = false
                        pitchLowLate = false
                        pitchHighLate = false
                        //do we need this?  We don't care about frequency for rests
                        if let freq = NoteService.getNote(Int(note.note.midiPitch) + transpositionOffset)?.frequency {
                            targetPitch = freq
                            lowPitchThreshold = freq / frequencyThresholdPercent
                            highPitchThreshold = freq * frequencyThresholdPercent
                        }
                    }

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

    class BeatHandler: SSEventHandler {
        let svc: TuneExerciseViewController
        
        init(vc: TuneExerciseViewController) {
            svc = vc
        }
        
        @objc func event(index: Int32, countIn isCountIn: Bool) {
            svc.countOffLabel.hidden = !isCountIn;
            if isCountIn {
                svc.countOffLabel.text = "\(index + 1)"
                if !svc.showNoteMarkers {
                    svc.startAnalysisTimer()
                }

                if index >= Int32(svc.beatsPerMeasure - 1) {
                    //stop after last countoff
                    svc.metronomeOn = false
                }

                svc.playTickSound()
            }

            svc.metronomeView.setBeat(Int(index))
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
            svc.showScore()
        }
    }

    //MARK: - Sounds
    
    func setupSounds() {
        let ticksound = "marmstk1"
        let ticktype = "wav"
        
        if let soundPath = NSBundle.mainBundle().pathForResource(ticksound, ofType: ticktype) {
            let soundUrl = NSURL(fileURLWithPath: soundPath)
            
            do {
                tickPlayer = try AVAudioPlayer(contentsOfURL: soundUrl)
                tickPlayer?.prepareToPlay()
            } catch {
                print("No sound found by URL:\(soundUrl)")
            }
        }
    }
    
    func playTickSound() {
        if let tp = tickPlayer {
            tp.play()
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
