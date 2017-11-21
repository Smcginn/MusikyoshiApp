//
//  StudentPerfomanceData.swift
//  FirstStage
//
//  Created by Scott Freshour on 11/6/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

//  Issues:
//      - The functions below that convert MusicXML durations/start times accept
//        BPM and beats per measure, etc. At a meta level, the use of
//        these funtions is correct as long as the Tempo and Meter (beats 
//        per measure) are constant throughout the song.
//        If we add songs that vary the tempo or meter, then other vars (at
//        a higher level, within the caller of these funcs) will need to be
//        added to store the interval up to the beginning of a specific
//        bar, etc. Also, the funcs will need to be adjusted as well.
//

/*   SCFTODO
 
- When playing legato, and a new note is detected by pitch change, should the old
  sound provide the dif samples for  the new sound
 
- change performanceSounds to non-optionals ?
 
 */

import Foundation

// If there is a current active Note from the score (that the student should be
// playing) these will be set (cleared when the Note ends, set for the next note, etc.)
public weak var currentPerfNote : PerformanceNote?
var currentlyInAScoreNote = false

// If there is a current active Sound, these will be set (cleared when the Sound 
// ends, set for the next Sound, etc.)
public weak var currentSound : StudentSound?
var currentlyTrackingSound = false

// Container of Expected Notes from the score. If there was an associated sound, 
// the sound data can be compared to the expectations for the given note.
var performanceNotes = [PerformanceNote]()

// Container of Sounds as they occured in real time. (may or may not be linked to Note)
var performanceSounds = [StudentSound?]()


//////////////////////////////////////////////////////////////////////////////
// Some tweakable settings relating to determing beginning and end of a sound

// Number of samples to let pass before before beginning to average the pitch, to
// consider it "stable". Without a little time to settle, pitch average is inaccurate
let kSamplesNeededToDeterminePitch = 10

// In legato playing: Number of consecutive samples consistantly not equal to established 
// pitch before considered a different note. (One or two variants in a stable pitch is 
// common, so must have a certain number in a row before commmiting to a new note.)
let kDifferentPitchSampleThreshold  = 10

// Save samples into a collection in the sound object? (useful for debugging)
// If no, a running sum is used to determine average. (Performance improvement)
let kSavePitchSamples = true
let kNumSamplesToCollect = 300

let kPrintStudentPerformanceDataDebugOutput = true

//   Note startTime is relative to songStart;
//   Sound startTime is relative to analysis Start.
//    (Two are necessary to be able to determine if first note is played early)
var soundToNoteOffset : TimeInterval = 0.0

let noNoteIDSet : Int32    =  0
let noSoundIDSet : Int32   =  0
let noTimeValueSet         =  0.0
let noPitchValueSet        =  0.0

let secsPerMin : TimeInterval = 60.0
let musicXMLUnitsPerQuarterNote : Int32 = 1000

enum soundType {
    case percusive  // Claps, etc.
    case pitched    // Trumpet, etc.
}


// Create a new StudentSound and add it to collection of sounds
@discardableResult
func startTrackingStudentSound( startAt: TimeInterval, soundMode: soundType)
    -> (StudentSound?) {
        
    guard (!currentlyTrackingSound) else { return nil }
    let newSound : StudentSound? = StudentSound.init(start: startAt,
                                                     mode:soundMode)
    guard newSound != nil  else {return nil}
        
    currentSound = newSound
    performanceSounds.append(newSound!)
    currentlyTrackingSound = true
    
    return newSound
}

// End current sound if signal stopped.  (Non-legato note change)
func endTrackedSoundAsSignalStopped(soundEndTime: TimeInterval,
                                    noteOffset: TimeInterval ) {
    guard currentlyTrackingSound, let currSound = currentSound else { return }
    
    currSound.endTime = soundEndTime
    
    if let soundsNote = currSound.linkedNoteObject {
        soundsNote.endTime = soundEndTime - noteOffset
    }
    
    currSound.printSoundResults()
    currentSound = nil
    currentlyTrackingSound = false
}

// End current sound if new note detected while playing legato
// - param splitTime: on return, set to when the old note ended and the new note started
func endCurrSoundAsNewPitchDetected( noteOffset: TimeInterval,
                                     splitTime: inout TimeInterval ) {
    guard currentlyTrackingSound, let currSound = currentSound else { return }
    
    splitTime = currSound.diffPitchSplitTime // end of old, start of new
    currSound.endTime = splitTime
    
    if let soundsNote = currSound.linkedNoteObject {
        soundsNote.endTime = splitTime - noteOffset
    }
    
    // stop current sound
    currSound.printSoundResults()
    currentSound = nil
    currentlyTrackingSound = false
}

