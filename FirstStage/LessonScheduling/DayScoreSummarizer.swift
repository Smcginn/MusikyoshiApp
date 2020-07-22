//
//  DayScoreSummarizer.swift
//  FirstStage
//
//  Created by Scott Freshour on 6/27/20.
//  Copyright © 2020 Musikyoshi. All rights reserved.
//
/*
 Gathers a Day's current score info, divides the info inot sub-categories,
 and pre-calculates averages, etc.
 
 This is used by ClassKit code
 */



import Foundation

// used below to tell come of the code to ignore bpm
let kThisIsALongToneExer = -1.0

let kDefaultLowBPMValue = 400 // when comparing, anything will be lower

enum tExerScoreCategory {
    case longtone
    case rhythmPrep
    case rhythmParty
    case tune
    case scale
    case misc       // CrossBreaks, Instervals, ScalePower
    case overall
}

struct categorySummaryValues {
    var overallNumExers:            Int
    var overallNumComplete:         Int
    var overallPercentDone:         Double
    var overallAvgStarScore:        Double
    var overallAvgNumAttempts:      Double
    var lowestBPM:                  Int
    var highestBPM:                 Int

    var ltNumExers:                 Int
    var ltAvgStarScore:             Double
    var ltAvgNumAttempts:           Double
    var ltAvgTargetTimePercentage:  Double
    var ltPercentDone:              Double

    var rythPrepNumExers:           Int
    var rythPrepAvgStarScore:       Double
    var rythPrepAvgNumAttempts:     Double
    var rythPrepPercentDone:        Double

    var rythPartyNumExers:          Int
    var rythPartyAvgStarScore:      Double
    var rythPartyAvgNumAttempts:    Double
    var rythPartyPercentDone:       Double

    var tuneNumExers:               Int
    var tuneAvgStarScore:           Double
    var tuneAvgNumAttempts:         Double
    var tunePercentDone:            Double

    var scaleNumExers:              Int
    var scaleAvgStarScore:          Double
    var scaleAvgNumAttempts:        Double
    var scalePercentDone:           Double
    
    var miscNumExers:               Int
    var miscAvgStarScore:           Double
    var miscAvgNumAttempts:         Double
    var miscPercentDone:            Double
    
    init() {
        self.overallNumExers            = 0
        self.overallNumComplete         = 0
        self.overallPercentDone         = 0.0
        self.overallAvgStarScore        = 0.0
        self.overallAvgNumAttempts      = 0.0
        self.lowestBPM                  = 0
        self.highestBPM                 = 0

        self.ltNumExers                 = 0
        self.ltAvgStarScore             = 0.0
        self.ltAvgNumAttempts           = 0.0
        self.ltAvgTargetTimePercentage  = 0.0
        self.ltPercentDone              = 0.0

        self.rythPrepNumExers           = 0
        self.rythPrepAvgStarScore       = 0.0
        self.rythPrepAvgNumAttempts     = 0.0
        self.rythPrepPercentDone        = 0.0

        self.rythPartyNumExers          = 0
        self.rythPartyAvgStarScore      = 0.0
        self.rythPartyAvgNumAttempts    = 0.0
        self.rythPartyPercentDone       = 0.0

        self.tuneNumExers               = 0
        self.tuneAvgStarScore           = 0.0
        self.tuneAvgNumAttempts         = 0.0
        self.tunePercentDone            = 0.0

        self.scaleNumExers              = 0
        self.scaleAvgStarScore          = 0.0
        self.scaleAvgNumAttempts        = 0.0
        self.scalePercentDone           = 0.0
    
        self.miscNumExers               = 0
        self.miscAvgStarScore           = 0.0
        self.miscAvgNumAttempts         = 0.0
        self.miscPercentDone            = 0.0
    }
}

class DayScoreSummarizer {
    
    var levelDay_LDCode: tLD_code
    
    init( levelDay: tLD_code ) {
        self.levelDay_LDCode = levelDay
    }

    // Clear all summaries, and get and calculate again.
    func recalcAndGetAllSummaries(summaryValues: inout categorySummaryValues) {
        resetAllValues()
        getExerSummaries()
        recalculateCategorySummaries()
        getSummaryValues(sumVals: &summaryValues)
    }

