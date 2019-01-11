//
//  PerformanceSound.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/7/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import Foundation

enum soundType {
    case percusive  // Claps, etc.
    case pitched    // Trumpet, etc.
}

public class PerformanceSound
{    
    init ( start: TimeInterval, mode : soundType, noteOffset: TimeInterval )
    {
        soundID = PerformanceSound.getUniqueSoundID()
        _startTime_abs  = start
        _startTime_song = soundTimeToNoteTimeExt(soundStart: _startTime_abs)
        _startTime_comp = _startTime_song - kSoundStartAdjustment

        soundMode = mode
        soundToNoteTimeOffset = noteOffset
        if kSavePitchSamples {
            pitchSamples.reserveCapacity(kNumSamplesToCollect)
        } else {
            pitchSamples.reserveCapacity(0)
        }
    }
    
    var isLinkedToNote  = false
    var linkedToNote    = noScoreObjIDSet
    public weak var linkedNoteObject : PerformanceNote?
    func linkToNote( noteID : Int32, note: PerformanceNote? ) {
        linkedToNote = noteID
        isLinkedToNote = true
        linkedNoteObject = note
    }
 
    // separate vars for Rests and Notes.
    var isLinkedToRest    = false
    var linkedToRest    = noScoreObjIDSet
    public weak var linkedRestObject : PerformanceRest?
    func linkToRest( restID : Int32, rest: PerformanceRest? ) {
        isLinkedToRest = true
        linkedToRest = restID
        linkedRestObject = rest
    }
    
    var soundMode : soundType = .pitched
    var soundID = noSoundIDSet
    
    // XYZ_abs   - "Absolute"         - interval since *analysis start*
    // XYZ_song  - "Song"             - interval since *song start*
    // XYZ_comp  - "Song Compensated" - interval since *song start*, with
    //                                    HW vs Sim delay compensation
    var _startTime_abs  = noTimeValueSet
    var _startTime_song = noTimeValueSet
    var _startTime_comp = noTimeValueSet
    var startTime_abs:TimeInterval {
        return _startTime_abs
    }
    var startTime_song:TimeInterval {
        return _startTime_song
    }
    var startTime_comp:TimeInterval {
        return _startTime_comp
    }
    
    func setStartTimeAbs(startTimeAbs: TimeInterval) {
        _startTime_abs  = startTimeAbs
        _startTime_song = soundTimeToNoteTimeExt(soundStart: _startTime_abs)
        _startTime_comp = _startTime_song - kSoundStartAdjustment
    }
    
    var _endTime_abs  = noTimeValueSet
    var _endTime_song = noTimeValueSet
    var _endTime_comp = noTimeValueSet
    var endTime_abs:TimeInterval {
        return _endTime_abs
    }
    var endTime_song:TimeInterval {
        return _endTime_song
    }
    var endTime_songComp:TimeInterval {
        return _endTime_comp
    }
    func setEndTimeAbs(endTimeAbs: TimeInterval) {
        _endTime_abs  = endTimeAbs
        _endTime_song = soundTimeToNoteTimeExt(soundStart: _endTime_abs)
        _endTime_comp = _endTime_song - kSoundStartAdjustment
        
        _duration = _endTime_abs - _startTime_abs
        if !initialPitchHasStablized() {
            let lastSamp = lastEarlySample()
            averagePitch = lastSamp
            averagePitchRunning = lastSamp
        }
    }
    
    var _duration = noTimeValueSet
    var duration: TimeInterval {
        return _duration
    }

