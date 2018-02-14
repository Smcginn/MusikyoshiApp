//
//  PerformanceNote.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/7/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import Foundation

public class PerformanceNote
{
    var perfNoteID          = noNoteIDSet
    var isLinkedToSound     = false
    var linkedToSoundID     = noSoundIDSet
    public weak var linkedSoundObject : PerformanceSound?
    func linkToSound( soundID : Int32, sound: PerformanceSound? ) {
        linkedToSoundID = soundID
        isLinkedToSound = true
        linkedSoundObject = sound
    }
    
    // The X-Coord of where on the scrolling view the XMLMusic note is diaplayed. 
    // Used to specify where to draw note-related factoids (debug or otherwise).
    var xPos : Int32 = 0
    var yPos : Int32 = 0
    
    // These are TimeIntervals since the beginning of song playback
    //   (Sound times are intervals since analysis start)
    var expectedStartTime : TimeInterval = noTimeValueSet
    var actualStartTime : TimeInterval = noTimeValueSet
    var endTime : TimeInterval = noTimeValueSet {
        didSet {
            actualDuration = endTime - actualStartTime
        }
    }
    
    // The expected and actual duration of the played notes
    var expectedDuration: TimeInterval = noTimeValueSet
    {
        didSet {
            // The input is a calculation using MusicXML note type (e.g., quarter),
            // BPM, and the definition of the note in question, e.g., qtr note == 1
            // second at 60 BPM). In reality, a correctedly played note might need
            // a slight gap between notes (breath, stress non-legato, etc.), so 
            // adjust accordingly.
            let kDurationAdjustment = 0.05 // milliseconds. Change this to dial in.
            expectedDurAdjusted = expectedDuration - kDurationAdjustment
        }
    }
    var expectedDurAdjusted  : TimeInterval   = noTimeValueSet
    var actualDuration  : TimeInterval     = noTimeValueSet
    
    // Ah, transposing instruments. Our code has to deal with two worlds: the
    // transposed notes (as they appear on the score) and the concert-pitch
    // oriented pitch detection modules and functions that translate pitch
    // to a cononical note ID system. Previous work used MIDI note IDs (a wise
    // choice). So:
    //   - Need to store info for:
    //     - Expected Transposed Note (for lookup for display, etc.)
    //     - Expected Concert Note (to determine correct pitch, etc.)
    //     - Actual Concert Note (to convert the performed pitch to NoteID, etc.)
    //     - Actual Transposed Note (for display, "You played a Bb, not a B")
    // (It would be possible to do concert-to-transposed and visa-versa conversions
    // on the fly, as needed, but storing this data for instant lookup during 
    // debugging is necessary for maintaining sanity.)
    var expectedFrequency   = noPitchValueSet   // concert pitch of expected note
    var actualFrequency     = noPitchValueSet { // concert pitch of performacne
        didSet {
            guard actualFrequency > 0.0 else { return }
            actualMidiNote  = NoteID(actualFrequency.frequencyToRoundedMIDINote())
            actualMidiNoteTransposed =
                         concertNoteIdToInstrumentNoteID( noteID: actualMidiNote)
        }
    }
    var expectedMidiNote: NoteID = 0 { // note ID for concert pitch of expected note
        didSet {
            transExpectedNoteID =
                concertNoteIdToInstrumentNoteID( noteID: NoteID(expectedMidiNote) )
        }
    }
    var transExpectedNoteID: NoteID = 0 // note ID for transposed note (note on score)
    var actualMidiNote:      NoteID = 0 // note ID for concert pitch of performance note
    var actualMidiNoteTransposed: NoteID = 0 // transposed note ID of performance note
    
    func averageFrequency() -> Double {
        var pitchVal = 0.0
        guard isLinkedToSound else { return pitchVal }
        if let linkedSound =
            PerformanceTrackingMgr.instance.findSoundBySoundID(
                                                        soundID: linkedToSoundID) {
            pitchVal = linkedSound.averagePitchRunning }
        return pitchVal
    }
    
    // the performance issue for each category, if there was one
    var attackRating: performanceRating   = .notRated
    var durationRating: performanceRating = .notRated
    var pitchRating: performanceRating    = .notRated
    
    // the weighted score, or severity of the issue for each category
    var attackScore:   Int =  0  // 0 is the best, 1 next best, etc.
    var durationScore: Int =  0
    var pitchScore:    Int =  0
    var weightedScore: Int =  0  // Overall; combined of the above
    
    var pitchVariance = noPitchValueSet

    //////////////////////////////////////////////////////////////////////////
    // Did post-performance analysis discover an instrument-specific problem?
    var isInstrSpecificIssue = false
    var instrumentSpecificError: InstrumentSpecificError = .none
    
    //////////////////////////////////////////////////////////////////////////
    //   TODO: Below is Instrument specific!!!!  Post-Alpha (or sooner), this
    //   should be represented in some subclass or protocol/extension sort of
    //   way so that each instrument type can represent its issues. E.g., an
    //   way, optional pointing to (potentially very different) instrument-
    //   specific data objects that have the same calling interfaces, etc.)
    //
    // Was the freq an accidental partial of the expected note? If so which one?
    var isActFreqIsPartial = false
    var specificPartial: tNoteFreqRangeData = kEmptyNoteFreqRangeData
    
    // class functions/var; ID to uniquely identify PerformanceNote objects
    static private var currUniqueNoteID : Int32 = noNoteIDSet
    static func getUniqueNoteID() -> Int32 {
        PerformanceNote.currUniqueNoteID += 1
        return PerformanceNote.currUniqueNoteID
    }
    static func resetUniqueNoteID() {
        PerformanceNote.currUniqueNoteID = noNoteIDSet
    }

