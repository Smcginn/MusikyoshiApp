//
//  ScoreMgr.swift
//  FirstStage
//
//  Created by Scott Freshour on 7/27/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

//
// Actual disk file managment in ScoreMgr extension in file
// ScoreFileVersionManagement.swift
//

import UIKit
import Foundation
import SwiftyJSON

// TODO: Save score data when backgrounded, etc.

let kPrintJsonBeforeWritingToDisk = true

typealias tDB_Version = (major: Int, mid: Int, minor: Int)
let kBadDBVersion: tDB_Version = (major: -1, mid: -1, minor: -1)

class ScoreMgr {
    
    var currUserScore: studentScoreV2? = nil
    
    // This is only needed if we need to convert an exsiting V1 Score file to
    // a V2 score file
    var tempV1UserScore: studentScore? = nil
    
    private var _currLevel: Int = 0
    private var _currDay: Int = 0
    private var _currExer: Int = 0
    private var _currExerciseData: exerciseScore = exerciseScore()
    func setCurrLevel(_ level: Int) {
        guard verifyLevel(level: level) else {
            itsBad()
            _currLevel = 0
            return
        }
        _currLevel = level
    }
    func currLevel() -> Int { return _currLevel }
    
    func setCurrDay(_ day: Int) {
        guard verifyDay(level: _currLevel, day: day) else {
            itsBad()
            _currDay = 0
            return
        }
        _currDay = day
    }

    func currExer() -> Int { return _currExer }
    
    func getExerStrings(ld: tLD_code) -> [String] {
        var strs:[String] = []
        guard verifyLD(ld) else { return strs }
        
        for oneEntry in currUserScore!.levels[ld.level].days[ld.day].exercises {
            let exerCode = oneEntry.exerciseID
            strs.append(exerCode)
        }
        return strs
    }
    
    func reset() {
        _currLevel  = 0
        _currDay    = 0
        _currExer   = 0
        _currExerciseData = exerciseScore()
    }

    
    func numLevels() -> Int {
        if currUserScore != nil {
            return currUserScore!.levels.count
        } else {
            return 0
        }
    }
    
    func numDays(inLevel: Int) -> Int {
        guard verifyLevel(level: inLevel) else {
            print("levels wrong in numDays()")
            itsBad()
            return 0
        }

        return currUserScore!.levels[inLevel].days.count
    }

    func numExercises(inLevel: Int, inDay: Int) -> Int {
        guard verifyDay(level: inLevel, day: inDay) else {
            print("something wrong in numDays()")
            itsBad()
            return 0
        }
        return currUserScore!.levels[inLevel].days[inDay].exercises.count
    }
    func numExercises(ld: tLD_code) -> Int {
        guard verifyLD(ld) else {
            print("can't verify LD in numExercises()")
            itsBad()
            return 0
        }
        return numExercises(inLevel: ld.level, inDay: ld.day)
    }
    
    func exerciseFileCode(exerIdx: Int) -> String {
        guard verifyExercise(level: _currLevel, day: _currDay, exercise: exerIdx) else {
            itsBad()
            _currExer = 0
            return "SOMETHING WRONG WITH EXERIDX"
        }
        return
            currUserScore!.levels[_currLevel].days[_currDay].exercises[exerIdx].exerciseID
    }
    
    func currentExerciseFileCode() -> String {
        return _currExerciseData.exerciseID
    }
    
    /////////////////////////////////////////
    //  Get Exercise Code Str
    func getExerIDStr( lde: tLDE_code ) -> String {
        guard verifyLDE(lde: lde) else {
            print("Error: In getExerIDStr; verifyLDE failed")
            return ""
        }
        
        return currUserScore!.levels[lde.level].days[lde.day].exercises[lde.exer].exerciseID
    }
    
    func getExerciseState( lde: tLDE_code ) -> Int {
        guard verifyLDE(lde: lde) else {
            print("Error: In getExerciseState; verifyLDE failed")
            return 0
        }
        
        return currUserScore!.levels[lde.level].days[lde.day].exercises[lde.exer].state
    }
    
