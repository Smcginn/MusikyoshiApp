//
//  PerformanceLevelSettings.swift
//  FirstStage
//
//  Created by Scott Freshour on 9/13/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//
//
// For processing and storing entries retrieved from
// the PerformanceLevelSettings.json file.

import Foundation

// E.g., InstSettingsMgr.Instance
// typealias InstSettingsMgr = InstrumentSettingsManager

/////////////////////////////////////////////////
// IsASoundThreshold

//var gAdjustedIsASoundThreshold: Double = 0.4

// gSamplesNeededToDeterminePitch
// var gDifferentPitchSampleThreshold     16


struct performanceLevelZoneSettings_RawStrings: Codable {
    var zone: String
    var isASoundThresholdLow: String
    var isASoundThresholdMid: String
    var isASoundThresholdHigh: String
    var attackTolerance: String  // new
    var numSamplesToDeterminePitch: String // legato_SkipWindow
    var numSamplesForLegatoPitchChange: String // scanForPitchLegatoChange
    var ampRise_SkipWindow: String
    var ampRise_AnalysisWindow: String
    var ampRise_RiseLowBPM: String
    var ampRise_RiseMidBPM: String
    var ampRise_RiseHighBPM: String
    var soundStartOffSet: String
    var rhythmPercent_correct: String
    var rhythmPercent_aBit: String
    var rhythmPercent_Very: String
    var pitchcCorrectPC: String
    var pitchABitToVeryPC: String
    var pitchVeryBoundaryPC: String
    
    init() {
        self.zone = ""
        self.isASoundThresholdLow = ""
        self.isASoundThresholdMid = ""
        self.isASoundThresholdHigh = ""
        self.attackTolerance = ""
        self.numSamplesToDeterminePitch = ""
        self.numSamplesForLegatoPitchChange = ""
        self.ampRise_SkipWindow = ""
        self.ampRise_AnalysisWindow = ""
        self.ampRise_RiseLowBPM = ""
        self.ampRise_RiseMidBPM = ""
        self.ampRise_RiseHighBPM = ""
        self.soundStartOffSet = ""
        self.rhythmPercent_correct = ""
        self.rhythmPercent_aBit = ""
        self.rhythmPercent_Very = ""
        self.pitchcCorrectPC = ""
        self.pitchABitToVeryPC = ""
        self.pitchVeryBoundaryPC = ""
    }
}

extension performanceLevelZoneSettings_RawStrings: Equatable {
    static func == (lhs: performanceLevelZoneSettings_RawStrings,
                    rhs: performanceLevelZoneSettings_RawStrings) -> Bool {
        return
            lhs.zone == rhs.zone &&
            lhs.attackTolerance == rhs.attackTolerance &&
            lhs.isASoundThresholdLow == rhs.isASoundThresholdLow &&
            lhs.isASoundThresholdHigh == rhs.isASoundThresholdHigh &&
            lhs.numSamplesToDeterminePitch == rhs.numSamplesToDeterminePitch &&
            lhs.numSamplesForLegatoPitchChange == rhs.numSamplesForLegatoPitchChange &&
            lhs.ampRise_SkipWindow == rhs.ampRise_SkipWindow &&
            lhs.ampRise_AnalysisWindow == rhs.ampRise_AnalysisWindow &&
            lhs.ampRise_RiseLowBPM == rhs.ampRise_RiseLowBPM &&
            lhs.ampRise_RiseMidBPM == rhs.ampRise_RiseMidBPM &&
            lhs.ampRise_RiseHighBPM == rhs.ampRise_RiseHighBPM &&
            lhs.soundStartOffSet == rhs.soundStartOffSet &&
            lhs.rhythmPercent_correct == rhs.rhythmPercent_correct &&
            lhs.rhythmPercent_aBit == rhs.rhythmPercent_aBit &&
            lhs.rhythmPercent_Very == rhs.rhythmPercent_Very &&
            lhs.pitchcCorrectPC == rhs.pitchcCorrectPC  &&
            lhs.pitchABitToVeryPC == rhs.pitchABitToVeryPC &&
            lhs.pitchVeryBoundaryPC == rhs.pitchVeryBoundaryPC
    }
}


