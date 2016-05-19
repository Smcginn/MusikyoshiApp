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
        case NoteRhythmMatch
        case NoteRhythmMiss
        case NoteRhythmLate
        case NoteRhythmLateRepeat
        case RestMatch
        case RestMiss
        case RestLateMiss
        case RestLateMissRepeat
        case NoResult
    
        case PitchMatch
        case PitchLow
        case PitchHigh
        case PitchMatchLate
        case PitchLowLate
        case PitchHighLate
    }

    var noteResultValues = [NoteResult: Int]()
}
