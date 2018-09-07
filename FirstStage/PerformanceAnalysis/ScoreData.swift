//
//  ScoreData.swift
//  FirstStage
//
//  Created by Scott Freshour on 7/27/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

// Level. Day, Exercise states . . .
let  kLDEState_FieldEmpty:          Int = -2 // entry valid but no members
let  kLDEState_FieldNotPresent:     Int = -1 // entry simply not in disk file
let  kLDEState_NotStarted:          Int =  0
let  kLDEState_NotStartedDisabled:  Int =  1
let  kLDEState_InProgress:          Int =  2
let  kLDEState_Completed:           Int =  3

let  kLT_NotAttemptedYet: Double =  0.0


struct exerciseScore: Codable {
    var exerciseID: String
    var index:      Int
    var state:      Int
    var starScore:  Int     // "Rounded" version of raw score below
    var rawScore:   Float
    
    init() {
        self.exerciseID = ""
        self.index      = 0
        self.state      = kLDEState_NotStarted
        self.starScore  = 0
        self.rawScore   = 0.0
    }
    
    init(exerciseID: String, index: Int) {
        self.exerciseID = exerciseID
        self.index      = index
        self.state      = kLDEState_NotStarted
        self.starScore  = 0
        self.rawScore   = 0.0
    }
}

struct dayScore: Codable {
    var dayTitle:   String
    var dayIndex:   Int
    var dayState:   Int
    var dayScore:   Float
    var exercises:  [exerciseScore]

    init() {
        self.dayTitle   = "NOTSET"
        self.dayIndex   = 0
        self.dayState   = kLDEState_NotStarted
        self.dayScore   = 0.0
        self.exercises  = []
    }
    
    init(dayTitle: String, index: Int) {
        self.dayTitle   = dayTitle
        self.dayIndex   = index
        self.dayState   = kLDEState_NotStarted
        self.dayScore   = 0.0
        self.exercises  = []
    }
}

struct level: Codable {
    var title:     String
    var state:     Int
    var levelID:   String
    var days:      [dayScore]
    
    init( title:     String,
          state:     Int,
          levelID:   String,
          days:      [dayScore] )  {
        self.title   = title
        self.state   = state
        self.levelID = levelID
        self.days    = days
    }
    init() {
        self.title   = "NOTSET"
        self.state   = kLDEState_NotStarted
        self.levelID = "NOTSET"
        self.days    = []
    }
}

struct studentScore: Codable {
    var name: String
    var title: String
    var jsonVersionString: String
    var jsonVersionMajor:  Int
    var jsonVersionMid:    Int
    var jsonVersionMinor:  Int
    var managedLevel:      Int
    var managedDay:        Int
    var longtonePersRecords: [Double]
    var levels: [level]
    
    init( name: String,
          title: String,
          jsonVersionMajor:  Int,
          jsonVersionMid:    Int,
          jsonVersionMinor:  Int,
          levels: [level] )  {
        self.name              = name
        self.title             = title
        self.managedLevel      = 0
        self.managedDay        = 0
        self.jsonVersionMajor  = jsonVersionMajor
        self.jsonVersionMid    = jsonVersionMid
        self.jsonVersionMinor  = jsonVersionMinor
        self.levels            = levels
        
        self.longtonePersRecords = Array( repeating: kLT_NotAttemptedYet,
                                          count: kLTPersBestKey_NumKeys )

        let versMajStr = String(jsonVersionMajor)
        let versMidStr = String(jsonVersionMid)
        let versMinStr = String(jsonVersionMinor)

        self.jsonVersionString = versMajStr + "." + versMidStr + "." + versMinStr
    }
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

// Move me . . .
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