enum timingRating { // for timingScore
    case notRated
    
    // attack
    case missed
    case veryEarly
    case slightlyEarly
    case timingGood
    case slightlyLate
    case veryLate
    
    // duration
    case veryShort
    case slightlyShort
    case durationGood
    case slightlyLong
    case veryLong
}

enum pitchRating { // for pitchScore
    case notRated
    case wrongNote
    case veryFlat
    case slightlyFlat
    case pitchVeryGood
    case slightlySharp
    case verySharp
}

public class PerformanceNote
{
    var noteID              = noNoteIDSet
    var isLinkedToSound     = false
    var linkedToSoundID     = noSoundIDSet // get / set
    public weak var linkedSoundObject : StudentSound?
    func linkToSound( soundID : Int32, sound: StudentSound? ) {
        linkedToSoundID = soundID
        isLinkedToSound = true
        linkedSoundObject = sound
    }
    
    // This will be passed to the scrolling view to identify the note, and will 
    // be used to identify a note associated with a touch on the scroll view
    var xPos : Int32 = 0
    
    // These are TimeIntervals since the beginning of song playback
    //   (Sound times are intervals since analysis start)
    var expectedStartTime : TimeInterval = noTimeValueSet
    var actualStartTime : TimeInterval = noTimeValueSet
    var endTime : TimeInterval = noTimeValueSet {
        didSet{
            actualDuaration = endTime - actualStartTime;
        }
    }

    // The expected and actual duration of the played notes
    var expectedDuaration  : TimeInterval   = noTimeValueSet
    var actualDuaration  : TimeInterval     = noTimeValueSet
    
    var attackRating : timingRating =  .notRated
    var durationRating : timingRating = .notRated
    
    var expectedFrequency   = noPitchValueSet
    var actualFrequency     = noPitchValueSet
    var expectedMidiPitch: Int32 = 0
    var actualMidiPitch:   Int32 = 0

    func averageFrequency() -> Double {
        var pitchVal = 0.0
        guard isLinkedToSound else { return pitchVal }
        if let linkedSound = findSoundBySoundID(soundID: linkedToSoundID) {
            pitchVal = linkedSound.averagePitchRunning }
        return pitchVal
    }
    
    var pitchVariance = noPitchValueSet
    var pitchScore : pitchRating = .notRated
    
    static private var uniqueNoteID : Int32 = noNoteIDSet
    static func getUniqueNoteID() -> Int32 {
        PerformanceNote.uniqueNoteID += 1
        return PerformanceNote.uniqueNoteID
    }
    static func resetUniqueNoteID() {
        PerformanceNote.uniqueNoteID = noNoteIDSet
    }
    
    init ()
    {
        noteID = PerformanceNote.getUniqueNoteID()
    }
    
    deinit {
        if kPrintStudentPerformanceDataDebugOutput {
            print ( "De-initing note \(noteID)" )
        }
    }
}


public class StudentSound
{
    init ( start: TimeInterval, mode : soundType )
    {
        soundID = StudentSound.getUniqueSoundID()
        startTime = start
        soundMode = mode
        if kSavePitchSamples {
            pitchSamples.reserveCapacity(kNumSamplesToCollect)
        } else {
            pitchSamples.reserveCapacity(0)
        }
    }
    
    var isLinkedToNote  = false
    var linkedToNote    = noNoteIDSet
    public weak var linkedNoteObject : PerformanceNote?
    func linkToNote( noteID : Int32, note: PerformanceNote? ) {
        linkedToNote = noteID
        isLinkedToNote = true
        linkedNoteObject = note
    }
    
    var soundMode : soundType = .pitched
    var soundID = noSoundIDSet
    
    // These are intervals since *analysis start*
    //   (Note times are intervals since *song start*)
    var startTime           = noTimeValueSet
    var endTime             = noTimeValueSet {
        didSet{
            duration = endTime - startTime;
        }
    }
    var duration = noTimeValueSet
    
    var pitch  = noPitchValueSet
    var pitchLow = Double(0.0)
    var pitchHigh = Double(0.0)
    
    private var pitchSamples = [Double]()
    var averagePitch = Double(0.0) // calculated using pitchSamples array, above
    
    // Does not use pitchSamples array; much more performant
    var pitchSampleCount = 0.0
    var pitchSumRunning = 0.0
    var averagePitchRunning = 0.0
   
    // A short time is allowed for the pitch to settle, i.e., these samples are ignored
    // when determining the pitch of the sound. They are stored for debugging purposes.
    private var earlySamples = [Double]() // not used to determine avg pitch
    var earlyPitchSampleCount = 0
    private func addEarlyPitchSample(pitchSample : Double) {
        earlyPitchSampleCount += 1
        if kSavePitchSamples {
            earlySamples.append(pitchSample)
        }
    }
    func initialPitchHasStablized() -> Bool {
        return earlyPitchSampleCount > kSamplesNeededToDeterminePitch || forcedPitch
    }
    