    func getExerciseStarScore( lde: tLDE_code ) -> Int {
        guard verifyLDE(lde: lde) else {
            print("Error: In getExerciseStarScore; verifyLDE failed")
            return 0
        }
        
        return currUserScore!.levels[lde.level].days[lde.day].exercises[lde.exer].starScore
    }
    
    func getExerciseRawScore( lde: tLDE_code ) -> Float {
        guard verifyLDE(lde: lde) else {
            print("Error: In getExerciseStarScore; verifyLDE failed")
            return 0
        }
        
        return currUserScore!.levels[lde.level].days[lde.day].exercises[lde.exer].rawScore
    }
    
/////////////  LDE Setters . . .
    func setExerciseState( lde: tLDE_code, exerState: Int ) {
        guard verifyLDE(lde: lde) else {
            print("Error: In setExerciseState; verifyLDE failed")
            itsBad()
            return
        }
        
        currUserScore!.levels[lde.level].days[lde.day].exercises[lde.exer].state = exerState
    }
    
    func setExerciseStarScore( lde: tLDE_code, starScore: Int ) {
        guard verifyLDE(lde: lde) else {
            print("Error: In setExerciseStarScore; verifyLDE failed")
            itsBad()
            return
        }
        
        currUserScore!.levels[lde.level].days[lde.day].exercises[lde.exer].starScore = starScore
    }
    
    func setExerciseRawScore( lde: tLDE_code, rawScore: Float ) {
        guard verifyLDE(lde: lde) else {
            print("Error: In setExerciseRawScore; verifyLDE failed")
            itsBad()
            return
        }
        
        currUserScore!.levels[lde.level].days[lde.day].exercises[lde.exer].rawScore = rawScore
    }
    
    func updateScoreFields( forLDE: tLDE_code, rawScore: Float,
                            starScore: Int,    state: Int )     -> Bool {
        guard verifyLDE(lde: forLDE) else {
            print("Error: In updateScoreFields; verifyLDE failed")
            return false
        }
        _currExerciseData.rawScore  = rawScore
        _currExerciseData.starScore = starScore
        _currExerciseData.state     = state
        return true
    }
    
    // MARK: - -- Funcs to see if Day, Level completed
   
    func getManagedLD() -> tLD_code {
        guard currUserScore != nil else { return kLD_NotFound }
        
        let currMngdLD: tLD_code = (currUserScore!.managedLevel,
                                    currUserScore!.managedDay)
        return currMngdLD
    }
    
    func setManagedLD(newMngdLD: tLD_code) -> Bool {
        guard currUserScore != nil,
              verifyLD(newMngdLD)  else { return false }
        
        currUserScore!.managedLevel = newMngdLD.level
        currUserScore!.managedDay   = newMngdLD.day
        return true
    }
    
    func incrementManagedDay() -> tLD_code {
        guard currUserScore != nil else { return kLD_NotFound }
        
        let currMngdLD: tLD_code = (currUserScore!.managedLevel,
                                    currUserScore!.managedDay)
        guard verifyLD(currMngdLD) else { return kLD_NotFound }
        
        // go to next Day
        var proposedLD: tLD_code = (currMngdLD.level,
                                    currMngdLD.day + 1)
        if !verifyLD(proposedLD) { // No more days left in current Level
            proposedLD = (currMngdLD.level+1, 0 ) // try next level
            if !verifyLD(proposedLD) { // No more levels left!
                return kLD_AtEndOfEntries
            }
        }
        
        // if still here, then proposedLD is good to go
        currUserScore!.managedLevel = proposedLD.level
        currUserScore!.managedDay   = proposedLD.day
        return proposedLD
    }
    
