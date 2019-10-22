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

class NotePitchPerformanceAnalyzer : NotePerformanceAnalyzer {
    
    override func analyzeScoreObject( perfScoreObject: PerformanceScoreObject?  ) {
        guard let note = perfScoreObject as! PerformanceNote? else { return }
        
        note.pitchRating = .pitchGood
        note.pitchScore =  0
        
        // Issue: How to rate and weight the pitch of a missed note? 
        //   (If we don't rate it high enough, a missed note can end up with less 
        //   cumulative weight than a note that's slightly late, slightly short,
        //   and slightly sharp - for example.)
        if !note.isLinkedToSound { // missed note
            note.pitchRating = .pitchGood
            note.weightedScore += IssueWeight.kCorrect
            return
        }
        
        // Get the percentage of how off-pitch the average was compared to expected.
        //   (Don't delete:  This generates a warning, but being able to quickly
        //   look at this is extremely useful when debugging.)
        let pitchDelta = note.expectedFrequency - note.actualFrequency
        useThisToSuppressWarnings(str: "\(pitchDelta)")

        // To establish amount of deviance from expected freq. "Low" means PC will
        // always be < 1.0. So . . . use this to check against low ranges, THEN check
        // to see if it's actually higher or lower than expected pitch.
        var expToActPitchPCLow: Double
        let isFlat = note.expectedFrequency > note.actualFrequency

        let weightedPCCorrect = note.getWeightedPercentageCorrect()
        let correctNotePlayedPercentage =  note.correctNotePlayedPercentage
        var msgStr = "In Pitch Analyzer; For Note \(note.perfNoteOrRestID), "
        msgStr    += "Weighted Percentage Correct == \(weightedPCCorrect)"
        print (msgStr)
        
        note.determineMostCommonPlayedNote()
        let mostCommonNote = note.mostCommonPlayedNote
        let mostCommonNotePerc = note.mostCommonPlayedNotePercentage

        if gUseWeightedPitchScore {   // "Bucket" algo
            var isPartial = false
            if weightedPCCorrect >= kWeightedPitch_Threshold_Correct {
                note.pitchRating = .pitchGood
                // no weighting to add . . .
            
            } else {
                // first, check to see if partial played
                if mostCommonNotePerc > kWeightedPitch_MostCommonNotePlayedThreshold {
                    let freq = NoteService.getFreqForNoteID( noteID: mostCommonNote )
                    note.actualFrequency = freq

                    // isInstrSpecificVeryHiLowIssue() sets weights, etc., if is partial
                    isPartial = isInstrSpecificVeryHiLowIssue( perfNote: note )
                }
                
                if !isPartial { // continue the "weighting" game
                    if weightedPCCorrect >= kWeightedPitch_Threshold_Reasonable {
                        // use the percentage of time in the actual note to
                        // determine if this is wavering, or just a wrong note
                        if correctNotePlayedPercentage >= kCorrectNotePlayedPercThreshold {
                            note.pitchRating = .fluctuatingReasonable
                            note.pitchScore = IssueWeight.kWaveringReasonable
                            note.weightedScore += note.pitchScore
                        } else { // let's just call it a wrong note
                            if isFlat {
                                note.pitchRating = .slightlyFlat
                            } else {
                                note.pitchRating = .slightlySharp
                            }
                            note.pitchScore = IssueWeight.kSlightyFlatOrSharp
                            note.weightedScore += note.pitchScore
                        }
                        
                    } else if weightedPCCorrect >= kWeightedPitch_Threshold_Accecptable {
                        note.pitchRating = .fluctuatingAcceptable
                        note.pitchScore = IssueWeight.kWaveringAcceptable
                        note.weightedScore += note.pitchScore

                    } else {  // pitch is in the "very flat" or very sharp" range
                        if isFlat {
                            note.pitchRating = .wrongNoteFlat
                        } else {
                            note.pitchRating = .wrongNoteSharp
                        }
                        note.pitchScore = IssueWeight.kFlatOrSharpWrongNote
                        note.weightedScore += note.pitchScore
                    }
                }
            }
            return
        }
        
        // else . . .
        
//        // Get the percentage of how off-pitch the average was compared to expected.
//        //   (Don't delete:  This generates a warning, but being able to quickly
//        //   look at this is extremely useful when debugging.)
//        let pitchDelta = note.expectedFrequency - note.actualFrequency
//
//        // To establish amount of deviance from expected freq. "Low" means PC will
//        // always be < 1.0. So . . . use this to check against low ranges, THEN check
//        // to see if it's actually higher or lower than expected pitch.
//        var expToActPitchPCLow: Double
//        let isFlat = note.expectedFrequency > note.actualFrequency
        if isFlat {
            expToActPitchPCLow = note.actualFrequency / note.expectedFrequency
        } else {
            expToActPitchPCLow = note.expectedFrequency / note.actualFrequency
        }
        
        // Now compare against ranges of acceptable tolerances, and grade the result.
        // Finally,for each range, add the appropriate weight to the overall weight.
        if expToActPitchPCLow >= tolerances.correctPitchPC {
            note.pitchRating = .pitchGood
            // no weighting to add . . .
            
        } else if expToActPitchPCLow >= tolerances.aBitToVeryPC {
            if isFlat {
                note.pitchRating = .slightlyFlat
            } else {
                note.pitchRating = .slightlySharp
            }
            note.pitchScore = IssueWeight.kSlightyFlatOrSharp
            note.weightedScore += note.pitchScore 
            
        } else {  // pitch is in the "very flat" or very sharp" range
            // First, check if there is some instrument-specific issue with pitch.
            //   If there is, isInstrSpecificVeryHiLowIssue() will set accordingly.
            //   If not, set very low/high status and rating here.
            if !isInstrSpecificVeryHiLowIssue( perfNote: note ) {
                if isFlat {
                    note.pitchRating = .wrongNoteFlat
                } else {
                    note.pitchRating = .wrongNoteSharp
                }
                note.pitchScore = IssueWeight.kFlatOrSharpWrongNote
                note.weightedScore += note.pitchScore
            }
        }
    }
    