    func getSummaryValues(sumVals: inout categorySummaryValues) {
        
        sumVals.overallNumExers         = overallSummary.numExers
        sumVals.overallNumComplete      = overallSummary.numComplete
        sumVals.overallPercentDone      = overallSummary.percentComplete
        sumVals.overallAvgStarScore     = overallSummary.averageStarScore
        sumVals.overallAvgNumAttempts   = overallSummary.averageNumAttempts
        sumVals.lowestBPM               = overallSummary.lowBPM
        sumVals.highestBPM              = overallSummary.hiBPM
        
        sumVals.ltNumExers              = longToneSummary.numExers
        sumVals.ltPercentDone           = longToneSummary.percentComplete
        sumVals.ltAvgStarScore          = longToneSummary.averageStarScore
        sumVals.ltAvgNumAttempts        = longToneSummary.averageNumAttempts
        sumVals.ltAvgTargetTimePercentage = longToneSummary.averageTargetTimePercentage
  
        sumVals.rythPrepNumExers        = rhythmPrepSummary.numExers
        sumVals.rythPrepAvgStarScore    = rhythmPrepSummary.averageStarScore
        sumVals.rythPrepAvgNumAttempts  = rhythmPrepSummary.averageNumAttempts
        sumVals.rythPrepPercentDone     = rhythmPrepSummary.percentComplete
        
        sumVals.rythPartyNumExers       = rhythmPartySummary.numExers
        sumVals.rythPartyAvgStarScore   = rhythmPartySummary.averageStarScore
        sumVals.rythPartyAvgNumAttempts = rhythmPartySummary.averageNumAttempts
        sumVals.rythPartyPercentDone    = rhythmPartySummary.percentComplete
        
        sumVals.tuneNumExers            = tuneSummary.numExers
        sumVals.tuneAvgStarScore        = tuneSummary.averageStarScore
        sumVals.tuneAvgNumAttempts      = tuneSummary.averageNumAttempts
        sumVals.tunePercentDone         = tuneSummary.percentComplete
        
        sumVals.scaleNumExers           = scaleSummary.numExers
        sumVals.scaleAvgStarScore       = scaleSummary.averageStarScore
        sumVals.scaleAvgNumAttempts     = scaleSummary.averageNumAttempts
        sumVals.scalePercentDone        = scaleSummary.percentComplete
        
        sumVals.miscNumExers            = miscSummary.numExers
        sumVals.miscAvgStarScore        = miscSummary.averageStarScore
        sumVals.miscAvgNumAttempts      = miscSummary.averageNumAttempts
        sumVals.miscPercentDone         = miscSummary.percentComplete
    }
    
    var overallSummary      = categorySummary(exerScoreCategory: .overall)
    var longToneSummary     = categorySummary(exerScoreCategory: .longtone)
    var rhythmPrepSummary   = categorySummary(exerScoreCategory: .rhythmPrep)
    var rhythmPartySummary  = categorySummary(exerScoreCategory: .rhythmParty)
    var tuneSummary         = categorySummary(exerScoreCategory: .tune)
    var scaleSummary        = categorySummary(exerScoreCategory: .scale)
    var miscSummary         = categorySummary(exerScoreCategory: .misc)

    
    struct categorySummary {
        var exerCategory: tExerScoreCategory
        var numExers                    = Int(0)        // of this category
        var numComplete                 = Int(0)        // of this category
        var percentComplete             = Double(0.0)   // of this category

        var averageStarScore            = Double(0.0)
        var averageNumAttempts          = Double(0.0)
        var lowBPM                      = Int(kDefaultLowBPMValue) // for Tune-based exers
        var hiBPM                       = Int(0)   // for Tune-based exers
        var averageTargetTimePercentage = Double(0.0)   // for Longtone exers

        var cumulativeStarScore         = Int(0)
        var cumulativeNumAttempts       = Int(0)
        var cumulativeTargetTimePerc    = Double(0.0)   // for Longtone exers
        
        init(exerScoreCategory:tExerScoreCategory) {
            self.exerCategory = exerScoreCategory
        }
        
