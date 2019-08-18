//
//  ScoreFileVersion Management.swift
//  FirstStage
//
//  Created by Scott Freshour on 1/26/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//
//
//  extension of ScoreMgr, stuff that deals with disk file
//

import UIKit
import Foundation
import SwiftyJSON

let MKDataDirName       = "MKData"
let MKUserDataFileName  = "UserScore"

// When converting a V1 file to a V2 file, this is the highest level in the V1
// file we want to keep the records for.
let kV1HighestSaveLevel = 10

extension ScoreMgr {
    
    func convertV1FileToV2File(forInstrument: Int) -> Bool {
        // Step 1: get the existing disk file into memory as a V1 data struct
        if !loadV1ScoreFile()  {
            itsBad() // todo real error handling!
            return false
        }
        let numV1Levels = tempV1UserScore?.levels.count
        guard tempV1UserScore != nil,
              numV1Levels != nil else {
            itsBad() // todo real error handling!
            return false
        }
        // At this point, the old file has been successfully loaded into tempV1UserScore
        
        // Step 2:  Create a V2 data struct, with top-level info in current json.
        guard createStudentScoreDataFromJSON(forV2File: false)  else {
            print ("\nconvertV1FileToV2File: Unable to create initial in-memory data storage from JSON\n")
            itsBad() // todo real error handling!
            return false
        }
        
        guard currUserScore != nil else {
            itsBad()
            return false
        }
        
        // Step 3:  From the existing V1 file, take the "Keeper" levels, convert
        //          them to V2 Levels, then use them to replace the V2 Score entries
        let numLevelsToConvert = min(kV1HighestSaveLevel, numV1Levels!)
        var idx = 0
        for lev1 in tempV1UserScore!.levels {
            let lev2 = create_LevelV2_FromLevelV1(currLevelV1:lev1,
                                                  discardable: false)
            currUserScore!.levels[idx] = lev2
            
            idx += 1
            if idx >= numLevelsToConvert {
                break
            }
        }
        
 //       return true
        
        // delete old file, save new one
        
        // RESTORE      FILEFILEFILEFILE
        // deleteCurrentScoreFile()  // this call deletes the older V1 file
        _ = saveScoreFile()
        return true
    }
    
    ////////////////////////////////////////////////////////////////////
    // Find Score file on disk, and and open it.
    //   If first time in App, will create.
    func loadScoreFile() -> Bool {
        var succeeded = false
        guard let mkDataDirUrl = getMKDataDir() else { return succeeded }
        let strVal = String(describing: mkDataDirUrl )
        if alwaysFalseToSuppressWarn() { print("\(strVal)" ) }
        
        let fm = FileManager.default
        let currInstr = getCurrentStudentInstrument()
        if !vers2ScoreFileExistsForInst(instr: currInstr) {
            // Is there a version 1 file that needs to be converted?
            if vers1ScoreFileExists() {
                _ = convertV1FileToV2File(forInstrument: currInstr)
                // Convert the file                     TODO
            }
            else {
                let currInstr = getCurrentStudentInstrument()
                guard let mkScoreFileURL = getURLForV2ScoreFile(instr: currInstr) else {
                    itsBad() // todo real error handling!
                    return false
                }
                let mkScoreFilePath = mkScoreFileURL.path
                if !fm.fileExists(atPath: mkScoreFilePath) {
                    // first time in App. Try to create the Score file.
                    if !createScoreFile(mkScoreFileUrl: mkScoreFileURL) { return succeeded }
                }
            }
        }

        if vers2ScoreFileExistsForInst(instr: currInstr) {
//        let mkScoreFileURL = mkDataDirUrl.appendingPathComponent(MKUserDataFileName)
//        let mkScoreFilePath = mkScoreFileURL.path
//        if !fm.fileExists(atPath: mkScoreFilePath) {
//            // first time in App. Try to create the Score file.
//            if !createScoreFile(mkScoreFileUrl: mkScoreFileURL) { return succeeded }
//        }
//        if fm.fileExists(atPath: mkScoreFilePath) {
            currUserScore = nil
             guard let mkScoreFileURL = getURLForV2ScoreFile(instr: currInstr) else {
                itsBad() // todo real error handling!
                return false
            }
//            let mkScoreFilePath = mkScoreFileURL.path

            
            
            let jsonDecoder = JSONDecoder()
            let retreivedData = try? Data(contentsOf:mkScoreFileURL)
            // Uncomment to print out contents of score file as JSON data
//            if let jsonString = String(data:retreivedData!, encoding: .utf8) {
//                               print("\nLoaded file:\n")
//                               print(jsonString)
//                              print("\n")
//            }
            currUserScore = try? jsonDecoder.decode(studentScoreV2.self, from: retreivedData!)
            if currUserScore != nil {
                print("Created currUserScore from disk file data")
                succeeded = true
            } else {
                itsBad()
                print("Error - Unable to create currUserScore from disk file data")
            }
        }

        
        
        
        
        // Old stuff, for V1 file
        /*
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
        */
        
        return succeeded
    }
    
