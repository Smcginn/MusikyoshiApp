//
//  NotePerformanceAnalyzer.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/12/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//
//    (Moved work from PerformanceAnalyzer.swift, created on 11/24/17; 
//     PerformanceAnalyzer.swift is now deleted.)

import Foundation

/////////////////////////////////////////////////////////////////////////
// Base class for:  NotePitchPerformanceAnalyzer and 
//                  NoteRhythmPerformanceAnalyzer

import Foundation

class NotePerformanceAnalyzer {
    
    var tolerances : pitchAndRhythmTolerances
    
    init() {
        tolerances = PerformanceAnalysisMgr.instance.currTolerances
    }
    
    func reset() {
        tolerances = PerformanceAnalysisMgr.instance.currTolerances
    }
    
    // setting for must override for this func?  ~sort of like~ pure virtual in C++?
    func analyzeNote( perfNote: PerformanceNote? ) {}
}