        mutating func reset() {
            numExers                    = 0
            numComplete                 = 0
            percentComplete             = 0.0
            averageStarScore            = 0.0
            cumulativeStarScore         = 0
            averageNumAttempts          = 0.0
            cumulativeNumAttempts       = 0
            lowBPM                      = kDefaultLowBPMValue
            hiBPM                       = 0
            averageTargetTimePercentage = 0.0
            cumulativeTargetTimePerc    = 0.0
        }
        
        mutating func addNewEntry(complete: Bool,   starScore: Int,
                                  numAttempts: Int, bpm: Double) {
            numExers += 1
            if complete {
                numComplete += 1
                cumulativeStarScore += starScore
                averageStarScore = Double(cumulativeStarScore) / Double(numComplete)
                cumulativeNumAttempts += numAttempts
                averageNumAttempts = Double(cumulativeNumAttempts) / Double(numComplete)
            }
            percentComplete = Double(numComplete) / Double(numExers)
 
            // Set hi/low BPM, but only use if complete and not a LongTone exer
            if complete && bpm != kThisIsALongToneExer {
                let bpmInt = Int(bpm)
                if bpmInt > hiBPM {
                     hiBPM = bpmInt
                }
                if bpmInt < lowBPM {
                     lowBPM = bpmInt
                }
            }
        }
        
        mutating func addNewEntry(complete: Bool,   starScore: Int,
                                  numAttempts: Int, targetTimePercentage: Double) {
            numExers += 1
            if complete {
                 numComplete += 1
                 cumulativeStarScore += starScore
                 averageStarScore = Double(cumulativeStarScore) / Double(numComplete)
                 cumulativeNumAttempts += numAttempts
                 averageNumAttempts = Double(cumulativeNumAttempts) / Double(numComplete)
 
                 cumulativeTargetTimePerc += targetTimePercentage
                 averageTargetTimePercentage = Double(cumulativeTargetTimePerc) / Double(numComplete)
            }
            percentComplete = Double(numComplete) / Double(numExers)
        }
    }
    
    struct exerSummary {    // one exer
        var exerNum:                Int
        var exerCat:                tExerScoreCategory
        var exerType:               ExerciseType
        var exerFileCode:           String
        var done:                   Bool
        var starScore:              Double
        var numAttempts:            Int
        var bpmOrPercTargetTime:    Double  // usage depends on exer category

        init(exerNum:               Int,
             exerCat:               tExerScoreCategory,
             exerType:              ExerciseType,
             exerFileCode:          String,
             done:                  Bool,
             starScore:             Double,
             numAttempts:           Int,
             bpmOrPercTargetTime:   Double)
        {
            self.exerNum             = exerNum
            self.exerCat             = exerCat
            self.exerType            = exerType
            self.exerFileCode        = exerFileCode
            self.done                = done
            self.starScore           = starScore
            self.numAttempts         = numAttempts
            self.bpmOrPercTargetTime = bpmOrPercTargetTime
        }
    }
 
    // array of summaries of all exers
    var exerStati = [exerSummary]()
    
    // Calls the ScoreManager and gets stats for each exercise in the Day,
    // then adds this to the list of exerStati
    private func getExerSummaries() {
        let numExers = LsnSchdlr.instance.numExercises(ld: levelDay_LDCode)

        for exerIdx in 0..<numExers {
            let exerLDE = tLDE_code(level: levelDay_LDCode.level,
                                    day:levelDay_LDCode.day,     exer: exerIdx)
            
            let exerFileCode = LsnSchdlr.instance.getExerIDStr(lde: exerLDE)
            let exerType     = getExerciseType( exerCode: exerFileCode )
            let exerCat      = getExerCatFromExerType(exerType: exerType)

            let state = LsnSchdlr.instance.getExerState( lde: exerLDE )
            let isDone = (state == kLDEState_Completed) ? true : false
            let starScore = LsnSchdlr.instance.getExerStarScore(lde: exerLDE)
            let numAttempts = LsnSchdlr.instance.getExerNumAttempts(lde: exerLDE)
            
            // This call accesses a feild that has meaning depending on the exer type.
            let bpmOrPerc = LsnSchdlr.instance.getExerBPM(lde: exerLDE)
            
            let oneExerSum = exerSummary(exerNum:               exerIdx,
                                         exerCat:               exerCat,
                                         exerType:              exerType,
                                         exerFileCode:          exerFileCode,
                                         done:                  isDone,
                                         starScore:             Double(starScore),
                                         numAttempts:           numAttempts,
                                         bpmOrPercTargetTime:   bpmOrPerc)
            exerStati.append(oneExerSum)
        }
    }
    