    func calcAllExersInDayState(dayLD: tLD_code) -> Int {
        guard verifyLD(dayLD) else { return kLDEState_FieldNotPresent }
        
        let numExers = numExercises(inLevel: dayLD.level, inDay: dayLD.day)
        guard numExers > 0 else { return kLDEState_FieldEmpty }

        var atLeastOneIsDone   = false
        var oneOrMoreIsNotDone = false
        var retState = kLDEState_NotStarted
        
        for exerIdx in 0...numExers-1 {
            let exerLDE: tLDE_code = (dayLD.level, dayLD.day, exerIdx)
            let exerState = getExerciseState(lde: exerLDE)
            if exerState == kLDEState_Completed {
                atLeastOneIsDone   = true
            } else {
                oneOrMoreIsNotDone = true
            }
        }
        if !oneOrMoreIsNotDone { // then all are done
            retState = kLDEState_Completed
        } else if atLeastOneIsDone {
            retState = kLDEState_InProgress
        } // else default state of kLDEState_NotStarted
        
        return retState
    }
    
    func calcAllDaysInLevelState(level: Int) -> Int {
        guard verifyLevel(level: level) else {
            itsBad()
            return kLDEState_FieldNotPresent
        }
        
        let dayCount = numDays(inLevel: level)
        guard dayCount > 0 else { return kLDEState_FieldEmpty }

        var atLeastOneIsDone   = false
        var oneOrMoreIsNotDone = false
        var retState = kLDEState_NotStarted
        
        for dayIdx in 0...dayCount-1 {
            let dayLD: tLD_code = (level, dayIdx )
            let dayState = getDayState(forLD: dayLD)
            if dayState == kLDEState_Completed {
                atLeastOneIsDone   = true
            } else {
                oneOrMoreIsNotDone = true
            }
        }
        if !oneOrMoreIsNotDone { // then all are done
            retState = kLDEState_Completed
        } else if atLeastOneIsDone {
            retState = kLDEState_InProgress
        } // else default state of kLDEState_NotStarted
        
        return retState
    }
    
    func setLevelState(level: Int, newState: Int) {
        guard verifyLevel(level: level) else { return }
        
        currUserScore!.levels[level].state = newState
    }
    
    func getLevelState(level: Int) -> Int {
        guard verifyLevel(level: level) else { return kLDEState_FieldNotPresent }
        
        return currUserScore!.levels[level].state
    }
    
    
    func setDayState( forLD: tLD_code, newState: Int) {
        guard verifyLD(forLD) else { return }
        
        currUserScore!.levels[forLD.level].days[forLD.day].dayState = newState
    }
    
    func getDayState( forLD: tLD_code) -> Int {
        guard verifyLD(forLD) else { return kLDEState_FieldNotPresent }
        
        return currUserScore!.levels[forLD.level].days[forLD.day].dayState
    }
    
    
    // MARK: - -- Verify Level, Day, Exercise
    
    func verifyLevel(level: Int) -> Bool {
        guard currUserScore != nil else { return false }
        guard level >= 0, level < numLevels() else { return false }

        return true
    }
    
    func verifyDay(level: Int, day: Int) -> Bool {
        guard verifyLevel(level: level) else { return false }
        guard day >= 0 && day < numDays(inLevel: level) else { return false }
 
        return true
    }
    func verifyLD(_ ld: tLD_code) -> Bool {
        return verifyDay(level: ld.level, day: ld.day)
    }
    func verifyCurrDay() -> Bool {
        return verifyDay(level: _currLevel, day: _currDay)
    }

    func verifyExercise(level: Int, day: Int, exercise: Int) -> Bool {
        guard verifyDay(level: level, day: day) else { return false }
        guard exercise >= 0,
              exercise < numExercises(inLevel: level, inDay: day) else { return false }
        
        return true
    }
    
    func verifyLDE( lde: tLDE_code) -> Bool {
        return verifyExercise(level: lde.level, day: lde.day, exercise: lde.exer)
    }
    
    func updateScoreFields(lde: tLDE_code,  rawScore: Float,
                           starScore: Int,     state: Int)  -> Bool  {
        guard verifyLDE(lde: lde) else {
            print ("Something wrong in ScoreMgr.updateScoreFields()")
            itsBad()
            return false
        }
        
        currUserScore!.levels[lde.level].days[lde.day].exercises[lde.exer].rawScore = rawScore
        currUserScore!.levels[lde.level].days[lde.day].exercises[lde.exer].starScore = starScore
        currUserScore!.levels[lde.level].days[lde.day].exercises[lde.exer].state = state
        return true
    }
    