    func makeAdjustmentsAfterSongStart() {
        // _startTime_abs was set correctly; everything else could be off
        print("In makeAdjustmentsAfterSongStart")
        print("   Before: _startTime_song == \(_startTime_song), _startTime_comp == \(_startTime_comp)")
        
        _startTime_song = soundTimeToNoteTimeExt(soundStart: _startTime_abs)
        _startTime_comp = _startTime_song - kSoundStartAdjustment
        print("   After:  _startTime_song == \(_startTime_song), _startTime_comp == \(_startTime_comp)")

        if isLinkedToNote && linkedNoteObject != nil {
            linkedNoteObject!.actualStartTime_song = _startTime_song
        }
        
        if isLinkedToRest && linkedRestObject != nil {
            linkedRestObject!.actualStartTime_song = _startTime_song
        }
    }
    
    var soundToNoteTimeOffset: TimeInterval // difference b/t sound and note times.
    var xOffsetStart = 0 // relevant to a scrolling view that would display this sound
    var xOffsetEnd   = 0 // relevant to a scrolling view that would display this sound
    
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
    private var earlySamples = [Double]() // not generally used to determine avg pitch
    var earlyPitchSampleCount = 0
    private func addEarlyPitchSample(pitchSample : Double) {
        earlyPitchSampleCount += 1
        if kSavePitchSamples {
            earlySamples.append(pitchSample)
        }
    }
    func lastEarlySample() -> Double {
        return earlySamples.isEmpty ? 0.0 : earlySamples.last!
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
  //      guard Int(pitchSampleCount) < kNumSamplesToCollect else {return}
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
    var createdBecauseOfLegatoPitchChange = false // beginning of sound
    var stoppedBecauseOfLegatoPitchChange = false // end of sound

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
        return consecutiveDiffPitches >= gDifferentPitchSampleThreshold
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
    
    // Every nth sample, updateLinkedNoteCount is incremented. 
    // When it == kNumSamaplesPerLinkedNoteUpdate, the linked note (if there is 
    // one) is updated, and updateLinkedNoteCount is reset to 0.
    var updateLinkedNoteCount = 0
    
    // How many samples between linked note updates?
    let kNumSamaplesPerLinkedNoteUpdate = 15
    
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
        
        updateLinkedNoteCount += 1
        if updateLinkedNoteCount > kNumSamaplesPerLinkedNoteUpdate {
            updateCurrentNoteIfLinkedPeriodic()
            updateLinkedNoteCount = 0
        }
    }
    
    // class / type vars and funcs - provides unique IDs for sounds
    private static var uniqueSoundID : Int32 = noSoundIDSet
    private static func getUniqueSoundID() -> Int32 {
        PerformanceSound.uniqueSoundID += 1
        return PerformanceSound.uniqueSoundID
    }
    static func resetUniqueSoundID() {
        PerformanceSound.uniqueSoundID = noSoundIDSet;
    }
    
    func updateCurrentNoteIfLinkedFinal()
    {
        guard isLinkedToNote, let linkNote = linkedNoteObject else {return}
        guard linkNote.isNote() else {return}  // WHAT ??? !!! FIMEUP
        
        linkNote.setActualEndTimeAbs(endTimeAbs: self._endTime_abs)
        linkNote.actualFrequency = self.averagePitchRunning
    }
    
    func updateCurrentNoteIfLinkedPeriodic()
    {
        guard isLinkedToNote, let linkNote = linkedNoteObject else {return}
        guard linkNote.isNote() else {return}
        
        linkNote.actualFrequency = self.averagePitchRunning
    }
    
    ///////////////////////////////////////////////////////////////////////////
    //
    //    For Debugging and Testing from here to end of class
    //
    ///////////////////////////////////////////////////////////////////////////
    
    func numPitchSamples() -> Int {  // called externally for debug output
        return pitchSamples.count
    }
    