struct performanceLevelZoneSettings {
    var zone: String
    var isASoundThresholdLow: Double
    var isASoundThresholdMid: Double
    var isASoundThresholdHigh: Double
    var attackTolerance: TimeInterval // new
    var numSamplesToDeterminePitch: Int
    var numSamplesForLegatoPitchChange: Int
    var ampRise_SkipWindow: Int
    var ampRise_AnalysisWindow: Int
    var ampRise_RiseLowBPM: Double
    var ampRise_RiseMidBPM: Double
    var ampRise_RiseHighBPM: Double
    var soundStartOffSet: Double
    var rhythmPercent_correct: Double
    var rhythmPercent_aBit: Double
    var rhythmPercent_Very: Double
    var pitchCorrectPC: Double
    var pitchABitToVeryPC: Double
    var pitchVeryBoundaryPC: Double
    
    init() {
        self.zone = ""
        self.attackTolerance = TimeInterval(0.0)
        self.isASoundThresholdLow = 0.0
        self.isASoundThresholdMid = 0.0
        self.isASoundThresholdHigh = 0.0
        self.numSamplesToDeterminePitch = 0
        self.numSamplesForLegatoPitchChange = 0
        self.ampRise_SkipWindow = 0
        self.ampRise_AnalysisWindow = 0
        self.ampRise_RiseLowBPM = 0.0
        self.ampRise_RiseMidBPM = 0.0
        self.ampRise_RiseHighBPM = 0.0
        self.soundStartOffSet = 0.0
        self.rhythmPercent_correct = 0.0
        self.rhythmPercent_aBit = 0.0
        self.rhythmPercent_Very = 0.0
        self.pitchCorrectPC = 0.0
        self.pitchABitToVeryPC = 0.0
        self.pitchVeryBoundaryPC = 0.0
    }
    
    mutating func reset() {
        self.zone = ""
        self.isASoundThresholdLow = 0.0
        self.isASoundThresholdMid = 0.0
        self.isASoundThresholdHigh = 0.0
        self.attackTolerance = TimeInterval(0.0)
        self.numSamplesToDeterminePitch = 0
        self.numSamplesForLegatoPitchChange = 0
        self.ampRise_SkipWindow = 0
        self.ampRise_AnalysisWindow = 0
        self.ampRise_RiseLowBPM = 0.0
        self.ampRise_RiseMidBPM = 0.0
        self.ampRise_RiseHighBPM = 0.0
        self.soundStartOffSet = 0.0
        self.rhythmPercent_correct = 0.0
        self.rhythmPercent_aBit = 0.0
        self.rhythmPercent_Very = 0.0
        self.pitchCorrectPC = 0.0
        self.pitchABitToVeryPC = 0.0
        self.pitchVeryBoundaryPC = 0.0
    }
    