    init () {
        perfNoteID = PerformanceNote.getUniqueNoteID()
    }
    
    deinit {
        // here for debugging, making sure there are no reference cycles
        if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput {
            print ( "De-initing note \(perfNoteID)" )
        }
    }

    // Used by an Alert to populate the messageString with data about this Note.
    //  (The Alert is a debug feature. It is not visible in release mode.)
    func constructSummaryMsgString( msgString: inout String )
    {
        let expFreqStr = String(format: "%.2f", expectedFrequency)
        var expDurStr = String(format: "%.2f", expectedDuration)
        expDurStr += " ("
        expDurStr += String(format: "%.2f", expectedDurAdjusted) + ")"
        
        // Used the Transposed Note (note on score, etc.) for "Expected Note"
        var expectedNoteName = ""
        let expNote = NoteService.getNote(Int(transExpectedNoteID))
        if expNote != nil {
            expectedNoteName = expNote!.fullName
        }
        
        if !isLinkedToSound {
            msgString += "\nNote not linked to sound\n\n"
            msgString += "  - didn't play,\n"
            msgString += "  - or missed timing target\n\n"
            msgString += "Expected Note:     " + expectedNoteName + "\n"
            msgString += "Expected Freq:     " + expFreqStr + "\n"
            msgString += "Expected Duration: " + expDurStr + "\n"
            return
        }
        
        // Still here: Note *is* linked. Output some details about timing and pitch
        
        // Need to distinguish the transposed note (seen on the score) from the
        // concert pitch we expect to hear.
        let actualNoteIDTransposed =
            concertNoteIdToInstrumentNoteID( noteID: actualMidiNote)
        var actualNoteName = ""
        let actNote = NoteService.getNote(Int(actualNoteIDTransposed))
        if actNote != nil {
            actualNoteName = actNote!.fullName
        }
        
        let actFreqStr = String(format: "%.2f", actualFrequency)
        let actDurStr = String(format: "%.2f", actualDuration)
        
        let timingDiff = actualStartTime - expectedStartTime
        var timDiffStr = ""
        if timingDiff > 0 {
            timDiffStr = String(format: "+%.2f", timingDiff)
        } else {
            timDiffStr = String(format: "%.2f", timingDiff) // auto includes "-"
        }
       
        var timingRatingStr = ""
        performanceRating.displayStringForRating( attackRating,
                                                  ratingText: &timingRatingStr )
        var durationRatingStr = ""
        performanceRating.displayStringForRating( durationRating,
                                                  ratingText: &durationRatingStr )
        var pitchRatingStr = ""
        performanceRating.displayStringForRating( pitchRating,
                                                  ratingText: &pitchRatingStr )
        
        msgString += "Expected Note:     " + expectedNoteName + "\n"
        msgString += "         Freq:     " + expFreqStr + "\n"
        msgString += "         Duration: " + expDurStr + "\n"
        msgString +=  "\n"
        msgString += "Actual Frequency:    " + actFreqStr + "\n"
        msgString += "       Note (Guess): " + actualNoteName + "\n"
        msgString += "       Duration:     " + actDurStr + "\n"
        msgString +=  "\n"
        msgString += "Start Time Delta: " + timDiffStr + "secs\n\n"
        msgString += "Timing Rating:    " + timingRatingStr + "\n"
        msgString += "Duration Rating:  " + durationRatingStr + "\n"
        msgString += "Pitch Rating:     " + pitchRatingStr + "\n"
       
        if isInstrSpecificIssue && isActFreqIsPartial {
            let concName = specificPartial.concertNoteFullName
            let concFreq = specificPartial.concertFreq
            let concFreqStr  = String(format: "%.2f", concFreq)
            let transName = specificPartial.noteFullName
            msgString += "\n"
            msgString += "This is a partial of the\n attempted Note:\n"
            msgString += "  Note Name (Trans):    " + transName + "\n"
            msgString += "  Freq (Concert):       " + concFreqStr + "\n"
            msgString += "   (Concert Note Name): " + concName + "\n"
        } else {
            if !( pitchRating == .slightlyFlat ||
                  pitchRating == .pitchGood    ||
                  pitchRating == .slightlySharp  )
            {
                msgString += "\n"
                msgString += "Possible Pitch Issues:\n"
                msgString += "  Your fingering is wrong\n"
                msgString += "  Your embouchure is off\n"
                msgString += "  Your breath is too fast\n"
                msgString += "    or too slow\n"
            }
        }
        
        // overall rating
        let weightedStr = String(format: "%d", weightedScore)
        msgString += "\n"
        msgString += "Overall Weighted Rating: " + weightedStr + "\n"
    }
}

// frequencyToMIDINote copied from AudioKeyHelpers - couldn't figure out how to bring 
// into project Extension to Double to get the a MIDI Note Number from the frequency 
//   (frequencyToRoundedMIDINote my variant)
extension Double {
    
    /// Calculate MIDI Note Number from a frequency in Hz
    ///
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)

    public func frequencyToMIDINote(_ aRef: Double = 440.0) -> Double {
        return 69 + 12 * log2(self / aRef)
    }
    
    // uses the freq halfway between notes as the cutoff
    public func frequencyToRoundedMIDINote(_ aRef: Double = 440.0) -> Int {
        let nonRounded = 69 + 12 * log2(self / aRef)
        return Int(nonRounded.rounded())
    }
}


