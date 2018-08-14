//
//  LongToneViewController.swift
//  FirstStage
//
//  Created by Adam Kinney on 12/8/15.
//  Changed by David S Reich - 2016.
//  Copyright © 2015 Musikyoshi. All rights reserved.
//

import UIKit

enum enharmonicSpelling {
    case displayAsNatural
    case displayAsSharp
    case displayAsFlat
}

class LongToneViewController: UIViewController, SSSyControls, SSUTempo, SSSynthParameterControls, SSFrequencyConverter {
    
    var exerciseState = ExerciseState.notStarted
    var timer = Timer()
    var currentTime = 0.0
    var targetNote : Note?
    var absoluteTargetNote: Note?
    var showFarText = true
    var noteName = ""
    var enharmonicDisplay = enharmonicSpelling.displayAsNatural
    var exerLevelIndex: Int = 0
    var exerExerciseIndex: Int = 0
    var exerExerciseTag: String = ""
    
    // To compensate for inevitable drift in signal that may have nothing
    // to do with performance
    let kMaxTimesWrongPitchAllowed: UInt = 15
    let kMaxTimesNoSoundAllowed: UInt    =  5
    var numTimesWrongPitch: UInt = 0
    var numTimesNoSound: UInt = 0

    // AK_ISSUE
    var firstTimeAfterAKRestart = true
    
    // These were added because it wasn't clear that "sparklinetapped" resulted
    // in playback. This was all part of getting this broken view working again.
    @IBOutlet weak var tapToHearButton: UIButton!
    @IBAction func tapToHearBtnTapped(_ sender: Any) {
        playScore()
    }
    
    // protocol SSFrequencyConverter
    
    /*!
     @method frequency:
     @abstract convert a midi pitch to frequency
     */
    public func frequency(_ midiPitch: Int32) -> Float {
        return intonation.frequency(midiPitch)
    }
    
    private let intonation = Intonation(temperament: Intonation.Temperament.Equal)


    var targetTime = 3.0
    var targetNoteID = 0
    let kFirstLongTone25Note = 55
    let kLastLongTone25Note = 79
    var kC4 = 60
    var kDb4 = 61
    var kD4 = 62
    var kE4 = 64
    /* Long_Tone_25G3G5:
        G3 Ab A Bb B C4 C# D Eb E F F# G Ab A Bb B C5 C# D Eb E F F# G5
    */


    let amplitudeThreshold = UserDefaults.standard.double(forKey: Constants.Settings.AmplitudeThreshold)
    let tempoBPM = 60
    let transpositionOffset = UserDefaults.standard.integer(forKey: Constants.Settings.Transposition)
    let frequencyThreshold = UserDefaults.standard.double(forKey: Constants.Settings.FrequencyThreshold)
    var frequencyThresholdPercent = Double(0.0)
    var farFrequencyThresholdPercent = Double(0.0)
    var targetPitch = Double(0.0)
    var lowPitchThreshold = Double(0.0)
    var highPitchThreshold = Double(0.0)
    var lowFarPitchThreshold = Double(0.0)
    var highFarPitchThreshold = Double(0.0)
    let minPitch = Double(NoteService.getLowestFrequency())
    let maxPitch = Double(NoteService.getHighestFrequency())
    var firstTime = true
    var pitchSampleRate = 0.01
    var balloonUpdateRate = 0.01
    var longToneEndTime = 0.0
    var startTime = Date()
    var actualStartTime = Date()

    
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

    let feedbackView = FeedbackView()
    var starScoreView = StarScore()
    var starScore: Int = 0

    ///////////////////////////////////////////////
    // New SF
    private var sampledInstrumentIds = [UInt]()
    private var synthesizedInstrumentIds = [UInt]()
    private var metronomeInstrumentIds = [UInt]()
    private static let kMaxInstruments = 10
    private var synthVoice = SSSynthVoice.Sampled
    private static  let kDefaultRiseFallSamples = 4
    private var waveformSymmetryValue = Float(0.5)
    private var waveformRiseFallValue = kDefaultRiseFallSamples // samples in rise/fall of square waveform
    
