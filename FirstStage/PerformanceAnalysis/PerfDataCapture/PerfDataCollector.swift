//
//  PerfDataCollector.swift
//  FirstStage
//
//  Created by Scott Freshour on 1/16/20.
//  Copyright © 2020 Musikyoshi. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

// THIS SHOULD NEVER BE TRUE FOR RELEASE
//
// If this is set to true, then the entire app will ignore the amplitude and freq
// data from the Microphone and instead use values from the MKPerfData file (which
// is from an actual performance supplied by a user.
let kWorkingFromPerfDataFile = false

let perfDataVersMaj = 1
let perfDataVersMin = 0

let MKPerfDataDirName   = "MKPerfData"
let kSongStart          = -1000.0

typealias perfDataAndUrl = (inMemPerfData: Data?, url: URL?)

struct noteScore: Codable {
    var noteNum:        Int
    var soundNum:       Int32
    var pitch:          Double
    var startAdj:       Double
    var duration:       Double
    var durationScore:  Int
    var durationRating: String
    var attackScore:    Int
    var attackRating:   String
    var pitchScore:     Int
    var pitchRating:    String
    var weightedScore:  Int
    
    init() {
        self.noteNum        = 0
        self.soundNum       = 0
        self.pitch          = 0.0
        self.startAdj       = 0.0
        self.duration       = 0.0
        self.durationScore  = 0
        self.durationRating = ""
        self.attackScore    = 0
        self.attackRating   = ""
        self.pitchScore     = 0
        self.pitchRating    = ""
        self.weightedScore  = 0
    }
}

struct perfData: Codable {
    var level:             Int
    var day:               Int
    var exerID:            String
    var bpm:               Int
    var instrument:        Int
    var perfDataVerMaj:    Int
    var perfDataVerMin:    Int
    var appVer:            String
    var appBuildVer:       String
    var starScore:         Int
    var perfId:            String   // UUID
    var worstIssueNoteID:  Int32
    var worstIssueCode:    Int
    var worstIssueType:    Int
    var worstIssueScore:   Int
    var data:              [String]
    var noteScores:        [noteScore]
    
    init() {
        self.level  = 0
        self.day    = 0
        self.exerID = ""
        self.bpm    = 0
        self.instrument = kInst_Trumpet
        self.perfId = UUID().uuidString
        self.perfDataVerMaj = perfDataVersMaj
        self.perfDataVerMin = perfDataVersMin
        self.appVer      = ""
        self.appBuildVer = ""
        self.starScore   = 0
        self.worstIssueNoteID  = 0
        self.worstIssueCode    = 0
        self.worstIssueType    = 0
        self.worstIssueScore   = 0

        self.data        = [String]()
        self.noteScores  = [noteScore]()
    }
    
    func printNoteScores() {
        print ("\n--------------------------\nNote Scores:\n\n")
        
        let numScores = self.noteScores.count
        for idx in 00..<numScores {
            let oneNoteScore = self.noteScores[idx]
            print ("- - - - - - - - -")
            print ("Note Num:\t \(oneNoteScore.noteNum)")
            print (" Sound Num:\t \(oneNoteScore.soundNum)")
            print (" Pitch:\t\t \(oneNoteScore.pitch)")
            print ("   Score:\t\t \(oneNoteScore.pitchScore)")
            print ("   Rating:\t\t \(oneNoteScore.pitchRating)")
            print (" Start, Adj: \(oneNoteScore.startAdj)")
            print ("   Score:\t\t \(oneNoteScore.attackScore)")
            print ("   Rating:\t\t \(oneNoteScore.attackRating)")
            print (" Duration:\t \(oneNoteScore.duration)")
            print ("   Score:\t\t \(oneNoteScore.durationScore)")
            print ("   Rating:\t\t \(oneNoteScore.durationRating)")
            print (" Weighted Score: \(oneNoteScore.weightedScore)")
        }
        
        print ("\n(End Note Scores)\n------------------------------ \n\n")
    }
}

let kBlankPerfSample     = "0.0, 0.0, 0.0"
let kSongStartPerfSample = "   -1.0, -1.0, -1.0"
let kSongEndPerfSample   = "   -100.0, -100.0, -100.0"

class PerfDataCollector {
    
    static let instance = PerfDataCollector()

    var store: [String]? = nil

