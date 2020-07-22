//
//  ScoreData.swift
//  FirstStage
//
//  Created by Scott Freshour on 7/27/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation
import SwiftyJSON

// Level. Day, Exercise states . . .
let  kLDEState_FieldEmpty:          Int = -2 // entry valid but no members
let  kLDEState_FieldNotPresent:     Int = -1 // entry simply not in disk file
let  kLDEState_NotStarted:          Int =  0
let  kLDEState_NotStartedDisabled:  Int =  1
let  kLDEState_InProgress:          Int =  2
let  kLDEState_Completed:           Int =  3

let  kLT_NotAttemptedYet: Double =  0.0

struct exerciseScoreV4: Codable {
    var exerciseID:     String
    var index:          Int
    var state:          Int
    var starScore:      Int     // "Rounded" version of raw score below
    var rawScore:       Float
    // new
    var numAttempts:    Int
    var exerVar1:       Float  // percentOfTarget, or BPM
    var exerVar2:       Float
    var exerVar3:       Float

    init() {
        self.exerciseID     = ""
        self.index          = 0
        self.state          = kLDEState_NotStarted
        self.starScore      = 0
        self.rawScore       = 0.0
        self.numAttempts    = 0
        self.exerVar1       = 0.0
        self.exerVar2       = 0.0
        self.exerVar3       = 0.0
    }
    
    init(exerciseID: String, index: Int) {
        self.exerciseID     = exerciseID
        self.index          = index
        self.state          = kLDEState_NotStarted
        self.starScore      = 0
        self.rawScore       = 0.0
        self.numAttempts    = 0
        self.exerVar1       = 0.0
        self.exerVar2       = 0.0
        self.exerVar3       = 0.0
    }
}

struct dayScoreV4: Codable {
    var dayTitle:             String
    var dayIndex:             Int
    var dayState:             Int
    var dayScore:             Float
    var invokedFromCKSession: Bool // was this day invoked from SchoolWork/ClassKit session?
    var dayVar1:              Float // extensible, for possible future use w/o upgrade
    var dayVar2:              Float // extensible, for possible future use w/o upgrade
    var exercises:  [exerciseScoreV4]

    init() {
        self.dayTitle             = "NOTSET"
        self.dayIndex             = 0
        self.dayState             = kLDEState_NotStarted
        self.dayScore             = 0.0
        self.invokedFromCKSession = false
        self.exercises            = []
        self.dayVar1              = 0.0
        self.dayVar2              = 0.0
    }
    
    init(dayTitle: String, index: Int) {
        self.dayTitle             = dayTitle
        self.dayIndex             = index
        self.dayState             = kLDEState_NotStarted
        self.dayScore             = 0.0
        self.invokedFromCKSession = false
        self.exercises  = []
        self.dayVar1              = 0.0
        self.dayVar2              = 0.0
    }
}

struct levelV4: Codable {
    var title:      String
    var canDiscard: Int
    var state:      Int
    var levelID:    String
    var days:       [dayScoreV4]
    var levelVar1:  Float // extensible, for possible future use w/o upgrade
    var levelVar2:  Float // extensible, for possible future use w/o upgrade

    init( title:      String,
          canDiscard: Int,
          state:      Int,
          levelID:    String,
          days:       [dayScoreV4] )  {
        self.title      = title
        self.canDiscard = canDiscard
        self.state      = state
        self.levelID    = levelID
        self.days       = days
        self.levelVar1  = 0.0
        self.levelVar2  = 0.0
    }
    init() {
        self.title      = "NOTSET"
        self.canDiscard = 1
        self.state      = kLDEState_NotStarted
        self.levelID    = "NOTSET"
        self.days       = []
        self.levelVar1  = 0.0
        self.levelVar2  = 0.0
    }
}


struct studentScoreV4: Codable {
    var name: String
    var title: String
    var jsonVersionString: String
    var jsonVersionMajor:  Int
    var jsonVersionMid:    Int
    var jsonVersionMinor:  Int
    var managedLevel:      Int
    var managedDay:        Int
    var scoreVar1:         Float // extensible, for possible future use w/o upgrade
    var scoreVar2:         Float // extensible, for possible future use w/o upgrade
    var longtonePersRecords: [Double]
    var levels: [levelV4]
    
