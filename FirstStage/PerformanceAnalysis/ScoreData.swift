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

struct levelV2: Codable {
    var title:      String
    var canDiscard: Int         // diff between V1 and V2
    var state:      Int
    var levelID:    String
    var days:       [dayScore]
    
    init( title:      String,
          canDiscard: Int,
          state:      Int,
          levelID:    String,
          days:       [dayScore] )  {
        self.title      = title
        self.canDiscard = canDiscard
        self.state      = state
        self.levelID    = levelID
        self.days       = days
    }
    init() {
        self.title      = "NOTSET"
        self.canDiscard = 1
        self.state      = kLDEState_NotStarted
        self.levelID    = "NOTSET"
        self.days       = []
    }
}

struct level: Codable { // V1
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

struct studentScore: Codable {     // V1
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
                                          count: kLTPersBestKey_NumEntries )

        let versMajStr = String(jsonVersionMajor)
        let versMidStr = String(jsonVersionMid)
        let versMinStr = String(jsonVersionMinor)

        self.jsonVersionString = versMajStr + "." + versMidStr + "." + versMinStr
    }
}

struct studentScoreV2: Codable {
    var name: String
    var title: String
    var jsonVersionString: String
    var jsonVersionMajor:  Int
    var jsonVersionMid:    Int
    var jsonVersionMinor:  Int
    var managedLevel:      Int
    var managedDay:        Int
    var longtonePersRecords: [Double]
    var levels: [levelV2]
    
    init( name: String,
          title: String,
          jsonVersionMajor:  Int,
          jsonVersionMid:    Int,
          jsonVersionMinor:  Int,
          levels: [levelV2] )  {
        self.name              = name
        self.title             = title
        self.managedLevel      = 0
        self.managedDay        = 0
        self.jsonVersionMajor  = jsonVersionMajor
        self.jsonVersionMid    = jsonVersionMid
        self.jsonVersionMinor  = jsonVersionMinor
        self.levels            = levels
        
        self.longtonePersRecords = Array( repeating: kLT_NotAttemptedYet,
                                          count: 128 )
        
        let versMajStr = String(jsonVersionMajor)
        let versMidStr = String(jsonVersionMid)
        let versMinStr = String(jsonVersionMinor)
        
        self.jsonVersionString = versMajStr + "." + versMidStr + "." + versMinStr
    }
}

func create_LevelV2_FromLevelV1(currLevelV1:level,
                                discardable: Bool = false) -> levelV2 {
    let canDiscardInt = discardable ? 1 : 0
    let levV2 = levelV2(title:      currLevelV1.title,
                        canDiscard: canDiscardInt,
                        state:      currLevelV1.state,
                        levelID:    currLevelV1.levelID,
                        days:       currLevelV1.days)
    
    return levV2
}

func create_ScoreV2_FromScoreV1(currScoreV1: studentScore,
                                includingUpToLevel: Int) ->studentScoreV2 {
    
    let currJsonVers = LsnSchdlr.instance.scoreMgr.getInstrumentJsonVersion()
    
    var newScoreV2 = studentScoreV2( name: currScoreV1.name,
                                     title: currScoreV1.title,
                                     jsonVersionMajor:  currJsonVers.major,
                                     jsonVersionMid:    currJsonVers.mid,
                                     jsonVersionMinor:  currJsonVers.minor,
                                     levels: [] )
    newScoreV2.managedLevel         = currScoreV1.managedLevel
    newScoreV2.managedDay           = currScoreV1.managedDay
    
    //  ARRRR   LTPR !!!!!
    for i in kLTPersBestKey_First..<kLTPersBestKey_NumKeys {
        let oldLTRScore = currScoreV1.longtonePersRecords[i]
        newScoreV2.longtonePersRecords[Int(NoteIDs.G5)+i] = oldLTRScore
    }
    
    newScoreV2.longtonePersRecords  = currScoreV1.longtonePersRecords

    // Add the old levels, but only if they are in the range we want to keep
    var idx = 0
    for oldLev in currScoreV1.levels {
        if let oldLevIdx = Int(oldLev.levelID) {
            if oldLevIdx <= includingUpToLevel {
                let levV2 = create_LevelV2_FromLevelV1(currLevelV1: oldLev,
                                                       discardable: false)
                newScoreV2.levels.append(levV2)
            }
        }
        idx += 1
    }
    
    return newScoreV2
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
    if alwaysFalseToSuppressWarn() { print("\(res)") }
    res = getIntStarCount(floatScore: x2)
    res = getIntStarCount(floatScore: x3)
    res = getIntStarCount(floatScore: x4)
    
}

//import UIKit

class DiskStatus {
    
    //MARK: Formatter MB only
    class func MBFormatter(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useMB
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes) as String
    }
    
    
    //MARK: Get String Value
    class var totalDiskSpace:String {
        get {
            return ByteCountFormatter.string(fromByteCount: totalDiskSpaceInBytes,
                                             countStyle: ByteCountFormatter.CountStyle.file)
        }
    }
    
    class var freeDiskSpace:String {
        get {
            return ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes,
                                             countStyle: ByteCountFormatter.CountStyle.file)
        }
    }
    
    class var usedDiskSpace:String {
        get {
            return ByteCountFormatter.string(fromByteCount: usedDiskSpaceInBytes,
                                             countStyle: ByteCountFormatter.CountStyle.file)
        }
    }
    
    
    //MARK: Get raw value
    class var totalDiskSpaceInBytes:Int64 {
        get {
            do {
                let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
                let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value
                return space!
            } catch {
                return 0
            }
        }
    }
    
    class var freeDiskSpaceInBytes:Int64 {
        get {
            do {
                let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
                let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value
                return freeSpace!
            } catch {
                return 0
            }
        }
    }
    
    class var usedDiskSpaceInBytes:Int64 {
        get {
            let usedSpace = totalDiskSpaceInBytes - freeDiskSpaceInBytes
            return usedSpace
        }
    }
    
}

