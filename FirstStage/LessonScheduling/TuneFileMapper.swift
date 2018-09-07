//
//  TuneFileMapper.swift
//  FirstStage
//
//  Created by Scott Freshour on 8/14/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

let kFieldDataNotDefined = "NOTDEFINED"
let kTryForLongtonePersonalRecord = -1

struct tuneFileInfo: Codable {
    var fileCode:       String
    var xmlFile:        String
    var title:          String
    var commentStr1:    String
    var commentStr2:    String
    var helpCode1:      String // for now.  Prob an enum
    var helpCode2:      String // for now.  Prob an enum
    
    init()
    {
        self.fileCode        = kFieldDataNotDefined
        self.xmlFile         = kFieldDataNotDefined
        self.title           = kFieldDataNotDefined
        self.commentStr1     = kFieldDataNotDefined
        self.commentStr2     = kFieldDataNotDefined
        self.helpCode1       = kFieldDataNotDefined
        self.helpCode2       = kFieldDataNotDefined 
    }
    
    init( fileCode:      String,
          xmlFile:       String,
          title:         String,
          commentStr1:   String,
          commentStr2:   String,
          helpCode1:     String,
          helpCode2:     String  )
    {
        self.fileCode        = fileCode
        self.xmlFile         = xmlFile
        self.title           = title
        self.commentStr1     = commentStr1
        self.commentStr2     = commentStr2
        self.helpCode1       = helpCode1
        self.helpCode2       = helpCode1
    }
    
    init( fileCode:      String,
          xmlFile:       String,
          title:         String,
          commentStr1:   String )
    {
        self.fileCode        = fileCode
        self.xmlFile         = xmlFile
        self.title           = title
        self.commentStr1     = commentStr1
        self.commentStr2     = ""
        self.helpCode1       = ""
        self.helpCode2       = ""
    }
}
extension tuneFileInfo: Equatable {
    static func == (lhs: tuneFileInfo, rhs: tuneFileInfo) -> Bool {
        return
            lhs.fileCode == rhs.fileCode &&
            lhs.xmlFile == rhs.xmlFile &&
            lhs.title == rhs.title &&
            lhs.commentStr1 == rhs.commentStr1 &&
            lhs.commentStr1 == rhs.commentStr2 &&
            lhs.helpCode1 == rhs.helpCode1 &&
            lhs.helpCode2 == rhs.helpCode2
    }
}

struct helpCodeInfo: Codable {
    var helpCode:       String
    var helpText:        String
    
    init()
    {
        self.helpCode = "NOTDEFINED"
        self.helpText = "NOTDEFINED"
    }
    
    init( helpCode: String,
          helpText: String )
    {
        self.helpCode = helpCode
        self.helpText = helpText
    }
}

struct fileMappingInfo: Codable {
    var helpCodeEntries: [helpCodeInfo] // [String: helpCodeInfo] = [:]
    var tuneFileEntries: [tuneFileInfo] // [String: tuneFileInfo] = [:]
}

let kNoTuneFileEntry = tuneFileInfo( fileCode:    "NOTDEFINED",
                                     xmlFile:     "NOTDEFINED",
                                     title:       "NOTDEFINED",
                                     commentStr1: "NOTDEFINED",
                                     commentStr2: "NOTDEFINED",
                                     helpCode1:   "NOTDEFINED",
                                     helpCode2:   "NOTDEFINED"
                                   )

enum ExerciseType {
    case unknownExer
    case longtoneExer
    case longtoneRecordExer
    case rhythmPartyExer
    case rhythmPrepExer
    case lipSlurExer
    case scalePowerExer
    case intervalExer
    case tuneExer
}

class TuneFileMapper {
    
    var fileMappingData: fileMappingInfo? = nil
    var tuneFileJson: JSON? = nil
    var jsonData: Data? = nil
    
    init() {
        loadTuneFileData()
    }

    func getTuneFileInfo(forFileCode: String) -> tuneFileInfo {
        var retInfo = kNoTuneFileEntry
        
        guard fileMappingData != nil else { return retInfo }
        
        for oneEntry in fileMappingData!.tuneFileEntries {
            if oneEntry.fileCode == forFileCode {
                retInfo = oneEntry
                break
            }
        }
        
        if retInfo == kNoTuneFileEntry {
            print("Error.  In getTuneFileInfo, unable to locate entry for \(forFileCode)")
        }
        
        return retInfo
    }

