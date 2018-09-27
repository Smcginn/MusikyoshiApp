//
//  LongToneViewController.swift
//  FirstStage
//
//  Created by Adam Kinney on 12/8/15.
//  Changed by David S Reich - 2016.
//  Copyright © 2015 Musikyoshi. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit

enum enharmonicSpelling {
    case displayAsNatural
    case displayAsSharp
    case displayAsFlat
}

let kLTExerState_Waiting   = 0 // waiting to start
let kLTExerState_Countdown = 1
let kLTExerState_InExer    = 2
let kLTExerState_TryAgain  = 3
let kLTExerState_Done      = 4

let kPerCentThreshold_FourStar:  Int =  95
let kPerCentThreshold_ThreeStar: Int =  55
let kPerCentThreshold_TwoStar:   Int =  35
let kPerCentThreshold_OneStar:   Int =  10

class LongToneViewController: UIViewController, SSSyControls, SSUTempo, SSSynthParameterControls, SSFrequencyConverter {
    
    
    func switchExerState( newState: Int ) {
        // let oldState = currLTExerState
        currLTExerState = newState
        
        switch currLTExerState {
        case kLTExerState_Countdown:
//            if !starScoreViewIsSetup {
//                setupStarScoreStuff()
//                starScoreViewIsSetup = true
//            }
            playBtn.isHidden = true
            starScoreView.setStarCount(numStars: bestStarScore)
            starScoreView.isHidden = false
            starScoreLbl?.text = "Best so far:"
            starScoreLbl?.isHidden = false
            
        case kLTExerState_InExer:
            playBtn.isHidden = true
            currStarScore = 0
            starScoreView.setStarCount(numStars: currStarScore)
            starScoreView.isHidden = false
            starScoreLbl?.text = "This time:"
            starScoreLbl?.isHidden = false
            // hide button, switch text to congrats lable, show Monkey
            
        case kLTExerState_TryAgain:
            starScoreView.setStarCount(numStars: currStarScore)
            starScoreView.isHidden = false
            starScoreLbl?.text = "This time:"
            starScoreLbl?.isHidden = false
            var playBtnAttrStr: NSMutableAttributedString
            if doingPersonalRecord {
                playBtnAttrStr = createAttributedText(str: "Try Again?", fontSize: 24.0)
            } else {
                playBtnAttrStr = createAttributedText(str: "Try Again", fontSize: 24.0)
            }
            playBtn.setAttributedTitle(playBtnAttrStr, for: .normal)
            playBtn.isHidden = false
            // show button, reset text
            
        case kLTExerState_Done:
            starScoreView.setStarCount(numStars: bestStarScore)
            starScoreLbl?.text = "Best so far:"
            starScoreLbl?.isHidden = false
            starScoreView.isHidden = false
            playBtn.isHidden = false
            // hide button, switch text to congrats lable, auto-fade monkey face out
            
            let playBtnAttrStr = createAttributedText(str: "Next Exercise", fontSize: 24.0)
            playBtn.setAttributedTitle(playBtnAttrStr, for: .normal)

        default:
            playBtn.isHidden = false
        }
    }
     
    
    
    
    // Invoking VC sets these
    var noteName = ""           // "C#4", "Db4", etc.
    var targetTime = 3.0        // duration of exercise
    var exerNumber: Int    = -1
    var secondaryText:String = ""
    var callingVCDelegate: ExerciseResults? = nil
    var exerciseType: ExerciseType = .longtoneExer

    
    var doingPersonalRecord = false
    var currPersBest: Double = 0.0
    
    var numberOfAttempts = 0
    
    var currLTExerState = kLTExerState_Waiting
    
    var exerciseState = ExerciseState.notStarted
    var lockedInTimer = Timer()
    var timer = Timer()
    var currentTime = 0.0
    var targetNote : Note?
    var absoluteTargetNote: Note?
    var showFarText = true
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
    var tryCount = 0
    let tryMax   = 3
    var pitchSampleRate = 0.01
    var balloonUpdateRate = 0.01
    var longToneEndTime = 0.0
    var startTime = Date()
//    var exerStartTime = Date()
    var actualStartTime = Date()
    var actualTimeNotSet = true
    
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