    var numSamples:   Int  = 0
    var storeCapcity: Int  = 0
    var perfDataUUID = ""
    
    // Below are for working with PerfData supplied by a user
    var perfDataFromFile: perfData? = nil // = perfData()
    
    ////////////////////////////////////////////////////////////////////////////
    // - MARK:- Creating PerfData during and after a performance
    // and the file
    //          if requested
    
    func setupForRecordingPerf(size: Int) {
        numSamples = 0
        let desiredSize:Int  = size + 400 // a little buffer
        
        var storeSize = 0
        if store != nil {
            storeSize = store!.count
        }
        
        if store == nil || storeSize < desiredSize {
            store = [String](repeating: kBlankPerfSample, count: desiredSize)
        }
        
        if store != nil {
            storeCapcity = store!.count
        } else {
            storeCapcity = 0
        }
    }
    
    func addSample(time: Double, amplitude: Double, freq: Double) {
        guard store != nil,
              store!.count > numSamples+10  else {
            itsBad()
            return
        }
        
        let timeStr   = String(format: "%.4f", time)
        let ampStr    = String(format: "%.4f", amplitude)
        let freqStr   = String(format: "%.2f", freq)
        let entryStr = timeStr + ", " + ampStr + ", " + freqStr
        store![numSamples] = entryStr
        numSamples += 1
    }
    
    func markSongStart() {
        guard store != nil,
            store!.count > numSamples+10  else {
                itsBad()
                return
        }
        store![numSamples] = kSongStartPerfSample
        numSamples += 1
    }
    
    func markSongEnd() {
        guard store != nil,
            store!.count > numSamples+10  else {
                itsBad()
                return
        }
        store![numSamples] = kSongEndPerfSample
        numSamples += 1
    }
    
    func createPerfDataFileFromLastPerf(level:      Int,
                                        day:        Int,
                                        exerID:     String,
                                        bpm:        Int,
                                        instr:      Int,
                                        starScore:  Int ) -> perfDataAndUrl {
        var retDataAndURL = perfDataAndUrl(inMemPerfData: nil, url: nil)
        guard store != nil,
            numSamples < store!.count else {
                itsBad()
                return retDataAndURL
        }
        
        deletePerfDataFileIfExists()

        // create a perfData object from last performance
        var perfDataForFile = perfData()
        perfDataUUID = perfDataForFile.perfId
        perfDataForFile.level      = level
        perfDataForFile.day        = day
        perfDataForFile.exerID     = exerID
        perfDataForFile.bpm        = bpm
        perfDataForFile.starScore  = starScore
        perfDataForFile.instrument = instr
        perfDataForFile.data =  self.store!
        populateNoteScores(notesScores: &perfDataForFile.noteScores)
        perfDataForFile.printNoteScores()
        
        if let worstIssue = PerformanceIssueMgr.instance.getFirstPerfIssue() {
            perfDataForFile.worstIssueNoteID  = worstIssue.perfScoreObjectID
            perfDataForFile.worstIssueCode    = worstIssue.issueCode.rawValue
            perfDataForFile.worstIssueType    = worstIssue.issueType.rawValue
            perfDataForFile.worstIssueScore   = worstIssue.issueScore

        }
        
        if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            perfDataForFile.appVer    = appVersion
        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            perfDataForFile.appBuildVer = build
        }
        
        // convert to json
        let perfDataURL = getMKPerfDataDir()
        guard perfDataURL != nil else { itsBad();    return retDataAndURL } //fileURL }
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let jsonData: Data? = try? jsonEncoder.encode(perfDataForFile)
        if jsonData != nil  {
            try? jsonData!.write(to: perfDataURL!, options: .atomic)
        }

        let filePath = perfDataURL!.path
        let fm = FileManager.default
        if fm.fileExists(atPath: filePath) {
            retDataAndURL.url = perfDataURL
            retDataAndURL.inMemPerfData = jsonData
        }
        
