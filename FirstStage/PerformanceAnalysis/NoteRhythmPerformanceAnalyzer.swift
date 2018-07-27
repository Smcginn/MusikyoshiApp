//
//  NoteRhythmPerformanceAnalyzer.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/12/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//
//    (Moved work from RhythmPerformanceAnalyzer.swift, created on 11/24/17;
//     RhythmPerformanceAnalyzer.swift is now deleted.)
//

import Foundation

/////////////////////////////////////////////////////////////////////////
// NoteRhythmPerformanceAnalyzer - Analyzes PerformanceNote for
//                                 Attack and Duration accuracy

// Duraton Thresholds; Delta values In seconds
let kRhythmDurationVariance_OK : Double           = 0.05
let kRhythmDurationVariance_Acceptable : Double   = 0.25
let kRhythmDurationVariance_Unacceptable : Double = 0.5  

class NoteRhythmPerformanceAnalyzer : NotePerformanceAnalyzer {
    
    func determineWeightedRating( perfNote: PerformanceNote ) {
        
        // Adjust weightedRating based on attack time accuracy
        if perfNote.attackRating == .slightlyEarly || perfNote.attackRating == .slightlyLate {
            perfNote.attackScore = IssueWeight.kSlightlyEarlyOrLate
        }
        else if perfNote.attackRating == .veryEarly || perfNote.attackRating == .veryLate {
            perfNote.attackScore = IssueWeight.kVeryEarlyOrLate
        }
        else if perfNote.attackRating == .missedNote {
            if kIgnoreMissedNotes { // for debugging . . .
                perfNote.attackScore = IssueWeight.kCorrect
           } else {
                perfNote.attackScore = IssueWeight.kMissed
            }
        }
        perfNote.weightedScore += perfNote.attackScore
        
        // Adjust weightedRating based on duration accuracy
        if perfNote.durationRating == .slightlyShort || perfNote.durationRating == .slightlyLong {
            perfNote.durationScore = IssueWeight.kSlightyLongOrShort
        }
        else if perfNote.durationRating == .veryShort || perfNote.durationRating == .veryLong {
            perfNote.durationScore = IssueWeight.kVeryLongOrShort
        }
        else if perfNote.durationRating == .tooShort || perfNote.durationRating == .tooLong {
            perfNote.durationScore = IssueWeight.kTooLongOrShort
        }
        perfNote.weightedScore += perfNote.durationScore
    }
    
    func rateAttack( perfNote: PerformanceNote )
    {
        let startTimeDelta     = perfNote.expectedStartTime - perfNote.actualStartTime
        let startTimeDeltaABS  = abs(startTimeDelta)
        if startTimeDeltaABS <= attackVariance_Correct {
            perfNote.attackRating = .timingOrRestGood
        }
        else if startTimeDeltaABS <= attackVariance_ABitOff {
            if startTimeDelta > 0.0 {
                perfNote.attackRating = .slightlyEarly
            } else {
                perfNote.attackRating = .slightlyLate
            }
        } else if startTimeDeltaABS <= attackVariance_VeryOff {
            if startTimeDelta > 0.0 {
                perfNote.attackRating = .veryEarly
            } else {
                perfNote.attackRating = .veryLate
            }
        } else {   // > attackVariance_VeryOff
            if kIgnoreMissedNotes { // for debugging . . .
                perfNote.attackRating = .timingOrRestGood
            } else {
                perfNote.attackRating = .missedNote
            }
        }
    }
    
    func rateDuration( perfNote: PerformanceNote ) {
        // If note started at wrong time, should they be graded on how long the
        // note lasted (actualDurDelta), or how close to expected end time they were
        // (adjustedDurDelta)?
        // Use one or the other . . .
        let actualDurDelta =
            perfNote.expectedDurAdjusted - perfNote.actualDuration // pos == short
        let durationDeltaABS = abs(actualDurDelta)
        if durationDeltaABS <= kRhythmDurationVariance_OK {
            perfNote.durationRating = .durationGood
        }
        else if durationDeltaABS <= kRhythmDurationVariance_Acceptable {
            if actualDurDelta > 0.0 {
                perfNote.durationRating = .slightlyShort
            } else {
                perfNote.durationRating = .slightlyLong
            }
        } else if durationDeltaABS <= kRhythmDurationVariance_Unacceptable {
            if actualDurDelta > 0.0 {
                perfNote.durationRating = .veryShort
            } else {
                perfNote.durationRating = .veryLong
            }
        } else {
            if actualDurDelta > 0.0 {
                perfNote.durationRating = .tooShort
            } else {
                perfNote.durationRating = .tooLong
            }
        }
    }
    
    override func analyzeScoreObject( perfScoreObject: PerformanceScoreObject? )  {
        guard let note = perfScoreObject as! PerformanceNote? else { return }
        
        note.attackRating   = .timingOrRestGood
        note.durationRating = .durationGood
        note.attackScore    =  0
        note.durationScore  =  0
        
        if !note.isLinkedToSound {
            if kIgnoreMissedNotes { // for debugging . . .
                note.attackRating   = .timingOrRestGood
                note.durationRating = .durationGood
            } else {
                note.attackRating   = .missedNote
                note.durationRating = .missedNote
            }

            determineWeightedRating( perfNote: note )
            return
        }
        
        rateAttack( perfNote: note )
        rateDuration( perfNote: note )
        determineWeightedRating( perfNote: note )
    }
}