    // Convert strings in stringVers to values, and set members
    // useDefaults: if true, assign default values if stringVers member is empty
    //              if false, don't assign anything.
    mutating func setUsing(stringVers: performanceLevelZoneSettings_RawStrings,
                           useDefaults: Bool ) {
        self.zone = stringVers.zone
        
        if stringVers.isASoundThresholdLow == "" {
            if useDefaults {
                self.isASoundThresholdLow = 0.0
            } // else  - do not set. Leave current value in place
        } else {
            self.isASoundThresholdLow =
                convertStringToDouble(str: stringVers.isASoundThresholdLow)
        }
        
        if stringVers.isASoundThresholdMid == "" {
            if useDefaults {
                self.isASoundThresholdMid = 0.0
            } // else  - do not set. Leave current value in place
        } else {
            self.isASoundThresholdMid =
                convertStringToDouble(str: stringVers.isASoundThresholdMid)
        }
        
        if stringVers.isASoundThresholdHigh == "" {
            if useDefaults {
                self.isASoundThresholdHigh = 0.0
            } // else  - do not set. Leave current value in place
        } else {
            self.isASoundThresholdHigh =
                convertStringToDouble(str: stringVers.isASoundThresholdHigh)
        }
        
        if stringVers.attackTolerance == "" {
            if useDefaults {
                self.attackTolerance = 0.0
            } // else  - do not set. Leave current value in place
        } else {
            self.attackTolerance =
                convertStringToDouble(str: stringVers.attackTolerance)
        }
        
        if stringVers.numSamplesToDeterminePitch == "" {
            if useDefaults {
                self.numSamplesToDeterminePitch = 0
            } // else  - do not sett. Leave current value in place
        } else {
            self.numSamplesToDeterminePitch =
                convertStringToInt(str: stringVers.numSamplesToDeterminePitch)
        }
        
        if stringVers.numSamplesForLegatoPitchChange == "" {
            if useDefaults {
                self.numSamplesForLegatoPitchChange = 0
            } // else  - do not sett. Leave current value in place
        } else {
            self.numSamplesForLegatoPitchChange =
                convertStringToInt(str: stringVers.numSamplesForLegatoPitchChange)
        }
    
        if stringVers.ampRise_SkipWindow == "" {
            if useDefaults {
                self.ampRise_SkipWindow = 0
            } // else  - do not sett. Leave current value in place
        } else {
            self.ampRise_SkipWindow =
                convertStringToInt(str: stringVers.ampRise_SkipWindow)
        }
        
        if stringVers.ampRise_AnalysisWindow == "" {
            if useDefaults {
                self.ampRise_AnalysisWindow = 0
            } // else  - do not sett. Leave current value in place
        } else {
            self.ampRise_AnalysisWindow =
                convertStringToInt(str: stringVers.ampRise_AnalysisWindow)
        }
        
        if stringVers.ampRise_RiseLowBPM == "" {
            if useDefaults {
                self.ampRise_RiseLowBPM = 0.0
            } // else  - do not sett. Leave current value in place
        } else {
            self.ampRise_RiseLowBPM =
                convertStringToDouble(str: stringVers.ampRise_RiseLowBPM)
        }
        
        if stringVers.ampRise_RiseMidBPM == "" {
            if useDefaults {
                self.ampRise_RiseMidBPM = 0.0
            } // else  - do not sett. Leave current value in place
        } else {
            self.ampRise_RiseMidBPM =
                convertStringToDouble(str: stringVers.ampRise_RiseMidBPM)
        }
        
        if stringVers.ampRise_RiseHighBPM == "" {
            if useDefaults {
                self.ampRise_RiseHighBPM = 0.0
            } // else  - do not sett. Leave current value in place
        } else {
            self.ampRise_RiseHighBPM =
                convertStringToDouble(str: stringVers.ampRise_RiseHighBPM)
        }
        
        if stringVers.soundStartOffSet == "" {
            if useDefaults {
                self.soundStartOffSet = 0.0
            } // else  - do not sett. Leave current value in place
        } else {
            self.soundStartOffSet =
                convertStringToDouble(str: stringVers.soundStartOffSet)
        }
        
        if stringVers.rhythmPercent_correct == "" {
            if useDefaults {
                self.rhythmPercent_correct = 0.0
            } // else  - do not sett. Leave current value in place
        } else {
            self.rhythmPercent_correct =
                convertStringToDouble(str: stringVers.rhythmPercent_correct)
        }
        
        if stringVers.rhythmPercent_aBit == "" {
            if useDefaults {
                self.rhythmPercent_aBit = 0.0
            } // else  - do not sett. Leave current value in place
        } else {
            self.rhythmPercent_aBit =
                convertStringToDouble(str: stringVers.rhythmPercent_aBit)
        }
        
        if stringVers.rhythmPercent_Very == "" {
            if useDefaults {
                self.rhythmPercent_Very = 0.0
            } // else  - do not sett. Leave current value in place
        } else {
            self.rhythmPercent_Very =
                convertStringToDouble(str: stringVers.rhythmPercent_Very)
        }
        
        if stringVers.pitchcCorrectPC == "" {
            if useDefaults {
                self.pitchCorrectPC = 0.0
            } // else  - do not sett. Leave current value in place
        } else {
            self.pitchCorrectPC =
                convertStringToDouble(str: stringVers.pitchcCorrectPC)
        }
        
        if stringVers.pitchABitToVeryPC == "" {
            if useDefaults {
                self.pitchABitToVeryPC = 0.0
            } // else  - do not sett. Leave current value in place
        } else {
            self.pitchABitToVeryPC =
                convertStringToDouble(str: stringVers.pitchABitToVeryPC)
        }
        
        self.pitchVeryBoundaryPC = 0.0
        if stringVers.pitchVeryBoundaryPC == "" {
            if useDefaults {
                self.pitchVeryBoundaryPC = 0.0
            } // else  - do not sett. Leave current value in place
        } else {
            self.pitchVeryBoundaryPC =
                convertStringToDouble(str: stringVers.pitchVeryBoundaryPC)
        }
 
    }
}


