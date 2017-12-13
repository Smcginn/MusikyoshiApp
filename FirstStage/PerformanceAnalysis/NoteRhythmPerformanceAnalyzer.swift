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

// Thresholds; Delta values In milliseconds
let kRhythmAttackVariance_OK : Double             = 0.05
let kRhythmAttackVariance_Acceptable : Double     = 0.20
let kRhythmAttackVariance_Unacceptable : Double   = 0.40

let kRhythmDurationVariance_OK : Double           = 0.05
let kRhythmDurationVariance_Acceptable : Double   = 0.20
let kRhythmDurationVariance_Unacceptable : Double = 0.40

let kAttackSlightlyEarlyOrLateWeight : Int32      = 3
let kAttackVeryEarlyOrLateWeght : Int32           = 6
let kAttackMissedWeght : Int32                    = 9
let kDurationSlightyLongOrShortWeight : Int32     = 1
let kDurationVeryLongOrShortWeight : Int32        = 2
let kDurationTooLongOrShortWeight : Int32         = 3

class NoteRhythmPerformanceAnalyzer : NotePerformanceAnalyzer {
    
    func determineWeightedRating( perfNote: PerformanceNote ) {
        
        // Adjust weightedRating based on attack time accuracy
        if perfNote.attackRating == .slightlyEarly || perfNote.attackRating == .slightlyLate {
            perfNote.weightedRating += kAttackSlightlyEarlyOrLateWeight
        }
        else if perfNote.attackRating == .veryEarly || perfNote.attackRating == .veryLate {
            perfNote.weightedRating += kAttackVeryEarlyOrLateWeght
        }
        else if perfNote.attackRating == .missed {
            perfNote.weightedRating += kAttackMissedWeght
        }
        
        // Adjust weightedRating based on duration accuracy
        if perfNote.durationRating == .slightlyShort || perfNote.durationRating == .slightlyLong {
            perfNote.weightedRating += kDurationSlightyLongOrShortWeight
        }
        else if perfNote.durationRating == .veryShort || perfNote.durationRating == .veryLong {
            perfNote.weightedRating += kDurationVeryLongOrShortWeight
        }
        else if perfNote.durationRating == .tooShort || perfNote.durationRating == .tooLong {
            perfNote.weightedRating += kDurationTooLongOrShortWeight
        }
    }
    
    func rateAttack( perfNote: PerformanceNote )
    {
        let startTimeDelta     = perfNote.expectedStartTime - perfNote.actualStartTime
        let startTimeDeltaABS  = abs(startTimeDelta)
        if startTimeDeltaABS <= kRhythmAttackVariance_OK {
            perfNote.attackRating = .timingGood
        }
        else if startTimeDeltaABS <= kRhythmDurationVariance_Acceptable {
            if startTimeDelta > 0.0 {
                perfNote.attackRating = .slightlyEarly
            } else {
                perfNote.attackRating = .slightlyLate
            }
        } else if startTimeDeltaABS <= kRhythmAttackVariance_Acceptable {
            if startTimeDelta > 0.0 {
                perfNote.attackRating = .veryEarly
            } else {
                perfNote.attackRating = .veryLate
            }
        } else {
            perfNote.attackRating = .missed
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
    
    override func analyzeNote( perfNote: PerformanceNote? ) {
        guard let note = perfNote else { return }
        
        if !note.isLinkedToSound {
            note.attackRating   = .missed
            note.durationRating = .missed
            determineWeightedRating( perfNote: note )
            return
        }
        
        rateAttack( perfNote: note )
        rateDuration( perfNote: note )
        determineWeightedRating( perfNote: note )
    }
}
