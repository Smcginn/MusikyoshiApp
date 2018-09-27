//
//  LessonScheduler.swift
//  FirstStage
//
//  Created by Scott Freshour on 8/14/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//
//  Keeps track of Which is the next exercise, Day, Level, etc. to do.
//
//  Pass through calls to ScoreMgr, to save/set. retreive score info
//


import Foundation

typealias longtoneExerciseInfo = (note: String, durationSecs: Int)
let kBadLTExerInfo = longtoneExerciseInfo("C0", 0)

//////////////////////////////////////////////////////////////////////////////
//
//  LDE's and LD's: tuple IDs for specifying specific Days or Exercises
//     Used throughout the codebase
//       LDE:  "Level, Day, Exercise"
//       LD:   "Level, Day"
//
typealias tLD_code  = (level: Int, day: Int)
typealias tLDE_code = (level: Int, day: Int, exer: Int)
let kLDE_FldNotSet      = -1
let kLDE_FldNotFound    = -2
let kLDE_AtEndOfEntries = -3

let kLD_NotSet:         tLD_code   = (level: kLDE_FldNotSet, day: kLDE_FldNotSet)
let kLD_NotFound:       tLD_code   = (level: kLDE_FldNotFound, day: kLDE_FldNotFound)
let kLD_AtEndOfEntries: tLD_code   = (level: kLDE_AtEndOfEntries, day: kLDE_AtEndOfEntries)
let kLDE_NotSet: tLDE_code   = ( level: kLDE_FldNotSet,
                                 day:   kLDE_FldNotSet,
                                 exer:  kLDE_FldNotSet )
let kLDE_NotFound: tLDE_code = ( level: kLDE_FldNotFound,
                                 day:   kLDE_FldNotFound,
                                 exer:  kLDE_FldNotFound )
func ldIsUsable(ld:tLD_code) -> Bool {
    if ld != kLD_NotSet && ld != kLD_NotFound && ld != kLD_AtEndOfEntries {
        return true
    } else {
        return false 
    }
}


struct exerciseData {
    var exerCodeStr: String
    var exerType:    ExerciseType
    
    init() {
        self.exerCodeStr = ""
        self.exerType    = .unknownExer
    }
    init( exerCode: String, exerType: ExerciseType ) {
        self.exerCodeStr = exerCode
        self.exerType    = exerType
     }
}


// to shorten the name in calling code
typealias LsnSchdlr = LessonScheduler

class LessonScheduler
{
    static let instance = LessonScheduler()
    
    init() {
    }
    
    let scoreMgr = ScoreMgr()
    let tuneFileMapper = TuneFileMapper()

    // currentLDE: The Exercise being currently performed
    var currentLDE: tLDE_code = kLDE_NotSet
    
    func getCurrentLDE() -> tLDE_code {
        return currentLDE
    }
    func setCurrentLDE(toLDE: tLDE_code) -> Bool {
        guard scoreMgr.verifyLDE(lde: toLDE) else {
            currentLDE = kLDE_NotSet
            return false
        }
        currentLDE = toLDE
        return true
    }
    func incrementCurrentLDE() -> Bool {
        guard currentLDE != kLDE_NotSet else { return false }
        
        let possLDE: tLDE_code = ( level: currentLDE.level,
                                   day:   currentLDE.day,
                                   exer:  currentLDE.exer + 1 )
        guard scoreMgr.verifyLDE(lde: possLDE) else { return false }
        
        currentLDE = possLDE
        return true
    }
    func verifyLDE(_ thisLDE: tLDE_code ) -> Bool {
        return scoreMgr.verifyLDE(lde: thisLDE)
    }
    
    // For Current Day
    var exercisesData:[exerciseData] = []
    func clearExercisesData() {
        exercisesData.removeAll()
    }

    func numExercises(ld: tLD_code) -> Int {   //  GETRIDOF  ???
        return scoreMgr.numExercises(ld: ld)
    }

    func reset() {  //  GETRIDOF ??
        scoreMgr.reset()
    }
    
