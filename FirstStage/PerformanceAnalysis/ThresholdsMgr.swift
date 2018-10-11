//
//  ThresholdsMgr.swift
//  FirstStage
//
//  Created by Scott Freshour on 8/4/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

let kThershIDsStr_Begin_1      = "beginner1"
let kThershIDsStr_Begin_2      = "beginner2"
let kThershIDsStr_Begin_3      = "beginner3"
let kThershIDsStr_Inter_1      = "intermediate1"
let kThershIDsStr_Inter_2      = "intermediate2"
let kThershIDsStr_Inter_3      = "intermediate3"

let kSingleEventThreshDefaultStr = String("\(kStopPerformanceThresholdDefault)")

class ThresholdsMgr {
    
    static let instance = ThresholdsMgr()
    
    func setThresholds(thresholdsID: String,
                       ejectorSeatThreshold: String) {
        switch thresholdsID {
        case kThershIDsStr_Begin_1:   setThresholdWith(useThresholds: Thresh_Beginner_1)
            break
        case kThershIDsStr_Begin_2:   setThresholdWith(useThresholds: Thresh_Beginner_2)
            break
        case kThershIDsStr_Begin_3:   setThresholdWith(useThresholds: Thresh_Beginner_3)
            break
        case kThershIDsStr_Inter_1:   setThresholdWith(useThresholds: Thresh_Intermediate_1)
            break
        case kThershIDsStr_Inter_2:   setThresholdWith(useThresholds: Thresh_Intermediate_2)
            break
        case kThershIDsStr_Inter_3:   setThresholdWith(useThresholds: Thresh_Intermediate_3)
            break
        default: // use "beginner1" vals
            print("\n\n  INCORRECT THRESHOLD SPECIFIED IN JSON: \(thresholdsID) \n\n")
            setThresholdWith(useThresholds: Thresh_Beginner_1)
        }
        
        if let ejectorInt = UInt(ejectorSeatThreshold) {
            // clamp ejectorInt between (0, Max)
            let usableEjectorInt:UInt =
                    (0 ... kStopPerformanceThresholdMax).clamp(ejectorInt)
            kStopPerformanceThreshold = usableEjectorInt
        } else {
            kStopPerformanceThreshold = kStopPerformanceThresholdDefault
        }
    }
    
    struct AnalysisThresholds {
        var rhythmTolerance:     Double
        var correctPitchPC:      Double
        var pitchABitToVeryPC:   Double
        var pitchVeryBoundaryPC: Double
    }
    
    let Thresh_Beginner_1: AnalysisThresholds =
        AnalysisThresholds( rhythmTolerance:        0.5,
                            correctPitchPC:         0.97,
                            pitchABitToVeryPC:      0.915,
                            pitchVeryBoundaryPC:    0.05 )
    
    let Thresh_Beginner_2: AnalysisThresholds =
        AnalysisThresholds( rhythmTolerance:        0.4,
                            correctPitchPC:         0.97,
                            pitchABitToVeryPC:      0.915,
                            pitchVeryBoundaryPC:    0.05 )
    
    let Thresh_Beginner_3: AnalysisThresholds =
        AnalysisThresholds( rhythmTolerance:        0.3,
                            correctPitchPC:         0.97,
                            pitchABitToVeryPC:      0.915,
                            pitchVeryBoundaryPC:    0.05 )
    
    let Thresh_Intermediate_1: AnalysisThresholds =
        AnalysisThresholds( rhythmTolerance:        0.25,
                            correctPitchPC:         0.97,
                            pitchABitToVeryPC:      0.915,
                            pitchVeryBoundaryPC:    0.05 )
    
    let Thresh_Intermediate_2: AnalysisThresholds =
        AnalysisThresholds( rhythmTolerance:        0.2,
                            correctPitchPC:         0.97,
                            pitchABitToVeryPC:      0.915,
                            pitchVeryBoundaryPC:    0.05 )
    
    let Thresh_Intermediate_3: AnalysisThresholds =
        AnalysisThresholds( rhythmTolerance:        0.2,
                            correctPitchPC:         0.97,
                            pitchABitToVeryPC:      0.915,
                            pitchVeryBoundaryPC:    0.05 )
    
    private func setThresholdWith(useThresholds: AnalysisThresholds)
    {
        var tols = pitchAndRhythmTolerances()
        tols.set(rhythmTolerance:        useThresholds.rhythmTolerance,
                 correctPitchPercentage: useThresholds.correctPitchPC,
                 aBitToVeryPercentage:   useThresholds.pitchABitToVeryPC,
                 veryBoundaryPercentage: useThresholds.pitchVeryBoundaryPC)
        PerformanceAnalysisMgr.instance.rebuildAllAnalysisTables(tols)
    }
    
}