    // Called if pitch established, and the sample matches current average.
    private func addPitchSampleAndUpdateRelatedData(pitchSample: Double) {
        if ( pitchSample < pitchLow ) {
            pitchLow = pitchSample
        }
        if ( pitchSample > pitchHigh ) {
            pitchHigh = pitchSample
        }
        
        // Are there enough samples to accurately determine pitch? If so, return
        //  revisit: don't want to thrash growing arrays, or overflow Double (unlikely)
        guard Int(pitchSampleCount) < kNumSamplesToCollect else {return}
        pitchSampleCount += 1.0
        pitchSumRunning += pitchSample
        averagePitchRunning = pitchSumRunning / pitchSampleCount
        
        if kSavePitchSamples {
            pitchSamples.append(pitchSample)
            let pitchSum = pitchSamples.reduce(0, +)
            averagePitch = pitchSum/Double(pitchSamples.count)
        } else {
            averagePitch = averagePitchRunning
        }
    }
    
    ///////////////////////////////////////////////////////////////////////
    //
    //       Vars and funcs related to detecting Legato note change
    //
    // These relate to legato note playing. If a new note is detected, then
    // curr sound is stopped and another begun, AND the pitch is considered stable

    // Used (after pitch stablized) if caller detects possible change to different note
    func addDifferentPitchSample( sample: Double, sampleTime: TimeInterval  ) {
        diffPitchSamples.append(sample)
        consecutiveDiffPitches += 1
        if consecutiveDiffPitches == 1 {    // save time of first diff pitch, as
            diffPitchSplitTime = sampleTime // potentially used later as sound end time
        }
    }
    
    // Use this after addDifferentPitchSample: have enough samples at diff pitch accrued
    // to say it's definitely a new note? (Is so, stop curr sound and create new)
    func isDefinitelyADifferentNote() -> Bool {
        return consecutiveDiffPitches >= kDifferentPitchSampleThreshold
    }
    
    // After a new sound was created because of new legato note, call this to
    // override the early pitch stabilization period; we know the pitch
    private var forcedPitch = false
    func forceAveragePitch(pitchSample: Double) {
        forcedPitch = true
        addPitchSampleAndUpdateRelatedData(pitchSample: pitchSample)
    }

    // If the tracking module detects a change in pitch, it may or may not be a new 
    // note; a number of consecutive samples at the new pitch must accrue to establish 
    // this. These vars/func are for that purpose.
    var diffPitchSplitTime : TimeInterval = noTimeValueSet
    private var diffPitchSamples = [Double]()
    private var consecutiveDiffPitches = 0
    private func clearPotentialDifferentPitchData() {
        if consecutiveDiffPitches > 0 { // at least one was enocountered, so reset
            diffPitchSamples.removeAll()
            consecutiveDiffPitches = 0
            diffPitchSplitTime = noTimeValueSet
        }
    }

    // Normal call: Call this before pitch established, or if current sample is 
    // in current pitch range
    func addPitchSample( pitchSample : Double ) {
        
        if !initialPitchHasStablized() && !forcedPitch {
            earlyPitchSampleCount += 1
            earlySamples.append(pitchSample)
            
            // was adding that one enough?
            if !initialPitchHasStablized() { return }
            // else fall through
        }
        
        // If here, then IF spurious freqs were encountered, they too have
        // stabilzed back to average pitch; this temp variance should be ignored.
        clearPotentialDifferentPitchData()
        
        addPitchSampleAndUpdateRelatedData(pitchSample: pitchSample)
    }
    
    // class / type vars and funcs - provides unique IDs for sounds
    private static var uniqueSoundID : Int32 = noSoundIDSet
    private static func getUniqueSoundID() -> Int32 {
        StudentSound.uniqueSoundID += 1
        return StudentSound.uniqueSoundID
    }
    static func resetUniqueSoundID() {
        StudentSound.uniqueSoundID = noSoundIDSet;
    }
    
    // For debugging support . . .
    
    func numPitchSamples() -> Int {  // called externally for debug output
        return pitchSamples.count
    }
    
    func printSamples() {
        guard kPrintStudentPerformanceDataDebugOutput else { return }
        
        print ("   pitchSumRunning == \(pitchSumRunning)")
        print ("       - sound had \(self.numPitchSamples()) pitched samples:")
        print ( "            -------- Early samples: ------" )
        for eSamp in earlySamples {
            print ( "            \(eSamp)" ) }
        print ( "            -------- Established Pitch samples: ------" )
        for samp in pitchSamples {
            print ( "            \(samp)" ) }
        if diffPitchSamples.count > 0 {
            print ( "            ------- Diff Samples -------" )
            for dSamp in diffPitchSamples {
                print ( "            \(dSamp)" ) }
        }
    }
    