    init( name: String,
          title: String,
          jsonVersionMajor:  Int,
          jsonVersionMid:    Int,
          jsonVersionMinor:  Int,
          levels: [levelV4] )  {
        self.name              = name
        self.title             = title
        self.managedLevel      = 0
        self.managedDay        = 0
        self.scoreVar1         = 0.0
        self.scoreVar2         = 0.0
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

let kSlurLevelIndex = 31

//         SCOREFILEHERE - search tag
func create_ScoreV3_FromScoreV2(currScoreV2: inout studentScoreV2) -> Bool { // success?

    currScoreV2.jsonVersionMid   = 3
    currScoreV2.jsonVersionMinor = 0

    
//    print("\n==============================================\n")
//    print("        Converting V2 to V3 score file")
//    print("\n==============================================\n")
//    print("\n Old V2 file:\n\n")
//    print("\(currScoreV2)\n\n")

    if  currInstIsAClarinet() {

        // Need to add Clarinet exers where Slurs would go, and
        // add new level for Clarinet-only exers
        
        // Loop through existing Levels, and see if need to add CrossBreak Exers
        //var levelIdx = 0
        let numScoreLevels = currScoreV2.levels.count
        for scrLvlIdx in 0..<numScoreLevels  {
            let levelID  = currScoreV2.levels[scrLvlIdx].levelID
            print("--------->>>>>   levelID == \(levelID)")
            if levelID == kIdxForLipSlurs { // This will change exisitng lip slurs to cross breaks.
                
                print("====================\n    Slur Score Level, before conversion: \n\n")
                print("\(currScoreV2.levels[scrLvlIdx])\n\n =============================")

                currScoreV2.levels[scrLvlIdx].title = ""
                let numDays = currScoreV2.levels[scrLvlIdx].days.count
                for dayIdx in 0..<numDays {
                    let numExers =
                        currScoreV2.levels[scrLvlIdx].days[dayIdx].exercises.count
                    for exerIdx in 0..<numExers {
                        var exerID =
                            currScoreV2.levels[scrLvlIdx].days[dayIdx].exercises[exerIdx].exerciseID
                        if getExerciseType(exerCode: exerID) == .lipSlurExer {
                            changeSlurExerStrToCBExerStr(slrStr: &exerID)
                            currScoreV2.levels[scrLvlIdx].days[dayIdx].exercises[exerIdx].exerciseID =
                                exerID
                        }
                    }
                }
                
                print("====================\n    Slur Score Level, after conversion: \n\n")
                print("\(currScoreV2.levels[scrLvlIdx])\n\n =============================")
            }
        }
  
        // Now, loop through all levels looking for need to insert ....
 
        guard let jsonExerTop = getJsonExerPlan() else {
            itsBad();  return false }
        
        // Need to add Clarinet exers where Slurs would go, and
        // add new level for Clarinet-only exers
        
        // Loop through existing Levels, and see if need to add CrossBreak Exers
        //var levelIdx = 0
        for scrLvlIdx in 0..<numScoreLevels  {
            let jsonLevel  = jsonExerTop["levels"][scrLvlIdx]
            let levelID  = currScoreV2.levels[scrLvlIdx].levelID
            print("--------->>>>>   levelID == \(levelID)")
//            if levelID == kIdxForLipSlurs {
                
            print("====================\n    Score Level \(scrLvlIdx), before conversion: \n\n")
            print("\(currScoreV2.levels[scrLvlIdx])\n\n =============================")
            
            currScoreV2.levels[scrLvlIdx].title = ""
            let numDays = currScoreV2.levels[scrLvlIdx].days.count
            for dayIdx in 0..<numDays {
                var jsonDay = jsonLevel["days"][dayIdx]
                let jsonExersStr = jsonDay["exercises"].string!
                let exerStringsArray = parseExercises(exercisesList: jsonExersStr)
                let jsonExerCount = exerStringsArray.count
                
                let numScoreExers =
                    currScoreV2.levels[scrLvlIdx].days[dayIdx].exercises.count
                
                if numScoreExers == jsonExerCount { // nothing to do
                    continue
                }
                
                var dayScoreCopy = currScoreV2.levels[scrLvlIdx].days[dayIdx]
                
                var scoreExerIdx = 0 // start out in sync
                // This will add new cross break exers if not present.
                if scrLvlIdx == kSlurLevelIndex && numScoreExers == 0 {
                    // In old scores, there are no exers in the days
                    for jsonExerIdx in 0..<jsonExerCount {
                        let jsonExerStr = exerStringsArray[jsonExerIdx]
                        if getExerciseType( exerCode: jsonExerStr ) == .lipSlurExer {
                            var newExerStr = jsonExerStr
                            changeSlurExerStrToCBExerStr(slrStr: &newExerStr)
                            let newExer = exerciseScore(exerciseID: newExerStr, index: jsonExerIdx)
                            dayScoreCopy.exercises.insert(newExer, at: jsonExerIdx)
                        } else {
                            itsBad()
                        }
                    }
                 }   // else {
/*
                     for jsonExerIdx in 0..<jsonExerCount {
                        let scoreExerID =
                            currScoreV2.levels[scrLvlIdx].days[dayIdx].exercises[scoreExerIdx].exerciseID
                        let jsonExerStr = exerStringsArray[jsonExerIdx]
                        if scoreExerID.uppercased() != jsonExerStr.uppercased() {
                            if getExerciseType( exerCode: jsonExerStr ) == .lipSlurExer {
                                var newExerStr = jsonExerStr
                                changeSlurExerStrToCBExerStr(slrStr: &newExerStr)
                                let newExer = exerciseScore(exerciseID: newExerStr, index: jsonExerIdx)
                                dayScoreCopy.exercises.insert(newExer, at: jsonExerIdx)
                            } else {
                                itsBad()
                            }
                        } else {
                            scoreExerIdx += 1
                        }
                    }
                }
*/
                currScoreV2.levels[scrLvlIdx].days[dayIdx] = dayScoreCopy
            }

            print("====================\n   Score Level \(scrLvlIdx), after conversion: \n\n")
            print("\(currScoreV2.levels[scrLvlIdx])\n\n =============================")
        }
        
        return true
        
    } else { // current instrument is not a clarinet; nothing to do.
        
        return true
        
    }
} // create_ScoreV3_FromScoreV2

func create_ScoreV4_FromScoreV3(currScoreV3: studentScoreV2,
                                newScoreV4: inout studentScoreV4) -> Bool { // success?

    guard newScoreV4.levels.count == 0 else {
        itsBad(); return false  }
    
    newScoreV4.name                 = currScoreV3.name
    newScoreV4.title                = currScoreV3.title
    newScoreV4.jsonVersionString    = currScoreV3.jsonVersionString
    newScoreV4.jsonVersionMajor     = currScoreV3.jsonVersionMajor
    newScoreV4.jsonVersionMid       = 4
    newScoreV4.jsonVersionMinor     = currScoreV3.jsonVersionMinor
    newScoreV4.managedLevel         = currScoreV3.managedLevel
    newScoreV4.managedDay           = currScoreV3.managedDay
    newScoreV4.scoreVar1            = 0.0
    newScoreV4.scoreVar2            = 0.0
    newScoreV4.longtonePersRecords  = currScoreV3.longtonePersRecords

    let numLevels = currScoreV3.levels.count
    for levIdx in 0..<numLevels {
        let oneCurrScoreLevel = currScoreV3.levels[levIdx]
        var newScoreLevel = levelV4()
        
        newScoreLevel.title      = oneCurrScoreLevel.title
        newScoreLevel.canDiscard = oneCurrScoreLevel.canDiscard
        newScoreLevel.state      = oneCurrScoreLevel.state
        newScoreLevel.levelID    = oneCurrScoreLevel.levelID
        
        let numDays = oneCurrScoreLevel.days.count
        for dayIdx in 0..<numDays {
            let oneCurrScoreDay = oneCurrScoreLevel.days[dayIdx]
            var newScoreDay = dayScoreV4()
            
            newScoreDay.dayTitle                = oneCurrScoreDay.dayTitle
            newScoreDay.dayIndex                = oneCurrScoreDay.dayIndex
            newScoreDay.dayState                = oneCurrScoreDay.dayState
            newScoreDay.dayScore                = oneCurrScoreDay.dayScore
            
            let numExers = oneCurrScoreDay.exercises.count
            for exerIdx in 0..<numExers {
                let oneCurrScoreExer = oneCurrScoreDay.exercises[exerIdx]
                var newScoreExer = exerciseScoreV4()

                newScoreExer.exerciseID     = oneCurrScoreExer.exerciseID
                newScoreExer.index          = oneCurrScoreExer.index
                newScoreExer.state          = oneCurrScoreExer.state
                newScoreExer.starScore      = oneCurrScoreExer.starScore
                newScoreExer.rawScore       = oneCurrScoreExer.rawScore
                newScoreDay.exercises.append(newScoreExer)
            }
            newScoreLevel.days.append(newScoreDay)
        }
        newScoreV4.levels.append(newScoreLevel)
        
        // for testing
        if levIdx == 2   ||
           levIdx == 9   ||
           levIdx == 21  ||
           levIdx == 30  ||
           levIdx == 31    {
            print("Found one")
        }
    }
    
    return true
    
} // create_ScoreV4_FromScoreV3
    

func getJsonExerPlan() -> JSON? {
    guard let file = Bundle.main.path(forResource: "TrumpetLessons",
                                      ofType: "json")    else {
                                        print("Invalid filename/path for TrumpetLessons.JSON")
                                        return false
    }
    
    guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: file))  else {
        print("Could not create JSON data from TrumpetLessons.JSON")
        itsBad()
        return false
    }
    
    let instrumentJson = try? JSON(data: jsonData)
    guard instrumentJson != nil  else {
        print("Could not create JSON data from TrumpetLessons.JSON")
        itsBad()
        return nil
    }

    return instrumentJson
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

// MARK: - Older Versions of structs

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

// There is no structural diff bt V2 and V3, it's just diff content (For clarinet,
// diff num of Levels and diff num of exers in common levels).
typealias studentScoreV3 = studentScoreV2

