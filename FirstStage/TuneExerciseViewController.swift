//
//  TuneExerciseViewController.swift
//  FirstStage
//
//  Created by David S Reich on 14/05/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit

protocol DoneShowingVideo : class {
    func VideoViewClosed()
}


class TuneExerciseViewController: PlaybackInstrumentViewController, SSUTempo, SSNoteHandler,
OverlayViewDelegate,PerfAnalysisSettingsChanged, DoneShowingVideo {

   // @IBOutlet weak var orderStatusNavigationbar: UINavigationBar!
    
    // Invoking VC sets these
    var navBarTitle:String   = ""         // to use as the screen's title
    var exerciseName         = ""         // the XML file to load
    var specifiedMag: Float  = 0          // from TuneMapping json file
    var specifiedNoteWidth:  Int = 0      // from TuneMapping json file
    var specifiedFrameWidth: Int = 0      // from TuneMapping json file
    var isTune               = false
    var exerciseType: ExerciseType = .tuneExer // tune, rhythm party, rhythm prep, etc.
    var exerNumber: Int      = -1
    var secondaryText:String = ""
    var callingVCDelegate: ExerciseResults? = nil

    let testFreqAndPitchSampleSim = PATestFreqAndPitchSampleSim()
    
    var perfStarScore = 0
    var numberOfAttempts = 0

    @IBOutlet weak var panelTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var doneBtn: UIButton!
    @IBAction func doneBtnTapped(_ sender: Any) {
        returnToCallingVC()
    }
    
    func returnToCallingVC() {
        if synth != nil && (synth?.isPlaying)! {
            synth?.reset()
        }
        callingVCDelegate?.setExerciseResults(exerNumber: exerNumber,
                                              exerStatus: kLDEState_Completed,
                                              exerScore:  bestStarScore)
         navigationController?.popViewController(animated: true)
    }

    
    @IBOutlet weak var ssScrollView: SSScrollView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playForMeButton: UIButton!
    @IBOutlet weak var countOffLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var gateView: UIView!
    @IBOutlet weak var metronomeView: VisualMetronomeView!
//    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverSeeScoreBtnView: UIView!
//    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var panelLabel: UILabel!
    @IBOutlet weak var starStackView: UIStackView!
    
    @IBOutlet weak var internalSettingsBtn: UIButton!

    let amplitudeThreshold = UserDefaults.standard.double(forKey: Constants.Settings.AmplitudeThreshold)
    let timingThreshold = UserDefaults.standard.double(forKey: Constants.Settings.TimingThreshold)
    let tempoBPM = UserDefaults.standard.integer(forKey: Constants.Settings.BPM)
    // TRANSHYAR
    let transpositionOffset = UserDefaults.standard.integer(forKey: Constants.Settings.Transposition)
    let frequencyThreshold = UserDefaults.standard.double(forKey: Constants.Settings.FrequencyThreshold)
    var showNoteMarkers = UserDefaults.standard.bool(forKey: Constants.Settings.ShowNoteMarkers)

    var score: SSScore?
    var showingSinglePart = false // is set when a single part is being displayed
    var showingSinglePartIndex: Int32 = 0
    var	showingParts = [NSNumber]()
    var layOptions = SSLayoutOptions()  // set of options for layout
    var playData: SSPData?
    
    var cursorBarIndex = Int32(0)
//    let kDefaultMagnification: Float = 1.5
    let kDefaultMagnification: Float = UserDefaults.standard.float(forKey: Constants.Settings.ScoreMagnification) / 10.0
    var beatsPerBar = 0
    var timeSigBeatType = 4 //  if 2/4, 3/4, 4/4, then 4.   6/8, then 8.  etc.

//    var tickPlayer: AVAudioPlayer?

//    // 3 metronome ticks are currently supported (tickpitch = 0, 1 or 2):
//    //    static const sscore_sy_synthesizedinstrumentinfo kTick1Info = {"Tick1", 0, 1.0};
//    var kTick1Info = sscore_sy_synthesizedinstrumentinfo(instrument_name: ("Tick1" as NSString).utf8String, tickpitch: Int32(0), volume: Float(1.0), voice: sscore_sy_tick1, dummy: (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))

    let perfTrkgMgr: PerformanceTrackingMgr! = PerformanceTrackingMgr.instance

    let kfAnim = CAKeyframeAnimation()
    var exerciseDuration = 0.0
    var animHorzOffset = 0.0
    var animValues = [Double]()
    var animKeyTimes = [Double]()
    var playingAnimation = false

    var analysisTimer: Timer?
    var checkPerfObjsTimer: Timer?
    var startTime : Date = Date()
    var elapsedPlayTime: TimeInterval = 0.0
    var thresholdStartTime = 0.0
    var thresholdEndTime = 0.0
    var frequencyThresholdPercent = Double(0.0)
    var targetPitch = Double(0.0)
    var lowPitchThreshold = Double(0.0)
    var highPitchThreshold = Double(0.0)
    let minPitch = NoteService.getLowestFrequency()
    let maxPitch = NoteService.getHighestFrequency()
    var soundSampleRate = 0.01
    var checkPerfObjsRate = 0.003
    var insideNote = false
    var insideRest = false
    var foundSound = false
    var soundDetectedDuringSession = false
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
    var checkPerfObjsStarted = false
    //used for colored notes
    let kUseColoredNotes = false
    var currentNotes = [AnyObject]()
    
    // Needed by PerformanceTrackingMgr methods
    var songStartTm : Date = Date() {
        didSet {
            PerfTrkMgr.instance.songStartTime = songStartTm
            PerfTrkMgr.instance.songStarted = true
            PerfTrkMgr.instance.repairCurrentSoundIfNeeded()
            soundDetectedDuringSession = false
            if kDoingPitchAmplitudePitchSimTest {
                testFreqAndPitchSampleSim.canBeginTesting = true
                testFreqAndPitchSampleSim.lastSampleIndex = 0
            }
            
//            PerfTrkMgr.instance.signalDetectedDuringPerformance = false
//            PerfTrkMgr.instance.perfLongEnoughToDetectNoSound = false
       }
    }
    var songStartTmOffset : TimeInterval = 0.0 {
        didSet {
            PerformanceTrackingMgr.instance.songStartTimeOffset = songStartTmOffset
            print("\n      ====================================================================")
            print("                                      Song Start")
            print("      ====================================================================\n")
        }
    }
    var shouldSetSongStartTime  = true
    var currNoteXPos: CGFloat = -1.0
    var notInCountdown    = false
    var firstNoteOrRestEventAcknowledged = false // for placing note data on ScrollView
    var firstNoteOrRestXOffset =  0
    // I think the visual metronome is behind. The SeeScore SW lets you specify a
    // negative delay for the beat callback, which lets you anticipate the beat
    // event. This makes the event changing the metronome dotes fire earlier. When
    // I set this to -40ms, I think the metronome is more inline with actual beat
    // of the music. But . . . I want others to try this out.
    // So leaving it at 0.
    // GLOBALITY
    let beatMillisecOffset:Int32 = kMetronomeTimingAdjustment // METROMETRO
    var trackingAudioAndNotes = false

    func xmlFileExistsInInstrumentDir( filename: String ) -> Bool {
        
        if let filePath = Bundle.main.path(forResource: filename,
                                           ofType: "xml") {
            let fm = FileManager.default
            if fm.fileExists(atPath: filePath) {
                return true
            }
        }
        return false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        internalSettingsBtn.isHidden = !gMKDebugOpt_ShowSlidersBtn
        // self.view.backgroundColor = kTuneExer_BackgroundColor
        coverSeeScoreBtnView.backgroundColor = .white
        whichVC = kTuneExerciseVC
        
        // Orientation BS - TuneExeciseVC --> viewDidLoad
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.orientationLock = .landscapeRight
        AppDelegate.AppUtility.lockOrientationToLandscape()
//        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight,
//                                               andRotateTo: UIInterfaceOrientation.landscapeRight)
        
        if exerciseType == .rhythmPartyExer {
            title = "Rhythm Party!"
            infoLabel.text = "Clap the notes"
        } else if exerciseType == .rhythmPrepExer {
            title = "Rhythm Prep"
            infoLabel.text = "Play the notes"
//        } else if exerciseType == .lipSlurExer {
//            title = "Play without tonguing"
//            infoLabel.text = "Play without tonguing"
        } else {
            title = "Tune"
            infoLabel.text = "Play the notes"
        }
        
        panelView.layer.cornerRadius = panelView.frame.height * 0.1
        if #available(iOS 11.0, *) {
            panelView.layer.maskedCorners = [.layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        
        // Do any additional setup after loading the view.
        gateView.isHidden = true
        showingSinglePart = false // is set when a single part is being displayed
        cursorBarIndex = 0

        let instSubpath = getXMLInstrDirString()
        var subpath = "XML Tunes/" + instSubpath + exerciseName
        
        if !xmlFileExistsInInstrumentDir( filename: subpath ) {
            // Then this is probably one of the original Trumpet files, one level up.
            // This is temporary, until all musicXML files have been converted.
            if getCurrentStudentInstrument() == kInst_Trumpet {
                subpath = "XML Tunes/" + exerciseName
            }
        }
        
        loadFile(subpath)
        countOffLabel.text = ""

        frequencyThresholdPercent = 1.0 + frequencyThreshold
//        setupSounds()

        ssScrollView.overlayViewDelegate = self
        setupDebugSettingsBtn()
        if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput {
            printAndTestAnalysisTables()
        }
        
        // This stuff done in storyboard now
        
//        doneBtn.backgroundColor = kDefault_ButtonBckgrndColor
//        doneBtn.layer.cornerRadius = 10
//        doneBtn.clipsToBounds = true
//        let doneBtnAttrStr = createAttributedText(str: "Done", fontSize: 18.0)
//        doneBtn.titleLabel?.attributedText = doneBtnAttrStr // "All Done!"
        
//        playButton.backgroundColor = kDefault_ButtonBckgrndColor
//        playButton.layer.cornerRadius = 10
//        playButton.clipsToBounds = true
//        let playBtnAttrStr = createAttributedText(str: "Start Playing", fontSize: 18.0)
//        playButton.titleLabel?.attributedText = playBtnAttrStr
        
//        playForMeButton.backgroundColor = kDefault_ButtonBckgrndColor
//        playForMeButton.layer.cornerRadius = 10
//        playForMeButton.clipsToBounds = true
//        let playForMeBtnAttrStr = createAttributedText(str: "Play this for me", fontSize: 18.0)
//        playForMeButton.titleLabel?.attributedText = playForMeBtnAttrStr
        
        ssScrollView.contentSize.height = 1.0
        ssScrollView.isScrollEnabled = true

        NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAVAudioInterruption(_:)),
                name: NSNotification.Name.AVAudioSessionInterruption,
                object: self)
        if kDoingPitchAmplitudePitchSimTest {
            testFreqAndPitchSampleSim.SetupLegatoPitchTest1()
        }
        testFreqAndPitchSampleSim.canBeginTesting = false
        testFreqAndPitchSampleSim.lastSampleIndex = 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // VIDREDO
    // byAttackAndDurationRating // for Rhythm Prep
    // byPitchRating
    
    enum sortCriteriaPass {
        case starScoreGrading
        case videoSelection
    }
    
    enum slideDirection {
        case out
        case back
    }
    
    func setAnalysisCriteria( exerType: ExerciseType, forPass: sortCriteriaPass ) {
        if forPass == .starScoreGrading {
            switch exerType {
            case .rhythmPartyExer:
                setPerfIssueSortCriteria( sortCrit: .byAttackRating )
            case .rhythmPrepExer:
                setPerfIssueSortCriteria( sortCrit: .byIndividualRating )
            default:
                setPerfIssueSortCriteria( sortCrit: .byIndividualRating )
            }
        } else { // videoSelection
            switch exerType {
            case .rhythmPartyExer:
                setPerfIssueSortCriteria( sortCrit: .byAttackRating )
            case .rhythmPrepExer:
                setPerfIssueSortCriteria( sortCrit: .byAttackAndDurationRating )
            default:
                setPerfIssueSortCriteria( sortCrit: .byPitchRating )
            }
        }
    }
    
    var starScoreViewIsSetup = false
    var layoutStarScoreForiPad = false
    var starScoreLbl: UILabel? = nil
    let feedbackView = FeedbackView()
    // var starScoreView = StarScore() Replaced by stack view on storyboard
//    func showStarScore() {
//        starScoreView.isHidden = false
//    }
//    func hideStarScore() {
//        starScoreView.isHidden = true
//    }
    
    func animatePanel(direction: slideDirection) {
        
        if direction == .out {
            panelTrailingConstraint.constant = -panelView.frame.width
        } else if direction == .back {
            panelTrailingConstraint.constant = 0
        }
        
        UIView.animate(withDuration: 0.5) {
            self.panelView.superview?.layoutIfNeeded()
        }
        
    }
    
    func setBestStarScore(newScore: Int) {
        var theNewScore = newScore
        if theNewScore < kNoStars {
            theNewScore = kNoStars
        } else if theNewScore > kFourStars {
            theNewScore = kFourStars
        }
        
        if theNewScore > bestStarScore {
            bestStarScore = theNewScore
        }
    }
    var bestStarScore: Int = 0
    var currStarScore: Int = 0
    
    var starScoreMgr = StarScoreMgr()
    
//    func setupStarScoreStuff() {
//
//        let starSz  = StarScore.getSize()
//        let selfFrame = self.view.frame
//        let starX = selfFrame.size.width - (starSz.width + 20)
//
//        var starY =  selfFrame.height - 110 //(starSz.height/2.0)
//        if layoutStarScoreForiPad {
//            let ssFrame = ssScrollView.frame
//            starY = ssFrame.origin.y + ssFrame.size.height + 20
//        }
//
//        starY -= 10
//        let starOrigin = CGPoint(x:starX, y:starY)
//
//        starScoreView.initWithPoint(atPoint: starOrigin)
//        starScoreView.setStarCount(numStars: 3)
//        starScoreView.isHidden = true
//        self.view.addSubview(starScoreView)
//
//        let lblFrame = CGRect(x: 0, y: starY+25, width: 100, height: 30)
//        starScoreLbl = UILabel.init(frame: lblFrame)
//        starScoreLbl?.text = "Best so far:"
//        self.view.addSubview(starScoreLbl!)
//        starScoreLbl?.isHidden = true
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var ssFrame = ssScrollView.frame
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
//            ssFrame.size.height += 100.0
//            ssScrollView.frame = ssFrame
//            metronomeView.frame.origin.y = ssFrame.origin.y + ssFrame.size.height + 10
//            metronomeView.frame.size.width = (metronomeView.frame.size.height*6)
            layoutStarScoreForiPad = true
        } else if UIDevice.current.is_iPhoneX {
//            ssScrollView.frame = ssFrame
//            let leftOffset:  CGFloat = 40.0
//            let rightOffset: CGFloat = 30.0
//            let newWidth: CGFloat = ssScrollView.frame.size.width - (leftOffset+rightOffset)
//            ssScrollView.frame.size.width = newWidth
//            ssScrollView.frame.origin.x  += leftOffset
            ssScrollView.clipsToBounds = true
//            metronomeView.frame.origin.x += leftOffset
        } else {
            // metronomeView.frame.origin.y += 23
            coverSeeScoreBtnView.frame.size.height -= 20
            coverSeeScoreBtnView.frame.origin.y    += 20
            
//            playButton.frame.origin.y += 5
//            playForMeButton.frame.origin.y = playButton.frame.origin.y
        }
         
