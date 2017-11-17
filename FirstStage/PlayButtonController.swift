/
//  PlayButtonController.swift
//  FirstStage
//
//  Created by Chester Beard on 11/1/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import UIKit

class PlayButtonController: UIViewController, SSUTempo, SSSyControls{
    
    var timer = NSTimer()
    var exerciseState = ExerciseState.notStarted
    var timer = Timer()
    var currentTime = 0.0
    var targetNote : Note?
    var absoluteTargetNote: Note?
    var showFarText = true
    
    var targetTime = 3.0                                                    var targetNoteID = 0
    let kFirstLongTone25Note = 55
    let kLastLongTone25Note = 79
    var kC4 = 60
    
    let amplitudeThreshold = UserDefaults.standard.double(forKey: Constants.Settings.AmplitudeThreshold)
    let tempoBPM = 60
    let transpositionOffset = UserDefaults.standard.integer(forKey: Constants.Settings.Transposition)
    let frequencyThreshold = UserDefaults.standard.float(forKey: Constants.Settings.FrequencyThreshold)
    var frequencyThresholdPercent = Float(0.0)
    var farFrequencyThresholdPercent = Float(0.0)
    var targetPitch = Float(0.0)
    var lowPitchThreshold = Float(0.0)
    var highPitchThreshold = Float(0.0)
    var lowFarPitchThreshold = Float(0.0)
    var highFarPitchThreshold = Float(0.0)
    let minPitch = NoteService.getLowestFrequency()
    let maxPitch = NoteService.getHighestFrequency()
    var firstTime = true
    var pitchSampleRate = 0.01
    var balloonUpdateRate = 0.01
    var longToneEndTime = 0.0
    var startTime = Date()
    
    var score: SSScore?
    var partIndex: Int32 = 0
    var layOptions = SSLayoutOptions()  // set of options for layout
    var playData: SSPData?
    var synth: SSSynth?
    var instrumentId = UInt32(0)
    var cursorBarIndex = Int32(0)
    let kDefaultMagnification : Float = 2.85
    
    var hasNoteStarted = false
    var isExerciseSuccess = false
    var sparkLineCount : CGFloat = 0
    let nearUpArrowImage = UIImage(named: "NearArrow")
    let farUpArrowImage = UIImage(named: "FarArrow")
    let nearDownArrowImage = UIImage(cgImage: (UIImage(named: "NearArrow")?.cgImage)!, scale: CGFloat(1.0), orientation: UIImageOrientation.downMirrored)
    let farDownArrowImage = UIImage(cgImage: (UIImage(named: "FarArrow")?.cgImage)!, scale: CGFloat(1.0), orientation: UIImageOrientation.downMirrored)
    var arrowImageView : UIImageView!
    var smileImage = UIImage(named: "GreenSmile")
    var smileImageView : UIImageView!
    
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var balloon: Balloon!
    @IBOutlet weak var feedbackLbl: UILabel!
    @IBOutlet weak var feedbackPnl: UIStackView!
    @IBOutlet weak var sparkLine: SparkLine!
    @IBOutlet weak var countdownLbl: UILabel!
    @IBOutlet weak var ssScrollView: SSScrollView!
    @IBOutlet weak var guideTextView: UITextView!
    @IBOutlet var sparkLineTapRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        absoluteTargetNote = NoteService.getNote(targetNoteID + transpositionOffset)
        targetNote = NoteService.getNote(targetNoteID)
        if targetNote != nil {
            print("targetNote: \(targetNote)")
            
            navigationItem.title = "Long Tone - \(targetNote!.fullName)"
            instructionLbl.text = "Play a long \(targetNote!.friendlyName) note and fill up the balloon until it turns green!"
        }
        
        loadFile("XML Tunes/Long_Tone_25G3G5")
        