    func exerTypeMatchesCategory(exerName: String,
                                 exerCategory: tExerScoreCategory) -> Bool {
        
        return true
    }
    
    func recalculateCategorySummaries() {
        for oneExerStatus in exerStati {
            var isLongTone = false
            switch(oneExerStatus.exerCat) {
                case .longtone:
                    isLongTone = true
                    longToneSummary.addNewEntry(complete: oneExerStatus.done,
                                                starScore: Int(oneExerStatus.starScore),
                                                numAttempts: oneExerStatus.numAttempts,
                                                targetTimePercentage: oneExerStatus.bpmOrPercTargetTime)
                case .rhythmPrep:
                    rhythmPrepSummary.addNewEntry(complete: oneExerStatus.done,
                                                  starScore: Int(oneExerStatus.starScore),
                                                  numAttempts: oneExerStatus.numAttempts,
                                                  bpm: oneExerStatus.bpmOrPercTargetTime)
                case .rhythmParty:
                    rhythmPartySummary.addNewEntry(complete: oneExerStatus.done,
                                                  starScore: Int(oneExerStatus.starScore),
                                                  numAttempts: oneExerStatus.numAttempts,
                                                  bpm: oneExerStatus.bpmOrPercTargetTime)
                case .tune:
                    tuneSummary.addNewEntry(complete: oneExerStatus.done,
                                            starScore: Int(oneExerStatus.starScore),
                                            numAttempts: oneExerStatus.numAttempts,
                                            bpm: oneExerStatus.bpmOrPercTargetTime)
                case .scale:
                    scaleSummary.addNewEntry(complete: oneExerStatus.done,
                                             starScore: Int(oneExerStatus.starScore),
                                             numAttempts: oneExerStatus.numAttempts,
                                             bpm: oneExerStatus.bpmOrPercTargetTime)
                default:
                    miscSummary.addNewEntry(complete: oneExerStatus.done,
                                            starScore: Int(oneExerStatus.starScore),
                                            numAttempts: oneExerStatus.numAttempts,
                                            bpm: oneExerStatus.bpmOrPercTargetTime)
            }
            var bpmVal = oneExerStatus.bpmOrPercTargetTime
            if isLongTone {
                bpmVal = kThisIsALongToneExer
            }
            overallSummary.addNewEntry(complete: oneExerStatus.done,
                                       starScore: Int(oneExerStatus.starScore),
                                       numAttempts: oneExerStatus.numAttempts,
                                       bpm: bpmVal)
        }
    }
    
    func resetAllValues() {
        exerStati = [exerSummary]()
        longToneSummary.reset()
        rhythmPrepSummary.reset()
        rhythmPartySummary.reset()
        tuneSummary.reset()
        scaleSummary.reset()
        miscSummary.reset()
        overallSummary.reset()
    }
    
    func getExerCatFromExerType(exerType: ExerciseType) -> tExerScoreCategory {
         var retCat = tExerScoreCategory.misc
         
         switch(exerType) {
             case .longtoneExer,
                  .longtoneRecordExer:   retCat = .longtone
             case .rhythmPartyExer:      retCat = .rhythmParty
             case .rhythmPrepExer:       retCat = .rhythmPrep
             case .tuneExer:             retCat = .tune
             case .scalePowerExer:       retCat = .scale
             default: // scalePowerExer, intervalExer, crossBreakExer
                                         retCat = .misc
         }
         
         return retCat
     }
}

/*

 Notes: Defs for Apple's Activity Items
 
 CLSScoreItem -  Score out of maxScore.
 
    score: Double
    maxScore: Double
    ID:     String
    Title:  String
 
CLSQuantityItem
    ID:     String
    Title:  String
    quantity: Double
 
Binary item:
    ID:     String
    Title:  String
    value:  Bool
    valueType:  CLSBinaryValueType
         CLSBinaryValueTypeTrueFalse = 0,
         CLSBinaryValueTypePassFail,
         CLSBinaryValueTypeYesNo,
         CLSBinaryValueTypeCorrectIncorrect API_AVAILABLE(ios(12.2))

*/