//        if !starScoreViewIsSetup {
//            setupStarScoreStuff()
//            starScoreViewIsSetup = true
//        }
        setStarScore(score: bestStarScore)
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // return .landscapeRight
        
        // override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientationMask.landscapeRight // .rawValue
    }
    override var shouldAutorotate: Bool {
        return false
    }

    override func viewWillAppear(_ animated: Bool) {
        // Orientation BS - LongToneVC --> viewWillAppear
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.orientationLock = .landscapeRight
        AppDelegate.AppUtility.lockOrientationToLandscape()
//        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight,
//                                               andRotateTo: UIInterfaceOrientation.landscapeRight)

        PerfScoreObjScheduler.instance.setVC(vc:  self)
        
        // VIDREDO
//        setAnalysisCriteria( exerType: self.exerciseType )

        // this one is it:
        // titleLabel.text = navBarTitle
        
        // self.title = "Your Title"
    }

    override func viewWillDisappear(_ animated: Bool) {
        stopPlaying()
        PerfScoreObjScheduler.instance.setVC(vc: nil)
        if vhView != nil {
            vhView?.hideVideoVC()
            vhView?.cleanup()
            if let viewWithTag = self.view.viewWithTag(vhViewTag) {
                viewWithTag.removeFromSuperview()
            }
            vhView = nil
        }
        super.viewWillDisappear(animated)
        
        // Orientation BS - TuneExeciseVC --> viewWillDisappear
        //AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.orientationLock = .landscapeRight
        AppDelegate.AppUtility.lockOrientationToLandscape()
//       AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight,
//                                               andRotateTo: UIInterfaceOrientation.landscapeRight)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//    @IBAction func backBtnPressed(_ sender: Any) {
//        returnToCallingVC()
//    }

    @IBAction func playButtonTapped(_ sender: UIButton) {
        
        animatePanel(direction: .out)
        
        // starScoreView.isHidden = true
        ssScrollView.useSeeScoreCursor(false)
        
        // remove when Video help view is more correct (Modal, etc.) and this
        // is not an issue
        if vhView != nil && !(vhView!.isHidden) {
            vhView?.hideVideoVC()
        }

        playForMeButton.isEnabled = false
        if playButton.currentTitle == "PLAY" {
            
            showAnalysisOverview(doShow: false)
//            AVAudioSessionManager.sharedInstance.setSessionMode(forVideoPlayback: false)
            
//            playButton.setTitle("Stop", forState: UIControlState.Normal)
            playButton.setTitle("Listening...", for: UIControlState())
//            let playBtnAttrStr = createAttributedText(str: "Listening ...", fontSize: 18.0)
//            playButton.titleLabel?.attributedText = playBtnAttrStr

//            playButton.isEnabled = false
            playScore()
            trackingAudioAndNotes = true
            testFreqAndPitchSampleSim.canBeginTesting = false
            testFreqAndPitchSampleSim.lastSampleIndex = 0
        } else if playButton.currentTitle == "Next Exercise" {
            //TODO: goto Next Exercise
            _ = navigationController?.popViewController(animated: true)
            return
        } else {
            playButton.setTitle("Stopping...", for: UIControlState())
//            let playBtnAttrStr = createAttributedText(str: "Stopping ...", fontSize: 18.0)
//            playButton.titleLabel?.attributedText = playBtnAttrStr
            delay(0.1) {
                self.stopPlaying()
            }
        }
    }

    @IBAction func playForMeButtonTapped(_ sender: UIButton) {
        
        // starScoreView.isHidden = true
        ssScrollView.useSeeScoreCursor(true)

        // remove when Video help view is more correct (Modal, etc.) and this
        // is not an issue
        if vhView != nil && !(vhView!.isHidden) {
            vhView?.hideVideoVC()
        }
//        AVAudioSessionManager.sharedInstance.setSessionMode(forVideoPlayback: false)

        playingSynth = true
        
        playForMeButton.isEnabled = false
        playButton.setTitle("PLAYING...", for: UIControlState())
//        let playBtnAttrStr = createAttributedText(str: "Playing ...", fontSize: 18.0)
//        playButton.titleLabel?.attributedText = playBtnAttrStr
        playScore()
    }

    // Have animation parameter in future?
    func setStarScore(score: Int) {
        
        for i in 0..<starStackView.subviews.count {
            
            if let starImageView = starStackView.subviews[i] as? UIImageView {
                
                if i < score {
                    starImageView.alpha = 1
                } else {
                    starImageView.alpha = 0.6
                }
                
            }
            
        }
        
    }
    
    func loadFile(_ scoreFile: String) {
        playButton.setTitle("PLAY", for: UIControlState())
//        let playBtnAttrStr = createAttributedText(str: "Start Playing", fontSize: 18.0)
//        playButton.titleLabel?.attributedText = playBtnAttrStr
//        playButton.isEnabled = true
        playingAnimation = false

        if let filePath = Bundle.main.path(forResource: scoreFile, ofType: "xml") {
            ssScrollView.abortBackgroundProcessing({self.loadTheFile(filePath)})
        } else {
            print("Couldn't make path??? for ", scoreFile)
            return
            //            throw NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: [ NSFilePathErrorKey : fileName ])
        }
    }

    func loadTheFile(_ filePath: String) {
        ssScrollView.clearAll()
        score = nil
        showingParts.removeAll()
        cursorBarIndex = 0
        let loadOptions = SSLoadOptions(key: sscore_libkey)
        loadOptions.checkxml = true

//        let errP = UnsafeMutablePointer<sscore_loaderror>.allocate(capacity: 1)
        var err = SSLoadError()

        
        print("filePath: \(filePath)")
        print("loadOptions: \(String(describing: loadOptions))")
//        print("errP: \(errP)")

        // Part of first pass, trying things out. Might not keep this approach.
        var instrMods = MusicXMLInstrumentModifiers()
        instrMods.setForTrombone()
        //instrMods.setForTrumpet()

        // SCORESIZE
        var widthToUse = UserDefaults.standard.double(forKey: Constants.Settings.SmallestNoteWidth)
        if specifiedNoteWidth != 0 {
            widthToUse = 25
        }
        
        let sigWidth = UserDefaults.standard.double(forKey: Constants.Settings.SignatureWidth)
        guard let xmlData = MusicXMLModifier.modifyXMLToData(
                musicXMLUrl: URL(fileURLWithPath: filePath),
                smallestWidth: widthToUse,
                signatureWidth: sigWidth,
                InstrMods: instrMods) else {
            print("Cannot get modified xmlData from \(filePath)!")
            return
        }

        if let score0 = SSScore(xmlData: xmlData, options: loadOptions, error: &err) {
            score = score0
            guard score != nil else {
                itsBad()
                return
            }
 
/*
            // TRANSPOSEHERE
            var currTrans = score?.transpose()
            let currInst = getCurrentStudentInstrument()
            let transAmt = getSSTransposeForInstr(instr: currInst)
            let serr = score?.setTranspose(transAmt)
            if alwaysFalseToSuppressWarn() { print("\(String(describing: serr))") }
            currTrans = score?.transpose()
*/
//            var serr = score?.setTranspose(24)
//            if alwaysFalseToSuppressWarn() { print("\(String(describing: serr))") }
  //          let serr = score?.setTranspose(-14)
//            if alwaysFalseToSuppressWarn() { print("\(String(describing: serr))") }
            
            //				titleLabel.text = [filePath lastPathComponent];
            let numParts = score!.numParts
            for _ in 0..<numParts {
                showingParts.append(NSNumber(value: true as Bool)) // display all parts
            }

            showingSinglePart = false;
            layOptions.hidePartNames = true
            layOptions.hideBarNumbers = true

            if true {
                layOptions.ignoreXMLPositions = false
                layOptions.useXMLxLayout = true
                ssScrollView.optimalXMLxLayoutMagnification = true
                ssScrollView.forLongToneView = false
//            } else {
//                ssScrollView.optimalSingleSystem = true
            }

            var kMag: Float = kDefaultMagnification
            if specifiedMag != 0.0 {
                kMag = specifiedMag
            }
            
            if specifiedFrameWidth != 0 {
                ssScrollView.setSpecifiedFrameWidth(Int32(specifiedFrameWidth))
            }
            
            ssScrollView.clearScoreIsSetup()
            ssScrollView.setupScore( score!,   openParts: showingParts,   mag: kMag,
                                     opt: layOptions,    completion: getPlayData )
        }

        if err.err != sscore_NoError {
            itsBad() // so can set a breakpoint
            switch (err.err) {
            case sscore_OutOfMemoryError:	print("out of memory")

            case sscore_XMLValidationError: print("XML validation error line:" + String(err.line) + " col:" + String(err.col) + " " + err.text)

            case sscore_NoBarsInFileError:	print("No bars in file error")
            case sscore_NoPartsError:		print("NoParts Error")

            case sscore_UnknownError:		print("Unknown error")

            default: break
            }

            if !err.warnings.isEmpty {
                print("MusicXML consistency warnings:")
                for warning in err.warnings {
                    print(warning.toString)
                }
            }
        }
    }

    func playScore() {
        kMKDebugOpt_PrintMinimalNoteAnalysis = false
        if playingSynth {
            if isTune {
                infoLabel.text = "Listen - and play the notes"
            } else {
                infoLabel.text = "Listen - and clap at the beginning of each note and count the beats"
            }
        } else if isTune {
            infoLabel.text = "Play the notes"
        } else {
            infoLabel.text = "Clap at the beginning of each note and count the beats"
        }

        ssScrollView.contentOffset = CGPoint.zero // CGPoint(x:0.0, y:-5.0) //  HEY !!!
        ssScrollView.isScrollEnabled = false
        playingAnimation = false
        countOffLabel.isHidden = true;
        metronomeOn = true

        noteResultValues.removeAll()

        notInCountdown = false
        firstNoteOrRestEventAcknowledged = false
        PerformanceTrackingMgr.instance.resetSoundAndNoteTracking()
        ssScrollView.clearNotePerformanceResults();
        ssScrollView.turnHighlightOff()

        guard score != nil else { return }
        
        // TRANSPOSEHERE
        // TRANTRANTRAN  transpose here     - see SSScore.h
//        let serr = score?.setTranspose(-2)
        
        playData = SSPData.createPlay(from: score!, tempo: self)
        guard playData != nil else { return }

        let beatsPerBar = score!.getBarBeats( 0,  bpm: Int32(tempoBPM),
                                              barType: sscore_bartype_full_bar)
        let numBeatInBar = Int(beatsPerBar.beatsinbar)
        let oneBeatLen   = Int(beatsPerBar.beattime)
        let oneBarLen    = numBeatInBar * oneBeatLen

        print("\n   Used to set playback vals: numBeatInBar = \(numBeatInBar),  oneBeatLen = \(oneBeatLen)")
        PerformanceTrackingMgr.instance.setPlaybackVals(
                                    tempoInBPM:  tempoBPM,
                                    beatsPerBar: numBeatInBar,
                                    lenOneBeat:  oneBeatLen,
                                    lenOneBar:   oneBarLen )
        print("      currTempoBPM:        \(PerfTrkMgr.instance.currTempoBPM)")
        print("      currBeatsPerBar:     \(PerfTrkMgr.instance.currBeatsPerBar)")
        print("      currOneBarLen:       \(PerfTrkMgr.instance.currOneBarLen)")
        print("      qtrNoteTimeInterval: \(PerfTrkMgr.instance.qtrNoteTimeInterval)")

        ssScrollView.clearAllColouring()

        if synth != nil && (synth?.isPlaying)! {
            synth?.reset()
        } else {
            if synth == nil {
                
                // Build Instrument   BINSTHERE
                
                if let synth0 = SSSynth.createSynth(self, score: score!) {
                    synth = synth0
/*
 old
                     instrumentId.removeAll()

                    instrumentId.append((synth?.addSampledInstrument(pianoSampleInfo))!)
//                    instrumentId.append((synth?.addSampledInstrument(trumpetSampleInfo))!)

                    metronomeInstrumentId = (synth?.addSynthesizedInstrument(&kTick1Info))!
 */
                    ////new:
                    sampledInstrumentIds.removeAll()
                    synthesizedInstrumentIds.removeAll()
                    metronomeInstrumentIds.removeAll()
                    assert(kSampledInstrumentsInfo.count + kSynthesizedInstrumentsInfo.count < TuneExerciseViewController.kMaxInstruments)
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
            }

            guard synth != nil else {
                print("No licence for synth");
                return
            }

            // start playing if not playing  SFAUDIO
            var sessionMode: AudioSessMode  = .usingMicMode
//            var forVidPlayback = false
            if playingSynth {   // actually playing the tune, to be heard
                sessionMode = .playbackMode
//                forVidPlayback = true
            }
            
            //sessionMode = .usingMicMode // .playbackMode
            if AVAudioSessionManager.sharedInstance.setupAudioSession(sessionMode: sessionMode) {
//                if !playingSynth {
//                    _ = AVAudioSessionManager.sharedInstance.extraSetupForCountdown(turnSpeakerOn: true)
//                }
//
//                 AVAudioSessionManager.sharedInstance.setSessionMode(forVideoPlayback:forVidPlayback)
                
                print("\n\n\n==========================================================")
                print("==========================================================")
                print("==========================================================")
                print("==========================================================")
                print("==========================================================")
                print("\n\n              New Exercise . . . \n\n")
                print("==========================================================")
                print("==========================================================")
                print("==========================================================")
                print("==========================================================")
                print("==========================================================\n\n")
                
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

                showNoteMarkers = true // added this 8/2018

                if showNoteMarkers {
                    let cursorAnimationTime = CATransaction.animationDuration()
                    cursorAnimationTime_ms = Int32(cursorAnimationTime * 1000)
                    //cursorAnimationTime_ms = Int32(0.05 * 1000) // added this 8/2018
                }

                synth?.setNoteHandler(self, delay: -cursorAnimationTime_ms)

                //                synth?.setBarChangeHandler(BarChangeHandler(vc: self), delay: -cursorAnimationTime_ms)
                //                synth?.setBarChangeHandler(BarChangeHandler(vc: self, anim: anim), delay: 0)
                synth?.setEnd(EndHandler(vc: self), delay: 0)
                synth?.setBeat(BeatHandler(vc: self), delay: beatMillisecOffset) // METROMETRO

                var err = synth?.setup(playData!)
                if err == sscore_NoError {
                    let delayInSeconds = 3.0 // 9/29/18 SCF tried this, hoping reason 6/8 not working . . .
                    let startTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(delayInSeconds * 1000.0))
//                    let startTime = DispatchTime.now() + Double(Int64(delayInSeconds * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
                    err = synth?.start(at: startTime.rawValue, bar: cursorBarIndex, countIn: true)

                }

                print("synth.start err == \(String(describing: err))")
//                if err == sscore_UnlicensedFunctionError {
//                    print("synth license expired!")
//                } else if err != sscore_NoError {
//                    print("synth failed to start: \(String(describing: err))")
//                }
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
        
        // info I want to quickly see during debug sessions.
        // also, need to suppress "unused vars" warnings, below
        let ssFrm = ssScrollView.frame()
        let ssWd = ssFrm.size.width
        let ssHt = ssFrm.size.height
        let ht2 = ssHt
        if alwaysFalseToSuppressWarn() { print("\(ssFrm), \(ssWd), \(ssHt), \(ht2)") }
    }

    func stopPlaying() {
        // info I want to quickly see during debug sessions.
        // also, need to suppress "unused vars" warnings, below
        let ssFrm = ssScrollView.frame()
        let ssWd = ssFrm.size.width
        let ssHt = ssFrm.size.height
        if alwaysFalseToSuppressWarn() { print("\(ssWd), \(ssHt)") }

        clearCurrNoteLines()
        ssScrollView.isScrollEnabled = true

        elapsedPlayTime = Date().timeIntervalSince(songStartTm)

        let doPostPerfAnalysis = !playingSynth && trackingAudioAndNotes
        playingSynth = false
        trackingAudioAndNotes = false
        shouldSetSongStartTime  = true
        //        AudioKitManager.sharedInstance.stop()   // 9/7 SCF moved to below
//        AudioKitManager.sharedInstance.stop()   // 9/7 SCF moved to below

        
        stopCheckPerfObjsTimer()
        metronomeView.setBeat(-1)
        stopAnalysisTimer()
        PerformanceTrackingMgr.instance.songStarted = false
        
        gateView.isHidden = true

        if (synth != nil && synth!.isPlaying)
        {
            synth?.reset()
            countOffLabel.isHidden = true;
        }
        sleep(1)
 //        AudioKitManager.sharedInstance.stopMicTracker()

        // AudioKitManager.sharedInstance.stop() //  9/7 SCF moved to here

        if playingAnimation {
            playingAnimation = false
            ssScrollView.layer.removeAnimation(forKey: "move")
        }
        
        animatePanel(direction: .back)

        playButton.setTitle("PLAY", for: UIControlState())
//        let playBtnAttrStr = createAttributedText(str: "Start Playing", fontSize: 18.0)
//        playButton.titleLabel?.attributedText = playBtnAttrStr
//        playButton.setTitle("Next Exercise", for: UIControlState())
//        playButton.isEnabled = true
        playForMeButton.isEnabled = true
        ssScrollView.hideCursor()
        ssScrollView.isScrollEnabled = true

//        feedbackView.setupFeedbackView(self)
//        var feedbackRect = self.view.frame.insetBy(dx: 100, dy: 100)    //make it small so we can see analysis results.
//        feedbackRect.origin.y = feedbackRect.origin.y + 20
//        feedbackView.contentMode = .scaleAspectFit
//        feedbackView.showFeedback(feedbackRect)

        // uncomment to quickly see/test Monkey animation, as if perfect performance
        // animateMonkeyImageView();   return  // won't do doPostPerfAnalysis

        if doPostPerfAnalysis {
            kMKDebugOpt_PrintMinimalNoteAnalysis = true
            performPostPerfAnalysis()
        }
        ssScrollView.isScrollEnabled = true
    }

    func performPostPerfAnalysis()
    {
        PerfTrkMgr.instance.signalDetectedDuringPerformance =
                                                soundDetectedDuringSession
        // PerfTrkMgr.instance.perfLongEnoughToDetectNoSound = ??

        // VIDREDO
        setAnalysisCriteria( exerType: self.exerciseType, forPass: .starScoreGrading )
        PerformanceTrackingMgr.instance.analyzePerformance()
        if soundDetectedDuringSession || !PerfTrkMgr.instance.doDetectedDuringPerformance {
        
            printPostPerfDebugData(timingThreshold: timingThreshold)

            // Send PerfNote info to SeeScore overlay view - needed by a subview to
            // determine location of highlighted note, if called on to highlight.
            for onePerfScoreObj in PerformanceTrackingMgr.instance.perfNotesAndRests {
                if onePerfScoreObj.isNote() {
                    guard let onePerfNote = onePerfScoreObj as? PerformanceNote else {continue }
                    
                    let weightedAsInt32 : Int32 = Int32(onePerfNote.weightedScore)
                    let xPos = CGFloat(onePerfNote.xPos)
                    let yPos = CGFloat(onePerfNote.yPos)
                    self.ssScrollView.addScoreObjectPerformanceResult(
                        atXPos: xPos,
                        atYpos: yPos,
                        withWeightedRating: weightedAsInt32,
                        isNote: true,
                        withNoteOrRestID: onePerfNote.perfNoteOrRestID,
                        scoreObjectID:  onePerfNote.perfScoreObjectID,
                        isLinked: onePerfNote.isLinkedToSound,
                        linkedSoundID: onePerfNote.linkedToSoundID )
                } else {
                    guard let onePerfRest = onePerfScoreObj as? PerformanceRest else {continue }
                    
                    let weightedAsInt32 : Int32 = Int32(onePerfRest.weightedScore)
                    let xPos = CGFloat(onePerfRest.xPos)
                    let yPos = CGFloat(onePerfRest.yPos)
                    self.ssScrollView.addScoreObjectPerformanceResult(
                        atXPos: xPos,
                        atYpos: yPos,
                        withWeightedRating: weightedAsInt32,
                        isNote: false,    // Is Note RESTCHANGE
                        withNoteOrRestID: onePerfRest.perfNoteOrRestID,
                        scoreObjectID:  onePerfRest.perfScoreObjectID,
                        isLinked: onePerfRest.isLinkedToSound,
                        linkedSoundID: onePerfRest.linkedToSoundID )
                }
            }

            // Send PerfSound info to SeeScore overlay view (only needed for debugging)
            if FSAnalysisOverlayView.getShowSoundsAnalysis() {
                for onePerfSound in PerformanceTrackingMgr.instance.performanceSounds {
                    guard let onePerfSound = onePerfSound else { continue }
                    var dur: Int32 = Int32(onePerfSound.xOffsetEnd - onePerfSound.xOffsetStart)
                    if dur <= 0 {
                        dur = 1
                    }
                    self.ssScrollView.addSoundPerformanceResult(
                        atXPos:       CGFloat(onePerfSound.xOffsetStart),
                        withDuration: dur,
                        soundID:      onePerfSound.soundID,
                        isLinked:     onePerfSound.isLinkedToNote,
                        linkedNoteID: onePerfSound.linkedToNote )
                }
            }
        }
        
        // STARSTARSTAR
        let worstScore = PerformanceIssueMgr.instance.worstScore()
        let avgOverallScore =
            PerformanceIssueMgr.instance.averageScore(justForNotes: false)
        let avgNotesScore =
            PerformanceIssueMgr.instance.averageScore(justForNotes: true)
        perfStarScore =
            PerformanceIssueMgr.instance.getStarScoreForMostRecentPerformance()
        
        print("\n-------------------------------------------------")
        print("  Worst Score:                \(worstScore)")
        print("  Average Score (just Notes): \(avgNotesScore)")
        print("  Average Score (with Rests): \(avgOverallScore)")
        print("  Star Score:                 \(perfStarScore) Stars")
        print("-------------------------------------------------\n")

        /* delme
        setBestStarScore(newScore: perfStarScore)
        //bestStarScore = 3
        starScoreMgr.scoreForPortionCompleted = bestStarScore
        starScoreMgr.furthestThroughSong = elapsedPlayTime
        starScoreMgr.songLength = exerciseDuration
        let calcedStarScore = starScoreMgr.calculatedScore
        // starScoreView.setStarCount(numStars: perfStarScore)
        starScoreView.setStarCount(numStars: calcedStarScore)
        starScoreView.isHidden = false
        */
        
        // Take the performance score, and use the percentage of the
        // score that was completed to get the score to assign
        starScoreMgr.scoreForPortionCompleted   = perfStarScore
        starScoreMgr.songLength                 = exerciseDuration
        starScoreMgr.furthestThroughSong        = elapsedPlayTime
        let calcedStarScore = starScoreMgr.calculatedScore
        setBestStarScore(newScore: calcedStarScore)
        setStarScore(score: bestStarScore)
//        starScoreView.setStarCount(numStars: bestStarScore)
//        starScoreView.isHidden = false
        
        if  gMKDebugOpt_ShowDebugSettingsBtn {
            let titleStr = "Note Attack Summary\n('-' is early; otherwise late)"
            
            let minDiffStr = String(format: "%.4f", gLastRunMinAttackDiff)
            let maxDiffStr = String(format: "%.4f", gLastRunMaxAttackDiff)
            let avgDiffStr = String(format: "%.4f", gLastRunAvgAttackDiff)

            var msgStr = "\nAVERAGE Difference: \t"
            msgStr += avgDiffStr
            msgStr += ("\n\n")
            
            msgStr += "Smallest Difference: \t"
            msgStr += minDiffStr
            msgStr += ("\n")
            
            msgStr += "Largest Difference: \t"
            msgStr += maxDiffStr
            
            msgStr += "\n\n------------------------\n"

            let runningAvgDiffStr = String(format: "%.3f", gRunningAvgAttackDiff)
            msgStr += "Running Average Diff: \t"
            msgStr += runningAvgDiffStr

            
            // START_TIME_CHANGE
//            msgStr += "\n\n--- (Non-Compensated) ---\n"
//
//            let minNonCompDiffStr = String(format: "%.3f", gLastRunMinAttackDiff-kSoundStartAdjustment)
//            let maxNonCompDiffStr = String(format: "%.3f", gLastRunMaxAttackDiff-kSoundStartAdjustment)
//            let avgNonCompDiffStr = String(format: "%.3f", gLastRunAvgAttackDiff-kSoundStartAdjustment)
//
//            msgStr += "\nAVERAGE Difference: \t"
//            msgStr += avgNonCompDiffStr
//            msgStr += ("\n\n")
//
//            msgStr += "Smallest Difference: \t"
//            msgStr += minNonCompDiffStr
//            msgStr += ("\n")
//
//            msgStr += "Largest Difference: \t"
//            msgStr += maxNonCompDiffStr
            
            let ac = MyUIAlertController(title: titleStr,
                                         message: msgStr,
                                         preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK",
                                       style: .default,
                                       handler: nil))
            ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor
            self.present(ac, animated: true, completion: nil)
        }
        
        
        // VIDREDO - Redo Performance criteria here?
        setAnalysisCriteria( exerType: self.exerciseType, forPass: .videoSelection )

        PerformanceTrackingMgr.instance.analyzePerformance()
 
        // delme
//        var doTestVideos = true
//        var videoTestCode = vidIDs.kVid_NoVideoAvailable
        
        // Reacting to worst issue must be delayed slightly
        if soundDetectedDuringSession || !PerfTrkMgr.instance.doDetectedDuringPerformance {
            delay(0.1) {
                let worstPerfIssue = PerformanceIssueMgr.instance.getFirstPerfIssue()
    // delme            if doTestVideos && worstPerfIssue != nil {
    //                worstPerfIssue!.videoID = vidIDs.kVid_Duration_TooShort
    //                //self.testVideoMappsings(perfIssue: worstPerfIssue)
    //            }
                if worstPerfIssue != nil {
                    if (worstPerfIssue?.issueScore)! >= kLaunchVideoThreshold {
                        
                        let issScore = worstPerfIssue!.issueScore
                        let severity =
                            PerformanceIssueMgr.instance.getSeverity(issueScore: issScore)
                        let perfNoteID:Int32 = worstPerfIssue!.perfScoreObjectID
        //                worstPerfIssue!.videoID  = vidIDs.kVid_Pitch_VeryLow_SpeedUpAir // YYYYYOOOOO
                        if worstPerfIssue!.videoID != vidIDs.kVid_NoVideoAvailable {
                            self.scrollToNoteAndLaunchVideo(perfNoteID: perfNoteID,
                                                            videoID: worstPerfIssue!.videoID,
                                                            severity: severity)
                        }
                        else if worstPerfIssue!.alertID != alertIDs.kAlt_NoAlertMsgAvailable {
                            self.scrollToNoteAndLaunchAlert(perfNoteID: perfNoteID,
                                                            alertID: worstPerfIssue!.alertID,
                                                            severity: severity)
                        }
                    }
                }
            }
        }
    }

    // var videoCode = vidIDs.kVid_Attack_Early_WaitABit
//    func testVideoMappsings(perfIssue: PerfIssue?) {
//        guard perfIssue != nil else { return }
//
//        var severity = 0
//        perfIssue!.videoID = vidIDs.kVid_Attack_Early_WaitABit
//        while perfIssue!.videoID <= vidIDs.kVid_Pitch_VeryHigh_DoubleCheckFingering {
//            self.scrollToNoteAndLaunchVideo(perfNoteID: perfIssue!.perfScoreObjectID,
//                                            videoID:    perfIssue!.videoID,
//                                            severity:   severity)
//            perfIssue!.videoID += 1
//        }
//    }
    
    
    
    func adjustMetronomeLeftEdge() {
        
        return;
            
//        metronomeView.frame.origin.x = 10
//
//        if UIDevice.current.is_iPhoneX {
//            let leftOffset:  CGFloat = 40.0
//            metronomeView.frame.origin.x += leftOffset
//        }
    }
    
    
    //build arrays for CAKeyframeAnimation of UIScrollView (base class of SSScrollView)
    //maybe also collect breath marks?
    func getPlayData() {
        guard score != nil else { return }

        DispatchQueue.main.async(execute: {
//
//            let numBeats1 = self.score?.actualBeats(forBar: 1)
//            let timeSig1  = self.score?.timeSig(forBar: 1)
//
//            let numBeats3 = self.score?.actualBeats(forBar: 3)
//            let timeSig3  = self.score?.timeSig(forBar: 3)
            
            // if let numBeats = self.score?.actualBeats(forBar: 1) {
            if let timeSig  = self.score?.timeSig(forBar: 1) {
                self.beatsPerBar = Int(timeSig.numbeats)
                self.timeSigBeatType = Int(timeSig.beattype)
                
//                self.metronomeView.numBeats = Int(numBeats.numbeats)
                //self.metronomeView.numBeats = self.beatsPerBar
                //self.metronomeView.rebuildMetronome()
                self.metronomeView.setNumBeats(numberBeats: self.beatsPerBar)
                self.adjustMetronomeLeftEdge()
            }
        });

        playData = SSPData.createPlay(from: score!, tempo: self)
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

//        let kBeginningPause_ms = Int(bar.duration_ms)
//        exerciseDuration_ms += kBeginningPause_ms
        exerciseDuration = Double(exerciseDuration_ms) / 1000.0

        var exerciseDurationWithPause_ms = 0
        var exerciseDurationWithPause: Double = 0.0
        for bar in (playData?.bars)! {
            // SCF - look to this area for smoothing out scrolling. Perhaps
            // using bar start only ?


            
            //we just have one part
            let part = bar.part(0)
            //for note in (part?.notes)! {
            for note in (part.notes) {
//                let graceNote = (note.grace == sscore_pd_grace_no) ? "note" : "grace"
                //                print("part 0 \(graceNote) pitch:\(note.midiPitch) startbar:\(note.startBarIndex) start:\(note.start)ms duration:\(note.duration)ms at x=\(noteXPos(note))")

                let startFromBarBeginning = note.start // start offset within current measure
                if startFromBarBeginning != 0 {
                    continue // comment this line out to see per-note scrolling
                    // Doing this creates animation "points" only for the first
                    // element - note or rest - in the measure and ignores all
                    // others. (Previously, animation points were added for each
                    // individual note/rest.)
                    // This creates a smoother scrolling animation. While there
                    // is some variation between the lengths of measures, there
                    // can be a lot of difference between the distance between
                    // notes in a single measure and distance between the last
                    // note of one measure and the first of the next. This was
                    // the source of uneven scrolling.
                }

                thisNoteXPos = Double(noteXPos(note))

                if firstNote {
                    animHorzOffset = thisNoteXPos
                    print("animHorxOffset= \(animHorzOffset)")
                    firstNote = false

                    // attempt to pause the animation at the beginning, so the cursor
                    // moves more to the right (more or the left remains visible for longer)
                    let kBeginningPause_ms = Int(2*bar.duration_ms)
                    exerciseDurationWithPause_ms = exerciseDuration_ms + kBeginningPause_ms
                    //exerciseDuration_ms += kBeginningPause_ms
                    exerciseDurationWithPause = round(Double(exerciseDurationWithPause_ms) / 1000)

                    animValues.append(thisNoteXPos - animHorzOffset)
                    //animKeyTimes.append(Double(kBeginningPause_ms))
                    
                    animKeyTimes.append( Double(kBeginningPause_ms + Int(note.start)) / Double(exerciseDurationWithPause_ms) )
                    barsDuration_ms += Int(bar.duration_ms)
                }

                // Exclude the second note of a cross-bar tied note pair, which has a negative
                // start-from-bar-start time (i.e., previous measure). All data needed for animation
                // is in the first note of pair - including duration of combined 1st & 2nd notes.
                if startFromBarBeginning >= 0 {
                    animValues.append(thisNoteXPos - animHorzOffset)
                    animKeyTimes.append(Double(barsDuration_ms + Int(note.start)) / Double(exerciseDurationWithPause_ms))
                }
            }

            barsDuration_ms += Int(bar.duration_ms)
        }

        //move to end of last bar
        animValues.append(Double(ssScrollView.frame.width))
        animKeyTimes.append(1.0)


        kfAnim.keyPath = "bounds.origin.x"
        //        kfAnim.keyPath = "position.x"
        kfAnim.values = animValues
        kfAnim.keyTimes = animKeyTimes as [NSNumber]?
        kfAnim.duration = exerciseDurationWithPause     
        kfAnim.isAdditive = true
    }

    // MARK: Analysis

    // Support for PerfScoreObjScheduler.
    //   The timer that drives it all is is managed here.
    
    func startCheckPerfObjsTimer() {
        //don't start twice
        guard !checkPerfObjsStarted else { return }
        checkPerfObjsStarted = true
        
        checkPerfObjsTimer = Timer.scheduledTimer(timeInterval: checkPerfObjsRate, target: self, selector: #selector(TuneExerciseViewController.checkPerfObjectsForTransitions), userInfo: nil, repeats: true)
    }
    
    @objc func checkPerfObjectsForTransitions() {
        PerfScoreObjScheduler.instance.inspectPerfScoreObjectsForTransitions()
    }
    
    func stopCheckPerfObjsTimer() {
        //don't stop twice
        guard checkPerfObjsStarted else { return }
        checkPerfObjsStarted = false
        
        if checkPerfObjsTimer != nil {
            checkPerfObjsTimer?.invalidate()
            checkPerfObjsTimer = nil;
        }
        
        PerfScoreObjScheduler.instance.clearEntries()
    }
    
    
    func startAnalysisTimer() {
        //don't start twice
        guard !analysisStarted else { return }
        analysisStarted = true

        startTime = Date()

        // 9-17-18  commented this out, after getting things working, but
        // having the glitch issue in countdown.
//        DispatchQueue.global(qos: .userInitiated).async {
//            _ = AVAudioSessionManager.sharedInstance.setupAudioSession(sessionMode: .usingMicMode)
//        }
        
        // AudioKitManager.sharedInstance.startMicTracker()
        //AudioKitManager.sharedInstance.start(forRecordToo:false) // SFAUDIO
        print("starting analysis timer")
        analysisTimer = Timer.scheduledTimer(timeInterval: soundSampleRate, target: self, selector: #selector(TuneExerciseViewController.analyzePerformance), userInfo: nil, repeats: true)
    }

    func stopAnalysisTimer() {
        //don't stop twice
        guard analysisStarted else { return }
        analysisStarted = false

        if analysisTimer != nil {
            analysisTimer?.invalidate()
            analysisTimer = nil;
        }

 //       AudioKitManager.sharedInstance.stopMicTracker()
 //       AudioKitManager.sharedInstance.stop()  // SFAUDIO
    }

    //////////////////////////////////////////////////////////////////////////////
    //     TODO: Ultimately want to move this func out (or most of it) to
    //        PerformanceTrackingMgr, but currently this func uses too many vars
    //        local to this VC to make this a quick task. Will try again at a
    //        later date.
    //
    //        The main issue is the use of the existing timer and vars set up for
    //        the preliminary rhythm and pitch analysis by another dev. If we
    //        commit to using the newer code and none of the old, this will not
    //        be that hard.
    //
    func trackSounds() {

        guard perfTrkgMgr != nil else { return }

        // Do one of:
        // 1) If there is a signal and exsiting Sound, update it.
        //   Edge case: playing legato, and changing from one note to another.
        //              There will be an existing Sound, so need to detect change
        //              in pitch, and stop the current sound and start a new one.
        // 2) Detect the start of a Sound, or
        // 3) Detect the the end of a Sound
        // (4 - no signal and no existing Sound, then do nothing)

        // SFAUDIO
        var currAmpltd = 0.0
        var currFreq   = 0.0
        
        
        let lastTestSampleIdx = testFreqAndPitchSampleSim.lastSampleIndex
        if kDoingPitchAmplitudePitchSimTest &&
           testFreqAndPitchSampleSim.canBeginTesting &&
           lastTestSampleIdx < testFreqAndPitchSampleSim.numSamples() {
            currAmpltd = testFreqAndPitchSampleSim.amplitudeSamples[lastTestSampleIdx]
            currFreq   = testFreqAndPitchSampleSim.getPitchAt(index: lastTestSampleIdx)
            testFreqAndPitchSampleSim.lastSampleIndex += 1
        } else { // get actual live sample and pitch data
            if AudioKitManager.sharedInstance.amplitudeTracker != nil {
                currAmpltd = AudioKitManager.sharedInstance.amplitudeTracker.amplitude
            }
            if AudioKitManager.sharedInstance.frequencyTracker != nil {
                ///   AMPLEAMPLE
                //currAmpltd = AudioKitManager.sharedInstance.frequencyTracker.amplitude
    //            print("&&&&&& Amp = \(currAmpltd)")
                currFreq = AudioKitManager.sharedInstance.frequencyTracker.frequency
            }
            
     //       let currAmpltd = AudioKitManager.sharedInstance.frequencyTracker.amplitude
        }
        let signalDetected : Bool = currAmpltd > kAmplitudeThresholdForIsSound
        if signalDetected {
            soundDetectedDuringSession = true
        }

 //       let currFreq = AudioKitManager.sharedInstance.frequencyTracker.frequency
        let timeSinceAnalysisStart : TimeInterval = Date().timeIntervalSince(startTime)
        let timeSinceSongStart =
            timeSinceAnalysisStart - PerformanceTrackingMgr.instance.songStartTimeOffset
        let timeSinceSSComp = timeSinceSongStart - kSoundStartAdjustment // START_TIME_CHANGE

        printAmplitude(currAmp: currAmpltd, at: timeSinceSongStart, atComp: timeSinceSSComp)

        //       print("\n    In TuneExer::trackSounds, currAmpltd == \(currAmpltd)\n")
        if kDoPrintFrequency {
            print("    In TuneExer::trackSounds, currFreq == \(currFreq)")
        }
        
        if signalDetected && PerformanceTrackingMgr.instance.currentlyTrackingSound {
            // Currently tracking a sound; update it

            guard let currSound : PerformanceSound = perfTrkgMgr.currentSound else { return }

            perfTrkgMgr.addAmplitudeValue(ampVal: currAmpltd, absTime: timeSinceAnalysisStart)
            
            if !currSound.initialPitchHasStablized() { // Not enough samples yet
                currSound.addPitchSample(pitchSample: currFreq) // Just update, no qualifying

            } else { // sound with stable pitch exists
                var soundStopped = false
                if perfTrkgMgr.currentSoundWillEnd() { // one way or the other
                    printSoundRelatedMsg(msg: "   !!   Sound finished at: \(timeSinceSongStart)   !!")
                    if perfTrkgMgr.currentSoundFinished() &&
                       perfTrkgMgr.isANewNoteBCofAmpChange() {
                        let soundStartTIme = perfTrkgMgr.absTimeForNewSound
                        print("\n")
                        printSoundRelatedMsg(msg: " !!   Stopping Sound, creating new bc of amplitude drop at: \(timeSinceSongStart)   !!\n")
                        stopCurrentSound( soundEndTime: soundStartTIme )
                    }
                    soundStopped = true
                    
//                } else
//
//               // First, test for new note either bc of amp or pitch change
//                let isNewNote_Amp = currSound.isANewNoteBCofAmpChange()
//                if isNewNote_Amp { blar
//                    print ("\n   !!   New Note bc of amplitude drop   !!\n")
                }
                
                // Not a new note bc of Amp change (if soundStopped remains false).
                // Check for a new note because of a pitch change during legato playing.
                if !soundStopped && gScanForPitchDuringLegatoPlaying {
                    let oldFreq = currSound.averagePitchRunning
                    if areDifferentNotes( pitch1: oldFreq, pitch2: currFreq ) {
                        // The student could be playing legato, transitioning to diff note.
                        // Need multiple samples to determine this. Add this diff pitch, then
                        // test to see if that crossed threshold to determine for sure.
                        currSound.addDifferentPitchSample(sample: currFreq,
                                                          sampleTime: timeSinceAnalysisStart)
                        if currSound.isDefinitelyADifferentNote() { // last sample decided it
                            // Stop this sound

                            if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput  ||
                               kMKDebugOpt_PrintMinimalNoteAndSoundResults     {
                                  print("\n")
                                  printSoundRelatedMsg(msg: "  !!  Stopping current sound (due to legato split) at \(timeSinceSongStart)")
                            }
                            perfTrkgMgr.updateCurrentNoteIfLinked()

                            // get the x-coord of the spot where a sound should be
                            // drawn on the scroll view - for debugging
                            var currXOffset = Int(ssScrollView.getCurrentXOffset())
                            currXOffset -= kOverlayPixelAdjustment
                            if let currSound = perfTrkgMgr.currentSound {
                                currSound.xOffsetEnd = firstNoteOrRestXOffset + currXOffset
                            }

                            currSound.stoppedBecauseOfLegatoPitchChange = true
                            var splitTime: TimeInterval = 0.0
                            perfTrkgMgr.endCurrSoundAsNewPitchDetected(
                                noteOffset: perfTrkgMgr.songStartTimeOffset,
                                splitTime: &splitTime )

                            // Create a new sound.
                            let soundMode : soundType = isTune ? .pitched : .percusive
                            perfTrkgMgr.startTrackingPerformanceSound(
                                startAt: splitTime,
                                soundMode: soundMode,
                                noteOffset: perfTrkgMgr.songStartTimeOffset )

                            if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput ||
                               kMKDebugOpt_PrintMinimalNoteAndSoundResults     { // first half
                                let startABSStr     = String(format: "%.3f", currSound.startTime_abs)
                                let startSongStr     = String(format: "%.3f", currSound.startTime_song)
                                let startCompStr     = String(format: "%.3f", currSound.startTime_comp)

                                printSoundRelatedMsg(msg: "  S S =====================  Sound  / / / / / / / / /  Sound  ======")
                                printSoundRelatedMsg(msg: "  S S   Legato Split")
                                printSoundRelatedMsg(msg: "  S S      Old Sound: \(currSound.soundID)       - Legato Split")
                                printSoundRelatedMsg(msg: "  S S         Start Time ABS:          \(startABSStr)")
                                printSoundRelatedMsg(msg: "  S S         Start Time Song:         \(startSongStr)")
                                printSoundRelatedMsg(msg: "  S S         Start Time Comp:         \(startCompStr)")
                                printSoundRelatedMsg(msg: "  S S         Duration:                \(currSound.duration)")
                            }
                            perfTrkgMgr.resetAmpTracker()
                            
                            if let newSound = perfTrkgMgr.currentSound {
                                newSound.xOffsetStart = firstNoteOrRestXOffset + currXOffset
                                newSound.forceAveragePitch(pitchSample: currFreq)
                                // see if there's an unclaimed note
      //                          print("   Calling linkCurrSoundToCurrScoreObject() from trackSounds 1")
                                if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput ||
                                   kMKDebugOpt_PrintMinimalNoteAndSoundResults     { // second half
                                    let startABSStr      = String(format: "%.3f", currSound.startTime_abs)
                                    let startSongStr     = String(format: "%.3f", currSound.startTime_song)
                                    let startCompStr     = String(format: "%.3f", currSound.startTime_comp)
                                    
                                    printSoundRelatedMsg(msg: "  S S      New Sound: \(newSound.soundID)")
                                    printSoundRelatedMsg(msg: "  S S         Start Time ABS:          \(startABSStr)")
                                    printSoundRelatedMsg(msg: "  S S         Start Time Song:         \(startSongStr)")
                                    printSoundRelatedMsg(msg: "  S S         Start Time Comp:         \(startCompStr)")
                                    printSoundRelatedMsg(msg: "  S S           (initial amplitude = \(currAmpltd)")
                                    printSoundRelatedMsg(msg: "  S S ===========================================================")
                                }
    //                            if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput ||
    //                                kMKDebugOpt_PrintMinimalNoteAndSoundResults     {
    //                                print (" \n  SS1 - Creating new sound \(newSound.soundID) (legato split), abs time: \(newSound.startTime_abs), song time: \(newSound.startTime_song)")
    //                                print("    (initial amplitude = \(currAmpltd)")
    //                            }
                                perfTrkgMgr.linkCurrSoundToCurrScoreObject(isNewScoreObject: false)
                                currSound.createdBecauseOfLegatoPitchChange = true
                            } // if let newSound
                        } // isDefinitelyADifferentNote()
                    }  // if areDifferentNotes
                } // not a new note bc of Amp change; Check pitch change during legato playing
                else { // pitch is same as current sound average, so just update.
                    currSound.addPitchSample(pitchSample: currFreq)
                }

            } // else - sound with stable pitch exists
        } // signalDetected &&  currentlyTrackingSound

        else if signalDetected && !perfTrkgMgr.currentlyTrackingSound && notInCountdown {
            // New sound detected
            let soundMode : soundType = isTune ? .pitched : .percusive

            // check ampTracker for status.
            if perfTrkgMgr.isANewNoteBCofAmpChange() {
                let newStartTIme = perfTrkgMgr.absTimeForNewSound
                perfTrkgMgr.startTrackingPerformanceSound(
                    startAt: newStartTIme,
                    soundMode: soundMode,
                    noteOffset: perfTrkgMgr.songStartTimeOffset )
                perfTrkgMgr.resetAmpTracker()
            } else {
                perfTrkgMgr.startTrackingPerformanceSound(
                    startAt: timeSinceAnalysisStart,
                    soundMode: soundMode,
                    noteOffset: perfTrkgMgr.songStartTimeOffset )
            }
            
            var soundID: Int32 = 0
            if let currSound = perfTrkgMgr.currentSound {
                if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput ||
                   kMKDebugOpt_PrintMinimalNoteAndSoundResults            {
                    // print (" \n  Creating new sound \(soundID), effective time: \(timeSinceSongStart-kSoundStartAdjustment)")
                    // want to quickly see this during debugging
                    soundID = currSound.soundID
                    if alwaysFalseToSuppressWarn() { print("\(soundID)") } // suppress warning
//                    print ("\n  SS2 - Creating new sound \(soundID), abs time: \(currSound.startTime_abs), song time: \(currSound.startTime_song), comp time: \(currSound._startTime_comp)")
//                    print("    (initial amplitude = \(currAmpltd)")
                    
                    printSoundRelatedMsg(msg: "  S S =====================  Sound  =================  Sound  =======")
                    printSoundRelatedMsg(msg: "  S S  Creating Sound: \(currSound.soundID)       - New Sound")
                    printSoundRelatedMsg(msg: "  S S       Start Time ABS:         \(currSound.startTime_abs)")
                    printSoundRelatedMsg(msg: "  S S       Start Time Song:        \(currSound.startTime_song)")
                    printSoundRelatedMsg(msg: "  S S       Start Time Comp:        \(currSound.startTime_comp)")
                    printSoundRelatedMsg(msg: "  S S         (initial amplitude = \(currAmpltd)")
                    printSoundRelatedMsg(msg: "  S S ===============================================================")
                }
     //          print("   Calling linkCurrSoundToCurrScoreObject() from trackSounds 2")
                perfTrkgMgr.linkCurrSoundToCurrScoreObject(isNewScoreObject: false) // linkCurrSoundToCurrNote() // see if there's an unclaimed note

                var currXOffset = Int(ssScrollView.getCurrentXOffset())
                currXOffset -= kOverlayPixelAdjustment
                currSound.xOffsetStart = firstNoteOrRestXOffset + currXOffset
                soundID = currSound.soundID
            }
        }

        else if !signalDetected && perfTrkgMgr.currentlyTrackingSound {
            // Existing sound ended

            print("\n")
            printSoundRelatedMsg(msg: "  !!   Stopping Sound, Simple:  at: \(timeSinceSongStart)!!\n")
            perfTrkgMgr.resetAmpTracker()
            stopCurrentSound( soundEndTime: timeSinceAnalysisStart )
            
            /*
            if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput ||
               kMKDebugOpt_PrintMinimalNoteAndSoundResults      {
 //               print ("  Stopping dead sound at \(timeSinceSongStart)")
            }

            var currXOffset = Int(ssScrollView.getCurrentXOffset())
            currXOffset -= kOverlayPixelAdjustment
            if let currSound = perfTrkgMgr.currentSound {
                currSound.xOffsetEnd = currXOffset + firstNoteOrRestXOffset
            }

            perfTrkgMgr.updateCurrentNoteIfLinked()
            perfTrkgMgr.endTrackedSoundAsSignalStopped(
                soundEndTime: timeSinceAnalysisStart,
                noteOffset: perfTrkgMgr.songStartTimeOffset )
             */
        }
    }

    func stopCurrentSound(soundEndTime: TimeInterval) {
        if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput ||
            kMKDebugOpt_PrintMinimalNoteAndSoundResults      {
            //               print ("  Stopping dead sound at \(timeSinceSongStart)")
        }
        
        var currXOffset = Int(ssScrollView.getCurrentXOffset())
        currXOffset -= kOverlayPixelAdjustment
        if let currSound = perfTrkgMgr.currentSound {
            currSound.xOffsetEnd = currXOffset + firstNoteOrRestXOffset
        }
        
        perfTrkgMgr.updateCurrentNoteIfLinked()
        perfTrkgMgr.endTrackedSoundAsSignalStopped(
            soundEndTime: soundEndTime,
            noteOffset: perfTrkgMgr.songStartTimeOffset )
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

    @objc func analyzePerformance() {

        trackSounds()

        guard insideNote || insideRest else { return }

        let inThreshold = Date().timeIntervalSince(startTime) < thresholdEndTime
//        let amplitude = AudioKitManager.sharedInstance.amplitude()
//        let frequency = AudioKitManager.sharedInstance.frequency()
        // SFAUDIO
        var amplitude = 0.0
        var frequency = 0.0
        ///   AMPLEAMPLE
        if AudioKitManager.sharedInstance.amplitudeTracker != nil {
            amplitude = AudioKitManager.sharedInstance.amplitudeTracker.amplitude
        }
        if AudioKitManager.sharedInstance.frequencyTracker != nil {
            // amplitude = AudioKitManager.sharedInstance.frequencyTracker.amplitude
            //       print("&&&&&& Amp = \(amplitude)")
            frequency = AudioKitManager.sharedInstance.frequencyTracker.frequency
        }
        
        // Does this ignore and not process the case where the rhythm is correct but the
        // note is wrong? Either rename "hasCorrectSound", or create two separate vars
        let hasSound = amplitude > 0.01 && (minPitch...maxPitch ~= frequency)

        var result = NoteAnalysis.NoteResult.noResult

        if insideNote {
            // if insideNote then a sound before thresholdEndTime => note match
            // if insideNote no sound and reach thresholdEndTime ==> note miss
            // if insideNote a sound after thresholdEndTime ==> note late
            // if insideNote after thresholdEndTime any additional sound ==> note late repeat
            if hasSound && inThreshold {
                //if we already found a sound in threshold don't count it twice
                guard !foundSound else { return }
                foundSound = true
                result = NoteAnalysis.NoteResult.noteRhythmMatch
                if kUseColoredNotes {
                    if !isTune {
                        colorTheNote(currentNotes, theColor: UIColor.green)
                    }
                }
            } else if !hasSound && !inThreshold {
                //if we already missed the threshold don't count it twice
                guard !missedSound && !foundSound else { return }
                missedSound = true
                result = NoteAnalysis.NoteResult.noteRhythmMiss
            } else if hasSound && !inThreshold  && !lateSound {
                //cannot be late if we have not missed
    //yes we can on longer notes - one clap on time and then a second one later -- fix this later
                guard missedSound else { return }
                lateSound = true
                result = NoteAnalysis.NoteResult.noteRhythmLate
//            } else if hasSound && !inThreshold  && lateSound {
//                //cannot repeat if we haven't already been late
//                result = NoteAnalysis.NoteResult.NoteRhythmLateRepeat
            }

            if isTune && hasSound {
                //if we have a rhythm result save it first
                if result != NoteAnalysis.NoteResult.noResult {
                    if let count = noteResultValues[result] {
                        noteResultValues[result] = count + 1
//                        print("rhythm result: \(amplitude) - \(result) \(count + 1)")
                    } else {
                        noteResultValues[result] = 1
//                        print("rhythm result: \(amplitude) - \(result) 1")
                    }

                    result = NoteAnalysis.NoteResult.noResult
                }

                var freqMatch = false
                var freqLow = false
                var freqHigh = false

                if frequency < lowPitchThreshold {
                    freqLow = true
                } else if frequency > highPitchThreshold {
                    freqHigh = true
                } else {
                    freqMatch = true
                }

//                print("freq ...    low \(freqLow)    high \(freqHigh)    match \(freqMatch)")
                if inThreshold {
                    if freqLow {
                        guard !pitchLow else { return }
                        pitchLow = true
                        result = NoteAnalysis.NoteResult.pitchLow
                    } else if freqHigh {
                        guard !pitchHigh else { return }
                        pitchHigh = true
                        result = NoteAnalysis.NoteResult.pitchHigh
                    } else if freqMatch {
                        guard !pitchMatched else { return }
                        pitchMatched = true
                        result = NoteAnalysis.NoteResult.pitchMatch

                        if kUseColoredNotes {
                            colorTheNote(currentNotes, theColor: UIColor.green)
                        }
                    }
                } else {
                    if freqLow {
                        guard !pitchLowLate else { return }
                        pitchLowLate = true
                        result = NoteAnalysis.NoteResult.pitchLowLate
                    } else if freqHigh {
                        guard !pitchHighLate else { return }
                        pitchHighLate = true
                        result = NoteAnalysis.NoteResult.pitchHighLate
                    } else if freqMatch {
                        guard !pitchMatchedLate else { return }
                        pitchMatchedLate = true
                        result = NoteAnalysis.NoteResult.pitchMatchLate
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
                result = NoteAnalysis.NoteResult.restMiss
            } else if !hasSound && !inThreshold {
                //if we already missed the threshold don't count it twice
                guard !missedSound && !foundSound else { return }
                missedSound = true
                result = NoteAnalysis.NoteResult.restMatch
            } else if hasSound && !inThreshold  && !lateSound {
                //cannot be late if we have not missed
                guard missedSound else { return }
                lateSound = true
                result = NoteAnalysis.NoteResult.restLateMiss
//            } else if hasSound && !inThreshold  && lateSound {
//                //cannot repeat if we haven't already been late
//                result = NoteAnalysis.NoteResult.RestLateMissRepeat
            }
        }

//        guard result != NoteAnalysis.NoteResult.noResult else { return }
//        if insideNote {
//            if result == NoteAnalysis.NoteResult.noteRhythmMatch ||
//               result == NoteAnalysis.NoteResult.noteRhythmMiss  ||
//               result == NoteAnalysis.NoteResult.noteRhythmLate {
//
//                let resAsInt32 : Int32 = Int32(result.hashValue)
//                ssScrollView.addNotePerformanceResult( atXPos: currNoteXPos,
//                        withRhythmResult: resAsInt32, withPitchResult: 0 );
//            }
//        }
//




        if let count = noteResultValues[result] {
            noteResultValues[result] = count + 1
//            print("pitch result: \(amplitude) - \(result) \(count + 1)")
        } else {
            noteResultValues[result] = 1
//            print("pitch result: \(amplitude) - \(result) 1")
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
        if noteResultValues.count == 0 {
            infoLabel.text = ""
            return
        }

        var scoreString = "You got"

        if isTune {
            if let numResults = noteResultValues[NoteAnalysis.NoteResult.pitchMatch] {
                if numResults != 0 {
                    scoreString = scoreString + ": PitchMatch - \(numResults)"
                }
            }

            if let numResults = noteResultValues[NoteAnalysis.NoteResult.pitchLow] {
                if numResults != 0 {
                    scoreString = scoreString + ": PitchLow - \(numResults)"
                }
            }

            if let numResults = noteResultValues[NoteAnalysis.NoteResult.pitchHigh] {
                if numResults != 0 {
                    scoreString = scoreString + ": PitchHigh - \(numResults)"
                }
            }

            if let numResults = noteResultValues[NoteAnalysis.NoteResult.pitchMatchLate] {
                if numResults != 0 {
                    scoreString = scoreString + ": PitchMatchLate - \(numResults)"
                }
            }

            if let numResults = noteResultValues[NoteAnalysis.NoteResult.pitchLowLate] {
                if numResults != 0 {
                    scoreString = scoreString + ": PitchLowLate - \(numResults)"
                }
            }

            if let numResults = noteResultValues[NoteAnalysis.NoteResult.pitchHighLate] {
                if numResults != 0 {
                    scoreString = scoreString + ": PitchHighLate - \(numResults)"
                }
            }
        }

        if let numResults = noteResultValues[NoteAnalysis.NoteResult.noteRhythmMatch] {
            if numResults != 0 {
                scoreString = scoreString + ": NoteRhythmMatch - \(numResults)"
            }
        }

        if let numResults = noteResultValues[NoteAnalysis.NoteResult.noteRhythmMiss] {
            if numResults != 0 {
                scoreString = scoreString + ": NoteRhythmMiss - \(numResults)"
            }
        }

        if let numResults = noteResultValues[NoteAnalysis.NoteResult.noteRhythmLate] {
            if numResults != 0 {
                scoreString = scoreString + ": NoteRhythmLate - \(numResults)"
            }
        }

        if let numResults = noteResultValues[NoteAnalysis.NoteResult.noteRhythmLateRepeat] {
            if numResults != 0 {
                scoreString = scoreString + ": NoteRhythmLateRepeat - \(numResults)"
            }
        }

        if let numResults = noteResultValues[NoteAnalysis.NoteResult.restMatch] {
            if numResults != 0 {
                scoreString = scoreString + ": RestMatch - \(numResults)"
            }
        }

        if let numResults = noteResultValues[NoteAnalysis.NoteResult.restMiss] {
            if numResults != 0 {
                scoreString = scoreString + ": RestMiss - \(numResults)"
            }
        }

        if let numResults = noteResultValues[NoteAnalysis.NoteResult.restLateMiss] {
            if numResults != 0 {
                scoreString = scoreString + ": RestLateMiss - \(numResults)"
            }
        }

        if let numResults = noteResultValues[NoteAnalysis.NoteResult.restLateMissRepeat] {
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

    //used for colored notes
    func colorTheNote(_ theNote: [AnyObject], theColor: UIColor) {
        if kUseColoredNotes {
            // convert array of SSPDPartNote to array of SSPDNote
            var notes = [SSPDNote]()
            for note in theNote as! [SSPDPartNote] {
                notes.append(note.note)
            }

            ssScrollView.colour(notes, colour: theColor)
        }
    }
    
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
    
    //MARK: - SSNoteHandler protocol

    // New API, as of V330, or earlier
    func end(_ note: SSPDPartNote!, at dispatch_time: dispatch_time_t) {
        if note.note.midiPitch > 0 {
            insideNote = false
        } else {
            insideRest = false
        }
    }
    
    // - old API
    func end(_ note: SSPDPartNote!) {
        if note.note.midiPitch > 0 {
            insideNote = false
        } else {
            insideRest = false
        }
    }
    
    // Should probably just delete this . . .
    
    // what should be in Note or Rest end handler in scheduler
    /*
    func end(_ note: SSPDPartNote!) {
        if kMKDebugOpt_PrintMinimalNoteAndSoundResults {
            let timeSinceAnalysisStart : TimeInterval = Date().timeIntervalSince(startTime)
            let timeSinceSongStart =
                timeSinceAnalysisStart - PerformanceTrackingMgr.instance.songStartTimeOffset
            //            if note.note.midiPitch > 0 {
            //                print ("      NNN - Current Note should end now, at \(timeSinceSongStart)")
            //            } else {
            //                print ("      RRR - Current Rest should end now, at \(timeSinceSongStart)")
            //            }
        }
        
        if note.note.midiPitch > 0 {
            insideNote = false
        } else {
            insideRest = false
        }
        
        // Note or rest ended. See if there were errors with this particular note/rest that were
        // bad enough to reject the performance. If so, stop now, so student doesn't go through
        // entire song only to find out performance rejected due to error early on.
        if let currScoreObj: PerformanceScoreObject? =
            PerfTrkMgr.instance.currentlyInAScoreNote ? PerfTrkMgr.instance.currentPerfNote
                : PerfTrkMgr.instance.currentPerfRest
        {
            let good = PerfTrkMgr.instance.analyzeOneScoreObject(perfScoreObj:currScoreObj!)
            if !good {
                let issue: PerfIssue =
                    PerformanceIssueMgr.instance.scanPerfScoreObjForIssues( perfScoreObj: currScoreObj!,
                                                                            sortCrit: gPerfIssueSortCriteria )
                if issue.issueScore > kStopPerformanceThreshold {
                    stopPlaying() // Ejector Seat !!!!
                }
            }
        }
        currNoteXPos = -1.0
        if note.note.midiPitch > 0 && PerformanceTrackingMgr.instance.currentlyInAScoreNote {
            PerformanceTrackingMgr.instance.currentlyInAScoreNote = false
        } else {
            PerformanceTrackingMgr.instance.currentlyInAScoreRest = false
        }
        //        PerformanceTrackingMgr.instance.currentlyInAScoreNote = false
        //        PerformanceTrackingMgr.instance.currentlyInAScoreRest = false
    }
    */

    // New API, as of V330, or earlier
    func start(_ notes: [SSPDPartNote]!, at dispatch_time: dispatch_time_t) {
        assert(notes.count > 0)
        if !playingAnimation {
            gateView.frame.origin.x = CGFloat(animHorzOffset - 12.0)
            gateView.frame.origin.x = CGFloat(animHorzOffset - 24.0)
            
            // gateView.isHidden = false
            
            //           print("addAnimation!")
            //            print("anim.values: \(kfAnim.values)")
            //            print("keyTimes: \(kfAnim.keyTimes)")
            //            print("anim.duration: \(kfAnim.duration)")
            ssScrollView.layer.add(kfAnim, forKey: "move")
            playingAnimation = true
        }
        
        if !playingSynth {
            setNoteThresholdState(notes as NSArray)
        }
        
        if kUseColoredNotes {
            currentNotes = notes
        }
        
        if showNoteMarkers {
            moveNoteCursor(notes as NSArray)
        }
    }

    /*!
     * @method startNotes:
     * @abstract called for each note/chord starting
     * @param notes an array of SSPDPartNote, the set of all notes in all parts which should be starting
     */
    public func start(_ notes: [SSPDPartNote]!) {
        assert(notes.count > 0)
        if !playingAnimation {
            gateView.frame.origin.x = CGFloat(animHorzOffset - 12.0)
            gateView.frame.origin.x = CGFloat(animHorzOffset - 24.0)
            
           // gateView.isHidden = false
            
 //           print("addAnimation!")
//            print("anim.values: \(kfAnim.values)")
//            print("keyTimes: \(kfAnim.keyTimes)")
//            print("anim.duration: \(kfAnim.duration)")
            ssScrollView.layer.add(kfAnim, forKey: "move")
            playingAnimation = true
        }

        if !playingSynth {
            setNoteThresholdState(notes as NSArray)
        }

        if kUseColoredNotes {
            currentNotes = notes
        }
        
        if showNoteMarkers {
            moveNoteCursor(notes as NSArray)
        }
    }
    //@end

    // MARK: Misc Position funcs
    func noteXPos(_ note: SSPDNote) -> Float {
        let system = ssScrollView.systemContainingBarIndex(note.startBarIndex)
        guard system != nil else { return 0 }

        let comps = system?.components(forItem: note.item_h)
        for comp in comps! {
            if (comp.type == sscore_comp_notehead || comp.type == sscore_comp_rest) {
                let result = Float(comp.rect.origin.x + comp.rect.size.width / 2)
                if !firstNoteOrRestEventAcknowledged {
                    firstNoteOrRestEventAcknowledged = true
                    firstNoteOrRestXOffset = Int(Double(result))
                    firstNoteOrRestXOffset -= 10 //
                }
                return result
            }
        }

        return 0
    }

    func noteYPos(_ note: SSPDNote) -> Float {
        let system = ssScrollView.systemContainingBarIndex(note.startBarIndex)
        guard system != nil else { return 0 }

        let comps = system?.components(forItem: note.item_h)
        for comp in comps! {
            if (comp.type == sscore_comp_notehead || comp.type == sscore_comp_rest) {
                let result = Float(comp.rect.origin.y + comp.rect.size.height / 2)
                return result
            }
        }

        return 0
    }

    /////////////////////////////////////////////////////////////////////////////
    // Create a new PerformanceNote, add to appropriate container,
    // link to sound if one exists.
    //     TODO: Ultimately want to move this func out to PerformanceTrackingMgr,
    //        but may not be possible b/c currently this func uses too many vars
    //        local to this VC (mostly related to SeeScore, which can't be moved
    //        outside the VC). Will look at this again at a later date.
    func createNewPerfNote( nsNote: SSPDNote ) {

        // W let xpos = noteXPos(note.note)
        let xpos = noteXPos( nsNote )
        currNoteXPos = CGFloat(xpos)
        let ypos = noteYPos( nsNote )

        PerformanceTrackingMgr.instance.currentlyInAScoreNote = true
        let newNote : PerformanceNote = PerformanceNote.init()
        let noteDur = nsNote.duration
        
        // hyarbarlen
        let barStartIntvl =
            mXMLNoteStartInterval( bpm: bpm(),
                                   beatsPerBar: Int32(beatsPerBar),
                                   beatType: Int32(timeSigBeatType),
                                   startBarIndex: nsNote.startBarIndex,
                                   noteStartWithinBar: nsNote.start )
        
        
        let expectedDur = Double(noteDur) / 1000.0
        newNote.setExpectedTimes( startTime: barStartIntvl,
                                  duration:  expectedDur )
        newNote.xPos = Int32(xpos)
        newNote.yPos = Int32(ypos)

        let timeSinceAnalysisStart : TimeInterval = Date().timeIntervalSince(startTime)
        let timeSinceSongStart =
            timeSinceAnalysisStart - PerformanceTrackingMgr.instance.songStartTimeOffset
        let diff = newNote.expectedStartTime - timeSinceSongStart

        // Do this for both rests and notes
        delay(diff){
            //let xpos1:CGFloat = CGFloat(noteXPos(note.note))
 //           self.drawCurrNoteLineAt(xPos: CGFloat(newNote.xPos))
        }
        
        if kMKDebugOpt_PrintMinimalNoteAndSoundResults {
            let noteID = newNote.perfNoteOrRestID
            printNoteRelatedMsg(msg: "NNN - Creating New Note, ID = \(noteID) at \(timeSinceSongStart), should start at \(newNote.expectedStartTime)")
     
            // Uncomment to see the diffs during debugging
//            delay(diff){
//                let timeSinceAnalysisStart2 : TimeInterval = Date().timeIntervalSince(self.startTime)
//                let timeSinceSongStart2 =
//                    timeSinceAnalysisStart2 - PerformanceTrackingMgr.instance.songStartTimeOffset
//             }
        }
        
        newNote.expectedMidiNote = NoteID(nsNote.midiPitch)

        if newNote.perfNoteOrRestID == 3 {
 //           print("Hey")
        }

        if let freq = NoteService.getNote( Int(nsNote.midiPitch) )?.frequency {
            targetPitch = freq
            newNote.expectedFrequency = freq
        }
        
        PerfScoreObjScheduler.instance.addPerfScoreObj(perfScoreObj: newNote)
        
        if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput ||
           kMKDebugOpt_PrintMinimalNoteAndSoundResults            {
            printNoteRelatedMsg(msg: "N N =====================  Note  =================  Note  ===================")
            printNoteRelatedMsg(msg: "N N   Creating Note: \(newNote.perfNoteOrRestID)")
            printNoteRelatedMsg(msg: "N N        Expected Start Time:          \(newNote.expectedStartTime)")
            printNoteRelatedMsg(msg: "N N        Expected Start Time Comp:     \(newNote.expectedStartTime_comp)")
            printNoteRelatedMsg(msg: "N N        Actual Start Time:            \(newNote.actualStartTime_song)")
            printNoteRelatedMsg(msg: "N N        Actual Start Time Comp:       \(newNote.actualStartTime_comp)")
            printNoteRelatedMsg(msg: "N N =========================================================================")
        }
    }

    /////////////////////////////////////////////////////////////////////////////
    // Create a new PerformanceRest, add to appropriate container,
    // link to sound if one exists.
    //     TODO: Ultimately want to move this func out to PerformanceTrackingMgr,
    //        but may not be possible b/c currently this func uses too many vars
    //        local to this VC (mostly related to SeeScore, which can't be moved
    //        outside the VC). Will look at this again at a later date.
    func createNewPerfRest( nsNote: SSPDNote ) {
        
        // W let xpos = noteXPos(note.note)
        let xpos = noteXPos( nsNote )
        currNoteXPos = CGFloat(xpos)
        let ypos = noteYPos( nsNote )
        
        PerformanceTrackingMgr.instance.currentlyInAScoreRest = true
        let newRest : PerformanceRest = PerformanceRest.init()
        let restDur = nsNote.duration
        let barStartIntvl =
            mXMLNoteStartInterval( bpm: bpm(),
                                   beatsPerBar: Int32(beatsPerBar),
                                   beatType: Int32(timeSigBeatType),
                                   startBarIndex: nsNote.startBarIndex,
                                   noteStartWithinBar: nsNote.start )
        let expectedDur = Double(restDur) / 1000.0
        newRest.setExpectedTimes( startTime: barStartIntvl,
                                  duration:  expectedDur )
//  delme      newRest.startTime = barStartIntvl
//  delme     newRest.duration = Double(restDur) / 1000.0
        newRest.xPos = Int32(xpos)
        newRest.yPos = Int32(ypos)
        
        let timeSinceAnalysisStart : TimeInterval = Date().timeIntervalSince(startTime)
        let timeSinceSongStart =
            timeSinceAnalysisStart - PerformanceTrackingMgr.instance.songStartTimeOffset
        let diff = newRest.expectedStartTime - timeSinceSongStart
        
        // Do this for both rests and notes
        delay(diff){
            //let xpos1:CGFloat = CGFloat(noteXPos(note.note))
//            self.drawCurrNoteLineAt(xPos: CGFloat(newRest.xPos))
        }
        
        if kMKDebugOpt_PrintMinimalNoteAndSoundResults {
            let timeSinceAnalysisStart : TimeInterval = Date().timeIntervalSince(startTime)
            let timeSinceSongStart =
                timeSinceAnalysisStart - PerformanceTrackingMgr.instance.songStartTimeOffset
            let restID = newRest.perfNoteOrRestID
            //  want to see unused vars above in debug session; supresses warnings
            if alwaysFalseToSuppressWarn() { print ("\(timeSinceSongStart), \(restID)") }
        }

        PerfScoreObjScheduler.instance.addPerfScoreObj(perfScoreObj: newRest)
        
        if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput ||
           kMKDebugOpt_PrintMinimalNoteAndSoundResults            {
            printNoteRelatedMsg(msg: "R R =====================  Rest  =================  Rest  ===================")
            printNoteRelatedMsg(msg: "R R  Creating Rest: \(newRest.perfNoteOrRestID)")
            printNoteRelatedMsg(msg: "R R       Expected Start Time:        \(newRest.expectedStartTime)")
            printNoteRelatedMsg(msg: "R R       Expected Start Time Comp:   \(newRest.expectedStartTime_comp)")
            printNoteRelatedMsg(msg: "R R =========================================================================")
        }
    }

    // Called within  start  (a note/chord or rest has started)
    //this only makes sense if setNoteHandler() delay is -timingThreshold
    func setNoteThresholdState(_ notes: NSArray) {
        // normally this will not need to iterate over the whole chord, but will exit as soon as it has a valid xpos
        // modified for analysis threshold and state

        for note in notes as! [SSPDPartNote] {
            // priority given to notes over rests, but ignore cross-bar tied notes
            
            // Do this for both rests and notes
            let xpos1:CGFloat = CGFloat(noteXPos(note.note))
 //           drawCurrNoteLineAt(xPos: xpos1)
            
            print ("\n   > > > > > In setNoteThresholdState(),     xpos1 == \(xpos1)\n")
            
            if note.note.midiPitch > 0 && note.note.start >= 0 {
                let xpos = noteXPos(note.note)
                // noteXPos returns 0 if the note isn't found in the layout (it might be in a part which is not shown)
                if xpos > 0 {
                    insideNote = true
                    insideRest = false
                    foundSound = false
                    missedSound = false
                    lateSound = false

                    // For tracking student performance
                    createNewPerfNote( nsNote: note.note )

                    thresholdStartTime = Date().timeIntervalSince(startTime) - timingThreshold * 2
                    thresholdEndTime = Date().timeIntervalSince(startTime) + timingThreshold * 2

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
                    
                    // For tracking student performance
                    createNewPerfRest( nsNote: note.note )

                    thresholdEndTime = Date().timeIntervalSince(startTime) + timingThreshold * 2

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

    func moveNoteCursor(_ notes: NSArray) {
        
    //    return
        
        // normally this will not need to iterate over the whole chord, but will exit as soon as it has a valid xpos
        for note in notes as! [SSPDPartNote] {
            // priority given to notes over rests, but ignore cross-bar tied notes
            //   (negative note.start means note started prev measure - unique to 2nd note of cross-bar tie)
            if note.note.midiPitch > 0 && note.note.start >= 0 {
                let xpos = noteXPos(note.note)
                // noteXPos returns 0 if the note isn't found in the layout (it might be in a part which is not shown)
                if xpos > 0 {
                    ssScrollView.setCursorAtXpos(xpos, barIndex: note.note.startBarIndex, scroll: scroll_bar)
                    return // abandon iteration
                }
            }
        }

        for note in notes as! [SSPDPartNote] {
            if note.note.midiPitch == 0 {   //rest
                let xpos = noteXPos(note.note)
                // noteXPos returns 0 if the note isn't found in the layout (it might be in a part which is not shown)
                if xpos > 0 {
                    ssScrollView.setCursorAtXpos(xpos,
                                                 barIndex: note.note.startBarIndex,
                                                 scroll: scroll_bar)
                                                 // scroll: SSScrollView.ScrollType_e.scroll_bar)
                    return // abandon iteration
                }
            }
        }
    }

    func printBeatTime(dispatch_time: dispatch_time_t) {
        guard kMKDebugOpt_PrintMinimalNoteAndSoundResults else { return }
        let timeSinceAnalysisStart : TimeInterval = Date().timeIntervalSince(startTime)
        let timeSinceSongStart =
            timeSinceAnalysisStart - PerformanceTrackingMgr.instance.songStartTimeOffset
        print("   ------------> BEAT Time: \(timeSinceSongStart)")
    }
    
    let concurrentQueue = DispatchQueue(label: "MKConcurrentQueue", attributes: .concurrent)

    /*
    // CAlled in BeatHandler
    func turnSpeakerOff() {
        //_ = AVAudioSessionManager.sharedInstance.extraSetupForCountdown(turnSpeakerOn: false)
        
        let timeSinceAnalysisStart : TimeInterval = Date().timeIntervalSince(startTime)
        print("QQQQQQQ ---> QUEUE'ing async call to setupAudioSession at \(timeSinceAnalysisStart)")
        if !playingSynth { // switch to "listening" mode; turns off sound
            //DispatchQueue.global(qos: .userInitiated).async {
            concurrentQueue.async {
                let timeSinceAnalysisStart2 : TimeInterval = Date().timeIntervalSince(self.startTime)
                print("QQQQQQQ ---> PERFORM'ing async call to setupAudioSession at \(timeSinceAnalysisStart2)")
                //let res = AVAudioSessionManager.sharedInstance.setupAudioSession(sessionMode: .usingMicMode)
                let res = AVAudioSessionManager.sharedInstance.setSessionMode(forVideoPlayback: false)
                if !res {
                    print("Unable to switch AV settings in TExer::turnSpeakerOff()")
                }
                let timeSinceAnalysisStart3 : TimeInterval = Date().timeIntervalSince(self.startTime)
                print("QQQQQQQ ---> FINISHED async call to setupAudioSession at \(timeSinceAnalysisStart3)")
            }
        }
    }
    */
    
    func doingPlayForMe() -> Bool {
        return playingSynth
    }

    func doingPlayAlong() -> Bool {
        return !playingSynth
    }
    
    class BeatHandler: SSEventHandler {
        
        let svc: TuneExerciseViewController

        init(vc: TuneExerciseViewController) {
            svc = vc
        }

        // Old API
        //      @objc func event(_ index: Int32, countIn isCountIn: Bool) {
        // New API
        func event(_ index: Int32,
                   countIn isCountIn: Bool,
                   at dispatch_time: dispatch_time_t) {
            svc.countOffLabel.isHidden = !isCountIn;
            if isCountIn {
                svc.countOffLabel.text = "\(index + 1)"
                if !svc.playingSynth {
                    svc.startAnalysisTimer()
                    svc.startCheckPerfObjsTimer()
                }

                if index >= Int32(svc.beatsPerBar - 1) {
                    /* was:
                    svc.metronomeOn = false
                    svc.synth?.changedControls()
                    svc.notInCountdown = true
                    svc.turnSpeakerOff()
                    */
                    
                    var headphonesInUse = false
                    let currentRoute = AVAudioSession.sharedInstance().currentRoute
                    if currentRoute.outputs != nil {
                        print("\nHEADPHONES: currentRoute.outputs != nil")
                        for description in currentRoute.outputs {
                            if description.portType == AVAudioSessionPortHeadphones {
                                headphonesInUse = true
                                print("\nHEADPHONES: looping through currentRoute.outputs, headphones  found!!")
                                break
                            }
                            print("\nHEADPHONES: looping through currentRoute.outputs, headphones not found")
                        }
                    } else {
                        print("\nHEADPHONES: currentRoute.outputs IS = nil")
                    }
                    if !headphonesInUse && !svc.doingPlayForMe() {
                        print("\nHEADPHONES: code thinks headphonesInUse != true\n")
                        //delay(0.1) {
                            print("\nHEADPHONES: Setting metro off, speakerOff\n")
                            self.svc.metronomeOn = false
//                            self.svc.turnSpeakerOff()
                        //}
                    } else {
                        print("\nHEADPHONES: code thinks headphonesInUse == true\n")
                    }
                    
                    svc.synth?.changedControls()
                    svc.notInCountdown = true
                    svc.showAnalysisOverview(doShow: true)
                    svc.freezeSeeScoreLayout()

                    if !headphonesInUse && !svc.doingPlayForMe()  {
 //                       self.svc.turnSpeakerOff()
                    }
                }
//                svc.playTickSound()
            }
            else if svc.shouldSetSongStartTime {
                let msOffset = TimeInterval(abs(svc.beatMillisecOffset/1000)) // METROMETRO
                let nowPlus = Date().addingTimeInterval(msOffset)
                svc.songStartTm = nowPlus
                svc.songStartTmOffset = svc.songStartTm.timeIntervalSince(svc.startTime)
                svc.shouldSetSongStartTime  = false
            }

            svc.printBeatTime(dispatch_time: dispatch_time)
            svc.metronomeView.setBeat(Int(index))
        }
    }

    class EndHandler: SSEventHandler {

        let svc: TuneExerciseViewController

        init(vc: TuneExerciseViewController) {
            svc = vc
        }
        
        // Old API:
        //      @objc func event(_ index: Int32, countIn isCountIn: Bool) {
        // NEW API:
        func event(_ index: Int32,
                   countIn isCountIn: Bool,
                   at dispatch_time: dispatch_time_t)
        {
            svc.countOffLabel.isHidden = true
            svc.cursorBarIndex = 0
            svc.stopPlaying()
            svc.shouldSetSongStartTime  = true
            if UserDefaults.standard.bool(forKey: Constants.Settings.ShowAnalysis) && !svc.playingSynth {
                svc.showScore()
            }
        }
    }

    //MARK: - Sounds
    //TODO - get rid of this if we can keep using SeeScore metronome.
//    func setupSounds() {
//        let ticksound = "marmstk1"
//        let ticktype = "wav"
//
//        if let soundPath = Bundle.main.path(forResource: ticksound, ofType: ticktype) {
//            let soundUrl = URL(fileURLWithPath: soundPath)
//
//            do {
//                tickPlayer = try AVAudioPlayer(contentsOf: soundUrl)
//                tickPlayer?.prepareToPlay()
//            } catch {
//                print("No sound found by URL:\(soundUrl)")
//            }
//        }
//    }
//
//    func playTickSound() {
//        if let tp = tickPlayer {
//            tp.play()
//        }
//    }

 
    // MARK: - Navigation

    @IBAction func unwindToTuneExerciseVC(unwindSegue: UIStoryboardSegue) {
        
    }
     
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: PerfAnalysisSettingsPopupView

    ///////////////////////////////////////////////////////////////////////////
    //
    // Vars, funcs for popup to set Performance Analysis criteria at runtime.
    //
    //   This popup dialog allows you, for tuning and testing, to change some
    //   of the Performance Analysis vars at runtime.
    //
    //   Set kMKDebugOpt_ShowDebugSettingsBtn true or false to:
    //   1) Expose or hide the Button that launches the dialog.
    //   2) Secondarily, Unblocks/Blocks popping up dialog after button push
    //
    //   This button and the popup dialog are ONLY to be exposed (if desired) in
    //   development mode. It is a development tool only. NOT for release.
    //
    //   The PerfAnalysisSettingsPopupView popup allows setting:
    //   1) The Sort Criteria for post-performance analysis, for choosing which
    //      performance issue to consider "worst". See sortCriteria of class
    //      PerformanceIssueMgr.
    //   2) Whether to ignore Missd Nots during PerformanceAnalysis (they can
    //      get in the way if you stop the performance early to test something -
    //      you will most likely "miss" the last note).
    //   3) Turn on/off showing Notes and Sounds on the SeeScore scroll view
    //

    var showDebugSettingsBtn: UIButton?

    func setupDebugSettingsBtn() {
        guard gMKDebugOpt_ShowDebugSettingsBtn else { return }

        let btnWd: CGFloat     = 110.0
        let btnHt: CGFloat     = 45.0
        let debugBtnFrame = CGRect( x: 10,  y: 45,
                                    width: btnWd, height: btnHt )
        showDebugSettingsBtn = UIButton(frame: debugBtnFrame)
        showDebugSettingsBtn?.roundedButton()
        showDebugSettingsBtn?.backgroundColor =  (UIColor.blue).withAlphaComponent(0.05)
        showDebugSettingsBtn?.addTarget(self,
                           action: #selector(doShowDebugSetupBtnPressed(sender:)),
                           for: .touchUpInside )
        showDebugSettingsBtn?.isEnabled = true
        showDebugSettingsBtn?.titleLabel?.lineBreakMode = .byWordWrapping
        let btnStr = "    Performance\nGrading Settings"
        let btnAttrStr =
            NSMutableAttributedString( string: btnStr,
                                       attributes: [NSAttributedStringKey.font:UIFont(
                                        name: "System Font",
                                        size: 11.0)!])
        showDebugSettingsBtn?.titleLabel?.attributedText = btnAttrStr
        showDebugSettingsBtn?.setTitle(btnStr, for: .normal)
        showDebugSettingsBtn?.setTitleColor( (UIColor.black).withAlphaComponent(0.4),
                                             for: .normal )
        self.view.addSubview(showDebugSettingsBtn!)
    }

    var perfSettingsPopView: PerfAnalysisSettingsPopupView?

    @objc func doShowDebugSetupBtnPressed(sender: UIButton) {
        guard gMKDebugOpt_ShowDebugSettingsBtn else { return }

        if perfSettingsPopView == nil {
            let sz = PerfAnalysisSettingsPopupView.getSize()
            let frm = CGRect(x: 20, y: 35, width: sz.width, height: sz.height )
            perfSettingsPopView = PerfAnalysisSettingsPopupView.init(frame:frm)
            perfSettingsPopView?.settingsChangedDelegate = self
            self.view.addSubview(perfSettingsPopView!)
        }
        perfSettingsPopView?.showPopup()
    }

    // PerfAnalysisSettingsChangedProtocol func
    func perfAnalysisSettingsChange(_ whatChanged : Int)
    {
        guard gMKDebugOpt_ShowDebugSettingsBtn else { return }

        // Analysis sttings have been changed. Redo the analysis
        ssScrollView.turnHighlightOff()
        ssScrollView.clearNotePerformanceResults()
        performPostPerfAnalysis()
    }

    //MARK: - OverlayViewDelegate

    ////////////////////////////////////////////////////////////
    //   SeeScore view OverlayViewDelegate-related methods
    //

    func noteTapped(withThisID: Int32) {
        if FSAnalysisOverlayView.getShowNotesAnalysis() {
            PerformanceTrackingMgr.instance.displayPerfInfoAlert(
                perfNoteID: withThisID,
                parentVC: self )
        }
    }

    var vhView: VideoHelpView?
    let vhViewTag = 901 // just something unique

    var popVC: PopoverVC?
    
    func createVideoHelpView() {
        /*
        if self.popVC == nil {
            let sz = VideoHelpView.getSize()
            let horzSpacing = (self.view.frame.width - sz.width) / 2
            let x = horzSpacing * 1.75
            let frm = CGRect( x: x, y:40, width: sz.width, height: sz.height )
            self.popVC = PopoverVC.init(rect: frm)
        }
        */
        
        // I want to be able to quickly see these in a debug session.
        let scrnW    = ScreenSize.SCREEN_WIDTH
        let scrnH    = ScreenSize.SCREEN_HEIGHT
        let scrnMaxL = ScreenSize.SCREEN_MAX_LENGTH
        let scrnMinL = ScreenSize.SCREEN_MIN_LENGTH
        // supress warnings about unused vars
        if alwaysFalseToSuppressWarn() { print("\(scrnW), \(scrnH), \(scrnMaxL), \(scrnMinL)") }
        
        // 6s: 667, 375
        // SE: 568, 320
        
        if self.vhView == nil {
            let sz = VideoHelpView.getSize()
            let horzSpacing = (self.view.frame.width - sz.width) / 2
            let x = horzSpacing * 1.75
            var y = CGFloat(40.0)
            if DeviceType.IS_IPHONE_5orSE {
                y = 25.0
            }
            let frm = CGRect( x: x, y:y, width: sz.width, height: sz.height )
            self.vhView = VideoHelpView.init(frame: frm)
            self.vhView?.tag = vhViewTag
            self.view.addSubview(self.vhView!)
            self.vhView?.doneShowingVideoDelegate = self
        }
    }

    func enableButtons(doEnable: Bool) {
        if doEnable {
            playButton.isEnabled = true
            playForMeButton.isEnabled = true
            doneBtn.isEnabled = true
            // backBtn.isEnabled = true
            // ssScrollView.isEnabled = true
        } else {
            playButton.isEnabled = false
            playForMeButton.isEnabled = false
            doneBtn.isEnabled = false
            // backBtn.isEnabled = false
            // ssScrollView.isEnabled = false
         }
    }
    
    func VideoViewClosed() {
        enableButtons(doEnable: true)
    }
    
    func scrollToNoteAndLaunchVideo(perfNoteID: Int32, videoID: Int, severity: Int) {

        // Only do the highlighting if there was acutally a note detected
        var considerHighlightGood = true
        if soundDetectedDuringSession {
            considerHighlightGood = ssScrollView.highlightScoreObject(perfNoteID, severity: Int32(severity))
        }
        
        if considerHighlightGood { // do the video . . .
            self.enableButtons(doEnable:false)
            delay(1.0) {
               
                if self.vhView == nil {
                    self.createVideoHelpView()
                }
                self.vhView?.videoID = videoID // vidIDs.kVid_Pitch_VeryLow_SpeedUpAir // videoID
                self.vhView?.showVideoVC()
                
                /*
                if self.popVC == nil {
                    self.createVideoHelpView()
                }
                if self.popVC != nil && self.popVC?.vhView != nil {
                    self.popVC?.vhView?.videoID = videoID // vidIDs.kVid_Pitch_VeryLow_SpeedUpAir // videoID
                    self.popVC?.vhView?.showVideoVC()
                    self.popVC?.modalPresentationStyle = .popover
                    self.present((self.popVC!), animated: true, completion: nil)
                    self.popVC!.popoverPresentationController?.sourceView = view
                    self.popVC!.popoverPresentationController?.sourceRect = sender.frame
                }
 */
            }
        }
    }

    func scrollToNoteAndLaunchAlert(perfNoteID: Int32, alertID: Int, severity: Int) {

        if ssScrollView.highlightScoreObject(perfNoteID, severity: Int32(severity)) {
            delay(1.0) {
                if self.vhView == nil {
                    self.createVideoHelpView()
                }
                self.vhView?.videoID = vidIDs.kVid_NoVideoAvailable
                let msgText = getMsgTextForAlertID(alertID)
                self.vhView?.showTempMsg(tempMsg: msgText)
            }
        }
    }

    func clearCurrNoteLines() {
        ssScrollView.clearCurrNoteLines()
    }
    
    func drawCurrNoteLineAt(xPos: CGFloat) {
        ssScrollView.drawCurrNoteLine(at: xPos-10)
    }
    
    func showAnalysisOverview(doShow: Bool) {
//        if doShow {
//            print("Showing Analysis View")
//        } else {
//            print("Hiding Analysis View")
//        }
        ssScrollView.showAnalysisOverview(doShow)
    }
    
    func freezeSeeScoreLayout() {
        // Keeps the SeeScore view from thrashing through unneeded
        // (and error-producing) calls to LayoutSubviews, etc.
        ssScrollView.freezeLayout()
    }
    
    //MARK: - Jumping Monkey stuff
    
    ////////////////////////////////////////////////////////////////////////////
    //  Jumping Monkey stuff

    var monkeyImageView: UIImageView? = nil

    func buildMonkeyImageView() {
        let mnkyImg1 = UIImage(named:"Monkey_Jumping Temples_monkey 06@2x")!
        let mnkyImg2 = UIImage(named:"Monkey_Jumping Temples_monkey 02@2x")!
        let mnkyImg3 = UIImage(named:"Monkey_Jumping Temples_monkey 03@2x")!
        let mnkyImg4 = UIImage(named:"Monkey_Jumping Temples_monkey 04@2x")!
        // iOS 10 or later:
        //  let emptyImg = UIGraphicsImageRenderer(size: mnkyImg1.size).image {_ in}
        UIGraphicsBeginImageContextWithOptions(mnkyImg1.size, false, 0.0);
        let emptyImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // Using images, alternate to create dancing . . .
        let imgArr = [mnkyImg1, mnkyImg2, mnkyImg1, mnkyImg2,
                      mnkyImg1, mnkyImg2, mnkyImg3, mnkyImg2,
                      mnkyImg3, mnkyImg4, mnkyImg3, mnkyImg4,
                      mnkyImg3, mnkyImg4, mnkyImg3, mnkyImg2,
                      // now hold the thumbs up pose for a bit:
                      mnkyImg1, mnkyImg1, mnkyImg1, mnkyImg1,
                      mnkyImg1, mnkyImg1, mnkyImg1, mnkyImg1]
        monkeyImageView = UIImageView(image:emptyImg)
        monkeyImageView?.frame.origin = CGPoint(x: 160, y: 63)
        self.view.addSubview(monkeyImageView!)
        monkeyImageView?.animationImages = imgArr
        monkeyImageView?.animationDuration = 2.5
        monkeyImageView?.animationRepeatCount = 1
    }

    func animateMonkeyImageView() {
        return;
    
//        if monkeyImageView == nil {
//            buildMonkeyImageView()
//        }
//        monkeyImageView?.startAnimating()
    }

    @objc func handleAVAudioInterruption(_ n: Notification) {
        print("In TuneExer::handleAVAudioInterruption")
        guard let why = n.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        guard let type = AVAudioSessionInterruptionType(rawValue: why) else { return }
        if type == .began {
            stopPlaying()
            if vhView != nil && !(vhView!.isHidden) {
                vhView?.stop_hide_andResignModal()
            }
        }
    }
    
    //MARK: - Testing or debugging related

    ////////////////////////////////////////////////////////////////////////////
    //
    //  Testing or debugging related, from here to end of file
    //
    ////////////////////////////////////////////////////////////////////////////

    func printAndTestAnalysisTables() {

        guard kMKDebugOpt_PrintPerfAnalysisValues else { return }

        let perfAnalysisMgr: PerformanceAnalysisMgr! = PerformanceAnalysisMgr.instance

        var tolerances = pitchAndRhythmTolerances()
        tolerances.setWithInverse( rhythmTolerance:         0.3,
                                   correctPitchPercentage:  0.03,
                                   aBitToVeryPercentage:    0.085,
                                   veryBoundaryPercentage:  0.60 )
        perfAnalysisMgr.rebuildAllAnalysisTables( tolerances )

        perfAnalysisMgr.brassPartialsTable.printAllPartials()
        print ("===================================================================")
        print ("\nAll Partials by Note\n")
        perfAnalysisMgr.brassPartialsTable.printAllPartialsByNote()
        print ("\n")

        ////////////////////////////////////////////////
        let aNote = NoteService.getNote(Int(NoteIDs.A4))
        if aNote != nil {
            print("")
            print("For \(aNote!.fullName), freq = \(aNote!.frequency)")
            print("")
        }

        func printNoteFRInfo(noteFR: tNoteFreqRangeData) {
            let lo = String(format: "%.3f", noteFR.freqRange.lowerBound)
            let hi = String(format: "%.3f", noteFR.freqRange.upperBound)
            print("!! noteWithFreqRange; Name: \(noteFR.noteFullName), ConcName: \(noteFR.concertNoteFullName), ConcPitch: \(noteFR.concertFreq), Range: \(lo)...\(hi)")
        }

        print("")
        var noteFR: tNoteFreqRangeData =
            perfAnalysisMgr.getNoteFreqRangeData(noteID: NoteIDs.F3)
        printNoteFRInfo(noteFR: noteFR)

        noteFR = perfAnalysisMgr.getNoteFreqRangeData(noteID: NoteIDs.C4)
        printNoteFRInfo(noteFR: noteFR)

        noteFR = perfAnalysisMgr.getNoteFreqRangeData(noteID: NoteIDs.E4)
        printNoteFRInfo(noteFR: noteFR)

        noteFR = perfAnalysisMgr.getNoteFreqRangeData(noteID: NoteIDs.C5)
        printNoteFRInfo(noteFR: noteFR)

        noteFR = perfAnalysisMgr.getNoteFreqRangeData(noteID: NoteIDs.C6)
        printNoteFRInfo(noteFR: noteFR)

        ////////////////////////////////////////////////
        print("")

        tolerances.setWithInverse( rhythmTolerance:         0.3,
                                   correctPitchPercentage:  0.020,
                                   aBitToVeryPercentage:    0.035,
                                   veryBoundaryPercentage:  0.050 )
        perfAnalysisMgr.rebuildAllAnalysisTables( tolerances)

        noteFR = perfAnalysisMgr.getNoteFreqRangeData(noteID: NoteIDs.F3)
        printNoteFRInfo(noteFR: noteFR)

        noteFR = perfAnalysisMgr.getNoteFreqRangeData(noteID: NoteIDs.E4)
        printNoteFRInfo(noteFR: noteFR)

        noteFR = perfAnalysisMgr.getNoteFreqRangeData(noteID: NoteIDs.C5)
        printNoteFRInfo(noteFR: noteFR)

        noteFR = perfAnalysisMgr.getNoteFreqRangeData(noteID: NoteIDs.C6)
        printNoteFRInfo(noteFR: noteFR)
        print("")
    }

    func printPostPerfDebugData(timingThreshold: Double) {

        guard kMKDebugOpt_PrintStudentPerformanceDataDebugOutput else { return }

        print ("\n\n")
        print ("timingThreshold is: \(timingThreshold)\n")
        for onePerfScoreObj in PerformanceTrackingMgr.instance.perfNotesAndRests {
            if onePerfScoreObj.isNote() {
                guard let oneExpNote: PerformanceNote = onePerfScoreObj as? PerformanceNote
                    else { return }
                
                let expectedStart = oneExpNote.expectedStartTime
                if oneExpNote.linkedToSoundID == noSoundIDSet {
                    print ( "Note ID: \(oneExpNote.perfNoteOrRestID) is not linked to a sound" )
                    print ( "  ExpectedStart Time: \(expectedStart)" )
                }
                else {
                    let actualStart   = oneExpNote.actualStartTime_song
                    let diff          = actualStart - expectedStart
                    let endTime       = oneExpNote.actualEndTime_song
                    let duration      = oneExpNote.actualDuration
                    let expPitch      = oneExpNote.expectedFrequency
                    let actPitch      = oneExpNote.actualFrequency
                    let expMidiNote   = oneExpNote.expectedMidiNote
                    let actMidiNote   = oneExpNote.actualMidiNote

                    let expNote = NoteService.getNote(Int(expMidiNote))
                    let actNote = NoteService.getNote(Int(actMidiNote))

                    let expNoteName = expNote != nil ? expNote!.fullName : ""
                    let actNoteName = actNote != nil ? actNote!.fullName : ""

                    print ( "Note ID: \(oneExpNote.perfNoteOrRestID) is linked to sound \(oneExpNote.linkedToSoundID)" )
                    print ( "  ExpectedStart Time: \(expectedStart)" )
                    print ( "  Actual Start Time:  \(actualStart)" )
                    print ( "  Difference:         \(diff)" )
                    print ( "  End Time:           \(endTime)" )
                    print ( "  Duration:           \(duration)" )
                    print ( "  ExpectedPitch:      \(expPitch)" )
                    print ( "  Actual Pitch:       \(actPitch)" )
                    print ( "  Expected MIDI Note: \(expMidiNote) - \(expNoteName)" )
                    print ( "  Actual MIDI Note:   \(actMidiNote) - \(actNoteName)" )
                    let avgPitch      = oneExpNote.averageFrequency()
                    print ( "  AveragePitch:       \(avgPitch)" )
                }
            }
        }
        print ("\n\n")
    }
}

struct StarScoreMgr {
    var songLength: Double = 0.0
    var furthestThroughSong: Double = 0.0
    var scoreForPortionCompleted: Int = 0
    
    var calculatedScore: Int {
        guard songLength > 0.0 else { return 0 }
        
        let percentThruSong = furthestThroughSong/songLength
        let calcedScore = Double(scoreForPortionCompleted) * percentThruSong
        let calcedScoreInt = Int(round(calcedScore))
        return calcedScoreInt
    }
    
    init() {
    }
}
