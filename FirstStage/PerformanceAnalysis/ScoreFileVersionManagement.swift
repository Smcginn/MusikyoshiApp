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


/*     NOTE:     on 7/18/2020

To move from V3 Score files to V4, I reorganized and re-wrote
a lot of the code in here.
 
Now that I'm done I *should* go through and delete all the older, un-called code.
 
However, it's working, and I'm really relutant to make any changes before
checking it in as we are behind schedule as it is. So I'm checking it in as-is,
with all the unused code left in place.

So, unlikely as this probably is, I should come back at some point to do this.

Note: A V1 file probably won't upgrade to a V4 file. Could come back and address
      this or move on. Maybe 1 V1 user? This is trumpet only.

*/

import UIKit
import Foundation
import SwiftyJSON

////////////////////////////////////////////////////////////////////
 // For saving in-memory Score data to file on disk
 //   which file format?
let kSaveScoreFileAsV1File   = 1
let kSaveScoreFileAsV2File   = 2
let kSaveScoreFileAsV3File   = 3
let kSaveScoreFileAsV4File   = 4
let kSaveScoreFileAsMostRecentVersion  = kSaveScoreFileAsV4File


// SCOREFILEV3_V4 - TEMP!
// SCOREFILEV3_V4 - was:   let MKDataDirName       = "MKData"
let MKDataDirName        = "MKData"
let MKUserDataFileName   = "UserScore" // pre-V4
let MKUserDataV4FileName = "UserScoreV4"

// When converting a V1 file to a V2 file, this is the highest level in the V1
// file we want to keep the records for.
let kV1HighestSaveLevel = 10

extension ScoreMgr {
    
