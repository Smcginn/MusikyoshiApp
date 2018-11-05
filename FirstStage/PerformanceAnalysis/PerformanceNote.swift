//
//  PerformanceNote.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/7/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import Foundation

public class PerformanceNote : PerformanceScoreObject
{
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
        
    init () {
        super.init(noteOrRest : .note)
        perfNoteOrRestID = PerformanceScoreObject.getUniqueNoteID()
    }
    
    deinit {
        // here for debugging, making sure there are no reference cycles
        if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput {
            print ( "De-initing note \(perfNoteOrRestID)" )
        }
    }

    func printSoundsSamplesDetailed() {
        guard isLinkedToSound else {
            print("\n  Not Linked to Sound")
            return
        }
        
        guard let linkedSound =
            PerformanceTrackingMgr.instance.findSoundBySoundID(soundID: linkedToSoundID) else {
            print("\n  Unable to find Linked Sound")
            return
        }

        linkedSound.printSamplesDetailed()
    }
    
    // Used by an Alert to populate the messageString with data about this Note.
    //  (The Alert is a debug feature. It is not visible in release mode.)
    override func constructSummaryMsgString( msgString: inout String )
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
        
        let timingDiff = _actualStartTime_comp - _expectedStartTime
        var timDiffStr = ""
        if timingDiff > 0 {
            timDiffStr = String(format: "+%.3f", timingDiff)
        } else {
            timDiffStr = String(format: "%.3f", timingDiff) // auto includes "-"
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
                msgString += "  fingering, embouchure, breath\n"
            }
        }
        
        // overall rating
        let weightedStr = String(format: "%d", weightedScore)
        msgString += "\n"
        msgString += "Overall Weighted Rating: " + weightedStr
        
        var worstScore = max(attackScore, durationScore)
        worstScore = max(worstScore, pitchScore)
        let worstStr = String(format: "%d", worstScore)
        msgString += "\nWorst Rating: " + worstStr
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