    func saveCurrentExercise() {
        guard currUserScore != nil,
             verifyExercise( level:    _currLevel,
                             day:      _currDay,
                             exercise: _currExer ) else {
                print("Error: verifyExercise() failed in saveCurrentExercise")
                itsBad()
                return
        }
        
        currUserScore!.levels[_currLevel].days[_currDay].exercises[_currExer] = _currExerciseData
        print("In ScoreMgr.saveCurrentExercise(). Level:\(_currLevel), Day:\(_currDay), Exer:\(_currExer)")
    }
    
    /*
    ////////////////////////////////////////////////////////////////////
    // Find Score file on disk, and and open it.
    //   If first time in App, will create.
    func loadScoreFile() -> Bool {
        var succeeded = false
        guard let mkDataDirUrl = getMKDataDir() else { return succeeded }
        
        let fm = FileManager.default
        let currInstr = getCurrentStudentInstrument()
        if !vers2ScoreFileExistsForInst(instr: currInstr) {
            // Is there a version 1 file that needs to be converted?
            if vers1ScoreFileExists() {
                // Convert the file                     TODO
            } else {
                // create new version 2 ScoreFile       TODO
            }
        }
        
        
        let mkScoreFileURL = mkDataDirUrl.appendingPathComponent(MKUserDataFileName)
        let mkScoreFilePath = mkScoreFileURL.path
        if !fm.fileExists(atPath: mkScoreFilePath) {
            // first time in App. Try to create the Score file.
            if !createScoreFile(mkScoreFileUrl: mkScoreFileURL) { return succeeded }
        }
        if fm.fileExists(atPath: mkScoreFilePath) {
            currUserScore = nil
            let jsonDecoder = JSONDecoder()
            let retreivedData = try? Data(contentsOf:mkScoreFileURL)
            if let jsonString = String(data:retreivedData!, encoding: .utf8) {
                //               print("\nLoaded file:\n")
                //               print(jsonString)
                //              print("\n")
            }
            currUserScore = try? jsonDecoder.decode(studentScoreV2.self, from: retreivedData!)
            if currUserScore != nil {
                print("Created currUserScore from disk file data")
                succeeded = true
            } else {
                itsBad()
                print("Error - Unable to create currUserScore from disk file data")
            }
        }
        
        return succeeded
    }
    
    ////////////////////////////////////////////////////////////////////
    // Find Score file on disk, and and open it.
    //   If first time in App, will create.
    func loadV1ScoreFile() -> Bool {
        var succeeded = false
        guard let mkDataDirUrl = getMKDataDir() else { return succeeded }
        
        let fm = FileManager.default
        let mkScoreFileURL = mkDataDirUrl.appendingPathComponent(MKUserDataFileName)
        let mkScoreFilePath = mkScoreFileURL.path
        if !fm.fileExists(atPath: mkScoreFilePath) {
            // first time in App. Try to create the Score file.
            if !createScoreFile(mkScoreFileUrl: mkScoreFileURL) { return succeeded }
        }
        if fm.fileExists(atPath: mkScoreFilePath) {
            currUserScore = nil
            let jsonDecoder = JSONDecoder()
            let retreivedData = try? Data(contentsOf:mkScoreFileURL)
            if let jsonString = String(data:retreivedData!, encoding: .utf8) {
                //               print("\nLoaded file:\n")
                //               print(jsonString)
                //              print("\n")
            }
            currUserScore = try? jsonDecoder.decode(studentScoreV2.self, from: retreivedData!)
            if currUserScore != nil {
                print("Created currUserScore from disk file data")
                succeeded = true
            } else {
                itsBad()
                print("Error - Unable to create currUserScore from disk file data")
            }
        }
        
        return succeeded
    }
    */
    