    //XMLFileMapping
    func loadTuneFileData() {
        // Hey:  clear jsonData before trying?
        
        if let file = Bundle.main.path(forResource: "XMLFileMapping", ofType: "json"){
            jsonData = try? Data(contentsOf: URL(fileURLWithPath: file))
//            if let jsonString = String(data:jsonData!, encoding: .utf8) {
//                print("\nLoaded XMLFileMapping file:\n")
//                print(jsonString)
//                print("\n")
//            }
        }
        
        guard jsonData != nil else {
            print ("Could not load XMLFileMapping.json as jsonData")
            return
        }
        
        let jsonDecoder = JSONDecoder()
        fileMappingData = try? jsonDecoder.decode(fileMappingInfo.self, from: jsonData!)
        if fileMappingData != nil {
            print("Created fileMappingData from json file data")
        } else {
            print("Error - Unable to create fileMappingData from json file data")
        }
    }
}

// Misc general funcs


// Parse LT_C4_10, LT_C#4_10, etc.
func getLongtoneInfo(forLTCode: String) -> longtoneExerciseInfo {
    var retVal = kBadLTExerInfo
    
    let chunks = forLTCode.components(separatedBy: "_")
    guard chunks.count == 3 else {
        print ("Error in getLongtoneInfo, chunks != 3 for \(forLTCode)")
        return retVal
    }
    guard chunks[0] == "LT" else {
        print ("Error in getLongtoneInfo, chunks[0] != LT for \(forLTCode)")
        return retVal
    }
    
    retVal.note = chunks[1]
    retVal.durationSecs = Int(chunks[2])!
    
    return retVal
}

// Parse LTR_C4, LTR_C#4, etc.
func getLongtoneRecordInfo(forLTCode: String) -> longtoneExerciseInfo {
    var retVal = kBadLTExerInfo
    
    let chunks = forLTCode.components(separatedBy: "_")
    guard chunks.count == 2 else {
        print ("Error in getLongtoneRecordInfo, chunks != 2 for \(forLTCode)")
        return retVal
    }
    guard chunks[0] == "LTR" else {
        print ("Error in getLongtoneRecordInfo, chunks[0] != LTR for \(forLTCode)")
        return retVal
    }
    
    retVal.note = chunks[1]
    retVal.durationSecs = kTryForLongtonePersonalRecord
    
    return retVal
}



func getExerciseType( exerCode: String ) -> ExerciseType {
    if exerCode.isEmpty {
        return .unknownExer
    }
    
    var index = exerCode.index(exerCode.startIndex, offsetBy: 2)
    var subStr = exerCode.prefix(upTo: index)
    if subStr == "LT" {
        // Is it LT_ or LTR?
        index = exerCode.index(exerCode.startIndex, offsetBy: 3)
        subStr = exerCode.prefix(upTo: index)
        if subStr == "LTR" {
            return .longtoneRecordExer
        } else {
            return .longtoneExer
        }
    }
    
    index = exerCode.index(exerCode.startIndex, offsetBy: 3)
    subStr = exerCode.prefix(upTo: index)
    switch subStr {
    case "PTY":     return .rhythmPartyExer
    case "PRP":     return .rhythmPrepExer
    case "SLR":     return .lipSlurExer
    case "SCP":     return .scalePowerExer
    case "INT":     return .intervalExer
    case "TUN":     return .tuneExer
    default:
        return .unknownExer
    }
}

func getTextForExerciseType( exerType: ExerciseType ) -> String {
    switch exerType {
    case .longtoneExer:         return  "LongTone"
    case .longtoneRecordExer:   return  "LongTone Personal Record"
        
    case .rhythmPartyExer:      return  "Rhythm Party"
    case .rhythmPrepExer:       return  "Rhythm Prep"
    case .lipSlurExer:          return  "LipSlur"
    case .scalePowerExer:       return  "Scale Power"
    case .intervalExer:         return  "Interval"
    case .tuneExer:             return  "Tune"

    case  .unknownExer:     fallthrough
    default:
        return "Unknown"
    }
}

func parseExercises(exercisesList: String) -> [String] {
    let strNoBlanks = exercisesList.removingWhitespaces()
    let strNoBlanksUp = strNoBlanks.uppercased()
    let strArray = strNoBlanksUp.components(separatedBy: ",")
    return strArray
}

extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