struct oneInstrumentSettings: Codable {
    var instrument: String
    var levelZones: [performanceLevelZoneSettings_RawStrings]
}

struct allInstrumentSettings: Codable {
    var instrumentsSettings: [oneInstrumentSettings]
}

func convertStringToInt(str: String) -> Int {
    var retVal = 0
    if let convInt = Int(str) {
        retVal =  convInt
    } else {
        itsBad()
    }
    return retVal
}

func convertStringToBool(str: String) -> Bool {
    if str.lowercased() == "true" {
        return true
    } else {
        return false
    }
}

func convertStringToDouble(str: String) -> Double {
    var retVal = 0.0
//    let convStr = "0." + str
    if let convDbl = Double(str) {
        retVal =  convDbl
    } else {
        itsBad()
    }
    return retVal
}



















class InstrumentSettingsManager {

    static let sharedInstance = InstrumentSettingsManager()
    
    init() {
        _ = loadLevelSettingsData()
    }
    
    var defaultLvlSettingsForInstr = performanceLevelZoneSettings()
    var currLevelZoneSettingsForInstr = performanceLevelZoneSettings()

    var jsonData: Data? = nil
    var instrumentSettings: allInstrumentSettings? = nil
    var instAndDefaultZoneFound = false
    var levelZoneSet = false
    var currInstStr = ""
    
    func loadLevelSettingsData() -> Bool {
        var retVal = false
        
        if let file = Bundle.main.path(forResource: "PerformanceLevelSettings",
                                       ofType: "json") {
            jsonData = try? Data(contentsOf: URL(fileURLWithPath: file))
        }
        
        guard jsonData != nil else {
            print ("Could not load PerformanceLevelSettings as jsonData")
            itsBad()
            return retVal
        }
        
        let jsonDecoder = JSONDecoder()
        instrumentSettings =
            try? jsonDecoder.decode(allInstrumentSettings.self,
                                    from: jsonData!)
        if instrumentSettings != nil {
            print("Created instrumentSettings from json file data")
            retVal = true
        } else {
            itsBad()
            print("Error - Unable to create perfLvlSettingsRawData from json file data")
        }
        return retVal
    }

    
    //        var perLvlSettings = performanceLevelSettings()
    //        perLvlSettings.setUsing(stringVers: perfLvlSettingsRawData!, useDefaults: false)
    //
    //        let zone = perLvlSettings.zone
    //        print("\(zone)")

    func setupDefaultForCurrInstr() {
        defaultLvlSettingsForInstr.reset()
        currLevelZoneSettingsForInstr.reset()
        instAndDefaultZoneFound = false
        levelZoneSet = false
        guard instrumentSettings != nil  else {
            itsBad()
            return
        }
        
        let currInst = getCurrentStudentInstrument()

        let instStr = getInstrString(inst: currInst)
        if instStr.length != 0 {
            for oneEntry in instrumentSettings!.instrumentsSettings {
                if oneEntry.instrument == instStr {
                    for oneZone in oneEntry.levelZones {
                        if oneZone.zone == kZoneStr_defaults {
                            defaultLvlSettingsForInstr.setUsing(stringVers: oneZone,
                                                                useDefaults: true)
                            instAndDefaultZoneFound = true
                            currInstStr = instStr
                            break
                        }
                    }
                }
            }
        }
        
        if !instAndDefaultZoneFound {
            itsBad()
        }
    }
    
    func adjustSettingsForLevel(level: Int) {
        if !instAndDefaultZoneFound {
            self.setupDefaultForCurrInstr()
        }
        
        guard instAndDefaultZoneFound else {
            itsBad()
            return
        }
 
        // Setup default values as current, in case no specific entry for zone
        currLevelZoneSettingsForInstr = defaultLvlSettingsForInstr
        levelZoneSet = true // to defaults . . .
        
        /*  For now - restore the rest when ready
        
        let zoneStr = getZoneString(level: level)
        if zoneStr.length != 0 {
            for oneEntry in instrumentSettings!.instrumentsSettings {
                if oneEntry.instrument == currInstStr {
                    for oneZone in oneEntry.levelZones {
                        if oneZone.zone == zoneStr {
                            // copy the settings, but don't override defaults
                            currLevelZoneSettingsForInstr.setUsing(stringVers: oneZone,
                                                                   useDefaults: false)
                            break
                        }
                    }
                }
            }
        }
 
 */
    }
    
    
    let kLipsSlurs  = 998
    let kLTPersBest = 999

    
//    func resetPerfSettings() {
////        currBPM = getCurrBPM()
////        currentLevel = LessonScheduler.instance.getCurrLevel()
//        
//        resetAdjustedAmpRise()
//        
//        
//    }
    