    /*
    ////////////////////////////////////////////////////////////////////
    // Save in-memory Score data to file on disk
    //   As V2 file
    func saveScoreFile() -> Bool {
        var succeeded = false
        
        let currInstr = getCurrentStudentInstrument()
        guard let mkScoreFileURL = getURLForV2ScoreFile(instr: currInstr) else { return false }

//        guard let mkDataDirUrl = getMKDataDir() else { return succeeded }
//
//        let fm = FileManager.default
//        let mkScoreFileURL = mkDataDirUrl.appendingPathComponent(MKUserDataFileName)
        
        let mkScoreFilePath = mkScoreFileURL.path
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let jsonData: Data? = try? jsonEncoder.encode(currUserScore)
        if jsonData != nil  {
            if kPrintJsonBeforeWritingToDisk,
               let jsonString = String(data:jsonData!, encoding: .utf8) {
//                print("\nJSON when saving file:\n")
 //               print(jsonString)
//                print("\n")
            }
            try? jsonData!.write(to: mkScoreFileURL, options: .atomic)
        }
        let fm = FileManager.default
        if fm.fileExists(atPath: mkScoreFilePath) {
            succeeded = true
        }
        
        return succeeded
    }
    */
    
    // MARK: - -- PersonalBest related
    
    func getPersonalBestTime(forNoteID: Int) -> Double {
        var retVal: Double =  kLT_NotAttemptedYet
        guard currUserScore != nil  else {
            itsBad()
            return retVal
        }
        
        let pbKey = mapNoteIDToPBKey(noteID: forNoteID)
        guard verifyPersBestKey(persBestKey: pbKey) else {
            itsBad()
            return retVal
        }
        
        retVal = currUserScore!.longtonePersRecords[pbKey]
        
        return retVal
    }
    
    func setPersonalBestTime(forNoteID: Int, newPersBest: Double) {
        guard currUserScore != nil  else {
            itsBad()
            return
        }
        
        let pbKey = mapNoteIDToPBKey(noteID: forNoteID)
        guard verifyPersBestKey(persBestKey: pbKey) else {
            itsBad()
            return
        }
        
        currUserScore!.longtonePersRecords[pbKey] = newPersBest
    }
}

