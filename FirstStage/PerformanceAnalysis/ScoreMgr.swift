//
//  ScoreMgr.swift
//  FirstStage
//
//  Created by Scott Freshour on 7/27/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

// TODO: Save score data when backgrounded, etc.

class ScoreMgr {
    
    static let instance = ScoreMgr()
    
    let MKDataDirName       = "MKData"
    let MKUserDataFileName  = "UserScore"
 
    var currUserScore: studentScore? = nil
    var currentExerciseLevelIndex: Int = 0
    var currentExerciseIndex: Int = 0
    var currentExercise: exerciseScore = exerciseScore()
    
    var currentExerciseState: Int {
        get { return currentExercise.state }
        set {
            print("Setting ExerciseState for \(currentExercise.exerciseID) to \(newValue)\n")
            currentExercise.state = newValue
        }
    }
    
    var currentExerciseScore: Float {
        get { return currentExercise.score }
        set {
            print("Setting ExerciseScore for \(currentExercise.exerciseID) to \(newValue)\n")
            currentExercise.score = newValue
        }
    }
    
    var currentExerciseStarScore: Float {
        get { return currentExercise.starScore }
        set {
            print("Setting ExerciseStarScore for \(currentExercise.exerciseID) to \(newValue)\n")
            currentExercise.starScore = newValue
        }
    }
    
    func updateCurrentScore(score: Float, starScore: Float, state: Int) {
        currentExercise.score     = score
        currentExercise.starScore = starScore
        currentExercise.state     = state
    }
    
    func loadExercise( currLevelIndex: Int, currExerciseIndex: Int, exerciseTag: String ) -> Bool {
        guard currUserScore != nil,
            currLevelIndex >= 0,
            currLevelIndex < (currUserScore?.levels.count)! else {
                print("Error: Issue with Current User Score Integrity")
                return false
        }
        
        currentExercise =
            currUserScore!.levels[currLevelIndex].exercises[currExerciseIndex]
        
        // Sanity check:
        guard currentExercise.exerciseID == exerciseTag else {
            print("Error: Current Student exercise tag doesn't match expected tag")
            return false
        }
        
        currentExerciseLevelIndex = currLevelIndex
        currentExerciseIndex = currExerciseIndex

        return true
    }
    
    func saveCurrentExercise() {
        guard currUserScore != nil else {
            print ("Can't save exercise - Current User Score is nil")
            return
        }
        currUserScore!.levels[currentExerciseLevelIndex].exercises[currentExerciseIndex] = currentExercise
    }
    
    ////////////////////////////////////////////////////////////////////
    // Find Score file on disk, and and open it.
    //   If first time in App, will create.
    func loadScoreFile() -> Bool {
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
                print("\nLoaded file:\n")
                print(jsonString)
                print("\n")
            }
            currUserScore = try? jsonDecoder.decode(studentScore.self, from: retreivedData!)
            if currUserScore != nil {
                print("Created currUserScore from dosk file data")
                succeeded = true
            } else {
                print("Error - Unable to create currUserScore from dosk file data")
            }
        }
        
        return succeeded
    }
    
    ////////////////////////////////////////////////////////////////////
    // Save in-memory Score data to file on disk
    func saveScoreFile() -> Bool {
        var succeeded = false
        saveCurrentExercise()
        
        guard let mkDataDirUrl = getMKDataDir() else { return succeeded }
        
        let fm = FileManager.default
        let mkScoreFileURL = mkDataDirUrl.appendingPathComponent(MKUserDataFileName)
        let mkScoreFilePath = mkScoreFileURL.path
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let jsonData: Data? = try? jsonEncoder.encode(currUserScore)
        if jsonData != nil  {
            if let jsonString = String(data:jsonData!, encoding: .utf8) {
                print("\nJSON when saving file:\n")
                print(jsonString)
                print("\n")
            }
            try? jsonData!.write(to: mkScoreFileURL, options: .atomic)
        }
        if fm.fileExists(atPath: mkScoreFilePath) {
            succeeded = true
        }
        
        return succeeded
    }
    
    // MARK: Support methods for file opening and saving
    
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
    
    // MARK: Methods for initial data structs and file creation

    ////////////////////////////////////////////////////////////////////////
    // If first time in App, this method is called to create the
    // initial Student Score file
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
                print("\nJSON when creating initial Student Score file:\n")
                print(jsonString)
                print("\n")
            }
        }
        if fm.fileExists(atPath: mkScoreFilePath) {
            succeeded = true
        }

        return succeeded
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
        currUserScore = studentScore( name: (instrumentJson?["name"].string)!,
                                      title: (instrumentJson?["title"].string)!,
                                      levels: [])
        
        // Populate the empty top level score struct with entries, using Levels
        // and Exercise entries in TrumpetLessons.JSON data
        for lvlIdx in 0...numLevels-1 {
            let levelTag: String = jsonLevels[lvlIdx]["levelTag"].string!
            let levelIdx: String = jsonLevels[lvlIdx]["levelIdx"].string!
            let oneLevel = level(title: levelTag,
                                 levelID: levelIdx,
                                 exercises: [])
            currUserScore?.levels.append(oneLevel)
            
            // now populate this one level with the exercises in the level
            let jsonExers = jsonLevels[lvlIdx]["exercises"]
            let numExers  = jsonLevels[lvlIdx]["exercises"].count
            for exerIdx in 0...numExers-1 {
                let exerTag: String = jsonExers[exerIdx]["exerciseTag"].string!
                let oneExer = exerciseScore(exerciseID: exerTag)
                currUserScore?.levels[lvlIdx].exercises.append(oneExer)
            }
        }
        
        print("Succesfully created empty StudentScore data in memory from JSON")
        return true
    }
    
    /////////////////////////////////////////////////////////
    //
    //  temp stuff:
    
    func changeScore() {
        guard currUserScore != nil else { return }
        
        switch loadCycle {
        case 0: currUserScore?.levels[0].exercises[2].starScore = 2
                currUserScore?.levels[0].exercises[2].score = 2.4
                break
        case 1: currUserScore?.levels[1].exercises[0].starScore = 3
                currUserScore?.levels[1].exercises[0].score     = 2.8
                break
        case 2: currUserScore?.levels[1].exercises[1].starScore = 3
                currUserScore?.levels[1].exercises[1].score     = 3.4
                break
        case 3: currUserScore?.levels[1].exercises[2].starScore = 4
                currUserScore?.levels[1].exercises[2].score     = 3.8
                break
        case 4: currUserScore?.levels[2].exercises[0].starScore = 2
                currUserScore?.levels[2].exercises[0].score     = 3.1
                break
        default: break
        }
        
        loadCycle += 1
    }

 }