    ////////////////////////////////////////////////////////////////////
    // Find Score file on disk, and and open it.
    //   If first time in App, will create.
    func loadV1ScoreFile() -> Bool {
        var succeeded = false
        
        guard let mkV1ScoreFileURL = getURLForV1ScoreFile() else {
            itsBad() // todo real error handling!
            return false
        }
        
        let mkV1ScoreFilePath = mkV1ScoreFileURL.path
        let fm = FileManager.default

//
//        guard let mkDataDirUrl = getMKDataDir() else { return succeeded }
//
//        let fm = FileManager.default
//        let mkScoreFileURL = mkDataDirUrl.appendingPathComponent(MKUserDataFileName)
//        let mkScoreFilePath = mkScoreFileURL.path
//        if !fm.fileExists(atPath: mkScoreFilePath) {
//            // first time in App. Try to create the Score file.
//            if !createScoreFile(mkScoreFileUrl: mkScoreFileURL) { return succeeded }
//        }
//
        if fm.fileExists(atPath: mkV1ScoreFilePath) {
            tempV1UserScore = nil
            let jsonDecoder = JSONDecoder()
            let retreivedData = try? Data(contentsOf:mkV1ScoreFileURL)
            //if let jsonString = String(data:retreivedData!, encoding: .utf8) {
                //               print("\nLoaded file:\n")
                //               print(jsonString)
                //              print("\n")
            //}
            tempV1UserScore = try? jsonDecoder.decode(studentScore.self, from: retreivedData!)
            if tempV1UserScore != nil {
                print("Created tempV1UserScore from V1 disk file data")
                succeeded = true
            } else {
                itsBad()
                print("Error - Unable to create tempV1UserScore from V1 disk file data")
            }
        }
        
        return succeeded
    }
    
    
    /*  Original  (sort of)
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
    
    
    func getScoreFilenameForInstr(instr: Int) -> String {
        let subname = getScoreFileSubNameForInstr(instr: instr)
        let retStr = MKUserDataFileName + subname
        return retStr
    }
    
    func vers1ScoreFileExists() -> Bool {
        guard let mkScoreFileURL = getURLForV1ScoreFile() else {
            itsBad() // todo real error handling!
            return false
        }
        
        let mkScoreFilePath = mkScoreFileURL.path
        let fm = FileManager.default
        if fm.fileExists(atPath: mkScoreFilePath) {
            return true
        } else {
            return false
        }
    }
    
    func vers2ScoreFileExistsForInst(instr: Int) -> Bool {
        guard let mkScoreFileURL = getURLForV2ScoreFile(instr: instr) else {
            itsBad() // todo real error handling!
            return false
        }
        
        let mkScoreFilePath = mkScoreFileURL.path
        let fm = FileManager.default
        if fm.fileExists(atPath: mkScoreFilePath) {
            return true
        } else {
            return false
        }
    }
    
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
            if kPrintJsonBeforeWritingToDisk //,
                //let jsonString = String(data:jsonData!, encoding: .utf8)
            {
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
    
    /////////////////////////////////////////////////////////////
    // MARK: - -- Support methods for file opening and saving

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

    ///////////////////////////////////////////////////////////////////////
    // MARK: - -- Methods for creating initial data structs and file

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
            //if let jsonString = String(data:jsonData!, encoding: .utf8) {
                //                print("\nJSON when creating initial Student Score file:\n")
                //                print(jsonString)
                //                print("\n")
            //}
        }
        if fm.fileExists(atPath: mkScoreFilePath) {
            succeeded = true
        }
        
        return succeeded
    }


    /* original version
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
    */
    

