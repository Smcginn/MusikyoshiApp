//
//  ScoreData.swift
//  FirstStage
//
//  Created by Scott Freshour on 7/27/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

// Exercise states . . .
let  kExer_NotStarted: Int = 0
let  kExer_InProgress: Int = 1
let  kExer_Completed:  Int = 2

struct exerciseScore: Codable {
    var exerciseID:     String
    var state:          Int
    var starScore:      Float
    var score:          Float
    
    init() {
        self.exerciseID = ""
        self.state      = kExer_NotStarted
        self.starScore  = 0.0
        self.score      = 0.0
    }
    
    init(exerciseID: String) {
        self.exerciseID = exerciseID
        self.state      = kExer_NotStarted
        self.starScore  = 0.0
        self.score      = 0.0
    }
}

struct level: Codable {
    var title: String
    var levelID: String
    var exercises: [exerciseScore]
}

struct studentScore: Codable {
    var name: String
    var title: String
    var levels: [level]
}

struct exerciseIDs
{
    var whichLevelID:       String
    var whichLevelIndex:    Int
    var whichExerciseID:    String
    var whichExerciseIndex: Int
}


/////////////////////////////////////////////////////////////////////
//
//   Temp stuff for testing.  Remove soon.

var loadCycle: Int = 0
let kMaxStarCount = 4

func getIntStarCount( floatScore: Float ) -> Int {
    var retVal = Int(round(floatScore))
    if retVal > kMaxStarCount {
        retVal = kMaxStarCount
    }
    if retVal < 0 {
        retVal = 0
    }
    return retVal
}

func testThis() {
    let x1: Float = 3.4
    let x2: Float = 3.9
    let x3: Float = 0.2
    let x4: Float = 0.7
    
    var res = getIntStarCount(floatScore: x1)
    res = getIntStarCount(floatScore: x2)
    res = getIntStarCount(floatScore: x3)
    res = getIntStarCount(floatScore: x4)
    
}



