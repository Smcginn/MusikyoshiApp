//
//  NoteAnalysis.swift
//  FirstStage
//
//  Created by David S Reich on 16/05/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//

import Foundation

class NoteAnalysis {

    enum NoteResult {
        case noteRhythmMatch
        case noteRhythmMiss
        case noteRhythmLate
        case noteRhythmLateRepeat
        case restMatch
        case restMiss
        case restLateMiss
        case restLateMissRepeat
        case noResult
    
        case pitchMatch
        case pitchLow
        case pitchHigh
        case pitchMatchLate
        case pitchLowLate
        case pitchHighLate
    }

    var noteResultValues = [NoteResult: Int]()
}