    /////////////////////////////////////////
    //  Get Exercise String
    func getExerIDStr( lde: tLDE_code ) -> String {
         return scoreMgr.getExerIDStr(lde: lde)
    }
    
    /////////////////////////////////////////
    //  Exercise Status
    func getExerState( lde: tLDE_code ) -> Int {
        return scoreMgr.getExerciseState(lde: lde)
    }
    
    /////////////////////////////////////////
    //  Get Exercise Score
    func getExerStarScore( lde: tLDE_code ) -> Int {
        return scoreMgr.getExerciseStarScore(lde: lde)
    }
    
    /////////////  LDE Setters . . .
    func setExerciseState( lde: tLDE_code, exerState: Int ) {
        scoreMgr.setExerciseState( lde: lde, exerState: exerState )
    }
    
    func setExerciseStarScore( lde: tLDE_code, starScore: Int ) {
        scoreMgr.setExerciseStarScore( lde: lde, starScore: starScore )
    }
    
    func setExerciseRawScore( lde: tLDE_code, rawScore: Float ) {
        scoreMgr.setExerciseRawScore( lde: lde, rawScore: rawScore )
    }
   
    // MARK: - Funcs to see if Day, Level completed
    
    func calcAllExersInDayState(dayLD: tLD_code) -> Int {
        return scoreMgr.calcAllExersInDayState(dayLD: dayLD)
    }
    
    func calcAllDaysInLevelState(level: Int) -> Int {
        return scoreMgr.calcAllDaysInLevelState(level: level)
    }
    
    func setLevelState(level: Int, newState: Int) {
        scoreMgr.setLevelState(level: level, newState: newState)
    }
    
    func getLevelState(level: Int) -> Int {
        return scoreMgr.getLevelState(level: level)
    }
    
    func setDayState( forLD: tLD_code, newState: Int) {
        scoreMgr.setDayState( forLD: forLD, newState: newState)
    }
    
    func getDayState( forLD: tLD_code) -> Int {
        return scoreMgr.getDayState( forLD: forLD)
    }
    
    func setCurrentDay(_ dayIdx: Int) -> Bool {
        guard scoreMgr.verifyDay(level: scoreMgr.currLevel(), day:dayIdx) else {
            print ("Something wrong in LessonScheduler::setCurrentDay()")
            itsBad()
            return false
        }
        
        scoreMgr.setCurrDay(dayIdx)
        return true
    }
    
    func setCurrentLevel(_ levelIdx: Int) -> Bool {
        guard scoreMgr.verifyLevel(level:levelIdx) else {
            print ("Something wrong in LessonScheduler::setCurrentLevel()")
            itsBad()
            return false
        }
        
        scoreMgr.setCurrLevel(levelIdx)
        return true
    }
    
    func getCurrExerNumber() -> Int {
        return scoreMgr.currExer()
    }
    
    func getCurrExerType() -> ExerciseType {
        let exerFileCode = scoreMgr.currentExerciseFileCode()
        let exerType = getExerciseType( exerCode: exerFileCode )
        return exerType
    }
    
    func getCurrExerFileCode() -> String {
        return scoreMgr.currentExerciseFileCode()
    }

    func getTuneFileInfo(forFileCode: String) -> tuneFileInfo {
        return tuneFileMapper.getTuneFileInfo(forFileCode: forFileCode)
    }

     func loadLevelDay(ld: tLD_code) -> Bool {
        reset()
        scoreMgr.setCurrLevel(ld.level)  // REDUX - like get rid of this
        scoreMgr.setCurrDay(ld.day)      // REDUX - like get rid of this
        
        clearExercisesData()
        let exerStrings = scoreMgr.getExerStrings(ld: ld)
        if exerStrings.count == 0 {
            return false
        }
        
        for oneStr in exerStrings {
            let exerType = getExerciseType( exerCode: oneStr )
            if exerType == .unknownExer {
                print("ERROR!  unkown exerType encountered in loadLevelDay")
                return false
            }
            let oneExerData = exerciseData(exerCode: oneStr, exerType: exerType)
            exercisesData.append(oneExerData)
        }
        
        return true
    }
    