/*
    /////////////////////////////////////////////////////////////
    // MARK: - -- Support methods for file opening and saving
    
    let MKDataDirName       = "MKData"
    let MKUserDataFileName  = "UserScore"
    
    // Get the app's sandbox dir
    func getAppSupportDir() -> URL? {
        var retUrl: URL? = nil
        do {
            let fm = FileManager.default
            retUrl = try fm.url(for: .applicationSupportDirectory,
                                 in: .userDomainMask,
                     appropriateFor: nil,
                             create: true)
        } catch {
            // TODO deal with error
        }
        return retUrl
    }
    
    // Get the MKData dir, within the app's sandbox dir
    func getMKDataDir() -> URL? {
        var mkDataURL: URL? = nil
        if let appSptUrl = getAppSupportDir() {
            let fm = FileManager.default
            let tempMKDataURL = appSptUrl.appendingPathComponent(MKDataDirName)
            let filePath = tempMKDataURL.path
            if !fm.fileExists(atPath: filePath) {
                // First timerunning app.  Create the MKData dir in the sandbox dir.
                do {
                    try fm.createDirectory(at: tempMKDataURL,
                                           withIntermediateDirectories: true)
                } catch {
                    // TODO deal with error
                }
            }
            if fm.fileExists(atPath: filePath) {
                mkDataURL = tempMKDataURL
            }
        }

        return mkDataURL
    }
    
    func getURLForV1ScoreFile() -> URL? {
        guard let mkDataDirUrl = getMKDataDir() else { return nil }
        
        var mkDataURL: URL? = nil
        mkDataURL = mkDataDirUrl.appendingPathComponent(MKUserDataFileName)

        return mkDataURL
    }
    
    func getURLForV2ScoreFile(instr: Int) -> URL? {
        guard let mkDataDirUrl = getMKDataDir() else { return nil }
        
        var mkDataURL: URL? = nil
        let scoreFilename = getScoreFilenameForInstr(instr: instr)
        mkDataURL = mkDataDirUrl.appendingPathComponent(scoreFilename)
        
        return mkDataURL
    }
    
    // For version 1 Score File
    func deleteCurrentScoreFile() -> Bool {
        guard let mkScoreFileURL = getURLForV1ScoreFile() else { return false }
        let mkScoreFilePath = mkScoreFileURL.path
        
        let fm = FileManager.default
        do {
            if !fm.fileExists(atPath: mkScoreFilePath) {
                print("\n In deleteCurrentScoreFile;  File does not exist\n")
                return true // it's not there, so . . .
            } else {
                try fm.removeItem(atPath: mkScoreFilePath)
            }
        }
        catch let error as NSError {
            print("An error took place In deleteCurrentScoreFile: \(error)")
            return false
        }
        
        if fm.fileExists(atPath: mkScoreFilePath) {
            return false
        } else {
            return true
        }
    }
    
    func getScoreFilenameForInstr(instr: Int) -> String {
        let subname = getScoreFileSubNameForInstr(instr: instr)
        let retStr = MKUserDataFileName + subname
        return retStr
    }
    
    func vers1ScoreFileExists() -> Bool {
        // fixme todo
        return true
    }
    
    func vers2ScoreFileExistsForInst(instr: Int) -> Bool {
        // fixme todo
        return true
    }
    
    // For Version 2 (and up?) Score Files
    func deleteScoreFileForInst(instr: Int) -> Bool {
        guard let mkScoreFileURL = getURLForV2ScoreFile(instr: instr) else { return false }
        let mkScoreFilePath = mkScoreFileURL.path
        
        let fm = FileManager.default
//
//
//
//        guard let mkDataDirUrl = getMKDataDir() else { return false }
//
//        let fm = FileManager.default
//
//        let scoreFilename = getScoreFilenameForInstr(instr: instr)
//        let mkScoreFileURL = mkDataDirUrl.appendingPathComponent(scoreFilename)
//        let mkScoreFilePath = mkScoreFileURL.path
//
        do {
            if !fm.fileExists(atPath: mkScoreFilePath) {
                print("\n In deleteCurrentScoreFile;  File does not exist\n")
                return true // it's not there, so . . .
            } else {
                try fm.removeItem(atPath: mkScoreFilePath)
            }
        }
        catch let error as NSError {
            print("An error took place In deleteCurrentScoreFile: \(error)")
            return false
        }
        
        if fm.fileExists(atPath: mkScoreFilePath) {
            return false
        } else {
            return true
        }
    }
    

    
    // MARK: - -- Methods for initial data structs and file creation

    ////////////////////////////////////////////////////////////////////////
    // If first time in App, this method is called to create the
    // initial Student Score file    (Version 2 Score File)
    func createScoreFile(mkScoreFileUrl: URL?) -> Bool {
        var succeeded = false
        
        // Create the in-memory ScoreData, in the form to be saved to disk
        guard createStudentScoreDataFromJSON() else {
            print ("Unable to create initial in-memory data storage from JSON")
            return false
        }

        guard mkScoreFileUrl != nil else { return succeeded }
        
        let mkScoreFilePath = mkScoreFileUrl!.path
        let fm = FileManager.default
    
        // Sucessfully created in-memory data struct. Save to disk
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let jsonData: Data? = try? jsonEncoder.encode(currUserScore)
        if jsonData != nil  {
            try? jsonData!.write(to: mkScoreFileUrl!, options: .atomic)
            if let jsonString = String(data:jsonData!, encoding: .utf8) {
//                print("\nJSON when creating initial Student Score file:\n")
//                print(jsonString)
//                print("\n")
            }
        }
        if fm.fileExists(atPath: mkScoreFilePath) {
            succeeded = true
        }

        return succeeded
    }

/ * original version
    func createScoreFile(mkScoreFileUrl: URL?) -> Bool {
        var succeeded = false
        
        // Create the in-memory ScoreData, in the form to be saved to disk
        guard createStudentScoreDataFromJSON() else {
            print ("Unable to create initial in-memory data storage from JSON")
            return false
        }
        
        guard mkScoreFileUrl != nil else { return succeeded }
        
        let mkScoreFilePath = mkScoreFileUrl!.path
        let fm = FileManager.default
        
        // Sucessfully created in-memory data struct. Save to disk
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let jsonData: Data? = try? jsonEncoder.encode(currUserScore)
        if jsonData != nil  {
            try? jsonData!.write(to: mkScoreFileUrl!, options: .atomic)
            if let jsonString = String(data:jsonData!, encoding: .utf8) {
                //                print("\nJSON when creating initial Student Score file:\n")
                //                print(jsonString)
                //                print("\n")
            }
        }
        if fm.fileExists(atPath: mkScoreFilePath) {
            succeeded = true
        }
        
        return succeeded
    }
* /

    
    
    func getInstrumentJsonVersion() -> tDB_Version {
        var dbVersion: tDB_Version = kBadDBVersion
        
        guard let file = Bundle.main.path(forResource: "TrumpetLessons",
                                          ofType: "json")    else {
                                            print("In getJsonDBVersion, Invalid filename/path for TrumpetLessons.JSON")
                                            return dbVersion
        }
        
        guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: file))  else {
            print("In getJsonDBVersion, Could not create JSON data from TrumpetLessons.JSON")
            return dbVersion
        }
        
        let instrumentJson = try? JSON(data: jsonData)
        guard instrumentJson != nil  else {
            print("in getJsonDBVersion, Could not create JSON data from TrumpetLessons.JSON")
            return dbVersion
        }
        
        let jsonverMajInt: Int = Int((instrumentJson?["jsonVersionMajor"].string)!)!
        let jsonverMidInt: Int = Int((instrumentJson?["jsonVersionMid"].string)!)!
        let jsonverMinInt: Int = Int((instrumentJson?["jsonVersionMinor"].string)!)!
        
        dbVersion = (major: jsonverMajInt, mid: jsonverMidInt, minor: jsonverMinInt)
        
        return dbVersion
    }
    
    ////////////////////////////////////////////////////////////////////////
    // If first time in App, this method is called to create the
    // initial in-memory StudentScoreData
    func createStudentScoreDataFromJSON() -> Bool {
        guard let file = Bundle.main.path(forResource: "TrumpetLessons",
                                               ofType: "json")    else {
            print("Invalid filename/path for TrumpetLessons.JSON")
            return false
        }
        
        guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: file))  else {
            print("Could not create JSON data from TrumpetLessons.JSON")
            return false
        }
        
        let instrumentJson = try? JSON(data: jsonData)
        guard instrumentJson != nil  else {
            print("Could not create JSON data from TrumpetLessons.JSON")
            return false
        }
        
        guard let numLevels = instrumentJson?["levels"].count else {
            print("Could not get num Levels from TrumpetLessons.JSON data")
            return false
        }

        guard let jsonLevels = instrumentJson?["levels"] else {
            print("Could not get num Levels from TrumpetLessons.JSON")
            return false
        }
        
        // Create the empty top level score struct
        let jsonverMajInt: Int = Int((instrumentJson?["jsonVersionMajor"].string)!)!
        let jsonverMidInt: Int = Int((instrumentJson?["jsonVersionMid"].string)!)!
        let jsonverMinInt: Int = Int((instrumentJson?["jsonVersionMinor"].string)!)!
        currUserScore = studentScoreV2( name:  (instrumentJson?["name"].string)!,
                                        title: (instrumentJson?["title"].string)!,
                                        jsonVersionMajor: jsonverMajInt,
                                        jsonVersionMid:   jsonverMidInt,
                                        jsonVersionMinor: jsonverMinInt,
                                        levels: [] )
        
        // Populate the empty top level score struct with entries, using Levels
        // and Exercise entries in TrumpetLessons.JSON data
        for lvlIdx in 0...numLevels-1 {
            let oneJsonLevel = jsonLevels[lvlIdx]
            let levelTag:   String = oneJsonLevel["title"].string!
            let levelIdx:   String = oneJsonLevel["levelIdx"].string!
            var canDiscard: Int = 1
            if let canDiscardStr = oneJsonLevel["canDiscardForMerge"].string {
                if canDiscardStr == "Y" {
                    canDiscard = 1
                } else {
                    canDiscard = 0
                }
            }
            let oneLevel = levelV2(title: levelTag,
                                   canDiscard: canDiscard,
                                   state: kLDEState_NotStarted,
                                   levelID: levelIdx,
                                   days: [])
            currUserScore?.levels.append(oneLevel)
            
            // Days . . . populate this one level with the days in the level
            let jsonDays = oneJsonLevel["days"]
            let numDays  = jsonDays.count // jsonLevels[lvlIdx]["days"].count
            for dayIdx in 0...numDays-1 {
                let dayTitle: String = jsonDays[dayIdx]["title"].string!
                
                let oneDayScore = dayScore(dayTitle: dayTitle, index: dayIdx)
                currUserScore?.levels[lvlIdx].days.append(oneDayScore)

                // now, get the exercises and add them
                let exercisesStr = jsonDays[dayIdx]["exercises"].string!
                let exerStrings = parseExercises(exercisesList: exercisesStr)
                let numExers  = exerStrings.count
                for exerIdx in 0...numExers-1 {
                    let oneExerStr = exerStrings[exerIdx]
                    let oneExerScore = exerciseScore(exerciseID: oneExerStr, index: exerIdx)
                    currUserScore?.levels[lvlIdx].days[dayIdx].exercises.append(oneExerScore)
                }
            }
        }
        
        print("Succesfully created empty StudentScore data in memory from JSON")
        return true
    }
    
    func getDBMajorVersion() -> Int {
        if currUserScore == nil {
            return -1
        }
        
        return (currUserScore?.jsonVersionMajor)! as Int
    }
    
    func getDBMidVersion() -> Int {
        if currUserScore == nil {
            return -1
        }
        
        return (currUserScore?.jsonVersionMid)!  as Int
    }
    
    func getDBMinorVersion() -> Int {
        if currUserScore == nil {
            return -1
        }
        
        return (currUserScore?.jsonVersionMinor)!  as Int
    }
    
    func isJsonVersionEqual(versionTuple: tDB_Version) -> Bool {
        let dbMajor = getDBMajorVersion()
        let dbMid   = getDBMidVersion()
        let dbMinor = getDBMinorVersion()

        if dbMajor == versionTuple.major  &&
           dbMid   == versionTuple.mid    &&
           dbMinor == versionTuple.minor      {
            return true
        } else {
            return false
        }
    }
    
    // Instrument json will have this to be stored in future.  For now, return 1 for Trumpet
    func getInstrumentCode() -> Int {
        return 1; // Trumpet
    }
    
    func getAvailableDiscSpace() {
        
        //let ds = DiskStatus()
        let totalDiskSpace = DiskStatus.totalDiskSpace
        let freeDiskSpace = DiskStatus.freeDiskSpace
        let usedDiskSpace = DiskStatus.usedDiskSpace
        
        let totalDiskSpaceInt = DiskStatus.totalDiskSpaceInBytes
        let freeDiskSpaceInt = DiskStatus.freeDiskSpaceInBytes
        let usedDiskSpaceInt = DiskStatus.usedDiskSpaceInBytes

        print ("Available Disc Space: \(freeDiskSpace)")
    }
    
    func getScoreFileSize() -> UInt64 {
        var fileSz = UInt64(0)
        
//        var succeeded = false
        guard let mkDataDirUrl = getMKDataDir() else { return 0 }
        
        let fm = FileManager.default
        let mkScoreFileURL = mkDataDirUrl.appendingPathComponent(MKUserDataFileName)
        let mkScoreFilePath = mkScoreFileURL.path
        if !fm.fileExists(atPath: mkScoreFilePath) {
            return 0
        }
        if fm.fileExists(atPath: mkScoreFilePath) {
            fileSz = mkScoreFileURL.fileSize
            let fileSzStr = mkScoreFileURL.fileSizeString
            print ("ScoreFileSize ==  \(fileSzStr)")
        }
        
        return fileSz
    }
}

// moveme
extension URL {
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }
    
    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }
    
    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }
    
    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}
*/