    /*!
     @method waveform
     @abstract return a waveform type for the waveform generator
     @discussion called by the synthesizer while playing
     */
    func waveform() -> sscore_sy_synthesizedinstrument_waveform
    {
        switch synthVoice
        {
        case .Sine : return sscore_sy_sine
        case .Square : return sscore_sy_square
        case .Triangle : return sscore_sy_triangle
        default: return sscore_sy_sine
        }
    }
    
    /*!
     @method waveformSymmetry
     @abstract return a symmetry value for square and triangle waveforms
     @discussion called by the synthesizer while playing
     */
    func waveformSymmetry() -> Float
    {
        return waveformSymmetryValue
    }
    
    /*!
     @method waveformRiseFall
     @abstract return a rise-fall value for the square waveform (in samples at 44100samples/s)
     @discussion called by the synthesizer while playing
     */
    public func waveformRiseFall() -> Int32 {
        return Int32(waveformRiseFallValue)
    }

    private var kSampledInstrumentsInfo : [SSSampledInstrumentInfo] {
        get {
            var rval = [SSSampledInstrumentInfo]()
            rval.append(SSSampledInstrumentInfo("Piano", base_filename: "Piano.mf", extension: "m4a", base_midipitch: 23, numfiles: 86, volume: Float(1.0), attack_time_ms: 4, decay_time_ms: 10, overlap_time_ms: 10, alternativenames: "piano,pianoforte,klavier", pitch_offset: 0, family: sscore_sy_instrumentfamily_hammeredstring, flags: 0, samplesflags: 0))
            //rval.append(SSSampledInstrumentInfo("MidiPercussion", base_filename: "Drum", extension: "mp3", base_midipitch: 35, numfiles: 47, volume: Float(1.0), attack_time_ms: 4, decay_time_ms: 10, overlap_time_ms: 10, alternativenames: "percussion,MidiPercussion", pitch_offset: 0, family: sscore_sy_instrumentfamily_midi_percussion, flags: sscore_sy_suppressrmscompensation_flag, samplesflags: 0))
            rval.append(SSSampledInstrumentInfo("Trumpet", base_filename: "Trumpet.novib.mf", extension: "m4a", base_midipitch: 52, numfiles: 35, volume: Float(1.0), attack_time_ms: 2, decay_time_ms: 10, overlap_time_ms: 1, alternativenames: "trumpet", pitch_offset: 0, family: sscore_sy_instrumentfamily_hammeredstring, flags: 0, samplesflags: 0))
            return rval
        }
    }
    
    private var kSynthesizedInstrumentsInfo : [SSSynthesizedInstrumentInfo] {
        get {
            var rval = [SSSynthesizedInstrumentInfo]()
            rval.append(SSSynthesizedInstrumentInfo("Tick", volume: Float(1.0), type:sscore_sy_tick1, attack_time_ms:4, decay_time_ms:20, flags:0, frequencyConv: nil, parameters: nil))
            rval.append(SSSynthesizedInstrumentInfo("Waveform", volume: Float(1.0), type:sscore_sy_pitched_waveform_instrument, attack_time_ms:4, decay_time_ms:20, flags:0, frequencyConv: self, parameters: self))
            return rval
        }
    }