    // For debugging . . .
    func printLegatoSoundResults() {
        print ("   Detecting change note while playing legato. ")
//        print ("       - Amplitude is: \(amplitudeSCF)")
//        print ("       - Stopping current sound at \(self.endTime)")
        print ("       - duration: \(self.duration)")
        print ("       - avgPitch: \(self.averagePitch)")
        print ("       - avPtcRun: \(self.averagePitchRunning)")
        print ("       - based on \(self.numPitchSamples()) samples:")
        self.printSamples()
    }
    
    // For debugging . . .
    func printSoundResults() {
        guard kPrintStudentPerformanceDataDebugOutput else { return }
        
        print ("   duration: \(self.duration)")
        print ("   avgPitch: \(self.averagePitch)")
        print ("   avPtcRun: \(self.averagePitchRunning)")
        self.printSamples()
    }
    
    deinit {
        guard kPrintStudentPerformanceDataDebugOutput else { return }
        print ( "De-initing Sound \(soundID)" )
    }
}


func findSoundBySoundID(soundID: Int32) -> StudentSound? {
    
    var returnSound : StudentSound? = nil
    
    // SCFTODO - change to Filter->Set pattern?
    for oneSound in performanceSounds {
        let oneSound = oneSound
        let thisID = oneSound?.soundID
        if ( thisID == soundID) {
            returnSound = oneSound
            break;
        }
    }
    
    return returnSound
}

// This much of a freq change must be a different note
//  (Diff between one note and another, say E4 to F4, is 0.944.)
private let kDiffNotePercentage : Double = 0.955

// Used for determining if a constant sound is transitioning from one
// note to another (legato playing)
func areDifferentNotes( pitch1: Double, pitch2: Double ) -> Bool {
    let pitch1LoStretch = pitch1 * kDiffNotePercentage
    let pitch1HiStretch = pitch1 / kDiffNotePercentage
    if pitch2 > pitch1LoStretch && pitch2 < pitch1HiStretch {
        return false
    } else {
        if kPrintStudentPerformanceDataDebugOutput {
            print ( "     Different notes: \(pitch1) vs \(pitch2)")
        }
        return true
    }
}

// If starting a new performance, clear data from last performance
func resetSoundAndNoteTracking() {
    currentPerfNote = nil
    currentSound = nil
    performanceNotes.removeAll()
    performanceSounds.removeAll()
    StudentSound.resetUniqueSoundID()
    PerformanceNote.resetUniqueNoteID()
    currentlyInAScoreNote  = false
    currentlyTrackingSound = false
}

///////////////////////////////////////////////////////////////////
//
// Helper functions for working with MusicXML and Time Intervals
//    These are needed when creating PerformanceNotes from MusicXML data
//
//   MusicXML note start times and durations are stored as values independant of 
//   BPM, etc., using 1 quarter note = 1000  as the reference, regardless of tempo.

// What is the length of a quarter note at the current tempo?
func quarterNoteTimeInterval( bpm: Int32) -> TimeInterval {
    let bpmRatio: TimeInterval = secsPerMin / TimeInterval(bpm)
    let retVal: TimeInterval = TimeInterval(1.0) * bpmRatio
    
    return retVal
}

// Given the MusicXML startTime or duration, and the BPM, return TimeInterval 
func musXMLNoteUnitToInterval( noteDur: Int32, bpm: Int32) -> TimeInterval {
    let bpmRatio: TimeInterval = secsPerMin / TimeInterval(bpm)
    let noteInterval: TimeInterval = TimeInterval(noteDur/musicXMLUnitsPerQuarterNote)
    let adjustedNoteInterval: TimeInterval  = noteInterval * bpmRatio
    
    return adjustedNoteInterval
}

// Given the start time within the bar, the BPM, and Bar index, return the 
// time interval since song startTime (which is 0) for a given note
func mXMLNoteStartInterval ( bpm: Int32,  beatsPerBar: Int32, startBarIndex : Int32,
                             noteStartWithinBar: Int32 ) -> TimeInterval {
    let beatsToBeginningOfBar = startBarIndex * beatsPerBar
    let intervalToBarBegin =
        quarterNoteTimeInterval(bpm:bpm) * TimeInterval(beatsToBeginningOfBar)
    let noteStartInterval =
        intervalToBarBegin + musXMLNoteUnitToInterval(noteDur: noteStartWithinBar,
                                                      bpm:bpm)
    return noteStartInterval
}

