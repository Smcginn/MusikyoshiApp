//
//  TuneExerciseViewController.swift
//  FirstStage
//
//  Created by David S Reich on 14/05/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//

import UIKit
import AVFoundation

class TuneExerciseViewController: UIViewController, SSSyControls, SSUTempo, SSNoteHandler, SSSynthParameterControls, SSFrequencyConverter,
OverlayViewDelegate,PerfAnalysisSettingsChanged {


    @IBOutlet weak var ssScrollView: SSScrollView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playForMeButton: UIButton!
    @IBOutlet weak var countOffLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var gateView: UIView!
    @IBOutlet weak var metronomeView: VisualMetronomeView!

    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    // protocol SSFrequencyConverter

    /*!
     @method frequency:
     @abstract convert a midi pitch to frequency
     */
    public func frequency(_ midiPitch: Int32) -> Float {
        return intonation.frequency(midiPitch)
    }

    //protocol SSSynthParameterControls

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

    private let intonation = Intonation(temperament: Intonation.Temperament.Equal)

    private var kSynthesizedInstrumentsInfo : [SSSynthesizedInstrumentInfo] {
        get {
            var rval = [SSSynthesizedInstrumentInfo]()
            rval.append(SSSynthesizedInstrumentInfo("Tick", volume: Float(1.0), type:sscore_sy_tick1, attack_time_ms:4, decay_time_ms:20, flags:0, frequencyConv: nil, parameters: nil))
            rval.append(SSSynthesizedInstrumentInfo("Waveform", volume: Float(1.0), type:sscore_sy_pitched_waveform_instrument, attack_time_ms:4, decay_time_ms:20, flags:0, frequencyConv: self, parameters: self))
            return rval
        }
    }

//    let feedbackView = FeedbackView()

    var exerciseName = ""
    var isTune = false

//    let mxmlService = MusicXMLService()
    let amplitudeThreshold = UserDefaults.standard.double(forKey: Constants.Settings.AmplitudeThreshold)
    let timingThreshold = UserDefaults.standard.double(forKey: Constants.Settings.TimingThreshold)
    let tempoBPM = UserDefaults.standard.integer(forKey: Constants.Settings.BPM)
    let transpositionOffset = UserDefaults.standard.integer(forKey: Constants.Settings.Transposition)
    let frequencyThreshold = UserDefaults.standard.double(forKey: Constants.Settings.FrequencyThreshold)
    let showNoteMarkers = UserDefaults.standard.bool(forKey: Constants.Settings.ShowNoteMarkers)

    var score: SSScore?
    var showingSinglePart = false // is set when a single part is being displayed
    var showingSinglePartIndex: Int32 = 0
    var	showingParts = [NSNumber]()
    var layOptions = SSLayoutOptions()  // set of options for layout
    var playData: SSPData?
    var synth: SSSynth?
//    var instrumentId = [UInt32]()
//    var metronomeInstrumentId: UInt32 = 0

    private static  let kDefaultRiseFallSamples = 4
    private var synthVoice = SSSynthVoice.Sampled
    private var waveformSymmetryValue = Float(0.5)
    private var waveformRiseFallValue = kDefaultRiseFallSamples // samples in rise/fall of square waveform

    private var sampledInstrumentIds = [UInt]()
    private var synthesizedInstrumentIds = [UInt]()
    private var metronomeInstrumentIds = [UInt]()
    private static let kMaxInstruments = 10

    var cursorBarIndex = Int32(0)
//    let kDefaultMagnification: Float = 1.5
    let kDefaultMagnification: Float = UserDefaults.standard.float(forKey: Constants.Settings.ScoreMagnification) / 10.0
    var metronomeOn = false
    var beatsPerBar = 0

    var playingSynth = false    //if !playingSynth then must be analysing

//    var tickPlayer: AVAudioPlayer?

//    // 3 metronome ticks are currently supported (tickpitch = 0, 1 or 2):
//    //    static const sscore_sy_synthesizedinstrumentinfo kTick1Info = {"Tick1", 0, 1.0};
//    var kTick1Info = sscore_sy_synthesizedinstrumentinfo(instrument_name: ("Tick1" as NSString).utf8String, tickpitch: Int32(0), volume: Float(1.0), voice: sscore_sy_tick1, dummy: (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))

    let kfAnim = CAKeyframeAnimation()
    var exerciseDuration = 0.0
    var animHorzOffset = 0.0
    var animValues = [Double]()
    var animKeyTimes = [Double]()
    var playingAnimation = false

    var analysisTimer: Timer?
    var startTime : Date = Date()
    var thresholdStartTime = 0.0
    var thresholdEndTime = 0.0
    var frequencyThresholdPercent = Double(0.0)
    var targetPitch = Double(0.0)
    var lowPitchThreshold = Double(0.0)
    var highPitchThreshold = Double(0.0)
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
    //used for colored notes
    let kUseColoredNotes = false
    var currentNotes = [AnyObject]()

    // Needed by PerformanceTrackingMgr methods
    var songStartTm : Date = Date() {
        didSet {
            PerformanceTrackingMgr.instance.songStartTime = songStartTm
        }
    }
    var songStartTmOffset : TimeInterval = 0.0 {
        didSet {
            PerformanceTrackingMgr.instance.songStartTimeOffset = songStartTmOffset
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
    let beatMillisecOffset:Int32 = -40 // Suggest trying between -40 and -100 . . .
    var trackingAudioAndNotes = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gateView.isHidden = true
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
//        setupSounds()

        ssScrollView.overlayViewDelegate = self
        setupDebugSettingsBtn()
        if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput {
            printAndTestAnalysisTables()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight)
    }

    override func viewWillDisappear(_ animated: Bool) {
        stopPlaying()
        if vhView != nil {
            vhView?.hideVideoVC()
            vhView?.cleanup()
            if let viewWithTag = self.view.viewWithTag(vhViewTag) {
                viewWithTag.removeFromSuperview()
            }
            vhView = nil
        }
        super.viewWillDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func playButtonTapped(_ sender: UIButton) {

        // remove when Video help view is more correct (Modal, etc.) and this
        // is not an issue
        if vhView != nil && !(vhView!.isHidden) {
            vhView?.hideVideoVC()
        }

        playForMeButton.isEnabled = false
        if playButton.currentTitle == "Start Playing" {
//            playButton.setTitle("Stop", forState: UIControlState.Normal)
            playButton.setTitle("Listening ...", for: UIControlState())
//            playButton.isEnabled = false
            playScore()
            trackingAudioAndNotes = true
        } else if playButton.currentTitle == "Next Exercise" {
            //TODO: goto Next Exercise
            _ = navigationController?.popViewController(animated: true)
            return
        } else {
            stopPlaying()
        }
    }

    @IBAction func playForMeButtonTapped(_ sender: UIButton) {

        // remove when Video help view is more correct (Modal, etc.) and this
        // is not an issue
        if vhView != nil && !(vhView!.isHidden) {
            vhView?.hideVideoVC()
        }

        playingSynth = true
        playForMeButton.isEnabled = false
        playButton.setTitle("Playing ...", for: UIControlState())
        playScore()
    }

    func loadFile(_ scoreFile: String) {
        playButton.setTitle("Start Playing", for: UIControlState())
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
        loadOptions?.checkxml = true

//        let errP = UnsafeMutablePointer<sscore_loaderror>.allocate(capacity: 1)
        var err : SSLoadError?

        print("filePath: \(filePath)")
        print("loadOptions: \(String(describing: loadOptions))")
//        print("errP: \(errP)")


        ////////////
        guard let xmlData = MusicXMLModifier.modifyXMLToData(musicXMLUrl: URL(fileURLWithPath: filePath), smallestWidth: UserDefaults.standard.double(forKey: Constants.Settings.SmallestNoteWidth), signatureWidth: UserDefaults.standard.double(forKey: Constants.Settings.SignatureWidth)) else {
            print("Cannot get modified xmlData from \(filePath)!")
            return
        }
        ////////////

//        if let score0 = SSScore(xmlFile: filePath, options: loadOptions, error: errP) {
//        if let score0 = SSScore(xmlFile: filePath, options: loadOptions, error: &err) {
        if let score0 = SSScore(xmlData: xmlData, options: loadOptions, error: &err) {
            score = score0
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
//            } else {
//                ssScrollView.optimalSingleSystem = true
            }
            //            ssScrollView.setupScore(score, openParts: showingParts, mag: kDefaultMagnification, opt: layOptions)
            ssScrollView.setupScore(score, openParts: showingParts, mag: kDefaultMagnification, opt: layOptions, completion: getPlayData)
        }

        if let err = err {
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
        if playingSynth {
            if isTune {
                infoLabel.text = "Listen - and play the notes"
            } else {
                infoLabel.text = "Listen - and clap at the beginning of each note and count the beats"
            }
        } else
        if isTune {
            infoLabel.text = "Play the notes"
        } else {
            infoLabel.text = "Clap at the beginning of each note and count the beats"
        }

        ssScrollView.contentOffset = CGPoint.zero
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
        playData = SSPData.createPlay(from: score, tempo: self)
        guard playData != nil else { return }

        let beatsPerBar = score!.getBarBeats( 0,  bpm: Int32(tempoBPM),
                                              barType: sscore_bartype_full_bar)
        PerformanceTrackingMgr.instance.setPlaybackVals(
                                    tempoInBPM: tempoBPM,
                                    beatsPerBar: Int(beatsPerBar.beatsinbar) )

        ssScrollView.clearAllColouring()

        if synth != nil && (synth?.isPlaying)! {
            synth?.reset()
        } else {
            if synth == nil {
                if let synth0 = SSSynth.createSynth(self, score: score) {
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
                synth?.setEnd(EndHandler(vc: self), delay: 0)
                synth?.setBeat(BeatHandler(vc: self), delay: beatMillisecOffset)

                var err = synth?.setup(playData)
                if err == sscore_NoError {
                    let delayInSeconds = 2.0
                    let startTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(delayInSeconds * 1000.0))
//                    let startTime = DispatchTime.now() + Double(Int64(delayInSeconds * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
                    err = synth?.start(at: startTime.rawValue, bar: cursorBarIndex, countIn: true)

                }

                print("synth.start err == \(String(describing: err))")
                if err == sscore_UnlicensedFunctionError {
                    print("synth license expired!")
                } else if err != sscore_NoError {
                    print("synth failed to start: \(String(describing: err))")
                }
            }
        }
    }

    func stopPlaying() {
        let doPostPerfAnalysis = !playingSynth && trackingAudioAndNotes
        playingSynth = false
        trackingAudioAndNotes = false
        shouldSetSongStartTime  = true

        metronomeView.setBeat(-1)
        stopAnalysisTimer()

        gateView.isHidden = true

        if (synth != nil && synth!.isPlaying)
        {
            synth?.reset()
            countOffLabel.isHidden = true;
        }

        if playingAnimation {
            playingAnimation = false
            ssScrollView.layer.removeAnimation(forKey: "move")
        }

        playButton.setTitle("Start Playing", for: UIControlState())
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
            performPostPerfAnalysis()
        }
    }

    func performPostPerfAnalysis()
    {
        PerformanceTrackingMgr.instance.analyzePerformance()

        printPostPerfDebugData(timingThreshold: timingThreshold)

        // Send PerfNote info to SeeScore overlay view - needed by a subview to
        // determine location of highlighted note, if called on to highlight.
        for onePerfNote in PerformanceTrackingMgr.instance.performanceNotes {
            let weightedAsInt32 : Int32 = Int32(onePerfNote.weightedScore)
            let xPos = CGFloat(onePerfNote.xPos)
            let yPos = CGFloat(onePerfNote.yPos)
            self.ssScrollView.addNotePerformanceResult(
                atXPos: xPos,
                atYpos: yPos,
                withWeightedRating: weightedAsInt32,
                withRhythmResult: 0,
                withPitchResult: 0,
                noteID:  onePerfNote.perfNoteID,
                isLinked: onePerfNote.isLinkedToSound,
                linkedSoundID: onePerfNote.linkedToSoundID )
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

        // Reacting to worst issue must be delayed slightly
        delay(0.1) {
            let worstPerfIssue = PerformanceIssueMgr.instance.getFirstPerfIssue()
            if worstPerfIssue != nil {
                let perfNoteID:Int32 = worstPerfIssue!.perfNoteID
                if worstPerfIssue!.videoID != vidIDs.kVid_NoVideoAvailable {
                    self.scrollToNoteAndLaunchVideo(perfNoteID: perfNoteID,
                                                    videoID: worstPerfIssue!.videoID)
                }
                else if worstPerfIssue!.alertID != alertIDs.kAlt_NoAlertMsgAvailable {
                    self.scrollToNoteAndLaunchAlert(perfNoteID: perfNoteID,
                                                    alertID: worstPerfIssue!.alertID)
                }
            }
        }
    }

    //build arrays for CAKeyframeAnimation of UIScrollView (base class of SSScrollView)
    //maybe also collect breath marks?
    func getPlayData() {
        guard score != nil else { return }

        DispatchQueue.main.async(execute: {
            if let numBeats = self.score?.actualBeats(forBar: 1) {
                self.beatsPerBar = Int(numBeats.numbeats)
//                self.metronomeView.numBeats = Int(numBeats.numbeats)
                self.metronomeView.numBeats = self.beatsPerBar
                self.metronomeView.rebuildMetronome()
            }
        });

        playData = SSPData.createPlay(from: score, tempo: self)
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
            // SCF - look to this area for smoothing out scrolling. Perhaps
            // using bar start only ?

            //we just have one part
            let part = bar.part(0)
            for note in (part?.notes)! {
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
                }

                // Exclude the second note of a cross-bar tied note pair, which has a negative
                // start-from-bar-start time (i.e., previous measure). All data needed for animation
                // is in the first note of pair - including duration of combined 1st & 2nd notes.
                if startFromBarBeginning >= 0 {
                    animValues.append(thisNoteXPos - animHorzOffset)
                    animKeyTimes.append(Double(barsDuration_ms + Int(note.start)) / Double(exerciseDuration_ms))
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
        kfAnim.duration = exerciseDuration
        kfAnim.isAdditive = true
    }

    //MARK: Analysis

    func startAnalysisTimer() {
        //don't start twice
        guard !analysisStarted else { return }
        analysisStarted = true

        startTime = Date()

        AudioKitManager.sharedInstance.start()
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

        AudioKitManager.sharedInstance.stop()
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

        let perfTrkgMgr: PerformanceTrackingMgr! = PerformanceTrackingMgr.instance
        guard perfTrkgMgr != nil else { return }

        // Do one of:
        // 1) If there is a signal and exsiting Sound, update it.
        //   Edge case: playing legato, and changing from one note to another.
        //              There will be an existing Sound, so need to detect change
        //              in pitch, and stop the current sound and start a new one.
        // 2) Detect the start of a Sound, or
        // 3) Detect the the end of a Sound
        // (4 - no signal and no existing Sound, then do nothing)

        let currAmpltd = AudioKitManager.sharedInstance.frequencyTracker.amplitude
        let signalDetected : Bool = currAmpltd > kAmplitudeThresholdForIsSound
        let currFreq = AudioKitManager.sharedInstance.frequencyTracker.frequency
        let timeSinceAnalysisStart : TimeInterval = Date().timeIntervalSince(startTime)
        let timeSinceSongStart =
            timeSinceAnalysisStart - PerformanceTrackingMgr.instance.songStartTimeOffset

        if signalDetected && PerformanceTrackingMgr.instance.currentlyTrackingSound {
            // Currently tracking a sound; update it

            guard let currSound : PerformanceSound = perfTrkgMgr.currentSound else { return }

            if !currSound.initialPitchHasStablized() { // Not enough samples yet
                currSound.addPitchSample(pitchSample: currFreq) // Just update, no qualifying

            } else { // sound with stable pitch exists
                let oldFreq = currSound.averagePitchRunning
                if areDifferentNotes( pitch1: oldFreq, pitch2: currFreq ) {
                    // The student could be playing legato, transitioning to diff note.
                    // Need multiple samples to determine this. Add this diff pitch, then
                    // test to see if that crossed threshold to determine for sure.
                    currSound.addDifferentPitchSample(sample: currFreq,
                                                      sampleTime: timeSinceAnalysisStart)
                    if currSound.isDefinitelyADifferentNote() { // last sample decided it
                        // Stop this sound

                        if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput {
                            print ("  Stopping current sound (due to legato split) at \(timeSinceSongStart)")
                        }
                        perfTrkgMgr.updateCurrentNoteIfLinked()

                        // get the x-coord of the spot where a sound should be
                        // drawn on the scroll view - for debugging
                        var currXOffset = Int(ssScrollView.getCurrentXOffset())
                        currXOffset -= kOverlayPixelAdjustment
                        if let currSound = perfTrkgMgr.currentSound {
                            currSound.xOffsetEnd = firstNoteOrRestXOffset + currXOffset
                        }

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

                        // After creating new sound, need to re-establish currentSound opt.
                        if let newSound = perfTrkgMgr.currentSound {
                            newSound.xOffsetStart = firstNoteOrRestXOffset + currXOffset
                            newSound.forceAveragePitch(pitchSample: currFreq)
                            // see if there's an unclaimed note
                            perfTrkgMgr.linkCurrSoundToCurrNote()
                            if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput {
                                print (" \nCreated new sound \(newSound.soundID) (due to legato split) at \(timeSinceSongStart)")
                            }
                        }
                    }
                }
                else { // pitch is same as current sound a verage, so just update.
                    currSound.addPitchSample(pitchSample: currFreq)
                }
            }
        }

        else if signalDetected && !perfTrkgMgr.currentlyTrackingSound && notInCountdown {
            // New sound detected

            let soundMode : soundType = isTune ? .pitched : .percusive
            perfTrkgMgr.startTrackingPerformanceSound(
                startAt: timeSinceAnalysisStart,
                soundMode: soundMode,
                noteOffset: perfTrkgMgr.songStartTimeOffset )
            perfTrkgMgr.linkCurrSoundToCurrNote() // see if there's an unclaimed note

            var soundID: Int32 = 0
            if let currSound = perfTrkgMgr.currentSound {
                var currXOffset = Int(ssScrollView.getCurrentXOffset())
                currXOffset -= kOverlayPixelAdjustment
                currSound.xOffsetStart = firstNoteOrRestXOffset + currXOffset
                soundID = currSound.soundID
                if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput {
                    print (" \nCreating new sound \(soundID) at \(timeSinceSongStart)")
                }
            }
        }

        else if !signalDetected && perfTrkgMgr.currentlyTrackingSound {
            // Existing sound ended

            if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput {
                print ("  Stopping dead sound at \(timeSinceSongStart)")
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
        }
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
        let amplitude = AudioKitManager.sharedInstance.frequencyTracker.amplitude
        let frequency = AudioKitManager.sharedInstance.frequencyTracker.frequency

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

    //MARK: SSSyControls protocol
    func partEnabled(_ partIndex: Int32) -> Bool {
        return true;
    }

    func partInstrument(_ partIndex: Int32) -> UInt32 {
        guard playingSynth else
        {
            return 0
        }

//        if (kNumSampledInstruments > 1) {
//            return instrumentId[1]
//        }
//        return instrumentIds[0] // we can return any other instrument here
        if synthVoice == SSSynthVoice.Sampled {
            return UInt32(instrumentForPart(partIndex : Int(partIndex)))
        } else if !synthesizedInstrumentIds.isEmpty {
            return UInt32(synthesizedInstrumentIds[0])
        }
        return 0
  }

    func instrumentForPart(partIndex : Int) -> UInt
    {
        guard !sampledInstrumentIds.isEmpty else { return 0 }

        var index = 0
        if sampledInstrumentIds.count > 1 {
            index = UserDefaults.standard.bool(forKey: Constants.Settings.PlayTrumpet) ? 1 : 0
        }

        return sampledInstrumentIds[index]

//        if let iid = instrumentToPart_cache[partIndex]
//        {
//            return iid
//        }
//        else
//        {
//            if let score = score
//            {
//                // try matching part name to library instrument
//                let partName = score.header.parts[partIndex]
//                if let full_name = partName.full_name
//                {
//                    if full_name.characters.count > 0
//                    {
//                        let matchingIndex = indexOfInstrumentMatchingName(name: partName.full_name)
//                        if matchingIndex >= 0 && matchingIndex < SSSampleViewController.kMaxInstruments
//                        {
//                            let iid = sampledInstrumentIds[matchingIndex]
//                            instrumentToPart_cache[partIndex] = iid
//                            return iid
//                        }
//                    }
//                }
//                // try matching instrument name to library instrument
//                if let instrumentNameForPart = score.instrumentName(forPart: Int32(partIndex))
//                {
//                    if instrumentNameForPart.characters.count > 0
//                    {
//                        let matchingIndex = indexOfInstrumentMatchingName(name: instrumentNameForPart)
//                        if matchingIndex >= 0 && matchingIndex < SSSampleViewController.kMaxInstruments
//                        {
//                            let iid = sampledInstrumentIds[matchingIndex]
//                            instrumentToPart_cache[partIndex] = iid
//                            return iid
//                        }
//                    }
//                }
//            }
//            let iid = sampledInstrumentIds[0] // default is first in list (piano) if no name match
//            instrumentToPart_cache[partIndex] = iid
//            return iid
//        }
    }

    func partVolume(_ partIndex: Int32) -> Float {
        if playingSynth {
            return 1.0
        } else {
            return 0.0
        }
    }

    func metronomeEnabled() -> Bool {
        return metronomeOn
    }

    func metronomeInstrument() -> UInt32 {
        if !metronomeOn {
            return 0
        }

        if metronomeInstrumentIds.isEmpty {
            return 0
        }

        return UInt32(metronomeInstrumentIds[0])
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
    func end(_ note: SSPDPartNote!) {
        if note.note.midiPitch > 0 {
            insideNote = false
        } else {
            insideRest = false
        }

        currNoteXPos = -1.0
        PerformanceTrackingMgr.instance.currentlyInAScoreNote = false

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
            gateView.isHidden = false
            print("addAnimation!")
//            print("anim.values: \(kfAnim.values)")
//            print("keyTimes: \(kfAnim.keyTimes)")
            print("anim.duration: \(kfAnim.duration)")
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
        let barStartIntvl =
            mXMLNoteStartInterval( bpm: bpm(),
                                   beatsPerBar: Int32(beatsPerBar),
                                   startBarIndex: nsNote.startBarIndex,
                                   noteStartWithinBar: nsNote.start )
        newNote.expectedStartTime = barStartIntvl
        newNote.expectedDuration = Double(noteDur) / 1000.0
        newNote.xPos = Int32(xpos)
        newNote.yPos = Int32(ypos)

        newNote.expectedMidiNote = NoteID(nsNote.midiPitch)

        PerformanceTrackingMgr.instance.performanceNotes.append( newNote )
        PerformanceTrackingMgr.instance.currentPerfNote = newNote
        PerformanceTrackingMgr.instance.linkCurrSoundToCurrNote()

        if let freq = NoteService.getNote( Int(nsNote.midiPitch) )?.frequency {
            targetPitch = freq
            newNote.expectedFrequency = freq
        }
    }

    //this only makes sense if setNoteHandler() delay is -timingThreshold
    func setNoteThresholdState(_ notes: NSArray) {
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
        // normally this will not need to iterate over the whole chord, but will exit as soon as it has a valid xpos
        for note in notes as! [SSPDPartNote] {
            // priority given to notes over rests, but ignore cross-bar tied notes
            //   (negative note.start means note started prev measure - unique to 2nd note of cross-bar tie)
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

        @objc func event(_ index: Int32, countIn isCountIn: Bool) {
            svc.countOffLabel.isHidden = !isCountIn;
            if isCountIn {
                svc.countOffLabel.text = "\(index + 1)"
                if !svc.playingSynth {
                    svc.startAnalysisTimer()
                }

                if index >= Int32(svc.beatsPerBar - 1) {
                    svc.metronomeOn = false
                    svc.synth?.changedControls()
                    svc.notInCountdown = true
                }
//                svc.playTickSound()
            }
            else if svc.shouldSetSongStartTime {
                let msOffset = TimeInterval(abs(svc.beatMillisecOffset/1000))
                let nowPlus = Date().addingTimeInterval(msOffset)
                svc.songStartTm = nowPlus
                svc.songStartTmOffset = svc.songStartTm.timeIntervalSince(svc.startTime)
                svc.shouldSetSongStartTime  = false
            }

            svc.metronomeView.setBeat(Int(index))
        }
    }

    class EndHandler: SSEventHandler {
        let svc: TuneExerciseViewController

        init(vc: TuneExerciseViewController) {
            svc = vc
        }

        @objc func event(_ index: Int32, countIn isCountIn: Bool) {
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

    /*
    // MARK: - Navigation

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
        guard kMKDebugOpt_ShowDebugSettingsBtn else { return }

        let btnWd: CGFloat     = 110.0
        let btnHt: CGFloat     = 45.0
        let debugBtnFrame = CGRect( x: 10,  y: 45,
                                    width: btnWd, height: btnHt )
        showDebugSettingsBtn = UIButton(frame: debugBtnFrame)
        showDebugSettingsBtn?.roundedButton()
        showDebugSettingsBtn?.backgroundColor = (UIColor.blue).withAlphaComponent(0.05)
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
        guard kMKDebugOpt_ShowDebugSettingsBtn else { return }

        if perfSettingsPopView == nil {
            let sz = PerfAnalysisSettingsPopupView.getSize()
            let frm = CGRect(x: 20, y: 60, width: sz.width, height: sz.height )
            perfSettingsPopView = PerfAnalysisSettingsPopupView.init(frame:frm)
            perfSettingsPopView?.settingsChangedDelegate = self
            self.view.addSubview(perfSettingsPopView!)
        }
        perfSettingsPopView?.showPopup()
    }

    // PerfAnalysisSettingsChangedProtocol func
    func perfAnalysisSettingsChange(_ whatChanged : Int)
    {
        guard kMKDebugOpt_ShowDebugSettingsBtn else { return }

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

    func createVideoHelpView() {
        if self.vhView == nil {
            let sz = VideoHelpView.getSize()
            let horzSpacing = (self.view.frame.width - sz.width) / 2
            let x = horzSpacing * 1.75
            let frm = CGRect( x: x, y:40, width: sz.width, height: sz.height )
            self.vhView = VideoHelpView.init(frame: frm)
            self.vhView?.tag = vhViewTag
            self.view.addSubview(self.vhView!)
        }
    }

    func scrollToNoteAndLaunchVideo(perfNoteID: Int32, videoID: Int) {

        if ssScrollView.highlightNote(perfNoteID) {
            delay(1.0) {
                if self.vhView == nil {
                    self.createVideoHelpView()
                }
                self.vhView?.videoID = videoID
                self.vhView?.showVideoVC()
            }
        }
    }

    func scrollToNoteAndLaunchAlert(perfNoteID: Int32, alertID: Int) {

        if ssScrollView.highlightNote(perfNoteID) {
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
        if monkeyImageView == nil {
            buildMonkeyImageView()
        }
        monkeyImageView?.startAnimating()
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

        perfAnalysisMgr.trumpetPartialsTable.printAllPartials()
        print ("===================================================================")
        print ("\nAll Partials by Note\n")
        perfAnalysisMgr.trumpetPartialsTable.printAllPartialsByNote()
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
        for oneExpNote in PerformanceTrackingMgr.instance.performanceNotes {
            let expectedStart = oneExpNote.expectedStartTime
            if oneExpNote.linkedToSoundID == noSoundIDSet {
                print ( "Note ID: \(oneExpNote.perfNoteID) is not linked to a sound" )
                print ( "  ExpectedStart Time: \(expectedStart)" )
            }
            else {
                let actualStart   = oneExpNote.actualStartTime
                let diff          = actualStart - expectedStart
                let endTime       = oneExpNote.endTime
                let duration      = oneExpNote.actualDuration
                let expPitch      = oneExpNote.expectedFrequency
                let actPitch      = oneExpNote.actualFrequency
                let expMidiNote   = oneExpNote.expectedMidiNote
                let actMidiNote   = oneExpNote.actualMidiNote

                let expNote = NoteService.getNote(Int(expMidiNote))
                let actNote = NoteService.getNote(Int(actMidiNote))

                let expNoteName = expNote != nil ? expNote!.fullName : ""
                let actNoteName = actNote != nil ? actNote!.fullName : ""

                print ( "Note ID: \(oneExpNote.perfNoteID) is linked to sound \(oneExpNote.linkedToSoundID)" )
                print ( "  ExpectedStart Time: \(expectedStart)" )
                print ( "  Actual Start Time:  \(actualStart)" )
                print ( "  Difference:         \(diff)" )
                print ( "  End Time:           \(endTime)" )
                print ( "  Duration:         \(duration)" )
                print ( "  ExpectedPitch:      \(expPitch)" )
                print ( "  Actual Pitch:       \(actPitch)" )
                print ( "  Expected MIDI Note: \(expMidiNote) - \(expNoteName)" )
                print ( "  Actual MIDI Note:   \(actMidiNote) - \(actNoteName)" )
                let avgPitch      = oneExpNote.averageFrequency()
                print ( "  AveragePitch:       \(avgPitch)" )
            }
        }
        print ("\n\n")
    }
}