    ////////////////////////////////////////////////////////////////////////
    // If first time in App, this method is called to create the
    // initial in-memory StudentScoreData
    func createStudentScoreDataFromJSON(forV2File: Bool = true) -> Bool {
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
            return false
        }
        
        guard let numLevels = instrumentJson?["levels"].count else {
            print("Could not get num Levels from TrumpetLessons.JSON data")
            itsBad()
            return false
        }
        
        guard let jsonLevels = instrumentJson?["levels"] else {
            print("Could not get num Levels from TrumpetLessons.JSON")
            itsBad()
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
        guard currUserScore != nil else {
            print("Could not create new studentScoreV2")
            itsBad()
            return false
        }

//        if !forV2File {
//            print("Succesfully created partial empty StudentScore data in memory from JSON")
//            return true
//        }
        
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
                    
                    var skipThisOne = false
                    if !currInstrumentIsBrass() { // then have to check for slurs
                        let exerType = getExerciseType( exerCode: oneExerStr )
                        if exerType == .lipSlurExer { // Lips slurs only valid for brass
                            skipThisOne = true
                        }
                        if getCurrentStudentInstrument() == kInst_Mallet &&
                           (exerType == .longtoneExer || exerType == .longtoneRecordExer) {
                            skipThisOne = true // per Shawn's request
                        }
                    }
                    
                    if !skipThisOne {
                        let oneExerScore = exerciseScore(exerciseID: oneExerStr, index: exerIdx)
                        currUserScore?.levels[lvlIdx].days[dayIdx].exercises.append(oneExerScore)
                    }
                }
            }
        }
        
        print("Succesfully created empty StudentScore data in memory from JSON")
        return true
    }
    
    /////////////////////////////////////////////////////////////
    // MARK: - -- JSON version in the TrumpetLessons.json file
    
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
    
    /////////////////////////////////////////////////////////////
    // MARK: - -- Current saved data JSON version methods

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
    
    /////////////////////////////////////////////////////////////
    // MARK: - -- Available space, Score File size, etc.
    
    func getAvailableDiscSpace() {
        
        //let ds = DiskStatus()
        let totalDiskSpace = DiskStatus.totalDiskSpace
        let freeDiskSpace = DiskStatus.freeDiskSpace
        let usedDiskSpace = DiskStatus.usedDiskSpace
        
        let totalDiskSpaceInt = DiskStatus.totalDiskSpaceInBytes
        let freeDiskSpaceInt = DiskStatus.freeDiskSpaceInBytes
        let usedDiskSpaceInt = DiskStatus.usedDiskSpaceInBytes
        
        if alwaysFalseToSuppressWarn() {
            print("\(totalDiskSpace), \(freeDiskSpace), \(usedDiskSpace)")
            print("\(totalDiskSpaceInt), \(freeDiskSpaceInt), \(usedDiskSpaceInt)")
        }
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

// methods that deal with converting V1 file to V2 file
extension ScoreMgr {
    
    
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