    let kZoneStr_defaults    = "defaultsAllZones"
    let kZoneStr_1Thru4      = "zone1Thru4"
    let kZoneStr_5Thru20     = "zone5Thru20"
    let kZoneStr_21Thru30    = "zone21Thru30"

    func getZoneString(level: Int) -> String {
        var levelStr = ""
        switch level {
        case 0...4:         levelStr = kZoneStr_1Thru4
        case 5...20:        levelStr = kZoneStr_5Thru20
        case 21...30:       levelStr = kZoneStr_21Thru30
        case kLipsSlurs:    levelStr = kZoneStr_5Thru20
        case kLTPersBest:   levelStr = kZoneStr_5Thru20

        default:  break
        }
        
        return levelStr
    }
}

func getInstrString(inst: Int) -> String {
    var instStr = ""
    switch inst {
    case kInst_Trumpet:      instStr = "Trumpet"
    case kInst_Trombone:     instStr = "Trombone"
    case kInst_Euphonium:    instStr = "Euphonium"
    case kInst_FrenchHorn:   instStr = "FrenchHorn"
    case kInst_Tuba:         instStr = "Tuba"
    case kInst_Flute:        instStr = "Flute"
    case kInst_Oboe:         instStr = "Oboe"
    case kInst_Clarinet:     instStr = "Clarinet"
    case kInst_BassClarinet: instStr = "BassClarinet"
    case kInst_Bassoon:      instStr = "Bassoon"
    case kInst_AltoSax:      instStr = "AltoSax"
    case kInst_TenorSax:     instStr = "TenorSax"
    case kInst_BaritoneSax:  instStr = "BaritoneSax"
    case kInst_Mallet:       instStr = "Mallet"
        
    default:  break
    }
    
    return instStr
}


func getIsASoundThresholdStr() -> String {
    let storedIsASoundThreshold = UserDefaults.standard.double(forKey: Constants.Settings.UserNoteThresholdOverride)
    var currIsASoundThreshold   = kAmplitudeThresholdForIsSound
    if storedIsASoundThreshold > 0.01 { // it's been set if not == 0.0
        currIsASoundThreshold = storedIsASoundThreshold
    }
    let isASoundThrStr = String(format: "%.3f", currIsASoundThreshold)
    return isASoundThrStr
}



func getAmpRiseStr() -> String {
    var retStr = ""
    if gUseAmpRiseChangeSlowFastValues {
        retStr += "Using Calculated AmpRise\n"
        let slowStr = String(format: "%.3f", gAmpRiseChangeValue_Slow)
        let fastStr = String(format: "%.3f", gAmpRiseChangeValue_Fast)
        retStr += "  Slow Setting:\t\t\t\(slowStr)\n"
        retStr += "  Fast Setting:\t\t\t\(fastStr)\n"
    } else {
        let arStr = String(format: "%.3f", gAmpRiseForNewSound)
        retStr += "Using Settings AmpRise:\t\(arStr)\n"
    }
    return retStr
}

var gShowInternalSettingsPresentingVC: UIViewController? = nil

func presentSettingsSummaryAlert(presentingVC: UIViewController) {

    gShowInternalSettingsPresentingVC = presentingVC
    
    let titleStr = "Show Current Internal Settings"
    var msgStr  = "Display Auto-Calculated settings, or Editable settings?\n\n"
    msgStr += "(Currently using "
    if gUseOldRealtimeSettings {
        msgStr += "Editable settings)"
    } else {
        msgStr += "Auto-Calculated settings) "
    }

    let ac = UIAlertController(title: titleStr,
                               message: msgStr,
                               preferredStyle: .alert)
    
    ac.addAction(UIAlertAction(title: "Editable Settings",  style: .default,
                               handler: showEditableSettingsHandler))
    ac.addAction(UIAlertAction(title: "Auto-Calculated Settings",  style: .default,
                               handler: showAutoCalcSettingsHandler))
    ac.addAction(UIAlertAction(title: "Cancel",  style: .cancel, handler: nil))

    presentingVC.present(ac, animated: true, completion: nil)
}