    func loadExercisesDataForDay(ld: tLD_code) {
        guard scoreMgr.verifyLD(ld) else { return }
        
        clearExercisesData()
        let numExers = scoreMgr.numExercises(ld: ld) // should do this from Json . . .
        for exerIdx in 0...numExers-1 {
            let thisLDE: tLDE_code = ( ld.level, ld.day, exerIdx )
            let exerFileCode = scoreMgr.getExerIDStr(lde: thisLDE)
            let exerType     = getExerciseType( exerCode: exerFileCode )
            let oneExerData  = exerciseData(exerCode: exerFileCode, exerType: exerType)
            exercisesData.append(oneExerData)
        }
    }
    
    func getPrettyNameForExercise( forLDE: tLDE_code ) -> String {
        var retStr = "SOMETHING WRONG"
        let thisLD: tLD_code = (forLDE.level, forLDE.day)
        let exerNum = forLDE.exer
        guard exerNum >= 0,
              exerNum < scoreMgr.numExercises(ld: thisLD) else { return retStr }
        
        guard exerNum < exercisesData.count else { return "No Entries in exercisesData" }
        let exerEntry = exercisesData[exerNum]
        
        retStr = ""
//        retStr = getTextForExerciseType(exerType: exerEntry.exerType)
//        retStr += " - "
        if  exerEntry.exerType == .rhythmPartyExer   ||
            exerEntry.exerType == .rhythmPrepExer    ||
            exerEntry.exerType == .lipSlurExer       ||
            exerEntry.exerType == .scalePowerExer    ||
            exerEntry.exerType == .intervalExer      ||
            exerEntry.exerType == .tuneExer
        {
            let tuneFI = getTuneFileInfo(forFileCode: exerEntry.exerCodeStr)
            //retStr += "\"" + tuneFI.title + "\""
            retStr += tuneFI.title
        } else if exerEntry.exerType == .longtoneExer {
            let ltInfo:longtoneExerciseInfo = getLongtoneInfo(forLTCode: exerEntry.exerCodeStr)
            //retStr = "Long Tone - Play a \(ltInfo.note) for \(ltInfo.durationSecs) Seconds"
            retStr = "Long Tone - Play a \(ltInfo.note) for \(ltInfo.durationSecs) Seconds"
        } else if exerEntry.exerType ==  .longtoneRecordExer {
            let ltInfo:longtoneExerciseInfo = getLongtoneRecordInfo(forLTCode: exerEntry.exerCodeStr)
            retStr = "Long Tone Record - Play a \(ltInfo.note) for as long as you can"
        }
        return retStr
    }
    
    // MARK: - Score File related
    
    func loadScoreFile() {
        _ = scoreMgr.loadScoreFile()
    }
    
    func updateScoreFields(forLDE: tLDE_code,  rawScore: Float,
                           starScore: Int,     state: Int)  -> Bool  {
        guard scoreMgr.verifyLDE(lde: forLDE) else {
            print("Error: In updateScoreFields; verifyLDE failed")
            itsBad()
            return false
        }
        
        scoreMgr.setExerciseState( lde: forLDE, exerState: state )
        scoreMgr.setExerciseStarScore( lde: forLDE, starScore: starScore )
        scoreMgr.setExerciseRawScore( lde: forLDE, rawScore: rawScore )
        
        return true
    }
    
    func saveScoreFile() -> Bool {
        return scoreMgr.saveScoreFile()
    }

    // MARK: - Personal Best

    func getPersonalBestTime(forNoteID: Int) -> Double {
        return scoreMgr.getPersonalBestTime(forNoteID: forNoteID)
    }
    
    func setPersonalBestTime(forNoteID: Int, newPersBest: Double) {
        scoreMgr.setPersonalBestTime(forNoteID: forNoteID, newPersBest: newPersBest)
    }
}
