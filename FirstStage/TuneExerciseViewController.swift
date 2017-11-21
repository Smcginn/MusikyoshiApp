//
//  TuneExerciseViewController.swift
//  FirstStage
//
//  Created by David S Reich on 14/05/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//

import UIKit
import AVFoundation
//import StudentPerfomanceData.swift

// Turn on/off subset of output to debug window
let DEBUG_PRINT_PLAYALONG__ALL = false

class TuneExerciseViewController: UIViewController, SSSyControls, SSUTempo, SSNoteHandler, SSSynthParameterControls, SSFrequencyConverter, OverlayViewDelegate {


    @IBOutlet weak var ssScrollView: SSScrollView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playForMeButton: UIButton!
    @IBOutlet weak var countOffLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var gateView: UIView!
    @IBOutlet weak var metronomeView: VisualMetronomeView!

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

    // Used by student Note and Sound Performance data and methods - SCF
    var songStartTime : Date = Date()
    var songStartTimeOffset : TimeInterval = 0.0
    var shouldSetSongStartTime  = true
    var currNoteXPos : CGFloat = -1.0
    var notInCountdown    = false

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
    }

    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight)
    }

    override func viewWillDisappear(_ animated: Bool) {
        stopPlaying()
        super.viewWillDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func playButtonTapped(_ sender: UIButton) {
        playForMeButton.isEnabled = false
        if playButton.currentTitle == "Start Playing" {
//            playButton.setTitle("Stop", forState: UIControlState.Normal)
            playButton.setTitle("Listening ...", for: UIControlState())
//            playButton.isEnabled = false
            playScore()
        } else if playButton.currentTitle == "Next Exercise" {
            //TODO: goto Next Exercise
            _ = navigationController?.popViewController(animated: true)
            return
        } else {
            stopPlaying()
        }
    }

    @IBAction func playForMeButtonTapped(_ sender: UIButton) {
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
        resetSoundAndNoteTracking()
        ssScrollView.clearNotePerformanceResults();

        guard score != nil else { return }
        playData = SSPData.createPlay(from: score, tempo: self)
        guard playData != nil else { return }

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
                let cursorAnimationTime_ms = Int32(timingThreshold * 1000)

//                if showNoteMarkers {
//                    let cursorAnimationTime = CATransaction.animationDuration()
//                    cursorAnimationTime_ms = Int32(cursorAnimationTime * 1000)
//                }

                synth?.setNoteHandler(self, delay: -cursorAnimationTime_ms)

                //                synth?.setBarChangeHandler(BarChangeHandler(vc: self), delay: -cursorAnimationTime_ms)
                //                synth?.setBarChangeHandler(BarChangeHandler(vc: self, anim: anim), delay: 0)
                synth?.setEnd(EndHandler(vc: self), delay: 0)
                synth?.setBeat(BeatHandler(vc: self), delay: 0)

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
        playingSynth = false
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

        // From this point to end of func, debugging printing for PerforamnceNotes
        guard kPrintStudentPerformanceDataDebugOutput else { return }

        print ("\n\n")
        print ("timingThreshold is: \(timingThreshold)\n")
        let numPNs = performanceNotes.count
        for oneExpNote in performanceNotes {
            if oneExpNote.linkedToSoundID == noSoundIDSet {
                print ( "Note ID: \(oneExpNote.noteID) is not linked to a sound" )
            }
            else {
                let expectedStart = oneExpNote.expectedStartTime
                let actualStart   = oneExpNote.actualStartTime
                let diff          = actualStart - expectedStart
                let endTime       = oneExpNote.endTime
                let duration      = oneExpNote.actualDuaration
                let expPitch      = oneExpNote.expectedFrequency

                print ( "Note ID: \(oneExpNote.noteID) is linked to sound \(oneExpNote.linkedToSoundID)" )
                print ( "  ExpectedStart Time: \(expectedStart)" )
                print ( "  Actual Start Time:  \(actualStart)" )
                print ( "  Difference:         \(diff)" )
                print ( "  End Time:           \(endTime)" )
                print ( "  Duration:         \(duration)" )
                print ( "  ExpectedPitch:      \(expPitch)" )
                let avgPitch      = oneExpNote.averageFrequency()
                print ( "  AveragePitch:       \(avgPitch)" )
            }
        }
        print ("\n\n")
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
            //we just have one part
            let part = bar.part(0)
            for note in (part?.notes)! {
//                let graceNote = (note.grace == sscore_pd_grace_no) ? "note" : "grace"
                //                print("part 0 \(graceNote) pitch:\(note.midiPitch) startbar:\(note.startBarIndex) start:\(note.start)ms duration:\(note.duration)ms at x=\(noteXPos(note))")

                thisNoteXPos = Double(noteXPos(note))

                if firstNote {
                    animHorzOffset = thisNoteXPos
                    print("animHorxOffset= \(animHorzOffset)")
                    firstNote = false
                }

                let startFromBarBeginning = note.start // start offset within current measure

                // Exclude the second note of a cross-bar tied note pair, which has a negative
                // start-from-bar-start time (i.e., previous measure). All data needed for animation
                // is in the first note of pair - including duration of combined 1st & 2nd notes.
                if startFromBarBeginning >= 0 {
                    animValues.append(thisNoteXPos - animHorzOffset)
                    animKeyTimes.append(Double(barsDuration_ms + Int(note.start)) / Double(exerciseDuration_ms))
                }

                // if this is a note (midiPitch == 0 means a rest) do some output for debugging support
                if DEBUG_PRINT_PLAYALONG__ALL && note.midiPitch != 0
                {
                    let thisBarIndex = bar.index
                    let noteStartBarIndex = note.startBarIndex
                    let duration = note.duration
                    print ("  In getPlayData:  thisNoteXPos = \(thisNoteXPos)")
                    print ("    noteStartBarIndex = \(noteStartBarIndex),    thisBarIndex = \(thisBarIndex)")
                    print ("    startFromBarBeginning = \(startFromBarBeginning),    duration = \(duration)")
                    if noteStartBarIndex != thisBarIndex {
                        print ("!! curr note didn't start in current bar  !!") }
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

    func trackSounds() {
        // Do one of:
        // 1) If there is a signal and exsiting Sound, update it.
        //   Edge case: playing legato, and changing from one note to another.
        //              There will be an existing Sound, so need to detect change
        //              in pitch, and stop the current sound and start a new one.
        // 2) Detect the start of a Sound, or
        // 3) Detect the the end of a Sound
        // (4 - no signal and no existing Sound, then do nothing)

        let kAmplitudeThresholdForIsSound = 0.05 // 0.01
        let currAmpltd = AudioKitManager.sharedInstance.frequencyTracker.amplitude
        let signalDetected : Bool = currAmpltd > kAmplitudeThresholdForIsSound
        let currFreq = AudioKitManager.sharedInstance.frequencyTracker.frequency
        let timeSinceAnalysisStart : TimeInterval = Date().timeIntervalSince(startTime)
        let timeSinceSongStart = timeSinceAnalysisStart - songStartTimeOffset

        if signalDetected && currentlyTrackingSound {
            // Currently tracking a sound; update it

            guard let currSound : StudentSound = currentSound else { return }

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

                        if kPrintStudentPerformanceDataDebugOutput {
                            print ("  Stopping current sound (due to legato split) at \(timeSinceSongStart)")
                        }
                        var splitTime: TimeInterval = 0.0
                        endCurrSoundAsNewPitchDetected( noteOffset: songStartTimeOffset,
                                                        splitTime: &splitTime )

                        // Create a new sound.
                        let soundMode : soundType = isTune ? .pitched : .percusive
                        startTrackingStudentSound(startAt: splitTime, soundMode:soundMode)

                        // After creating new sound, need to re-establish currentSound opt.
                        if let newSound = currentSound {
                            newSound.forceAveragePitch(pitchSample: currFreq)
                            linkCurrSoundToCurrNote() // see if there's an unclaimed note
                            if kPrintStudentPerformanceDataDebugOutput {
                                print (" \nCreated new sound \(newSound.soundID) (due to legato split) at \(timeSinceSongStart)")
                            }
                        }
                    }
                }
                else { // pitch is same as current sound average, so just update.
                    currSound.addPitchSample(pitchSample: currFreq)
                }
            }
        }

        else if signalDetected && !currentlyTrackingSound && notInCountdown {
            // New sound detected

            let soundMode : soundType = isTune ? .pitched : .percusive
            startTrackingStudentSound( startAt: timeSinceAnalysisStart, soundMode: soundMode)
            linkCurrSoundToCurrNote() // see if there's an unclaimed note

            var soundID: Int32 = 0
            if let currSound = currentSound {
                soundID = currSound.soundID
                if kPrintStudentPerformanceDataDebugOutput {
                    print (" \nCreating new sound \(soundID) at \(timeSinceSongStart)")
                }
            }
        }

        else if !signalDetected && currentlyTrackingSound {
            // Existing sound ended

            if kPrintStudentPerformanceDataDebugOutput {
                print ("  Stopping dead sound at \(timeSinceSongStart)")
            }
            endTrackedSoundAsSignalStopped(soundEndTime: timeSinceAnalysisStart,
                                           noteOffset: songStartTimeOffset )
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

    func analyzePerformance() {

        trackSounds()

        guard insideNote || insideRest else { return }

        let inThreshold = Date().timeIntervalSince(startTime) < thresholdEndTime
//        let amplitude = AudioKitManager.sharedInstance.amplitude()
//        let frequency = AudioKitManager.sharedInstance.frequency()
        let amplitude = AudioKitManager.sharedInstance.frequencyTracker.amplitude
        let frequency = AudioKitManager.sharedInstance.frequencyTracker.frequency
//        if DEBUG_PRINT_PLAYALONG__ALL {
//            print("  amplitude = \(amplitude),   freq = \(self.frequency)") }

        // FIXME? - I think this ignores and does not process the case where the rhythm is correct
        // but the note is wrong. Either rename "hasCorrectSound", or create two separate vars
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

        guard result != NoteAnalysis.NoteResult.noResult else { return }
        if insideNote {
            if result == NoteAnalysis.NoteResult.noteRhythmMatch ||
               result == NoteAnalysis.NoteResult.noteRhythmMiss  ||
               result == NoteAnalysis.NoteResult.noteRhythmLate {

                let resAsInt32 : Int32 = Int32(result.hashValue)
                ssScrollView.addNotePerformanceResult( atXPos: currNoteXPos,
                        withRhythmResult: resAsInt32, withPitchResult: 0 );
            }
        }




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
        if DEBUG_PRINT_PLAYALONG__ALL {
            NSLog ( "In TuneExerciseViewController::end")
            print ("")    } // blank line w/o timestamp.

        if note.note.midiPitch > 0 {
            insideNote = false
        } else {
            insideRest = false
        }

        currNoteXPos = -1.0
        currentlyInAScoreNote = false

    }

    /*!
     * @method startNotes:
     * @abstract called for each note/chord starting
     * @param notes an array of SSPDPartNote, the set of all notes in all parts which should be starting
     */
    public func start(_ notes: [SSPDPartNote]!) {
//        if DEBUG_PRINT_PLAYALONG__ALL {
//            print ("") // blank line w/o timestamp.
//            NSLog ( "In TuneExerciseViewController::start, notes.count = \(notes.count)" )
    //}

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
                return Float(comp.rect.origin.x + comp.rect.size.width / 2)
            }
        }

        return 0
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

                    /////////////////////////////////////////////
                    // Create a new PerformanceNote, add to appropriate container,
                    // link to sound if one exists

                    currNoteXPos = CGFloat(xpos)
                    currentlyInAScoreNote = true
                    let newNote : PerformanceNote = PerformanceNote.init()
                    // let noteID = newNote.noteID
                    let noteDur = note.note.duration
                    let noteDurTimeInterval = musXMLNoteUnitToInterval( noteDur: noteDur, bpm:bpm() )
                    let barStartIntvl =
                        mXMLNoteStartInterval( bpm:bpm(), beatsPerBar: Int32(beatsPerBar),
                                               startBarIndex: note.note.startBarIndex,
                                               noteStartWithinBar: note.note.start )
                    newNote.expectedStartTime = barStartIntvl
                    newNote.expectedDuaration = noteDurTimeInterval
                    newNote.xPos = Int32(xpos)
                    newNote.expectedMidiPitch = note.note.midiPitch

                    performanceNotes.append(newNote)
                    currentPerfNote = newNote
                    linkCurrSoundToCurrNote()

                    ///////////////////////////////////////////////

                    thresholdStartTime = Date().timeIntervalSince(startTime) - timingThreshold * 2
                    thresholdEndTime = Date().timeIntervalSince(startTime) + timingThreshold * 2
                    if DEBUG_PRINT_PLAYALONG__ALL {
                        print ("")
                        NSLog ( "  ->>> In setNoteThresholdState, deciding Note Rhythm and Pitch thresholds" )
                        let currTime = Date().timeIntervalSince(startTime)
                        print ( "    thresholdStartTime = \(thresholdStartTime)" )
                        print ( "    currTime           = \(currTime)" )
                        print ( "    thresholdEndTime   = \(thresholdEndTime)\n" )
                    }

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
                            newNote.expectedFrequency = freq
                            if DEBUG_PRINT_PLAYALONG__ALL {
                                print ( "    targetPitch        = \(targetPitch)" )
                                print ( "    lowPitchThreshold  = \(lowPitchThreshold)" )
                                print ( "    highPitchThreshold = \(highPitchThreshold)\n" )
                            }
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
                svc.songStartTime = Date()
                svc.songStartTimeOffset = svc.songStartTime.timeIntervalSince(svc.startTime)
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
 //           if UserDefaults.standard.bool(forKey: Constants.Settings.ShowAnalysis) && !svc.playingSynth {
                svc.showScore()
            svc.shouldSetSongStartTime  = true
            //}
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

    func findPerformanceNoteByStartTime(start: TimeInterval) -> PerformanceNote? {

        var returnNote : PerformanceNote? = nil

        // closure for comparing Entry's XPos against an acceptable range?

        let lowBound  = start - timingThreshold
        let highBound = start + timingThreshold

        let numPNs = performanceNotes.count
        for onePerformanceNote in performanceNotes {
            let expStart = onePerformanceNote.expectedStartTime
            if ( expStart >= lowBound && expStart <= highBound ) {
                returnNote = onePerformanceNote
                break;
            }
        }

        return returnNote
    }

    func findPerfomanceNoteByXPos(xPos: Int32) -> PerformanceNote? {

        var returnNote : PerformanceNote? = nil

        // closure for comparing Entry's XPos against an acceptable range?

        let lowBoundXpos  = xPos - 10
        let highBoundXpos = xPos + 10

        let numPNs = performanceNotes.count
        for onePerformanceNote in performanceNotes {
            let xPos = onePerformanceNote.xPos
            if ( xPos >= lowBoundXpos && xPos <= highBoundXpos ) {
                returnNote = onePerformanceNote
                break;
            }
        }

        return returnNote
    }

    // called when either a new note begins in the score, or new sound is detected
    func linkCurrSoundToCurrNote() {
        guard currentlyInAScoreNote && currentlyTrackingSound else { return }
        guard let currPerfNote : PerformanceNote = currentPerfNote else { return }
        guard let currSound : StudentSound = currentSound else { return }
        guard !currSound.isLinkedToNote && !currPerfNote.isLinkedToSound else { return }

        let diff = abs( soundTimeToNoteTime(songStart: currSound.startTime) -
                        currPerfNote.expectedStartTime  )
        if (diff <= timingThreshold ) {
            currPerfNote.linkToSound(soundID: currSound.soundID, sound: currSound)
            currSound.linkToNote(noteID: currPerfNote.noteID, note: currPerfNote)
            currPerfNote.actualStartTime = soundTimeToNoteTime(songStart: currSound.startTime)
        }
    }

    // For setting start time of note, adjusting for:
    //      note startTime is relative to songStart;
    //      sound startTime is relative to analysis Start.
    func soundTimeToNoteTime( songStart: TimeInterval ) -> TimeInterval {
        return songStart - songStartTimeOffset
    }


    func updateCurrentNoteIfLinked()
    {
        guard let currSound = currentSound else {return}
        guard let currNote  = currentPerfNote else {return}

        if currNote.linkedToSoundID == currSound.soundID {
             currNote.endTime = soundTimeToNoteTime(songStart: currSound.endTime)
        }
    }

// OverlayViewDelegate

    // func noteTappedAtXCoord(xCoord : Int32) ->() {
    func noteTapped(atXCoord xCoord: Int32) {

        let possibleNote: PerformanceNote? = findPerfomanceNoteByXPos(xPos: xCoord)
        guard let foundNote = possibleNote else { return }
    }

}