    var starScoreViewIsSetup = false
    var starScoreLbl: UILabel? = nil
    let feedbackView = FeedbackView()
    var starScoreView = StarScore()
    func showStarScore() {
        starScoreView.isHidden = false
    }
    func hideStarScore() {
        starScoreView.isHidden = true
    }

    func setBestStarScore(newScore: Int) {
        if newScore > bestStarScore {
            bestStarScore = newScore
        }
    }
    var bestStarScore: Int = 0
    var currStarScore: Int = 0
    
    
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
    
    @IBOutlet weak var navigationBar: UINavigationBar!
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
        prepareForReturnToCallingVC()
    }
    
    @IBOutlet weak var doneBtn: UIButton!
    @IBAction func doneBtnTapped(_ sender: Any) {
        prepareForReturnToCallingVC()
    }
    
    func prepareForReturnToCallingVC() {
        if synth != nil && (synth?.isPlaying)! {
            synth?.reset()
        }
        
        let kDecentScore = 1
        
        if numberOfAttempts == 0 || bestStarScore < kDecentScore {
            displayNotReallyDoneAlert()
        } else {
            returnToCallingVC(doSaveScore: true)
        }
    }
    
    func returnToCallingVC(doSaveScore: Bool) {
        if synth != nil && (synth?.isPlaying)! {
            synth?.reset()
        }
        if doSaveScore {
            callingVCDelegate?.setExerciseResults(exerNumber: exerNumber,
                                                  exerStatus: kLDEState_Completed,
                                                  exerScore:  bestStarScore)
        } else {
            callingVCDelegate?.setExerciseResults(exerNumber: exerNumber,
                                                  exerStatus: kLDEState_NotStarted,
                                                  exerScore:  0)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func setNoteID() {
        switch noteName {
        case "G3":          targetNoteID = 55
        case "G#3", "Ab3":  targetNoteID = 56
        case "A3":          targetNoteID = 57
        case "A#3", "Bb3":  targetNoteID = 58
        case "B3",  "Cb4":  targetNoteID = 59
            
        case "C4",  "B#3":  targetNoteID = 60
        case "C#4", "Db4":  targetNoteID = 61
        case "D4":          targetNoteID = 62
        case "D#4", "Eb4":  targetNoteID = 63
        case "E4" :         targetNoteID = 64
        case "F4" :         targetNoteID = 65
        case "F#4", "Gb4":  targetNoteID = 66
        case "G4":          targetNoteID = 67
        case "G#4", "Ab4":  targetNoteID = 68
        case "A4":          targetNoteID = 69
        case "A#4", "Bb4":  targetNoteID = 70
        case "B4",  "Cb5":  targetNoteID = 71
            
        case "C5":          targetNoteID = 72
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
    
    // orientation BS
    let appDel = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // orientation BS
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.orientationLock = .landscape

        playBtn.layer.cornerRadius = 10
        playBtn.clipsToBounds = true
 
        let playWd = CGFloat(175.0)
        playBtn.bounds.size.width = playWd
        playBtn.frame.size.width = playWd

        let visSz  = visualizationPanel.frame
         let playX = visSz.width/2.0 - playWd/2.0
        playBtn.frame.origin.x = playX
        let playBtnAttrStr = createAttributedText(str: "Start Playing", fontSize: 18.0)
        playBtn.titleLabel?.attributedText = playBtnAttrStr // "All Done!"
        playBtn.backgroundColor = kDefault_ButtonBckgrndColor

        
        doneBtn.layer.cornerRadius = 10
        doneBtn.clipsToBounds = true
        let doneBtnAttrStr = createAttributedText(str: "Done", fontSize: 18.0)
        doneBtn.titleLabel?.attributedText = doneBtnAttrStr // "All Done!"
        doneBtn.backgroundColor = kDefault_ButtonBckgrndColor
        
//        let kLongtone_ButtonBckgrndColor        =  kDefault_ButtonBckgrndColor
//        let kLongtone_ButtonTextColor           =  kDefault_ButtonTextColor

        // AK_ISSUE was: (comment 1 line below)
 //       AudioKitManager.sharedInstance.setup()  // SFAUDIO
        
        // AK_ISSUE - now:   (uncomment 4 lines below)
//        if !AudioKitManager.sharedInstance.isRunning {
//            AudioKitManager.sharedInstance.setup()  // SFAUDIO
//            firstTimeAfterAKRestart = true  // AK_ISSUE
//        }
        
        setNoteID()
        absoluteTargetNote = NoteService.getNote(targetNoteID + transpositionOffset)
        targetNote = NoteService.getNote(targetNoteID)
        if targetNote != nil {
            print("targetNote: \(String(describing: targetNote))")

            navigationItem.title = "Long Tone - \(targetNote!.fullName)"
            instructionLbl.text = "Play a long \(targetNote!.friendlyName) note and fill up the balloon until it turns green!"
        }
        
        feedbackLbl.isHidden = true
        
        if exerciseType == .longtoneRecordExer {
            doingPersonalRecord = true
            currPersBest =
                LessonScheduler.instance.getPersonalBestTime(forNoteID: targetNoteID)
            targetTime = 60.0
            timerLbl.text = String(format: "Current Record: %.2f", currPersBest)

            setTargetTimeIfDoingPersonalBest(setLabels: true)
            print("In Longtone;   doingPersonalRecord is true")
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

        let targtTimeInt = Int(targetTime)
        navigationItem.title = "Long Toney - Play A \(noteName) for \(targtTimeInt) Seconds"
        
        // this one is it:
        if doingPersonalRecord {
            navigationBar.topItem?.title =
                "Long Tone Personal Record - Play a \(noteName) for as long as you can"
            instructionLbl.text  = ""
        } else {
            navigationBar.topItem?.title =
                "Long Tone - Play a \(noteName) for \(targtTimeInt) Seconds"
            instructionLbl.text  =
                "Play a long \(noteName) note and fill up the balloon until it bursts!"
        }
        
        frequencyThresholdPercent = 1.0 + frequencyThreshold
        farFrequencyThresholdPercent = frequencyThresholdPercent + (frequencyThreshold * 1.5)
        firstTime = true
        tryCount = 0
        setupImageViews()
        
        self.view.backgroundColor = kLongtone_BackgroundColor
        self.guideTextView.backgroundColor  = kLongtone_BackgroundColor
        self.guideTextView.isHidden = true // per Shawn's request
        
        if kLongtone_DoSetVisPanelColor {
            self.visualizationPanel.backgroundColor = kLongtone_VisPanelBkgrndColor
        }
        
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAVAudioInterruption(_:)),
                name: NSNotification.Name.AVAudioSessionInterruption,
                object: self)
    }
    
    func setupStarScoreStuff() {

        let starSz  = StarScore.getSize()
 //       let ballFrame = balloon.frame
        let visFrame = visualizationPanel.frame
 //       let visbounds = visualizationPanel.bounds
        
        var starY =  visFrame.height - 110 //(starSz.height/2.0)
        var starX =  visFrame.size.width - (starSz.width + 10)
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            // center the star score view
            starX = (visFrame.size.width/2.0) - (starSz.width/2.0)
            // and bring it up a bit
            starY -= 100
        }
        let starOrigin = CGPoint(x:starX, y:starY)
        
        starScoreView.initWithPoint(atPoint: starOrigin)
        starScoreView.setStarCount(numStars: 3)
        starScoreView.isHidden = true
        visualizationPanel.addSubview(starScoreView)
        
        let lableWd  = CGFloat(100.0)
        let lableX   = starX - lableWd
        let lblFrame = CGRect(x: lableX, y: starY+25, width: lableWd, height: 30)
        starScoreLbl = UILabel.init(frame: lblFrame)
        starScoreLbl?.text = "Best so far:"
        starScoreLbl?.isHidden = true
        visualizationPanel.addSubview(starScoreLbl!)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight)
        ssScrollView.useSeeScoreCursor(false)
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !starScoreViewIsSetup {
            setupStarScoreStuff()
            starScoreViewIsSetup = true
        }

        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
        }
    }
    
    @IBAction func sparkLineTapped(_ sender: UITapGestureRecognizer) {
        playScore()
    }
    
    func loadFile(_ scoreFile: String) {
        playBtn.isHidden = false
        playBtn.isEnabled = true
        
//        let playBtnAttrStr = createAttributedText(str: "Start Playing", fontSize: 24.0)
//        playBtn.titleLabel?.attributedText = playBtnAttrStr // "All Done!"

        // WAS:       playBtn.setTitle("Start Playing", for: UIControlState())
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
        
  //      print("filePath: \(filePath)")
  //      print("loadOptions: \(loadOptions)")
  //      print("errP: \(errP)")
        
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
            if AVAudioSessionManager.sharedInstance.setupAudioSession(sessionMode: .playbackMode) {
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

        numberOfAttempts += 1
        
        if currLTExerState == kLTExerState_TryAgain { // playBtn.currentTitle == "Try Again" {
            tryAgainTap(sender)
            return
        } else if currLTExerState == kLTExerState_Done { // playBtn.currentTitle == "Next Exercise" {
            //TODO: goto Next Exercise
            
            prepareForReturnToCallingVC()
            
//            callingVCDelegate?.setExerciseResults(exerNumber: exerNumber,
//                                                  exerStatus: kLDEState_Completed,
//                                                  exerScore:  3)
//            self.dismiss(animated: true, completion: nil)

            
            
//            _ = navigationController?.popViewController(animated: true)
//            return
        }
        else if currLTExerState == kLTExerState_Waiting {
        //if exerciseState == ExerciseState.notStarted {
            startCountdown()
        }
//        else if exerciseState == ExerciseState.feedbackProvided {
//            //TODO: go to next exercise
//        }
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
    
    func updateTimerText() { // (currTime: Float, targTime: Float ) {
        if doingPersonalRecord {
            timerLbl.text = String(format: "%.2f", currentTime)
        } else {
            if isExerciseSuccess {
                timerLbl.text = String(format: "%.2f/%.2f", targetTime, targetTime)
            } else {
                timerLbl.text = String(format: "%.2f/%.2f", currentTime, targetTime)
            }
        }
    }
    
    func startCountdown()
    {
//        starScoreLbl?.isHidden = false
//        showStarScore()
        
        switchExerState(newState: kLTExerState_Countdown)
        timer.invalidate()
        feedbackLbl.isHidden = true
        
        hasNoteStarted = false
        isExerciseSuccess = false
        
        currentTime = 0.0
        updateTimerText()
        // timerLbl.text = String(format: "%.2f/%.2f", currentTime, targetTime)
        
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

//        playBtn.isEnabled = false
 //       playBtn.setTitle("", for: UIControlState())
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
//        starScoreLbl?.isHidden = true
//        starScoreView.setStarCount(numStars: currStarScore)
//        showStarScore()
        
        actualTimeNotSet = true
        switchExerState(newState: kLTExerState_InExer)
        startTime = Date()
        currStarScore = 0
        balloon.reset()
        numTimesWrongPitch = 0
        numTimesNoSound = 0
        //AudioKitManager.sharedInstance.start(forRecordToo:false)
        _ = AVAudioSessionManager.sharedInstance.setupAudioSession(sessionMode: .usingMicMode)
        firstTimeAfterAKRestart = true // AK_ISSUE  added
        
        print("\n    In startExercise, startTime == \(startTime)\n")
        var additionalTime = 5.0
        if targetTime > 5.0 {
            additionalTime += targetTime/3.0
        }
        longToneEndTime = Date().timeIntervalSince(startTime) + targetTime + additionalTime
        if doingPersonalRecord {
            longToneEndTime += 30.0
        }
        timer = Timer.scheduledTimer(timeInterval: pitchSampleRate, target: self, selector: #selector(LongToneViewController.updateTracking), userInfo: nil, repeats: true)
    }
    
    func setTargetTimeIfDoingPersonalBest(setLabels: Bool) {
        currPersBest =
            LessonScheduler.instance.getPersonalBestTime(forNoteID: targetNoteID)
        timerLbl.text = String(format: "Current Record: %.2f", currPersBest)
        
        if currPersBest > 0.0 {
            if currPersBest <= 10.0 {
                targetTime = 2 * currPersBest
            } else {
                targetTime = 1.5 * currPersBest
            }
            if setLabels {
                self.feedbackLbl.text =
                    String(format: "See if you can beat your current record",
                           currPersBest)
            }
        } else {
            targetTime = 5.0
            if setLabels {
                self.feedbackLbl.text = "See how long you can play the note"
            }
        }
        self.feedbackLbl.isHidden = false
    }
    
    func stopExercise(){
        resetSparkLine()
        setBestStarScore(newScore: currStarScore)
        
        AudioKitManager.sharedInstance.stop() // SFAUDIO // AK_ISSUE - didn't change this
        firstTimeAfterAKRestart = true // AK_ISSUE   new
        timer.invalidate()
        
//        playBtn.isHidden  = false
//        playBtn.isEnabled = true

        if doingPersonalRecord {
            let elapsed = Date().timeIntervalSince(actualStartTime)
//            let currBest =
//                LessonScheduler.instance.getPersonalBestTime(forNoteID: targetNoteID)
            if elapsed > currPersBest {
                currPersBest = elapsed
                LessonScheduler.instance.setPersonalBestTime(forNoteID: targetNoteID,
                                                             newPersBest: elapsed)
                _ = LessonScheduler.instance.saveScoreFile()
                setTargetTimeIfDoingPersonalBest(setLabels: false)
                feedbackLbl.text = "Great!!!   Best Ever!!!"
                feedbackLbl.isHidden = false
                switchExerState(newState: kLTExerState_TryAgain)
                timerLbl.text = String(format: "New Best Time: %.1f", currPersBest)
           } else {
                feedbackLbl.text = "Good Job, but not better than before . . ."
                feedbackLbl.isHidden = false
                switchExerState(newState: kLTExerState_TryAgain)
                timerLbl.text = String(format: "This Time: %.2f, Best: %.2f", elapsed, currPersBest)
           }
        } else if isExerciseSuccess {
            balloon.explodeBalloon()
            balloon.fillColor = UIColor.green.cgColor
            feedbackLbl.text = "You did it!"
            //smileImageView.isHidden = false
            starScoreView.setStarCount(numStars: bestStarScore)
            starScoreView.isHidden = false
            starScoreLbl?.text = "Best so far:"
            starScoreLbl?.isHidden = false
            starScoreView.pulseView()
            updateTimerText()
            //timerLbl.text = String(format: "%.2f/%.2f", targetTime, targetTime)
            switchExerState(newState: kLTExerState_Done)
        }
        else
        {
            balloon.deflateBallon()
           // timer = Timer.scheduledTimer(timeInterval: balloonUpdateRate, target: self, selector: #selector(LongToneViewController.deflateBalloon), userInfo: nil, repeats: true)
            feedbackLbl.text = "Almost..."
            starScoreView.setStarCount(numStars: currStarScore)
            starScoreView.isHidden = true
            starScoreLbl?.text = "This time:"
            starScoreLbl?.isHidden = false
       // }
        
        feedbackLbl.isHidden = false
 
        if tryCount < tryMax && currLTExerState != kLTExerState_Done {
        // if firstTime {
            tryCount += 1
//            playBtn.isHidden = false
//            playBtn.isEnabled = true
//            let playBtnAttrStr = createAttributedText(str: "Try Again", fontSize: 24.0)
//            playBtn.titleLabel?.attributedText = playBtnAttrStr // "All Done!"
            
            // WAS: playBtn.setTitle("Try Again", for: UIControlState())
            firstTime = false
            switchExerState(newState: kLTExerState_TryAgain)
        } else {
//            playBtn.isHidden = false
//            playBtn.isEnabled = true
            feedbackLbl.text = "Pretty Good!  Let's move on ..."
//            starScoreView.setStarCount(numStars: bestStarScore)
//            starScoreLbl?.isHidden = false
//
//            starScoreView.isHidden = false
//            let playBtnAttrStr = createAttributedText(str: "Next Exercise", fontSize: 24.0)
//            playBtn.titleLabel?.attributedText = playBtnAttrStr // "All Done!"
            // was: playBtn.setTitle("Next Exercise", for: UIControlState())
            switchExerState(newState: kLTExerState_Done)
        }
      }
        
//        exerciseState = ExerciseState.completed
//
//        if isExerciseSuccess {
//            starScoreView.isHidden = false
//
//            balloon.explodeBalloon()
////            feedbackView.setupFeedbackView(self)
////            let feedbackRect = visualizationPanel.frame
////            feedbackView.contentMode = .scaleAspectFill
////            feedbackView.showFeedback(feedbackRect)
//        }
////        delay(0.5){
////            self.feedbackPnl.center.y += 40
////            self.feedbackPnl.transform = CGAffineTransformMakeScale(0.5, 0.5)
////            UIView.animateWithDuration(0.3, animations: {
////                self.feedbackPnl.center.y -= 40
////                self.feedbackPnl.transform = CGAffineTransformMakeScale(1, 1)
////                self.feedbackPnl.alpha = 1
////            })
////
////            self.exerciseState = ExerciseState.FeedbackProvided
////        }
//        self.exerciseState = ExerciseState.feedbackProvided
    }
    
    @objc func updateTracking()
    {
        
        if Date().timeIntervalSince(startTime) > longToneEndTime {
            // we're done!
            stopExercise()
        }

//        let amplitude = AudioKitManager.sharedInstance.amplitude()
//        let frequency = AudioKitManager.sharedInstance.frequency()
        // SFAUDIO
        
        print("frequencyTracker == \(AudioKitManager.sharedInstance.frequencyTracker)")

        var amplitude = 0.0
        var frequency = 0.0
        if AudioKitManager.sharedInstance.frequencyTracker != nil {
            amplitude = AudioKitManager.sharedInstance.frequencyTracker.amplitude
            frequency = AudioKitManager.sharedInstance.frequencyTracker.frequency
        }
        
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
                    if currentTime >= targetTime && !doingPersonalRecord {
                        isExerciseSuccess = true
                        stopExercise()
                        return
                    } else {
                        if actualTimeNotSet {
                            actualStartTime = Date()
                            actualTimeNotSet = false
                        }

                        let elapsed = Date().timeIntervalSince(actualStartTime)
                        let timeLen = TimeInterval(targetTime)
                        print ("elapsed == \(elapsed)")
                        print ("timeLen == \(timeLen)")
                        //let percent:CGFloat = CGFloat(elapsed/timeLen)
                        let percent:CGFloat = CGFloat(currentTime/timeLen)
                        let percentInt = Int(percent*100)
                        print ("\n ****   percent == \(percent) \n")
                        balloon.increaseBalloonSize(toPercentage: percent)
                        if percentInt > kPerCentThreshold_FourStar {
                            currStarScore = 4
                        } else if percentInt > kPerCentThreshold_ThreeStar {
                            currStarScore = 3
                        } else if percentInt > kPerCentThreshold_TwoStar {
                            currStarScore = 2
                        } else if percentInt > kPerCentThreshold_OneStar {
                            currStarScore = 1 }
                        else  {
                            currStarScore = 0
                        }
                        
                        starScoreView.setStarCount(numStars: currStarScore)
                        starScoreLbl?.text = "This time:"
                        starScoreLbl?.isHidden = false

                        updateTimerText()
                        // timerLbl.text = String(format: "%.2f/%.2f", currentTime, targetTime)
                        // balloon.radius += 0.3
//                        playBtn.isHidden = false
//                        playBtn.isEnabled = false
                        
                        feedbackLbl.text = "Keep it up!"

                        // playBtn.setTitle("Keep it up!", for: UIControlState())
                    }
                } else if hasNoteStarted {  // Note started, but volume dropped
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
    
    
    func exitWithoutSaveHandler(_ act: UIAlertAction) {
        print("Alert Handler called")
        returnToCallingVC(doSaveScore: false)
    }
    
    func fakeScoreHandler(_ act: UIAlertAction) {
        print("fakeScoreHandler  called")
        bestStarScore = 3
        returnToCallingVC(doSaveScore: true)
    }
    
    func displayNotReallyDoneAlert() {
//        let vc = UIViewController()
//        vc.preferredContentSize = CGSize(width: 300, height: 160)
//        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 300, height: 160))
//        picker.delegate = self
//        picker.dataSource = self
//        vc.view.addSubview(picker)
        
        let ac = UIAlertController(title: "You haven't actually done anything",
                                   message: "\nIf you exit now, no score will be saved",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel",  style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Exit Anyway",
                                   style: .default,
                                   handler: exitWithoutSaveHandler))
        if gMKDebugOpt_ShowFakeScoreInLTAlert {
            ac.addAction(UIAlertAction(title: "(Fake Score)",
                                       style: .default,
                                       handler: fakeScoreHandler))
        }
        ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor

        self.present(ac, animated: true, completion: nil)
        
        print("After alert presenting")
    }
 
    @objc func handleAVAudioInterruption(_ n: Notification) {
        print("In LongTones::handleAVAudioInterruption")
        guard let why = n.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        guard let type = AVAudioSessionInterruptionType(rawValue: why) else { return }
        if type == .began {
            if synth != nil && (synth?.isPlaying)! {
                synth?.reset()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
