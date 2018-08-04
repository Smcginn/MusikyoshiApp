//
//  RestPerformanceAnalyzer.swift
//  FirstStage
//
//  Created by Scott Freshour on 7/22/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

/////////////////////////////////////////////////////////////////////////
// RestPerformanceAnalyzer - Analyzes PerformanceRest to make sure no
//                           notes (sounds) wwere played in rest "zone"

class RestPerformanceAnalyzer : NotePerformanceAnalyzer {
    
    override func analyzeScoreObject( perfScoreObject: PerformanceScoreObject? )  {
        guard let rest = perfScoreObject as! PerformanceRest? else { return }
        
        if rest.isLinkedToSound {
            rest.attackRating = .soundsDuringRest
            rest.attackScore  = IssueWeight.kNoteDuringRest
        } else {
            rest.attackRating = .timingOrRestGood
            rest.attackScore  = IssueWeight.kCorrect
        }
        rest.weightedScore = rest.attackScore
    }

}