    // derived classes should override this if necessary
    func isInstrSpecificVeryHiLowIssue( perfNote: PerformanceNote ) -> Bool {
        return false // nothing instrument specific about this
    }
}

class BrassPitchPerformanceAnalyzer : NotePitchPerformanceAnalyzer {
    
    override func isInstrSpecificVeryHiLowIssue( perfNote: PerformanceNote )
        -> Bool {
            
            // Check for partials
            let actFreq = perfNote.actualFrequency
            let actNote = NoteService.getNote(actFreq)
            let theNoteID = perfNote.transExpectedNoteID
            
            if actNote != nil {
                let actNoteID = Int(actNote!.orderId)
                if actNoteID == theNoteID {
                    return false
                }
            }
            
            let isPartRV: isPartialRetVal =
                PerformanceAnalysisMgr.instance.isThisFreqAPartialOfThisNote(
                    freq: actFreq,
                    noteID: theNoteID )
            if isPartRV.isPartial {
                perfNote.isInstrSpecificIssue = true
                perfNote.isActFreqIsPartial = true
                perfNote.specificPartial = isPartRV.partial
                if perfNote.actualFrequency > perfNote.expectedFrequency {
                    perfNote.pitchRating = .isUpperPartial
                    perfNote.pitchScore  = IssueWeight.kUpperPartial
                } else {
                    perfNote.pitchRating = .isLowerPartial
                    perfNote.pitchScore  = IssueWeight.kLowerPartial
                }
                perfNote.weightedScore += perfNote.pitchScore
                return true
                
            } else {
                return false // nothing instrument-specific about this
            }
    }
}
