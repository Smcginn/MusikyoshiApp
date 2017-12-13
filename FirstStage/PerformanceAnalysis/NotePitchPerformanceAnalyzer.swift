//
//  NotePitchPerformanceAnalyzer.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/12/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//
//    (Moved work from PitchPerformanceAnalyzer.swift, created on 11/24/17;
//     PitchPerformanceAnalyzer.swift is now deleted.)
//

import Foundation

/////////////////////////////////////////////////////////////////////////
// NotePitchPerformanceAnalyzer - Analyzes PerformanceNote for
//                                Gross and Fine Pitch accuracy
//    (E.g., Totally wrong note; or corrent note, possibly flat or sharp)

let kPitchSlightyFlatOrSharpWeight : Int32     = 1
let kPitchVeryFlatOrSharpWeight : Int32        = 2
let kPitchWrongNoteWeight : Int32              = 6

class NotePitchPerformanceAnalyzer : NotePerformanceAnalyzer {
    
    override func analyzeNote( perfNote: PerformanceNote? ) {
        guard let note = perfNote else { return }
        
        if !note.isLinkedToSound { // missed note
            note.pitchRating = .missedNote
            note.weightedRating += kPitchWrongNoteWeight // ?
            return
        }
        
        // Get the percentage of how off-pitch the average was compared to expected.
        let pitchDelta = note.expectedFrequency - note.actualFrequency
        
        // To establish amount of deviance from expected freq. "Low" means PC will
        // always be < 1.0. So . . . use this to check against low ranges, THEN check
        // to see if it's actually higher or lower than expected pitch.
        var expToActPitchPCLow: Double
        if note.expectedFrequency > note.actualFrequency {
            expToActPitchPCLow = note.expectedFrequency / note.actualFrequency
        } else {
            expToActPitchPCLow = note.actualFrequency / note.expectedFrequency
        }
        
        // Now compare against ranges of acceptable tolerances, and grade the result.
        // Finally,for each range, add the appropriate weight to the overall weight.
        if expToActPitchPCLow <= tolerances.correctPitchPC {
            note.pitchRating = .pitchVeryGood
            // no weighting to add . . .
            
        } else if expToActPitchPCLow <= tolerances.aBitToVeryPC {
            if pitchDelta > 0.0 {
                note.pitchRating = .slightlyFlat
            } else {
                note.pitchRating = .slightlySharp
            }
            note.weightedRating += kPitchSlightyFlatOrSharpWeight
            
        } else {  // pitch is in the "very flat" or very sharp" range
            // First, check if there is some instrument-specific issue with pitch.
            //   If there is, isInstrSpecificVeryHiLowIssue() will set accordingly.
            //   If not, set very low/high status and rating here.
            if !isInstrSpecificVeryHiLowIssue( perfNote: note ) {
                if pitchDelta > 0.0 {
                    note.pitchRating = .wrongNoteFlat
                } else {
                    note.pitchRating = .wrongNoteSharp
                }
                note.weightedRating += kPitchVeryFlatOrSharpWeight
            }
        }
    }
    
    func isInstrSpecificVeryHiLowIssue( perfNote: PerformanceNote ) -> Bool {
        
        return false // nothing instrument specific about this
    }
}

class TrumpetPitchPerformanceAnalyzer : NotePitchPerformanceAnalyzer {
    
    override func isInstrSpecificVeryHiLowIssue( perfNote: PerformanceNote )
        -> Bool {
            
            // Check for partials
            let actFreq = perfNote.actualFrequency
            let theNoteID = NoteID(perfNote.perfNoteID)
            
            let isPartRV: isPartialRetVal =
                PerformanceAnalysisMgr.instance.isThisFreqAPartialOfThisNote(
                    freq: actFreq,
                    noteID: theNoteID )
            if isPartRV.isPartial {
                perfNote.isInstrSpecificIssue = true
                perfNote.isActFreqIsPartial = true
                perfNote.specificPartial = isPartRV.partial
                return true
                
            } else {
                return false // nothing instrument-specific about this
            }
    }
}