    // New SF
    ///////////////////////////////
    
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var balloon: Balloon!
    @IBOutlet weak var feedbackLbl: UILabel!
    @IBOutlet weak var feedbackPnl: UIStackView!
    @IBOutlet weak var visualizationPanel: UIView!
    @IBOutlet weak var sparkLine: SparkLine!
    @IBOutlet weak var countdownLbl: UILabel!
    @IBOutlet weak var ssScrollView: SSScrollView!
    @IBOutlet weak var guideTextView: UITextView!
    @IBOutlet var sparkLineTapRecognizer: UITapGestureRecognizer!
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if synth != nil && (synth?.isPlaying)! {
            synth?.reset()
        }
        self.dismiss(animated: true, completion: nil)
    }

    func setNoteID() {
        switch noteName {
        case "Bb3":         targetNoteID = 58
        case "B3" :         targetNoteID = 59
        case "C4" :         targetNoteID = 60
        case "C#4", "Db4":  targetNoteID = 61
                                                //case "Db4": targetNoteID = 61
        case "D4":          targetNoteID = 62
        case "D#4", "Eb4":  targetNoteID = 63
                                                //case "Eb4":       targetNoteID = 63
        case "E4" :         targetNoteID = 64
        default:            targetNoteID = 60 // C4
        }
    }
    
    func setEnharmoniDisplay() {
        let flatChar:  Character = "b"
        let sharpChar: Character = "#"

        if noteName.contains(flatChar) {
            enharmonicDisplay = .displayAsFlat
        } else if noteName.contains(sharpChar) {
            enharmonicDisplay = .displayAsSharp
        } else {
            enharmonicDisplay = .displayAsNatural
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Parsing stuff:  Save for later.
//        let origStr: String = "LT_C4_10, LT_C#4_10, LT_D4_15, LT_Eb4_15, LT_E4_20"
//        let strArray = origStr.components(separatedBy: ", ")
//        for oneStr in strArray {
//            let chunks = oneStr.components(separatedBy: "_")
//            print("oneStr")
//        }
        
        // Set up the StarScore view as a subview of the Balloon view
        let ballFrame = balloon.frame
        let starSz  = StarScore.getSize()
        let starY = ballFrame.origin.y + (ballFrame.size.height/2.0) + (starSz.height/2.0)
        let starX = (ballFrame.size.width/2.0) - (starSz.width/2.0)
        let starOrigin = CGPoint(x:starX, y:starY)
        
        starScoreView.initWithPoint(atPoint: starOrigin)
        starScoreView.setStarCount(numStars: 3)
        starScoreView.isHidden = true
        balloon.addSubview(starScoreView)
        
        // AK_ISSUE was: (comment 1 line below)
        AudioKitManager.sharedInstance.setup()  // SFAUDIO
        
        // AK_ISSUE - now:   (uncomment 4 lines below)
//        if !AudioKitManager.sharedInstance.isRunning {
//            AudioKitManager.sharedInstance.setup()  // SFAUDIO
//            firstTimeAfterAKRestart = true  // AK_ISSUE
//        }

//        _ = ScoreMgr.instance.loadExercise(currLevelIndex: exerLevelIndex,
//                                           currExerciseIndex: exerExerciseIndex,
//                                           exerciseTag: exerExerciseTag )
        
        setNoteID()
        absoluteTargetNote = NoteService.getNote(targetNoteID + transpositionOffset)
        targetNote = NoteService.getNote(targetNoteID)
        if targetNote != nil {
            print("targetNote: \(String(describing: targetNote))")

            navigationItem.title = "Long Tone - \(targetNote!.fullName)"
            instructionLbl.text = "Play a long \(targetNote!.friendlyName) note and fill up the balloon until it turns green!"
        }

        setEnharmoniDisplay() // scan NoteName for "#" or "b"
        
        // If note is sharp, the # is already in the note name, and using
        // Long_Tone_25G3G5, it will display as sharp on the SeeScore view.
        // If note is flat, must use the flatName and Long_Tone_25G3G5_flat file,
        // and then it will display as flat on the SeeScore view.
        var notesMusicXMLFileName = "XML Tunes/Long_Tone_25G3G5"
        if targetNote != nil {
            switch enharmonicDisplay {
            case .displayAsNatural:
                noteName = targetNote!.name
            case .displayAsSharp:
                noteName = targetNote!.name
            case .displayAsFlat:
                notesMusicXMLFileName = "XML Tunes/Long_Tone_25G3G5_flat"
                noteName = targetNote!.flatName
             }
        }
        loadFile(notesMusicXMLFileName)

        navigationItem.title = "Long Tone - \(noteName)"
        instructionLbl.text  = "Play a long \(noteName) note and fill up the balloon until it turns green!"

//        ScoreMgr.instance.currentExerciseState = kExer_InProgress
//        ScoreMgr.instance.saveCurrentExercise()
        
        frequencyThresholdPercent = 1.0 + frequencyThreshold
        farFrequencyThresholdPercent = frequencyThresholdPercent + (frequencyThreshold * 1.5)
        firstTime = true
        setupImageViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight)
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        
//        ScoreMgr.instance.currentExerciseState = kExer_Completed
//        ScoreMgr.instance.saveCurrentExercise()
//        _ = ScoreMgr.instance.saveScoreFile()
        
        super.viewWillDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    @IBAction func sparkLineTapped(_ sender: UITapGestureRecognizer) {
//        let currScore = ScoreMgr.instance.currentExerciseScore
//        if currScore < 4 {
//            ScoreMgr.instance.currentExerciseScore += 1
//            ScoreMgr.instance.saveCurrentExercise()
//        }
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
        loadOptions?.checkxml = true
        let errP = UnsafeMutablePointer<sscore_loaderror>.allocate(capacity: 1)
        
        print("filePath: \(filePath)")
        print("loadOptions: \(loadOptions)")
        print("errP: \(errP)")
        
        ////////////
        // New, from TuneExer
        guard let xmlData = MusicXMLModifier.modifyXMLToData(musicXMLUrl: URL(fileURLWithPath: filePath), smallestWidth: UserDefaults.standard.double(forKey: Constants.Settings.SmallestNoteWidth), signatureWidth: UserDefaults.standard.double(forKey: Constants.Settings.SignatureWidth)) else {
            print("Cannot get modified xmlData from \(filePath)!")
            return
        }
        var err : SSLoadError?
        
        if let score0 = SSScore(xmlData: xmlData, options: loadOptions, error: &err) {

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
                showingParts.append(NSNumber(value: (Int32(i) == partNumber) as Bool)) // display the selected part
            }
            
            layOptions.hidePartNames = true
            layOptions.hideBarNumbers = true
            ssScrollView.optimalSingleSystem = false
            ssScrollView.setupScore(score, openParts: showingParts, mag: kDefaultMagnification, opt: layOptions, completion: getPlayData)
        }
        else
        {
            var err: sscore_loaderror
            err = errP.pointee
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
        
        playData = SSPData.createPlay(from: score, tempo: self)
    }
    
    func playScore() {
        ssScrollView.contentOffset = CGPoint.zero
        ssScrollView.isScrollEnabled = false

        guard score != nil else { return }
        playData = SSPData.createPlay(from: score, tempo: self)
        guard playData != nil else { return }
        
        if synth != nil && (synth?.isPlaying)! {
            synth?.reset()
        } else {
            if synth == nil {
                if let synth0 = SSSynth.createSynth(self, score: score) {
                    synth = synth0
                }
                sampledInstrumentIds.removeAll()
                synthesizedInstrumentIds.removeAll()
                metronomeInstrumentIds.removeAll()
                assert(kSampledInstrumentsInfo.count + kSynthesizedInstrumentsInfo.count < LongToneViewController.kMaxInstruments)
                for info in kSampledInstrumentsInfo {
                    let iid = synth?.addSampledInstrument_alt(info)
                    assert(iid! > 0 && iid! < 1000000)
                    sampledInstrumentIds.append(UInt(iid!))
                }
                for info in kSynthesizedInstrumentsInfo {
                    let iid = synth?.addSynthesizedInstrument_alt(info)
                    switch info.info.type
                    {
                    case sscore_sy_tick1: metronomeInstrumentIds.append(UInt(iid!))
                    case sscore_sy_pitched_waveform_instrument: synthesizedInstrumentIds.append(UInt(iid!))
                    default: break
                    }
                }
            }
        

            guard synth != nil else {
                print("No licence for synth");
                return
            }

            // AK_ISSUE - did not change this
            // start playing if not playing   SFAUDIO
            if AVAudioSessionManager.sharedInstance.setupAudioSession() {
                print("setupAudioSession == true")
                playData?.clearLoop()
                
                guard playData != nil else {
                    print("No playData");
                    return
                }
                
                var err = synth?.setup(playData)
                if err == sscore_NoError {
                    let delayInSeconds = 0.5
                    let startTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(delayInSeconds * 1000.0))
                    err = synth?.start(at: startTime.rawValue, bar: cursorBarIndex, countIn: false)
                }
                
                if err == sscore_UnlicensedFunctionError {
                    print("synth license expired!")
                } else if err == sscore_SynthStartFailedError {
                    print("synth Start Failed Error!")
                } else if err == sscore_SynthNoInstrumentsError {
                    print("synth No Instruments Error!")
                } else if err != sscore_NoError {
                    print("synth failed to start: \(String(describing: err))")
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
            _ = navigationController?.popViewController(animated: true)
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
    
    @objc func deflateBalloon(){
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
            targetPitch = Double(0.0)
            lowPitchThreshold = Double(0.0)
            highPitchThreshold = Double(0.0)
            lowFarPitchThreshold = Double(0.0)
            highFarPitchThreshold = Double(0.0)
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
                    self.startExercise()
                }
            }
        }
    }
    
    func startExercise(){
        actualStartTime = Date()
        starScore = 0
        balloon.reset()
        numTimesWrongPitch = 0
        numTimesNoSound = 0
        AudioKitManager.sharedInstance.start()
        firstTimeAfterAKRestart = true // AK_ISSUE  added
        
        print("\n    In startExercise, startTime == \(startTime)\n")
        
        longToneEndTime = Date().timeIntervalSince(actualStartTime) + targetTime + 2.0
        timer = Timer.scheduledTimer(timeInterval: pitchSampleRate, target: self, selector: #selector(LongToneViewController.updateTracking), userInfo: nil, repeats: true)
    }
    
    func stopExercise(){
        resetSparkLine()
        
        AudioKitManager.sharedInstance.stop() // SFAUDIO // AK_ISSUE - didn't change this
        firstTimeAfterAKRestart = true // AK_ISSUE   new
        timer.invalidate()
        
        if isExerciseSuccess
        {
            balloon.explodeBalloon()
            balloon.fillColor = UIColor.green.cgColor
            feedbackLbl.text = "You did it!"
            //smileImageView.isHidden = false
            starScoreView.setStarCount(numStars: starScore)
            starScoreView.isHidden = false
            starScoreView.pulseView()
        }
        else
        {
            balloon.deflateBallon()
           // timer = Timer.scheduledTimer(timeInterval: balloonUpdateRate, target: self, selector: #selector(LongToneViewController.deflateBalloon), userInfo: nil, repeats: true)
            feedbackLbl.text = "Almost..."
            starScoreView.setStarCount(numStars: starScore)
            starScoreView.isHidden = false
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

        if isExerciseSuccess {
            starScoreView.isHidden = false

            balloon.explodeBalloon()
//            feedbackView.setupFeedbackView(self)
//            let feedbackRect = visualizationPanel.frame
//            feedbackView.contentMode = .scaleAspectFill
//            feedbackView.showFeedback(feedbackRect)
        }
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
    
    @objc func updateTracking()
    {
        
        if Date().timeIntervalSince(actualStartTime) > longToneEndTime {
            // we're done!
            stopExercise()
        }

//        let amplitude = AudioKitManager.sharedInstance.amplitude()
//        let frequency = AudioKitManager.sharedInstance.frequency()
        // SFAUDIO
        
        print("frequencyTracker == \(AudioKitManager.sharedInstance.frequencyTracker)")

        let amplitude = AudioKitManager.sharedInstance.frequencyTracker.amplitude
        let frequency = AudioKitManager.sharedInstance.frequencyTracker.frequency
        
        // AK_ISSUE  -- just printing data, nos real audio changes
        if firstTimeAfterAKRestart {
            firstTimeAfterAKRestart = false
            if frequency > 199.95 && frequency < 200.05 {
                print("FrequencyTracker probably bad")
                print("  frequencyTracker == \(AudioKitManager.sharedInstance.frequencyTracker)")
            } else {
                print("FrequencyTracker probably good")
                print("  frequencyTracker == \(AudioKitManager.sharedInstance.frequencyTracker)")
            }
        }
        
        print ("----> Current Frequency: \(frequency)")
        print ("----> Current Amplitude: \(amplitude)")


        if amplitude > kAmplitudeThresholdForIsSound {
            if minPitch...maxPitch ~= frequency {
                if lowPitchThreshold...highPitchThreshold ~= frequency {
                    numTimesWrongPitch = 0
                    numTimesNoSound = 0
                    //inside threshold
                    clearArrowAndPrompt()
                    hasNoteStarted = true
                    currentTime += pitchSampleRate
                    if currentTime >= targetTime {
                        isExerciseSuccess = true
                        stopExercise()
                        return
                    } else {
                        
                        let elapsed = Date().timeIntervalSince(actualStartTime)
                        let timeLen = TimeInterval(targetTime)
                        print ("elapsed == \(elapsed)")
                        print ("timeLen == \(timeLen)")
                        let percent:CGFloat = CGFloat(elapsed/timeLen)
                        let percentInt = Int(percent*100)
                        print ("percent == \(percent)")
                        balloon.increaseBalloonSize(toPercentage: percent)
                        if percentInt > 95 {
                            starScore = 4
                        } else if percentInt > 55 {
                            starScore = 3
                        } else if percentInt > 35 {
                            starScore = 2
                        } else if percentInt > 10 {
                            starScore = 1 }
                        else  {
                            starScore = 0
                        }
                        
                        timerLbl.text = String(format: "%.2f/%.2f", currentTime, targetTime)
                        // balloon.radius += 0.3
                        playBtn.isHidden = false
                        playBtn.isEnabled = false
                        playBtn.setTitle("Keep it up!", for: UIControlState())
                    }
                } else if hasNoteStarted {
                    // outside threshold. But make sure it's not an intermittant
                    // signal; wait a few samples to see if it's back to correct
                    numTimesWrongPitch += 1
                    if numTimesWrongPitch > kMaxTimesWrongPitchAllowed {
                         if let noteHit = NoteService.getNote(frequency) {
                            print(String(format: "note hit: %@ not equal to %@", noteHit.fullName, (targetNote?.fullName)!))
                        } else {
                            print(String(format: "note hit: 'nil' not equal to %@", (targetNote?.fullName)!))
                        }
                        stopExercise()
                    }
                } else if lowFarPitchThreshold...highFarPitchThreshold ~= frequency {
                    setArrowAndPrompt(true, isUp: frequency < targetPitch)
                } else {
                    setArrowAndPrompt(false, isUp: frequency < targetPitch)
                }

//                if let noteHit = NoteService.getNote(frequency) {
//                    if sparkLineCount < sparkLine.bounds.width {
//                        sparkLineCount++
//                    } else {
//                        resetSparkLine()
//                    }
//
//                    //TODO: color green if hasNoteStarted==true, else red
//                    //TODO: the above requires adding a color input to sparkLine
//                    //TODO: make this continuous based upon freq
//                    let yPos = CGFloat(NoteService.getYPos(noteHit.orderId!) + Constants.MusicLine.yOffset)
//                    
//                    sparkLine.addValue(hasNoteStarted, newValue: CGPointMake(sparkLineCount, yPos))
//                    //print(String(format: "note hit: %@ x: \(trackingCount) y: \(yPos)", (noteHit?.fullName)!))
//                }
            } else {
                //stop extremely out-of-range
                print("sound out-of-range")
                return
            }
        } else if hasNoteStarted {
            print("no sound tracked; waiting to see if temp glitch")
           numTimesNoSound += 1
            if numTimesNoSound > kMaxTimesNoSoundAllowed {
                print("no sound tracked; stopping")
                stopExercise()
                return
            }
        } else {
            clearArrowAndPrompt()
        }
    }
    
    //MARK: SSSyControls protocol
    func partEnabled(_ partIndex: Int32) -> Bool {
        return partIndex == self.partIndex
    }
    
    func partInstrument(_ partIndex: Int32) -> UInt32 {
        if synthVoice == SSSynthVoice.Sampled {
            return UInt32(instrumentForPart(partIndex : Int(partIndex)))
        } else if !synthesizedInstrumentIds.isEmpty {
            return UInt32(synthesizedInstrumentIds[0])
        }

        return 0 // instrumentId
    }
    
    func instrumentForPart(partIndex : Int) -> UInt
    {
        guard !sampledInstrumentIds.isEmpty else { return 0 }
        
        var index = 0
        if sampledInstrumentIds.count > 1 {
            index = UserDefaults.standard.bool(forKey: Constants.Settings.PlayTrumpet) ? 1 : 0
        }
        
        return sampledInstrumentIds[index]
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