func showAutoCalcSettingsHandler(_ act: UIAlertAction) {
    guard gShowInternalSettingsPresentingVC != nil else {
        return }

    let currInst = getCurrentStudentInstrument()
    let instrStr = getInstrString(inst: currInst)
    let titleStr = "Auto-Calc Settings: \(instrStr)"
    
    var msgStr = ""
    
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "MM/dd/yyyy, hh:mm a"
    
    let dateStr =  formatter.string(from: Date())
    
    if !isiPhoneSE() {
        msgStr += "\n"
    }
    
    msgStr += " \t\(dateStr)\n\n"
    
    let currBPM = Int(getCurrBPM())
    msgStr += "Current BPM: \t\t\t\(currBPM)\n"
    
    let isASoundThrStr = gRTSM_IsASoundThreshold
    msgStr += "Is A Sound Threshold: "
    msgStr += "\t\(isASoundThrStr)\n"
    
    let soundStartOffset = gRTSM_SoundStartOffset
    let currSS  = Float(soundStartOffset)
    // let currSS  = Float(gSoundStartAdjustment)
    let soundStartStr = String(format: "%.3f", currSS)
    msgStr += "Sound Start Offset: "
    msgStr += "\t\t\(soundStartStr)\n"
    
    
    let pitchSampsStr = "\(Int(gRTSM_SamplesDeterminePitch))"
    msgStr += "Skip Samples For Pitch: \t\(pitchSampsStr)\n"
    
    let attackTol =
        Float(PerfAnlsisMgr.instance.currTolerances.rhythmTolerance)
    let attackTolStr = String(format: "%.3f", attackTol)
    msgStr += "Attack Tolerance (base): "
    msgStr += "\t\(attackTolStr)\n"
    
    if !isiPhoneSE() {
        msgStr += "\t\t\t- - - - -\n"
    }
    
//    let ampRiseStr = getAmpRiseStr()
//    let ampRiseStr = getAmpRiseStr()
//    msgStr += "\(ampRiseStr)"

    let currBPMDouble = getCurrBPM()
    let bpmMult = 60.0/currBPMDouble
    let quarterDur = (1.0 * bpmMult) * 0.85
    let eighthDur  = (0.5 * bpmMult) * 0.85
    let skipForQuarter =
        RTSMgr.instance.getAdjustedAmpRiseSkipWindow(expNoteDur: quarterDur)
    let skipForEighth =
        RTSMgr.instance.getAdjustedAmpRiseSkipWindow(expNoteDur: eighthDur)
//    let quarterStr = String(format: "%.3f", skipForQuarter)
//    let EighthStr  = String(format: "%.3f", gAmpRiseChangeValue_Fast)

    msgStr += "AmpRise Skip At \(currBPM) BPM:\n"
    msgStr += "  Quarter Note:\t\(skipForQuarter)\n"
    msgStr += "  Eighth Note: \t\(skipForEighth)\n"

    /*
    let arSkipWindowSampsStr = "\(Int(gRTSM_AmpRiseAnalysisWindow))"
    msgStr += "Amp Rise Window Size: \t\(arSkipWindowSampsStr)\n"
    
    if !isiPhoneSE() {
        msgStr += "\t\t\t- - - - -\n"
    }
    
    let legatoOnOffStr = gScanForPitchDuringLegatoPlayingAbsolute ? "ON" : "OFF"
    msgStr += "Legato Detection:\t\t\(legatoOnOffStr)\n"
    
    let diffPitchWindowStr = "\(Int(gDifferentPitchSampleThreshold))"
    msgStr += "Different Pitch Window: \t\(diffPitchWindowStr)\n"
    
    */
    
    let ac = UIAlertController(title: titleStr,
                               message: msgStr,
                               preferredStyle: .alert)
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = NSTextAlignment.left
    
    let messageText = NSMutableAttributedString(
        string: msgStr,
        attributes: [
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)
        ]
    )
    
    ac.setValue(messageText, forKey: "attributedMessage")
    
    ac.addAction(UIAlertAction(title: "OK",  style: .cancel, handler: nil))
    
    gShowInternalSettingsPresentingVC?.present(ac, animated: true, completion: nil)
    
}

