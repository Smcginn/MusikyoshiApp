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

private var gRunningAttackDiffs: [TimeInterval] = []
var gRunningAvgAttackDiff: TimeInterval {
    guard gRunningAttackDiffs.count > 0 else { return 0.0 }
    
    let total = gRunningAttackDiffs.reduce(0, +)
    let avg = total/TimeInterval(gRunningAttackDiffs.count)
    return avg
}
func clearGlobalRunningAttackDiffs() {
    gRunningAttackDiffs.removeAll()
}
func addCurrAttackDiffAvgToRunningAvg() {
    gRunningAttackDiffs.append(gLastRunAvgAttackDiff)
}
var gRunningAvgAttackDiffAvailable: Bool {
    if gRunningAttackDiffs.count > 0 {
        return true
    } else {
        return false
    }
}

var gLastRunMinAttackDiff: TimeInterval = 0.0
var gLastRunMaxAttackDiff: TimeInterval = 0.0
var gLastRunAvgAttackDiff: TimeInterval = 0.0

var gBPMAttackWindowMultiplier: Double = 1.0
let kBPMAttackWindow_Numerator: Double = 60.0

var gAdjustAttackVar_Correct: Double = 0.05
var gAdjustAttackVar_ABitOff: Double = DefaultTolerancePCs.defaultRhythmTolerance/2.0
var gAdjustAttackVar_VeryOff: Double = DefaultTolerancePCs.defaultRhythmTolerance

// Set by slider
var gAdjustAttackVar_VeryOffOverride: Double = DefaultTolerancePCs.defaultRhythmTolerance
var gAdjustAttackVar_VeryOff_DoOverride = false

var gAdjustDur_OK : Double           = 0.05
var gAdjustDur_Acceptable : Double   = 0.25
var gAdjustDur_Unacceptable : Double = 0.5

func calcAndSetAdjustedRhythmTolerances(bpm: Double) {
    guard bpm > 0.0 else {
        itsBad()
        return
    }
    
    gBPMAttackWindowMultiplier = kBPMAttackWindow_Numerator / bpm
    
    gAdjustAttackVar_Correct = attackVariance_Correct * gBPMAttackWindowMultiplier
    gAdjustAttackVar_ABitOff = attackVariance_ABitOff * gBPMAttackWindowMultiplier
    if gAdjustAttackVar_VeryOff_DoOverride {
        gAdjustAttackVar_Correct = gAdjustAttackVar_VeryOffOverride
    } else {
        gAdjustAttackVar_VeryOff = attackVariance_VeryOff * gBPMAttackWindowMultiplier
    }
    print("\n\nAt \(bpm) BPM:")
    print("   attackVariance_Correct == \(gAdjustAttackVar_Correct)")
    print("   attackVariance_ABitOff == \(gAdjustAttackVar_ABitOff)")
    print("   attackVariance_VeryOff == \(gAdjustAttackVar_VeryOff)")

    gAdjustDur_OK
        = kRhythmDurationVariance_OK     // * gBPMAttackWindowMultiplier
    gAdjustDur_Acceptable   =
        kRhythmDurationVariance_Acceptable * gBPMAttackWindowMultiplier
    gAdjustDur_Unacceptable
        = kRhythmDurationVariance_Unacceptable * gBPMAttackWindowMultiplier
    print("   kRhythmDurationVariance_OK           == \(gAdjustDur_OK)")
    print("   kRhythmDurationVariance_Acceptable   == \(gAdjustDur_Acceptable)")
    print("   kRhythmDurationVariance_Unacceptable == \(gAdjustDur_Unacceptable)")
}


func resetAttackDiffs() {
    gLastRunMinAttackDiff = 10.0
    gLastRunMaxAttackDiff = -10.0
    gLastRunAvgAttackDiff = 0.0
}

func setAttackDiffs(currDiff: TimeInterval, currAvg: TimeInterval) {
    if currDiff < gLastRunMinAttackDiff {
        gLastRunMinAttackDiff = currDiff
    }
    
    if currDiff > gLastRunMaxAttackDiff {
        gLastRunMaxAttackDiff = currDiff
    }
    gLastRunAvgAttackDiff = currAvg
}

class NoteRhythmPerformanceAnalyzer : NotePerformanceAnalyzer {
    
    var runningDiffSum: Double = 0.0
    var numDifs: Int = 0
    
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
        let startTimeDelta     = perfNote.actualStartTime_comp - perfNote.expectedStartTime
        let startTimeDeltaABS  = abs(startTimeDelta)
        
//        if kMKDebugOpt_PrintMinimalNoteAnalysis {
            if perfNote.isLinkedToSound {
                runningDiffSum += startTimeDelta
                numDifs += 1
                let currAverage = runningDiffSum/Double(numDifs)
                
                setAttackDiffs(currDiff: startTimeDelta, currAvg: currAverage)
                if kMKDebugOpt_PrintMinimalNoteAnalysis {
                    print("In Note Analysis; note #\(perfNote.perfNoteOrRestID) attack off by:\t\(startTimeDelta), \tcurr avg: \(currAverage)")
                }
            }
//        }
        
        if startTimeDeltaABS <= gAdjustAttackVar_Correct {
            perfNote.attackRating = .timingOrRestGood
        }
        else if startTimeDeltaABS <= gAdjustAttackVar_ABitOff {
            if startTimeDelta < 0.0 {
                perfNote.attackRating = .slightlyEarly
            } else {
                perfNote.attackRating = .slightlyLate
            }
        } else if startTimeDeltaABS <= gAdjustAttackVar_VeryOff {
            if startTimeDelta < 0.0 {
                perfNote.attackRating = .veryEarly
            } else {
                perfNote.attackRating = .veryLate
            }
        } else {   // > gAdjustAttackVar_VeryOff
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
        if durationDeltaABS <= gAdjustDur_OK {
            perfNote.durationRating = .durationGood
        }
        else if durationDeltaABS <= gAdjustDur_Acceptable {
            if actualDurDelta > 0.0 {
                perfNote.durationRating = .slightlyShort
            } else {
                perfNote.durationRating = .slightlyLong
            }
        } else if durationDeltaABS <= gAdjustDur_Unacceptable {
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
    
    func resetAverages() {
        runningDiffSum  = 0.0
        numDifs         = 0
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