    //=======================================================================
    // Find Score file on disk, and and open it.
    //   If first time in App, will create.
    func loadScoreFile() -> Bool {
            
        sleep(2)
        printAllFilesInMKDir()
        
//        clearAllFilesFromMKDirectory()
//        clearAllV4FilesFromMKDirectory()
        
        // Temp for testing
        
        
        
        // See if a Version 4 file exists, and load it.
        if loadV4ScoreFile() { // Will create one if first time in app
            return true  // Success! No need to bother with the older code below.
        }
        
        // No V4 file. See if a V3 file exists. If so, load and convert to V4 file.
        if convert_V3orV2_ToV4ScoreFileAndLoad() {
            return true  // Success! No need to bother with the older code below.
        }
        
        // Temp for testing - end of commented out code
    
        
        
        // If still here, then dealing with an older V1 or V2 score file.
        
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
// comment this clause out? Seems to create V2 file.
            else {
                let currInstr = getCurrentStudentInstrument()
                guard let mkScoreFileURL = getURLForV2ScoreFile(instr: currInstr) else {
                    itsBad() // todo real error handling!
                    return false
                }
                let mkScoreFilePath = mkScoreFileURL.path
                if !fm.fileExists(atPath: mkScoreFilePath) {
                    // first time in App. Try to create the Score file.
                    if !createV2ScoreFile(mkScoreFileUrl: mkScoreFileURL) { return succeeded }
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

                // SCOREFILEV3_V4 - TEMPTEMPTEMP   commenting out
                //   / *
                // SCOREFILEV3_V4
                //      change to studentScoreV4.self
            tempV2UserScore = try? jsonDecoder.decode(studentScoreV2.self, from: retreivedData!)
            if tempV2UserScore != nil {
                print("Created currUserScore from disk file data")
                succeeded = true
            } else {
                itsBad()
                print("Error - Unable to create currUserScore from disk file data")
            }
                //    * /
            
                // Added this to Temp V4, to get it working "as new file"
                    /*
                    //      change to studentScoreV4.self
                    currUserScore = try? jsonDecoder.decode(studentScoreV4.self, from: retreivedData!)
                    if currUserScore != nil {
                        print("Created currUserScore from disk file data")
                        succeeded = true
                    } else {
                        itsBad()
                        print("Error - Unable to create currUserScore from disk file data")
                    }
                    */
        }

            // SCOREFILEV3_V4 - TEMPTEMPTEMP   commenting out (for temp V4 working)
            //      / *

        // HERE
        // This is at least a V2 file, possible a V3.  If V2, convert to V3
        if !scoreFileIsVersion_0_3_x() { // need to upgrade
            if scoreFileCanBeUpdatedToVersion_0_3_x() {
                    // SCOREFILEV3_V4
                    //   Cannot convert value of type 'studentScoreV4' to expected argument type 'studentScoreV2'
                let success = create_ScoreV3_FromScoreV2(currScoreV2: &tempV2UserScore!)
                print("success: \(success)")
                if success {
                    _ = saveScoreFile(versionType: kSaveScoreFileAsV3File)
                }
            }
        }
            //      * /
        
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
    }                       //    loadScoreFile()
    
    
    // SCOREFILEV3_V4
    func convertV1FileToV2File(forInstrument: Int) -> Bool {
        // Step 1: get the existing disk file into memory as a V1 data struct
        if !loadV1ScoreFile()  {
            itsBad() // todo real error handling!
            return false
        }
        guard tempV1UserScore != nil else {
            itsBad(); return false }
        let numV1Levels = tempV1UserScore?.levels.count
        guard numV1Levels != nil else {
            itsBad() // todo real error handling!
            return false
        }
        // At this point, the old file has been successfully loaded into tempV1UserScore
        
        // Step 2:  Create a V2 data struct, with top-level info in current json.
/*V1->2*/ guard createV2StudentScoreDataFromJSON()  else {
            print ("\nconvertV1FileToV2File: Unable to create initial in-memory data storage from JSON\n")
            itsBad() // todo real error handling!
            return false
        }
        guard tempV2UserScore != nil else {
            itsBad(); return false }

        
                // SCOREFILEV3_V4 - TEMPTEMPTEMP   commenting out
                // / *
                // Step 3:  From the existing V1 file, take the "Keeper" levels, convert
                //          them to V2 Levels, then use them to replace the V2 Score entries
        let numLevelsToConvert = min(kV1HighestSaveLevel, numV1Levels!)
        var idx = 0
        for lev1 in tempV1UserScore!.levels {
            let lev2 = create_LevelV2_FromLevelV1(currLevelV1:lev1,
                                                  discardable: false)
                // SCOREFILEV3_V4
                //    V4 requires levelV3, not V2
            tempV2UserScore!.levels[idx] = lev2
            
            idx += 1
            if idx >= numLevelsToConvert {
                break
            }
        }
                // * /
        
 //       return true
        
        // delete old file, save new one
        
        // RESTORE      FILEFILEFILEFILE
        // deleteCurrentScoreFile()  // this call deletes the older V1 file
        _ = saveScoreFile(versionType: kSaveScoreFileAsV2File)
        return true
    }
    
    // see if a Version 4 file exists, and if so, load it
    func loadV4ScoreFile() -> Bool {
        let currInstr = getCurrentStudentInstrument()
        if vers4ScoreFileExistsForInst(instr: currInstr) {
            print("Found existing V4 Score file.")
            
            guard let mkV4ScoreFileURL = getURLForV4ScoreFile(instr: currInstr) else {
                itsBad() // todo real error handling!
                return false
            }

            let retreivedData = try? Data(contentsOf:mkV4ScoreFileURL)
            // Uncomment to print out contents of score file as JSON data
            if let jsonString = String(data:retreivedData!, encoding: .utf8) {
                               print("\n\n\nLoaded file:\n\n")
                               print(jsonString)
                              print("\n\n\n")
            }

                // SCOREFILEV3_V4 - TEMPTEMPTEMP   commenting out
                //   / *
                // SCOREFILEV3_V4
                //      change to studentScoreV4.self
            let jsonDecoder = JSONDecoder()
            currUserScore = try? jsonDecoder.decode(studentScoreV4.self, from: retreivedData!)
            if currUserScore != nil {
                print("Created currUserScore (V4) from disk file data")
                return true
            } else {
                itsBad()
                print("Error - Unable to create currUserScore (V4) from disk file data")
                return false
            }
            
        } else { // look for previous versions to upgrade
            print("Did not find existing V4 Score file. ")
            // (V2 and V3 look identical; must open them to scan for differences.
            // This is enough to determine if an xisting V1, V2, or V3 file
            // exists and needs to be upgraded.
            if vers2ScoreFileExistsForInst(instr: currInstr) ||
               vers1ScoreFileExists() {
                return false
            }
        }
            
        // If still here, then first time running app for any version.
        // Just create new V4 score file.
        
        guard let mkV4ScoreFileURL = getURLForV4ScoreFile(instr: currInstr) else {
            itsBad();     return false
        }
        
        if createV4ScoreFile(mkScoreFileUrl:  mkV4ScoreFileURL) {
            return true
        } else {
            return false
        }
    } // loadV4ScoreFile()
        
//
//        let strVal = String(describing: mkDataDirUrl )
//        if alwaysFalseToSuppressWarn() {
//            print("\(strVal)" )
//            let fm = FileManager.default
//            let currInstr = getCurrentStudentInstrument()
//            if !vers2ScoreFileExistsForInst(instr: currInstr) {
//                return false
//            }
//        }
//    }
    
    // See if a Version 2 or 3 file exists. If so, load it, and convert to V4 file.
    func convert_V3orV2_ToV4ScoreFileAndLoad() -> Bool {
        let currInstr = getCurrentStudentInstrument()
        if vers2ScoreFileExistsForInst(instr: currInstr) {
            // (V2 and V3 look identical name-wise; must open them to see version.)

            currUserScore = nil
            tempV1UserScore = nil
            guard let mkV2ScoreFileURL = getURLForV2ScoreFile(instr: currInstr) else {
                itsBad();  return false }
            
            let jsonDecoder = JSONDecoder()
            let retreivedData = try? Data(contentsOf:mkV2ScoreFileURL)
            // Uncomment to print out contents of score file as JSON data
//            if let jsonString = String(data:retreivedData!, encoding: .utf8) {
//                               print("\nLoaded file:\n")
//                               print(jsonString)
//                              print("\n")
//            }
            tempV2UserScore = try? jsonDecoder.decode(studentScoreV2.self, from: retreivedData!)
            _ = ASSUME(tempV2UserScore != nil)
            if tempV2UserScore != nil {
                print("Created tempV2UserScore from V2/3 disk file data")
            } else {
                print("Error - Unable to create tempV2UserScore from V2/3 disk file data")
                itsBad()
                return false
            }
            
            // V3 was an upgrade that included woodwinds. V2 and V3 are struturally
            // identical. The only diff is the Slur exers and Level is removed for
            // woodwinds, and there is a Breaks level for clarinets.
            let isV2 = tempV2UserScore?.jsonVersionMid == 2
            let isV3 = tempV2UserScore?.jsonVersionMid == 3
            _ = ASSUME(isV2 || isV3)
            if isV2 {   // upgrade to V3
                if create_ScoreV3_FromScoreV2(currScoreV2:  &tempV2UserScore!) {
                    print("Converted in-mem V2 scorefile data to V3")
                } else {
                    print("Error - Unable to convert in-mem V2 scorefile data to V3")
                    itsBad()
                    return false
                }
            }
            
            // If still here, then in-mem tempV2UserScore was or is now a V3.
            
            // created empty V4 score data
            currUserScore =
                studentScoreV4(name: tempV2UserScore!.name,
                               title: tempV2UserScore!.title,
                               jsonVersionMajor:  tempV2UserScore!.jsonVersionMajor,
                               jsonVersionMid:    4,
                               jsonVersionMinor:  tempV2UserScore!.jsonVersionMinor,
                               levels: [] )
            guard currUserScore != nil else {
                print("Unable to create empty V4 score file data")
                itsBad()
                return false
            }
            
            // move the data from the V3 format into the v4 struct
            if create_ScoreV4_FromScoreV3(currScoreV3: tempV2UserScore!,
                                          newScoreV4: &currUserScore!) {
                // save the fucker
                let currInstr = getCurrentStudentInstrument()
                guard let mkV4ScoreFileURL = getURLForV4ScoreFile(instr: currInstr) else {
                        print("Unable to get URL for V4 score file")
                        itsBad()
                        return false
                }
                let mkScoreFilePath = mkV4ScoreFileURL.path
                let fm = FileManager.default
                
                // Sucessfully created in-memory data struct. Save to disk
                let jsonEncoder = JSONEncoder()
                jsonEncoder.outputFormatting = .prettyPrinted
                let jsonData: Data? = try? jsonEncoder.encode(currUserScore)
                if jsonData != nil  {
                    try? jsonData!.write(to: mkV4ScoreFileURL, options: .atomic)
                }
                if !fm.fileExists(atPath: mkScoreFilePath) {
                    print("Unable to save converted V4 score file data")
                    itsBad()
                    return false
                }
            }
        }
        
        // Success! No need to bother with the older code below.
        print("Converted V2-or-V3 -> V4 score file saved successfully")
        return true
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
        // return false /////   temp
        
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
    
    func vers4ScoreFileExistsForInst(instr: Int) -> Bool {
        guard let mkV4ScoreFileURL = getURLForV4ScoreFile(instr: instr) else {
            itsBad() // todo real error handling!
            return false
        }
        
        let mkV4ScoreFilePath = mkV4ScoreFileURL.path
        let fm = FileManager.default
        if fm.fileExists(atPath: mkV4ScoreFilePath) {
            return true
        } else {
            return false
        }
    }
    
    ////////////////////////////////////////////////////////////////////
    // Save in-memory Score data to file on disk
    func saveScoreFile(versionType: Int) -> Bool {
        var succeeded = false
        
        var mkScoreFileURL: URL? = nil
        
        let currInstr = getCurrentStudentInstrument()
        if versionType == kSaveScoreFileAsV2File ||
           versionType == kSaveScoreFileAsV3File    {
            mkScoreFileURL = getURLForV2ScoreFile(instr: currInstr)
        } else if versionType == kSaveScoreFileAsV4File {
            mkScoreFileURL = getURLForV4ScoreFile(instr: currInstr)
        }
        
        guard mkScoreFileURL != nil  else {
            return false }

        //        guard let mkDataDirUrl = getMKDataDir() else { return succeeded }
        //
        //        let fm = FileManager.default
        //        let mkScoreFileURL = mkDataDirUrl.appendingPathComponent(MKUserDataFileName)
        
        let mkScoreFilePath = mkScoreFileURL?.path
        
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
            try? jsonData!.write(to: mkScoreFileURL!, options: .atomic)
        }
        let fm = FileManager.default
        if fm.fileExists(atPath: mkScoreFilePath!) {
            succeeded = true
        }
        
        return succeeded
    }

    // MARK: - Testing
    //======================================================
    //
    //                  FOR  TESTING
    //
    //======================================================

    func createNewV2orV3File(whichVersion: Int) {
        createV2StudentScoreDataFromJSON()
        
        
        
        
    }
    
    func addTestLevelsForInstrument() -> Bool {
        guard tempV2UserScore != nil else {
            itsBad(); return false }
        
        let lev3            =  2
        let lev10           =  9
        let lev22           = 21
        let levLngTns       = 30
        let levLipOrBreaks  = 31

        var lev = lev3
        var day = 0
        
        var higherSS = false
        var numExers = tempV2UserScore!.levels[lev].days[day].exercises.count
        for idx in 0..<numExers {
            tempV2UserScore?.levels[lev].days[day].exercises[idx].state = kLDEState_Completed
            tempV2UserScore?.levels[lev].days[day].exercises[idx].starScore =
                higherSS ? 3 : 2
            higherSS = !higherSS
        }
        
        lev = lev10
        day = 1
        higherSS = false
        for idx in 0..<5{
            tempV2UserScore?.levels[lev].days[day].exercises[idx].state = kLDEState_Completed
            tempV2UserScore?.levels[lev].days[day].exercises[idx].starScore =
                higherSS ? 3 : 2
            higherSS = !higherSS
        }
        
        lev = lev22
        day = 3
        higherSS = false
        numExers = tempV2UserScore!.levels[lev].days[day].exercises.count
        for idx in 0..<numExers{
            tempV2UserScore?.levels[lev].days[day].exercises[idx].state = kLDEState_Completed
            tempV2UserScore?.levels[lev].days[day].exercises[idx].starScore =
                higherSS ? 3 : 2
            higherSS = !higherSS
        }
        
        lev = levLngTns
        day = 1
        higherSS = false
        numExers = tempV2UserScore!.levels[lev].days[day].exercises.count
        for idx in 0..<numExers{
            tempV2UserScore?.levels[lev].days[day].exercises[idx].state = kLDEState_Completed
            tempV2UserScore?.levels[lev].days[day].exercises[idx].starScore =
                higherSS ? 3 : 2
            higherSS = !higherSS
        }
        
        if currInstrumentIsBrass() ||
           currInstIsAClarinet()      {
            lev = levLipOrBreaks
            day = 1
            higherSS = false
            numExers = tempV2UserScore!.levels[lev].days[day].exercises.count
            for idx in 0..<numExers{
                tempV2UserScore?.levels[lev].days[day].exercises[idx].state = kLDEState_Completed
                tempV2UserScore?.levels[lev].days[day].exercises[idx].starScore =
                    higherSS ? 3 : 2
                higherSS = !higherSS
            }
        }
        
        return true
    }
    
    /////////////////////////////////////////////////////////////
    // MARK: - -- Support methods for file opening and saving
    
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

    func getURLForV4ScoreFile(instr: Int) -> URL? {
        // example, trumpet:     <DataDirUrl>/
        
        guard let mkDataDirUrl = getMKDataDir() else { return nil }
        
        var mkDataURL: URL? = nil
        var scoreFilename = getScoreFilenameForInstr(instr: instr)
        scoreFilename += "V4"
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
                print("\n In deleteCurrentScoreFile;  V1 File does not exist\n")
                // Ok, so perhaps it's a V2 file . . .
                let currInst = getCurrentStudentInstrument()
                let retVal = deleteScoreFileForInst(instr: currInst)
                return retVal
                // return true // it's not there, so . . .
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
    
    // Needed for conversion of V1 -> V2 score file.
    func createV2ScoreFile(mkScoreFileUrl: URL?) -> Bool {
        var succeeded = false
        
        // Create the in-memory ScoreData, in the form to be saved to disk
/*Main*/    guard createV2StudentScoreDataFromJSON() else {
            print ("Unable to create initial in-memory data storage from JSON")
            return false
        }
        //=========================================================================
        // Testing Insert:
            
        let didSucceed = addTestLevelsForInstrument()
        
        if !didSucceed {
            itsBad()
        }
        
        //========================================================================
        guard mkScoreFileUrl != nil else { return succeeded }
        
        let mkScoreFilePath = mkScoreFileUrl!.path
        let fm = FileManager.default
        
        // Sucessfully created in-memory data struct. Save to disk
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let jsonData: Data? = try? jsonEncoder.encode(tempV2UserScore)
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

    
    func createV4ScoreFile(mkScoreFileUrl: URL?) -> Bool {
        var succeeded = false
        
        // Create the in-memory ScoreData, in the form to be saved to disk
/*Main*/    guard createV4StudentScoreDataFromJSON() else {
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
//            if let jsonString = String(data:jsonData!, encoding: .utf8) {
//                                print("\nJSON when creating initial Student Score file:\n")
//                                print(jsonString)
//                                print("\n")
//            }
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
//CMTOUT        guard createStudentScoreDataFromJSON() else {
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
    //         SCOREFILEHERE - search tag
    func createV4StudentScoreDataFromJSON(forV2File: Bool = true) -> Bool {
        
        
        // NEEDS DIFF SCORE FILE
        
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
            // SCOREFILEV3_V4
            //     Cannot assign value of type 'studentScoreV2' to type 'studentScoreV4'
        
            //     / * was SCOREFILEV3_V4
        
        // DIFFSCOREFILE
        // tempV2UserScore
        currUserScore = studentScoreV4( name:  (instrumentJson?["name"].string)!,
                                         title: (instrumentJson?["title"].string)!,
                                        jsonVersionMajor: jsonverMajInt,
                                        jsonVersionMid:   jsonverMidInt,
                                        jsonVersionMinor: jsonverMinInt,
                                        levels: [] )
            //      * /
        
                // SCOREFILEV3_V4 - switched to this for V4
                /*
                    currUserScore = studentScoreV4( name:  (instrumentJson?["name"].string)!,
                                                    title: (instrumentJson?["title"].string)!,
                                                    jsonVersionMajor: jsonverMajInt,
                                                    jsonVersionMid:   jsonverMidInt,
                                                    jsonVersionMinor: jsonverMinInt,
                                                    levels: [] )
                */
        
        guard currUserScore != nil else {
            print("Could not create new studentScoreV2")
            itsBad()
            return false
        }

        let currInst = getCurrentStudentInstrument()
        
        // Populate the empty top level score struct with entries, using Levels
        // and Exercise entries in TrumpetLessons.JSON data
        var arrayLvl = 0
        for lvlIdx in 0...numLevels-1 {
            let oneJsonLevel = jsonLevels[lvlIdx]
            var levelTag:   String = oneJsonLevel["title"].string!
            let levelIdx:   String = oneJsonLevel["levelIdx"].string!
            
            let currInst = getCurrentStudentInstrument()
            
            let isSlurLevel = levelIdx == kIdxForLipSlurs ? true : false
            if isSlurLevel && currInstIsAClarinet() {
                levelTag = "Clarinet"
            }
            
            var canDiscard: Int = 1
            if let canDiscardStr = oneJsonLevel["canDiscardForMerge"].string {
                if canDiscardStr == "Y" {
                    canDiscard = 1
                } else {
                    canDiscard = 0
                }
            }
            
                    // SCOREFILEV3_V4 changed to:  let oneLevel = levelV3(title: levelTag,
            let oneLevel = levelV4(title: levelTag,
                                   canDiscard: canDiscard,
                                   state: kLDEState_NotStarted,
                                   levelID: levelIdx,
                                   days: [])

                    // SCOREFILEV3_V4
                    //   Cannot convert value of type 'levelV2' to expected argument type 'levelV3'
            //tempV2UserScore
            currUserScore?.levels.append(oneLevel)
            
            // Days . . . populate this one level with the days in the level
            let jsonDays = oneJsonLevel["days"]
            let numDays  = jsonDays.count // jsonLevels[lvlIdx]["days"].count
            for dayIdx in 0...numDays-1 {
                var dayTitle: String = jsonDays[dayIdx]["title"].string!
                if isSlurLevel &&
                    (currInst == kInst_Clarinet || currInst == kInst_BassClarinet) {
                    dayTitle = "Cross Breaks \(dayIdx+1)"
                }
                        // SCOREFILEV3_V4 was:        let oneDayScore = dayScore(dayTitle: dayTitle, index: dayIdx)
                        // SCOREFILEV3_V4 changed to: let oneDayScore = dayScoreV2(dayTitle: dayTitle, index: dayIdx)
                let oneDayScore = dayScoreV4(dayTitle: dayTitle, index: dayIdx)
                        // SCOREFILEV3_V4
                        //     Cannot convert value of type 'dayScore' to expected argument type 'dayScoreV2'
                //tempV2UserScore
                currUserScore?.levels[arrayLvl].days.append(oneDayScore)
                
                // now, get the exercises and add them
                let exercisesStr = jsonDays[dayIdx]["exercises"].string!
                let exerStrings = parseExercises(exercisesList: exercisesStr)
                let numExers  = exerStrings.count
                for exerIdx in 0...numExers-1 {
                    var oneExerStr = exerStrings[exerIdx]
                    
                    var skipThisOne = false
                    if !currInstrumentIsBrass() { // then have to check for slurs
                        let exerType = getExerciseType( exerCode: oneExerStr )
                        if exerType == .lipSlurExer {
                            // Lips slurs only valid for brass, UNLESS the curr inst
                            // is clarinet or bass clarinet.  In that case, substitute
                            // cross bresk exer below
                            if isSlurLevel && currInstIsAClarinet() {
//
//                                currInst == kInst_BassClarinet ||
//                               currInst == kInst_Clarinet {
                                // change to equivelant Cross Break exer string
                                changeSlurExerStrToCBExerStr(slrStr: &oneExerStr)
                            } else {
                                skipThisOne = true
                            }
//                            skipThisOne = true
                        }
                        if getCurrentStudentInstrument() == kInst_Mallet &&
                           (exerType == .longtoneExer || exerType == .longtoneRecordExer) {
                            skipThisOne = true // per Shawn's request
                        }
                    }
                    
                    if !skipThisOne {
                            // SCOREFILEV3_V4 changed to: let oneExerScore = exerciseScoreV2(exerciseID: oneExerStr, index: exerIdx)
                        let oneExerScore = exerciseScoreV4(exerciseID: oneExerStr, index: exerIdx)
                            // SCOREFILEV3_V4
                            //     Cannot convert value of type 'dayScore' to expected argument type 'dayScoreV2'
                        // tempV2UserScore
                        currUserScore?.levels[arrayLvl].days[dayIdx].exercises.append(oneExerScore)
                    }
                }
            }
            arrayLvl += 1
        }
        
        print("Succesfully created empty StudentScore data in memory from JSON")
        return true
    }
    
    
    
    
    
    // original
    func createV2StudentScoreDataFromJSON() -> Bool {
        
        
        // NEEDS DIFF SCORE FILE
        
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
            // SCOREFILEV3_V4
            //     Cannot assign value of type 'studentScoreV2' to type 'studentScoreV4'
        
            //     / * was SCOREFILEV3_V4
        
        // DIFFSCOREFILE
        // tempV2UserScore
        tempV2UserScore = studentScoreV2( name:  (instrumentJson?["name"].string)!,
                                         title: (instrumentJson?["title"].string)!,
                                        jsonVersionMajor: jsonverMajInt,
                                        jsonVersionMid:   3,
                                        jsonVersionMinor: jsonverMinInt,
                                        levels: [] )
            //      * /
        
                // SCOREFILEV3_V4 - switched to this for V4
                /*
                    currUserScore = studentScoreV4( name:  (instrumentJson?["name"].string)!,
                                                    title: (instrumentJson?["title"].string)!,
                                                    jsonVersionMajor: jsonverMajInt,
                                                    jsonVersionMid:   jsonverMidInt,
                                                    jsonVersionMinor: jsonverMinInt,
                                                    levels: [] )
                */
        
        guard tempV2UserScore != nil else {
            print("Could not create new tempV2UserScore")
            itsBad()
            return false
        }

        let currInst = getCurrentStudentInstrument()
        
        // Populate the empty top level score struct with entries, using Levels
        // and Exercise entries in TrumpetLessons.JSON data
        var arrayLvl = 0
        for lvlIdx in 0...numLevels-1 {
            let oneJsonLevel = jsonLevels[lvlIdx]
            var levelTag:   String = oneJsonLevel["title"].string!
            let levelIdx:   String = oneJsonLevel["levelIdx"].string!
            
            let currInst = getCurrentStudentInstrument()
            
            let isSlurLevel = levelIdx == kIdxForLipSlurs ? true : false
            if isSlurLevel && currInstIsAClarinet() {
                levelTag = "Clarinet"
            }
            
            var canDiscard: Int = 1
            if let canDiscardStr = oneJsonLevel["canDiscardForMerge"].string {
                if canDiscardStr == "Y" {
                    canDiscard = 1
                } else {
                    canDiscard = 0
                }
            }
            
                    // SCOREFILEV3_V4 changed to:  let oneLevel = levelV3(title: levelTag,
            let oneLevel = levelV2(title: levelTag,
                                   canDiscard: canDiscard,
                                   state: kLDEState_NotStarted,
                                   levelID: levelIdx,
                                   days: [])

                    // SCOREFILEV3_V4
                    //   Cannot convert value of type 'levelV2' to expected argument type 'levelV3'
            //tempV2UserScore
            tempV2UserScore?.levels.append(oneLevel)
            
            // Days . . . populate this one level with the days in the level
            let jsonDays = oneJsonLevel["days"]
            let numDays  = jsonDays.count // jsonLevels[lvlIdx]["days"].count
            for dayIdx in 0...numDays-1 {
                var dayTitle: String = jsonDays[dayIdx]["title"].string!
                if isSlurLevel &&
                    (currInst == kInst_Clarinet || currInst == kInst_BassClarinet) {
                    dayTitle = "Cross Breaks \(dayIdx+1)"
                }
                        // SCOREFILEV3_V4 was:        let oneDayScore = dayScore(dayTitle: dayTitle, index: dayIdx)
                        // SCOREFILEV3_V4 changed to: let oneDayScore = dayScoreV2(dayTitle: dayTitle, index: dayIdx)
                let oneDayScore = dayScore(dayTitle: dayTitle, index: dayIdx)
                        // SCOREFILEV3_V4
                        //     Cannot convert value of type 'dayScore' to expected argument type 'dayScoreV2'
                //tempV2UserScore
                tempV2UserScore?.levels[arrayLvl].days.append(oneDayScore)
                
                // now, get the exercises and add them
                let exercisesStr = jsonDays[dayIdx]["exercises"].string!
                let exerStrings = parseExercises(exercisesList: exercisesStr)
                let numExers  = exerStrings.count
                for exerIdx in 0...numExers-1 {
                    var oneExerStr = exerStrings[exerIdx]
                    
                    var skipThisOne = false
                    if !currInstrumentIsBrass() { // then have to check for slurs
                        let exerType = getExerciseType( exerCode: oneExerStr )
                        if exerType == .lipSlurExer {
                            // Lips slurs only valid for brass, UNLESS the curr inst
                            // is clarinet or bass clarinet.  In that case, substitute
                            // cross bresk exer below
                            if isSlurLevel && currInstIsAClarinet() {
//
//                                currInst == kInst_BassClarinet ||
//                               currInst == kInst_Clarinet {
                                // change to equivelant Cross Break exer string
                                changeSlurExerStrToCBExerStr(slrStr: &oneExerStr)
                            } else {
                                skipThisOne = true
                            }
//                            skipThisOne = true
                        }
                        if getCurrentStudentInstrument() == kInst_Mallet &&
                           (exerType == .longtoneExer || exerType == .longtoneRecordExer) {
                            skipThisOne = true // per Shawn's request
                        }
                    }
                    
                    if !skipThisOne {
                            // SCOREFILEV3_V4 changed to: let oneExerScore = exerciseScoreV2(exerciseID: oneExerStr, index: exerIdx)
                        let oneExerScore = exerciseScore(exerciseID: oneExerStr, index: exerIdx)
                            // SCOREFILEV3_V4
                            //     Cannot convert value of type 'dayScore' to expected argument type 'dayScoreV2'
                        // tempV2UserScore
                        tempV2UserScore?.levels[arrayLvl].days[dayIdx].exercises.append(oneExerScore)
                    }
                }
            }
            arrayLvl += 1
        }
        
        print("Succesfully created empty StudentScore data in memory from JSON")
        return true
        
    } // createV2StudentScoreDataFromJSON()
        
    
    
    
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
           dbMinor == versionTuple.minor
        {
            return true
        } else {
            return false
        }
    }

    func scoreFileIsVersion_0_3_x() -> Bool {
        let dbMajor = getDBMajorVersion()
        let dbMid   = getDBMidVersion()
        
        if dbMajor == 0 && dbMid == 3 {
            return true
        } else {
            return false
        }
    }
    
    func scoreFileIsVersion_0_4_x() -> Bool {
        let dbMajor = getDBMajorVersion()
        let dbMid   = getDBMidVersion()
        
        if dbMajor == 0 && dbMid == 4 {
            return true
        } else {
            return false
        }
    }
    
    func scoreFileCanBeUpdatedToVersion_0_3_x() -> Bool {
        let dbMajor = getDBMajorVersion()
        let dbMid   = getDBMidVersion()
        let dbMinor = getDBMinorVersion()

        // The version right before 0.3.0 was 0.2.3
        if dbMajor == 0 && dbMid == 2 && dbMinor == 3 {
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
    
    
    func printAllFilesInMKDir() {
//        let documentDirectoryPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//        let myFilesPath = "\(documentDirectoryPath)/myfolder"
        
        guard let mkDataDirUrl = getMKDataDir() else { return }
        let mkScoreFilePath = mkDataDirUrl.path
        
        let fm = FileManager.default
        let files = fm.enumerator(atPath: mkScoreFilePath)
        
        print("\n\n=======================================================")
        print("\nFiles in MKDirectory:\n")
        while let file = files?.nextObject() {
            print(file)
        }
        print("\n=======================================================\n")
    }
    
    func clearAllFilesFromMKDirectory()
    {
        printAllFilesInMKDir()
        
        guard let mkDataDirUrl = getMKDataDir() else { return }
        let mkScoreFilePath = mkDataDirUrl.path

        let fm = FileManager.default

        do {
            let paths = try fm.contentsOfDirectory(atPath: mkScoreFilePath)
            for path in paths
            {
                let filePath = "\(mkScoreFilePath)/\(path)"
                try fm.removeItem(atPath: filePath)
            }
        }
        catch let error as NSError
        {
            print(error.localizedDescription)
        }
        
        printAllFilesInMKDir()
    }
    
    func clearAllV4FilesFromMKDirectory()
    {
        printAllFilesInMKDir()
        
        guard let mkDataDirUrl = getMKDataDir() else { return }
        let mkScoreFilePath = mkDataDirUrl.path

        let fm = FileManager.default
        do {
            let paths = try fm.contentsOfDirectory(atPath: mkScoreFilePath)
            for path in paths
            {
                if path.contains("V4") {
                    let filePath = "\(mkScoreFilePath)/\(path)"
                    try fm.removeItem(atPath: filePath)
                }
            }
        }
        catch let error as NSError
        {
            print(error.localizedDescription)
        }
        
        printAllFilesInMKDir()
    }
    
}

func changeSlurExerStrToCBExerStr(slrStr: inout String) {
    
    var tempStr = "CBR"
    
    // Get range of all characters past the first 6.
    let range = slrStr.index(slrStr.startIndex, offsetBy: 3)..<slrStr.endIndex
    let tempStr2 = slrStr[range]
    tempStr += tempStr2
    slrStr = tempStr
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