func showEditableSettingsHandler(_ act: UIAlertAction) {
    
    guard gShowInternalSettingsPresentingVC != nil else {
        return }
    
//func presentNonAutoSettingsSummaryAlert(presentingVC: UIViewController) {
    /*
     Date and Time
     curr BPM
     IsASound
     Sound Start Offset
     Attack Tolerance (base)
     Skip Samples For Pitch
     AmpRise - Single
     AmpRise - Slow
     AmpRise - Fast
     AmpRise Window
     AmpRise Skip
     
     Legato On/Off
     Legato Pitch Samples
     */

    let currInst = getCurrentStudentInstrument()
    let instrStr = getInstrString(inst: currInst)
    let titleStr = "Editable Settings: \(instrStr)"
  
    var msgStr = ""
    
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "MM/dd/yyyy, hh:mm a"

    let dateStr =  formatter.string(from: Date())

    if !isiPhoneSE() {
        msgStr += "\n"
    }
    
    msgStr += " \t\(dateStr)\n\n"
    
    let currBPM = Int(getCurrBPM())
    msgStr += "Current BPM: \t\t\t\(currBPM)\n"
    
    let isASoundThrStr = getIsASoundThresholdStr()
    msgStr += "Is A Sound Threshold: "
    msgStr += "\t\(isASoundThrStr)\n"
    
    let soundStartOffset = getSoundStartOffset()
    let currSS  = Float(soundStartOffset)
    // let currSS  = Float(gSoundStartAdjustment)
    let soundStartStr = String(format: "%.3f", currSS)
    msgStr += "Sound Start Offset: "
    msgStr += "\t\t\(soundStartStr)\n"
    

    let pitchSampsStr = "\(Int(gSamplesNeededToDeterminePitch))"
    msgStr += "Skip Samples For Pitch: \t\(pitchSampsStr)\n"
    
    let attackTol =
        Float(PerfAnlsisMgr.instance.currTolerances.rhythmTolerance)
    let attackTolStr = String(format: "%.3f", attackTol)
    msgStr += "Attack Tolerance (base): "
    msgStr += "\t\(attackTolStr)\n"
    
    if !isiPhoneSE() {
        msgStr += "\t\t\t- - - - -\n"
    }
    
    let ampRiseStr = getAmpRiseStr()
    msgStr += "\(ampRiseStr)"

//    var gSkipBeginningSamples:      UInt     = 15
    let arSkipSampsStr = "\(Int(gSkipBeginningSamples))"
    msgStr += "Amp Rise Skip Samples: \t\(arSkipSampsStr)\n"
    
//    var gSamplesInAnalysisWindow:   UInt     =  2
    let arWindowSampsStr = "\(Int(gSamplesInAnalysisWindow))"
    msgStr += "Amp Rise Window Size: \t\(arWindowSampsStr)\n"
    
    if !isiPhoneSE() {
        msgStr += "\t\t\t- - - - -\n"
    }
    
    let legatoOnOffStr = gScanForPitchDuringLegatoPlayingAbsolute ? "ON" : "OFF"
    msgStr += "Legato Detection:\t\t\(legatoOnOffStr)\n"
    
    let diffPitchWindowStr = "\(Int(gDifferentPitchSampleThreshold))"
    msgStr += "Different Pitch Window: \t\(diffPitchWindowStr)\n"
    

    let ac = UIAlertController(title: titleStr,
                               message: msgStr,
                               preferredStyle: .alert)
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = NSTextAlignment.left
    
    let messageText = NSMutableAttributedString(
        string: msgStr,
        attributes: [
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)
        ]
    )
    
    ac.setValue(messageText, forKey: "attributedMessage")
    
    ac.addAction(UIAlertAction(title: "OK",  style: .cancel, handler: nil))
    
    gShowInternalSettingsPresentingVC?.present(ac, animated: true, completion: nil)

}


/*
 
 To Do:
 
 Set values for each instrument in json
 
 retrieve per-instrumernt global Adjusted values or value ranges
 - In AppDelegate - for current instrument
 - when new instrument is chosen
 
 reset adjustable vales whenever Level is entered.
 
 Find every place previous vals were used in app, and substitute adjusted vals.
 
 
 
 */