        frequencyThresholdPercent = 1.0 + frequencyThreshold
        farFrequencyThresholdPercent = frequencyThresholdPercent + (frequencyThreshold * 1.5)
        firstTime = true
        setupImageViews()
    }
    
    @IBAction func sparkLineTapped(_ sender: UITapGestureRecognizer) {
        playScore()
    }
    
    func loadFile(_ scoreFile: String) {
        playBtn.isHidden = false
        playBtn.isEnabled = true
        playBtn.setTitle("Start Playing", for: UIControlState())
        //        playButton.setTitle("Start Playing", forState: UIControlState.Normal)
        //        playingAnimation = false
        
        if let filePath = Bundle.main.path(forResource: scoreFile, ofType: "xml") {
            ssScrollView.abortBackgroundProcessing({self.loadTheFile(filePath)})
        } else {
            print("Couldn't make path??? for ", scoreFile)
            return
        }
    }
    
    func setupImageViews() {
        //start with near, up - located below
        arrowImageView = UIImageView(image: nearUpArrowImage)
        arrowImageView.isHidden = true
        ssScrollView.addSubview(arrowImageView)
        //        arrowImageView.clipsToBounds = false
        //        ssScrollView.clipsToBounds = false
        
        smileImageView = UIImageView(image: smileImage)
        smileImageView.isHidden = true
        ssScrollView.addSubview(smileImageView)
        
        let imageX = (ssScrollView.frame.width - smileImageView.frame.width) / 2
        let imageY = ssScrollView.frame.height * 0.05
        smileImageView.frame = CGRect(x: imageX, y: imageY, width: smileImageView.frame.width, height: smileImageView.frame.height)
    }
    
    func setArrowAndPrompt(_ isNear: Bool, isUp: Bool) {
        //near or far, up or down
        arrowImageView.isHidden = false
        guideTextView.isHidden = false
        guideTextView.text = ""
        var imageX = CGFloat(0)
        var imageY = CGFloat(0)
        //        imageX = 120
        imageX = ssScrollView.frame.width * 0.7
        switch (isNear, isUp) {
        case (true, true):
            //            imageY = 100
            imageY = ssScrollView.frame.height * 0.56
            arrowImageView.image = nearUpArrowImage
            guideTextView.text = "Almost There!\nFaster Air!\nCurve lips in Slightly"
        case (true, false):
            //            imageY = 40
            imageY = ssScrollView.frame.height * 0.22
            arrowImageView.image = nearDownArrowImage
            guideTextView.text = "Might be pinching, relax lips\nSay \"Ohh\"\nPull out tuning slide 1/2 inch"
        case (false, true):
            //            imageY = 120
            imageY = ssScrollView.frame.height * 0.67
            arrowImageView.image = farUpArrowImage
            guideTextView.text = "Firm lip setting\nUse more air\nCheck Fingering"
        case (false, false):
            //            imageY = 20
            imageY = ssScrollView.frame.height * 0.11
            arrowImageView.image = farDownArrowImage
            guideTextView.text = "Curve lips out - think \"mm\"\nOpen throat - Say \"Oh\"\nMight be on a G or Upper C\nCheck Fingering"
        }
        
        //if far and no far text
        if !isNear && !showFarText {
            guideTextView.isHidden = true
            guideTextView.text = ""
        }
        arrowImageView.frame = CGRect(x: imageX, y: imageY, width: arrowImageView.frame.width, height: arrowImageView.frame.height)
    }
    
    func clearArrowAndPrompt() {
        arrowImageView.isHidden = true
        guideTextView.isHidden = true
        guideTextView.text = ""
    }
    
    func loadTheFile(_ filePath: String) {
        ssScrollView.clearAll()
        score = nil
        cursorBarIndex = 0
        let loadOptions = SSLoadOptions(key: sscore_libkey)
        loadOptions.checkxml = true
        let errP = UnsafeMutablePointer<sscore_loaderror>.alloc(1)
        
        print("filePath: \(filePath)")
        print("loadOptions: \(loadOptions)")
        print("errP: \(errP)")
        
        if let score0 = SSScore(XMLFile: filePath, options: loadOptions, error: errP) {
            score = score0
            
            //figure out which part#
            partIndex = Int32(kC4 - kFirstLongTone25Note)   //default to C4
            let partNumber = Int32(targetNoteID - kFirstLongTone25Note)
            if 0..<score!.numParts ~= partNumber {
                partIndex = partNumber
            }
            
            var    showingParts = [NSNumber]()
            showingParts.removeAll()
            let numParts = Int(score!.numParts)
            for i in 0..<numParts {
                showingParts.append(NSNumber(bool: (Int32(i) == partNumber))) // display the selected part
            }
            
            layOptions.hidePartNames = true
            layOptions.hideBarNumbers = true
            ssScrollView.optimalSingleSystem = true
            //            sysssScrollView.frame.size.width = CGFloat(scoreWidth * 2.28)
            //            ssScrollView.setupScore(score, openParts: showingParts, mag: kDefaultMagnification, opt: layOptions)
            ssScrollView.optimalSingleSystem = false
            ssScrollView.setupScore(score, openParts: showingParts, mag: kDefaultMagnification, opt: layOptions, completion: getPlayData)
            //            ssScrollView.setupScore(score, openParts: showingParts, mag: kDefaultMagnification, opt: layOptions)
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
    
    func getPlayData() {
        guard score != nil else { return }
        
        playData = SSPData.createPlayDataFromScore(score, tempo: self)
    }
    
    func playScore() {
        ssScrollView.contentOffset = CGPoint.zero
        ssScrollView.scrollEnabled = false
        
        guard score != nil else { return }
        playData = SSPData.createPlayDataFromScore(score, tempo: self)
        guard playData != nil else { return }
        
        if synth != nil && (synth?.isPlaying)! {
            synth?.reset()
        } else {
            if synth == nil {
                if let synth0 = SSSynth.createSynth(self, score: score) {
                    synth = synth0
                    
                    instrumentId = (synth?.addSampledInstrument(trumpetMinus2SampleInfo))!
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
                
                //                synth?.setEndHandler(EndHandler(vc: self), delay: 0)
                
                var err = synth?.setup(playData)
                if err == sscore_NoError {
                    let startTime = DispatchTime.now() + Double(Int64(0)) / Double(NSEC_PER_SEC)
                    err = synth?.startAt(startTime, bar: cursorBarIndex, countIn: false)
                }
                
                if err == sscore_UnlicensedFunctionError {
                    print("synth license expired!")
                } else if err != sscore_NoError {
                    print("synth failed to start: \(err)")
                }
            }
        }
    }
    
    @IBAction func playBtnTap(_ sender: UIButton) {
        //TODO - add extra states to ExerciseState to better cycle through Long Tone, instead of checking button title
        
        if playBtn.currentTitle == "Try Again" {
            tryAgainTap(sender)
            return
        } else if playBtn.currentTitle == "Next Exercise" {
            //TODO: goto Next Exercise
            navigationController?.popViewController(animated: true)
            return
        }
        
        if exerciseState == ExerciseState.notStarted {
            startCountdown()
        } else if exerciseState == ExerciseState.feedbackProvided {
            //TODO: go to next exercise
        }
    }
    
    @IBAction func tryAgainTap(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.1, animations: {
            //            self.feedbackPnl.alpha = 0
            self.feedbackLbl.text = ""
            self.smileImageView.isHidden = true
        })
        
        startCountdown()
    }
    
    func deflateBalloon(){
        if balloon.radius >= 10
        {
            balloon.radius -= 0.1
        }
        else
        {
            timer.invalidate()
        }
    }
    
    func resetSparkLine(){
        sparkLineCount = 0
        sparkLine.values = [CGPoint]()
    }
    
    func startCountdown()
    {
        timer.invalidate()
        feedbackLbl.isHidden = true
        
        hasNoteStarted = false
        isExerciseSuccess = false
        
        currentTime = 0.0
        timerLbl.text = String(format: "%.2f/%.2f", currentTime, targetTime)
        
        balloon.alpha = 0
        balloon.fillColor = UIColor.blue.cgColor
        balloon.radius = 10
        
        if let freq = absoluteTargetNote?.frequency {
            targetPitch = freq
            lowPitchThreshold = freq / frequencyThresholdPercent
            highPitchThreshold = freq * frequencyThresholdPercent
            lowFarPitchThreshold = freq / farFrequencyThresholdPercent
            highFarPitchThreshold = freq * farFrequencyThresholdPercent
        } else {
            targetPitch = Float(0.0)
            lowPitchThreshold = Float(0.0)
            highPitchThreshold = Float(0.0)
            lowFarPitchThreshold = Float(0.0)
            highFarPitchThreshold = Float(0.0)
        }
        
        playBtn.isEnabled = false
        playBtn.setTitle("", for: UIControlState())
        //        playBtn.setTitle("Get Ready", forState: .Normal)
        countdownLbl.text = "3"
        countdownLbl.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        exerciseState = ExerciseState.inProgress
        
        UIView.animate(withDuration: 1.0, animations: {
            self.countdownLbl.alpha = 1
            self.countdownLbl.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx countdown for play in 
        delay(1.0){
            //            self.playBtn.setTitle("Set", forState: .Normal)
            
            self.countdownLbl.alpha = 0
            self.countdownLbl.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.countdownLbl.text = "2"
            
            UIView.animate(withDuration: 1.0, animations: {
                self.countdownLbl.alpha = 1
                self.countdownLbl.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
            
            delay(1.0){
                //                self.playBtn.setTitle("Go!", forState: .Normal)
                
                self.countdownLbl.alpha = 0
                self.countdownLbl.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.countdownLbl.text = "1"
                
                UIView.animate(withDuration: 1.0, animations: {
                    self.countdownLbl.alpha = 1
                    self.countdownLbl.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
                delay(1.0){
                    self.countdownLbl.alpha = 0
                    self.balloon.alpha = 1
                }
                self.startExercise()
            }
        }
    }
    
    func startExercise(){
        AudioKitManager.sharedInstance.start()
        longToneEndTime = Date().timeIntervalSince(startTime) + 30.0
        timer = Timer.scheduledTimer(timeInterval: pitchSampleRate, target: self, selector: #selector(LongToneViewController.updateTracking), userInfo: nil, repeats: true)
    }
    
    func stopExercise(){
        resetSparkLine()
        
        AudioKitManager.sharedInstance.stop()
        timer.invalidate()
        
        if isExerciseSuccess
        {
            balloon.fillColor = UIColor.green.cgColor
            feedbackLbl.text = "You did it!"
            smileImageView.isHidden = false
        }
        else
        {
            timer = Timer.scheduledTimer(timeInterval: balloonUpdateRate, target: self, selector: #selector(LongToneViewController.deflateBalloon), userInfo: nil, repeats: true)
            feedbackLbl.text = "Almost..."
        }
        
        feedbackLbl.isHidden = false
        
        if firstTime {
            playBtn.isHidden = false
            playBtn.isEnabled = true
            playBtn.setTitle("Try Again", for: UIControlState())
            firstTime = false
        } else {
            playBtn.isHidden = false
            playBtn.isEnabled = true
            playBtn.setTitle("Next Exercise", for: UIControlState())
        }
        
        exerciseState = ExerciseState.completed
        
        //        delay(0.5){
        //            self.feedbackPnl.center.y += 40
        //            self.feedbackPnl.transform = CGAffineTransformMakeScale(0.5, 0.5)
        //            UIView.animateWithDuration(0.3, animations: {
        //                self.feedbackPnl.center.y -= 40
        //                self.feedbackPnl.transform = CGAffineTransformMakeScale(1, 1)
        //                self.feedbackPnl.alpha = 1
        //            })
        //
        //            self.exerciseState = ExerciseState.FeedbackProvided
        //        }
        self.exerciseState = ExerciseState.feedbackProvided
    }
    
    func updateTracking()
    {
        if Date().timeIntervalSince(startTime) > longToneEndTime {
            // we're done!
            stopExercise()
        }
        
        let amplitude = AudioKitManager.sharedInstance.amplitude()
        let frequency = AudioKitManager.sharedInstance.frequency()
        //        print("amplitude / freq = \(amplitude) / \(frequency)")
        
        if amplitude > 0.01 {
            if minPitch...maxPitch ~= frequency {
                if lowPitchThreshold...highPitchThreshold ~= frequency {
                    //inside threshold
                    clearArrowAndPrompt()
                    hasNoteStarted = true
                    currentTime += pitchSampleRate
                    if currentTime >= targetTime {
                        isExerciseSuccess = true
                        stopExercise()
                        return
                    } else {
                        timerLbl.text = String(format: "%.2f/%.2f", currentTime, targetTime)
                        balloon.radius += 0.3
                        playBtn.isHidden = false
                        playBtn.isEnabled = false
                        playBtn.setTitle("Keep it up!", for: UIControlState())
                    }
                } else if hasNoteStarted {
                    //outside threshold
                    if let noteHit = NoteService.getNote(frequency) {
                        print(String(format: "note hit: %@ not equal to %@", noteHit.fullName, (targetNote?.fullName)!))
                    } else {
                        print(String(format: "note hit: 'nil' not equal to %@", (targetNote?.fullName)!))
                    }
                    stopExercise()
                } else if lowFarPitchThreshold...highFarPitchThreshold ~= frequency {
                    setArrowAndPrompt(true, isUp: frequency < targetPitch)
                } else {
                    setArrowAndPrompt(false, isUp: frequency < targetPitch)
                }
                

            } else {
                //stop extremely out-of-range
                print("sound out-of-range")
                return
            }
        } else if hasNoteStarted {
            print("no sound tracked")
            stopExercise()
            return
        } else {
            clearArrowAndPrompt()
        }
    }
    
    //MARK: SSSyControls protocol
    func partEnabled(_ partIndex: Int32) -> Bool {
        return partIndex == self.partIndex
    }
    
    func partInstrument(_ partIndex: Int32) -> UInt32 {
        return instrumentId
    }
    
    func partVolume(_ partIndex: Int32) -> Float {
        return 1.0
    }
    
    func metronomeEnabled() -> Bool {
        return false
    }
    
    func metronomeInstrument() -> UInt32 {
        return 0
    }
    
    func metronomeVolume() -> Float {
        return 0.0
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

}