        return retDataAndURL
    }
    
    func populateNoteScores(notesScores: inout [noteScore]) {
        let numNotes = PerformanceTrackingMgr.instance.numPerfNotes()
        
        for idx in 0..<numNotes {
            guard let perfNote =
                PerformanceTrackingMgr.instance.getPerfNote(withID: idx+1) else {
                itsBad(); continue
            }
            
            var attackRatDispTxt = ""
            performanceRating.displayStringForRating(perfNote.attackRating,
                                                     ratingText: &attackRatDispTxt)
            var durRatDispTxt = ""
            performanceRating.displayStringForRating(perfNote.durationRating,
                                                     ratingText: &durRatDispTxt)
            var pitchRatDispTxt = ""
            performanceRating.displayStringForRating(perfNote.pitchRating,
                                                     ratingText: &pitchRatDispTxt)

            let attackRatTxt = "\(perfNote.attackRating.rawValue)"   + "-\(attackRatDispTxt)"
            let durRatTxt    = "\(perfNote.durationRating.rawValue)" + "-\(durRatDispTxt)"
            let pitchRatTxt  = "\(perfNote.pitchRating.rawValue)"    + "-\(pitchRatDispTxt)"

            var oneNoteScore = noteScore()
            oneNoteScore.noteNum = idx+1
            oneNoteScore.soundNum       = perfNote.linkedToSoundID
            oneNoteScore.pitch          = perfNote.actualFrequency
            oneNoteScore.startAdj       = perfNote.actualStartTime_comp
            oneNoteScore.duration       = perfNote.actualDuration
            oneNoteScore.durationScore  = perfNote.durationScore
            oneNoteScore.durationRating = durRatTxt //perfNote.durationRating.rawValue
            oneNoteScore.attackScore    = perfNote.attackScore
            oneNoteScore.attackRating   = attackRatTxt //perfNote.attackRating.rawValue
            oneNoteScore.pitchScore     = perfNote.pitchScore
            oneNoteScore.pitchRating    = pitchRatTxt //perfNote.pitchRating.rawValue
            oneNoteScore.weightedScore  = perfNote.weightedScore
            notesScores.append(oneNoteScore)
        }
    }
    
    /////////////////////////////////////////////////////////////////////
    // - MARK:- Using user-supplied Perf Data File
    
    ////////////////////////////////////////////////////////////////////
    // Find Score file on disk, and and open it.
    //   If first time in App, will create.
    func loadPerfDataFile() -> Bool {
//        var succeeded = false
        guard kWorkingFromPerfDataFile,
              let perfDataPath = getUserSuppliedPerfDataPath() else {
                itsBad(); return false }
        
        //let perfDataPath = getUserSuppliedPerfDataPath()
        //let mkPerfDataFilePath = perfDataURL.path
        let fm = FileManager.default
        guard fm.fileExists(atPath: perfDataPath) else {
            itsBad(); return false }

//        guard let perfDataUrl = URL(string: perfDataPath) else {
//            itsBad(); return false }
        
        //let retreivedData = try? Data(contentsOf:perfDataUrl)
        
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: perfDataPath))

        
        // Uncomment to print out contents of score file as JSON data
        //            if let jsonString = String(data:retreivedData!, encoding: .utf8) {
        //                               print("\nLoaded file:\n")
        //                               print(jsonString)
        //                              print("\n")
        //            }
        let jsonDecoder = JSONDecoder()
        perfDataFromFile = try? jsonDecoder.decode(perfData.self, from: jsonData!)
        if perfDataFromFile != nil {
            return true
        } else {
            return false
        }
        
        
        /*
        
        
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
 */
    }
    
    func getLDFromFilePerfData() -> tLD_code {
        var retLD: tLD_code  = ( level: 0, day: 0)
        if perfDataFromFile == nil {
            itsBad(); return retLD }
        
        retLD.level = perfDataFromFile!.level
        retLD.day   = perfDataFromFile!.day
        return retLD
    }
    
    func getExerIDFromFilePerfData() -> String {
        if perfDataFromFile == nil {
            itsBad(); return "" }
        
        let exerID = perfDataFromFile!.exerID
        return exerID
    }
    
    var bpm:               Int = 60
    var instrument:        Int =  0

    func getBPMFromFilePerfData() -> Int {
        if perfDataFromFile == nil {
            itsBad(); return 0 }
        
        let bpm = perfDataFromFile!.bpm
        return bpm
    }
    
    func getInstrumentFromFilePerfData() -> Int {
        if perfDataFromFile == nil {
            itsBad(); return kInst_Trumpet }
        
        let instrument = perfDataFromFile!.instrument
        return instrument
    }
    
    var perfDatasSampIndex = 0
    func resetPerfDatasSampIndex() {
        perfDatasSampIndex = 0
    }
    
    func getNextSampleData(time:  inout Double,
                           amp:   inout Double,
                           pitch: inout Double) -> Bool {
        guard perfDataFromFile != nil else {
            itsBad(); return false }
        
        let numPDSamples = perfDataFromFile!.data.count
        guard perfDatasSampIndex + 1 < numPDSamples else {
            itsBad(); return false }
        
        let dataStr = perfDataFromFile!.data[perfDatasSampIndex]
        getSampleValuesFromTriString(dataStr,    time:  &time,
                                     amp: &amp,  pitch: &pitch)
        perfDatasSampIndex += 1

        return true
    }
    
    func getSampleValuesFromTriString(_ triString: String,
                                      time:  inout Double,
                                      amp:   inout Double,
                                      pitch: inout Double) {
        time  = 0.0
        amp   = 0.0
        pitch = 0.0
        
        let strNoBlanks = triString.removingWhitespaces()
        //let strNoBlanksUp = strNoBlanks.uppercased()
        let strArray = strNoBlanks.components(separatedBy: ",")
        guard strArray.count == 3 else {
            itsBad(); return }
        
        let timeStr = strArray[0]
        let ampStr   = strArray[1]
        let pitchStr = strArray[2]
        
        time  = Double(timeStr) ?? 0.0
        amp   = Double(ampStr) ?? 0.0
        pitch = Double(pitchStr) ?? 0.0
        
    }
    
    var songStartIndex = 0

    func findSongStartIndex() -> Bool {
        guard perfDataFromFile != nil else {
            itsBad(); return false }

        let numPDSamples = perfDataFromFile!.data.count
        for idx in 0..<numPDSamples {
            if perfDataFromFile!.data[idx] == kSongStartPerfSample {
                songStartIndex = idx
                return true
            }
        }
        
        return false
    }

    func syncToSoundStart() {
        guard perfDataFromFile != nil else {
            itsBad(); return }
        perfDatasSampIndex = songStartIndex
    }
    
    /////////////////////////////////////////////////////////////////////
    // - MARK:- Misc support funcs
    
    func printEntries() {
        guard store != nil,
            numSamples < store!.count else {
                itsBad()
                return
        }
        
        let count = store!.count
        
        print ("\n\n\n============================================\n")
        print ("       In PerfDataCollector.printEntries\n\n")
        print ("Num Entries: \(numSamples)")
        print ("Store szie:  \(count)")
        
        for idx in 0..<numSamples {
            let oneEntry = store![idx]
            print (oneEntry)
        }
    }
    
    func deletePerfDataFileIfExists() {
        let perfDataURL = getMKPerfDataDir()
        guard perfDataURL != nil else { itsBad();    return }
        
        let perfDataFilePath = perfDataURL!.path
        
        let fm = FileManager.default
        do {
            if fm.fileExists(atPath: perfDataFilePath) {
                try fm.removeItem(atPath: perfDataFilePath)
            }
        }
        catch let error as NSError {
            print("An error took place In deleteCurrentScoreFile: \(error)")
            return
        }
        
        if fm.fileExists(atPath: perfDataFilePath) {
            itsBad()
        }
    }
    
    func getMKPerfDataDir() -> URL? {
        var mkPerfDataURL: URL? = nil
        if let appSptUrl = getAppSupportDir() {
            let fm = FileManager.default
            let tempMKPerfDataURL = appSptUrl.appendingPathComponent(MKPerfDataDirName)
            let filePath = tempMKPerfDataURL.path
            if !fm.fileExists(atPath: filePath) {
                // First timerunning app.  Create the MKData dir in the sandbox dir.
                do {
                    try fm.createDirectory(at: tempMKPerfDataURL,
                                           withIntermediateDirectories: true)
                } catch {
                    // TODO deal with error
                }
            }
            if fm.fileExists(atPath: filePath) {
                mkPerfDataURL = tempMKPerfDataURL
            }
        }
        
        return mkPerfDataURL
    }
    
    func getUserSuppliedPerfDataPath() -> String? {
        let subPath = "UserSuppliedPerfData/PT_PerfData"
        let filePath = Bundle.main.path(forResource: subPath,
                                           ofType: "txt")
        if filePath != nil {
            let fm = FileManager.default
            if fm.fileExists(atPath: filePath!) {
                return filePath
            }
        }
        return ""
    }
}