    func printSamples() {
        guard kMKDebugOpt_PrintStudentPerformanceDataDebugOutput else { return }
        guard kMKDebugOpt_PrintStudentPerformanceDataDebugSamplesOutput else { return }
        
        
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
    
    func getNoteInfoForPitch(pitch: Double,
                             concertNoteStr: inout String,
                             transposedNoteStr: inout String )
    {
        concertNoteStr = "<bad freq>"
        transposedNoteStr = "<bad freq>"
        guard pitch > 0.0 else { return }
        
        let midiNote  = NoteID(pitch.frequencyToRoundedMIDINote())
        let concertNote = NoteService.getNote(Int(midiNote))
        if concertNote != nil {
            concertNoteStr = concertNote!.fullName
        }
        
        let midiNoteTransposed =
            concertNoteIdToInstrumentNoteID( noteID: midiNote) // TRANSHYAR
        
        let transposedNote = NoteService.getNote(Int(midiNoteTransposed))
        if transposedNote != nil {
            transposedNoteStr = transposedNote!.fullName
        }
    }

    func printSamplesDetailed() {
        var concertNoteName: String = ""
        var trasnposedNoteName: String = ""
        let avgPitchStr = String(format: "%.1f", self.averagePitch)
        let avgPitchRunStr = String(format: "%.1f", self.averagePitchRunning)

        print ("\n==============================================================\n")
        if createdBecauseOfLegatoPitchChange {
            print ("   Sound created because of pitch change\n")
        }
        print ("   Pitch Samples for Sound #\(self.soundID)\n")
        print ("       - avgPitch:  \(avgPitchStr)")
        print ("       - avgPtcRun: \(avgPitchRunStr)\n")
        print ("    - sound had \(self.numPitchSamples()) pitched samples:")
        print ( "\n            -------- Early samples: ------" )
        for eSamp in earlySamples {
            getNoteInfoForPitch(pitch: eSamp,
                                concertNoteStr: &concertNoteName,
                                transposedNoteStr: &trasnposedNoteName )
            let pitchStr = String(format: "%.1f", eSamp)
            print ( "    \(pitchStr) Hz, \t\(trasnposedNoteName), \t(Concert: \(concertNoteName))" )
        }
        print ( "\n            -------- Established Pitch samples: ------" )
        for samp in pitchSamples {
            let pitchStr = String(format: "%.1f", samp)
            getNoteInfoForPitch(pitch: samp,
                                concertNoteStr: &concertNoteName,
                                transposedNoteStr: &trasnposedNoteName )
            print ( "    \(pitchStr), \tTransposed: \(trasnposedNoteName), \tConcert: \(concertNoteName)" )
        }
        if diffPitchSamples.count > 0 {
            print ( "\n            ------- Diff Samples -------" )
            for dSamp in diffPitchSamples {
                let pitchStr = String(format: "%.1f", dSamp)
                getNoteInfoForPitch(pitch: dSamp,
                                    concertNoteStr: &concertNoteName,
                                    transposedNoteStr: &trasnposedNoteName )
                print ( "    \(pitchStr), \tTransposed: \(trasnposedNoteName), \tConcert: \(concertNoteName)" )
            }
        }
        if stoppedBecauseOfLegatoPitchChange {
            print ("\n   Sound ended because of pitch change\n")
        }

        print ("\n==============================================================\n")
    }
    
    func printLegatoSoundResults() {
        guard kMKDebugOpt_PrintStudentPerformanceDataDebugOutput else { return }
        
        print ("   Detecting change note while playing legato. ")
        print ("       - duration: \(self.duration)")
        print ("       - avgPitch: \(self.averagePitch)")
        print ("       - avPtcRun: \(self.averagePitchRunning)")
        print ("       - based on \(self.numPitchSamples()) samples:")
        self.printSamples()
    }
    
    func printSoundResults() {
        guard kMKDebugOpt_PrintStudentPerformanceDataDebugOutput else { return }
        
        print ("   duration: \(self.duration)")
        print ("   avgPitch: \(self.averagePitch)")
        print ("   avPtcRun: \(self.averagePitchRunning)")
        self.printSamples()
    }
    
    deinit {
        guard kMKDebugOpt_PrintStudentPerformanceDataDebugOutput else { return }
        print ( "De-initing Sound \(soundID)" )
    }
}

