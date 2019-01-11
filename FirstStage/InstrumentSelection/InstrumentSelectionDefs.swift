//
//  InstrumentSelectionDefs.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/21/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

// Tag to search for:    DATA_BASE_CONVERT

//  French Horn Range
//     Samples:  34 - 77      A#1 - E#5,   3+ Octaves
//     Range in LT XML file   B2  - C5

import Foundation

// IMPORTANT: The order of these defs matches the order SampledInstrumentsInfos
//            are appended in PlaybackInstrumentViewController.
// Don't altering this order without also altering PlaybackInstrumentVC.
let kInst_Trumpet:    Int = 0
let kInst_Trombone:   Int = 1
let kInst_Euphonium:  Int = 2
let kInst_FrenchHorn: Int = 3
let kInst_Tuba:       Int = 4

let kTransposeFor_Trumpet:    Int =  -2
let kTransposeFor_Trombone:   Int =   0
let kTransposeFor_Euphonium:  Int =   kTransposeFor_Trombone
let kTransposeFor_FrenchHorn: Int =   0
let kTransposeFor_Tuba:       Int =   0

// sub directories, of bundles paths, for each instrument
let kTrumpetSubDir      = "Trumpet/"
let kTromboneSubDir     = "Trombone/"
let kEuphoniumSubDir    = "Trombone/"
let kFrenchHornSubDir   = "FrenchHorn/"
let kTubaSubDir         = "Tuba/"

// specific to Video directories
let kBrassVideos        = "/brass"
let kNoSpecificVideos   = ""

///////////////////////////////////////////////////////////////////////////////
// InstrumentSettings struct
//
//   - pitchTranspose: as varies from note pitch in score, E.g., Bb Trumpet will
//       be -2 (the note is written as C, but the pitch is Bb)
//   - dir fields: appended to bundle path to locate instrument-specific files
//   - baseVideoLibraryDir: where to look for a video if not found in
//       primaryVideoLibraryDir. For example, Base Brass videos will use the term
//       "fingering", and this will apply to all but trombone. Trombone will have
//       a few videos that use the term "slide position" instead of "fingering",
//       and the app should look in the Trombone dir first if Trombone.
// ToDo:
//    Partials offset?
//
struct InstrumentSettings {
    var pitchTranspose:         Int
    var longToneTranspose:      Int
    var xmlDir:                 String
    var toneLibraryDir:         String
    var primaryVideoLibraryDir: String
    var baseVideoLibraryDir:    String

    init( pitchTranspose:           Int,
          longToneTranspose:        Int,
          xmlDir:                   String,
          toneLibraryDir:           String,
          primaryVideoLibraryDir:   String,
          baseVideoLibraryDir:      String ) {
        self.pitchTranspose         = pitchTranspose
        self.longToneTranspose      = longToneTranspose
        self.xmlDir                 = xmlDir
        self.toneLibraryDir         = toneLibraryDir
        self.primaryVideoLibraryDir = primaryVideoLibraryDir
        self.baseVideoLibraryDir    = baseVideoLibraryDir
    }
}

let kTrumpetInstrumentSettings =
    InstrumentSettings( pitchTranspose:         -2,
                        longToneTranspose:      0,
                        xmlDir:                 kTrumpetSubDir,
                        toneLibraryDir:         kTrumpetSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos )

let kTromboneInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -14,
                        xmlDir:                 kTromboneSubDir,
                        toneLibraryDir:         kTromboneSubDir,
                        primaryVideoLibraryDir: kTromboneSubDir,
                        baseVideoLibraryDir:    kBrassVideos )

// Euphonium uses Trombone XML files and samples, but basic brass vids
let kEuphoniumInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -14,
                        xmlDir:                 kTromboneSubDir,
                        toneLibraryDir:         kTromboneSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos )

let kFrenchHornInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      5,
                        xmlDir:                 kFrenchHornSubDir,
                        toneLibraryDir:         kFrenchHornSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos )

let kTubaInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -26,
                        xmlDir:                 kTubaSubDir,
                        toneLibraryDir:         kTubaSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos )

private var gCurrentInstrument = kInst_Trumpet
var gInstrumentSettings: InstrumentSettings = kTrumpetInstrumentSettings

func getCurrentStudentInstrument() -> Int {
    return gCurrentInstrument
}

func setCurrentStudentInstrument( instrument: Int ) {
    gCurrentInstrument = instrument
    UserDefaults.standard.set(
        Int(gCurrentInstrument),
        forKey: Constants.Settings.StudentInstrument)

    switch instrument {
    case kInst_Trombone:
        gInstrumentSettings = kTromboneInstrumentSettings
        UserDefaults.standard.set(kTransposeFor_Trombone,
                                  forKey: Constants.Settings.Transposition)
        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: kInst_Trombone )
        
    case kInst_Euphonium:
        gInstrumentSettings = kEuphoniumInstrumentSettings
        UserDefaults.standard.set(kTransposeFor_Euphonium,
                                  forKey: Constants.Settings.Transposition)
        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: kInst_Euphonium )
        
    case kInst_FrenchHorn:
        gInstrumentSettings = kFrenchHornInstrumentSettings
        UserDefaults.standard.set(kTransposeFor_FrenchHorn,
                                  forKey: Constants.Settings.Transposition)
        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: kInst_FrenchHorn )
        
    case kInst_Tuba:
        gInstrumentSettings = kTubaInstrumentSettings
        UserDefaults.standard.set(kTransposeFor_Tuba,
                                  forKey: Constants.Settings.Transposition)
        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: kInst_Tuba )

    case kInst_Trumpet:      fallthrough
    default:
        gInstrumentSettings = kTrumpetInstrumentSettings
        UserDefaults.standard.set(kTransposeFor_Trumpet,
                                  forKey: Constants.Settings.Transposition)
        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: kInst_Trumpet )
    }
}

func getXMLInstrDirString() -> String {
    var retStr = kTrumpetSubDir
    
    switch gCurrentInstrument {
    case kInst_Trombone:     retStr = kTromboneSubDir
    case kInst_Euphonium:    retStr = kEuphoniumSubDir
    case kInst_FrenchHorn:   retStr = kFrenchHornSubDir
    case kInst_Tuba:         retStr = kTubaSubDir
        
    case kInst_Trumpet:      fallthrough
    default:                retStr = kTrumpetSubDir
    }
    
    return retStr
}

func getLongToneExerNote(origNoteStr: String) -> String {
    var retStr = origNoteStr
    if gCurrentInstrument == kInst_Trumpet {
        return retStr  // unaltered  . . .
    }
    
    let strLen = origNoteStr.length
    guard strLen == 2 || strLen == 3 else {
        itsBad()
        return origNoteStr
    }
    
    var alter = 0
//    var shift = -1

    let transAmount = gInstrumentSettings.longToneTranspose
    var idx = 0
    let noteStr = origNoteStr[idx]
    idx += 1
    var accidentalStr = ""
    if strLen == 3 {
        accidentalStr = origNoteStr[idx]
        idx += 1
        if accidentalStr == "b" || accidentalStr == "B" {
            alter = -1
        } else if accidentalStr == "#" {
//            shift = 1
            alter = 1
        } else {
            itsBad()
        }
    }
    let octStr = origNoteStr[idx]
    let octInt = NoteID(octStr)!
    
    let origPOAS = tPOAS(octave: octInt, alter: alter, step: noteStr)
    let newPOAS = getShiftedPOAS(currPOAS: origPOAS, shift: transAmount)
    
    retStr = newPOAS.step
    if newPOAS.alter != 0 {
        if newPOAS.alter < 0 {
            retStr += "b"
        } else {
            retStr += "#"
        }
    }
    retStr += String(newPOAS.octave)
    
    return retStr
}

func getFirstNoteForCurrentInstrument() -> Int {
    // trumpet is 55 - 79
    
    var retVal = 55
    
    switch gCurrentInstrument {
    case kInst_Trombone:     retVal = 39    // Eb2 == 39
    case kInst_Euphonium:    retVal = 39    // Eb2 == 39
    case kInst_FrenchHorn:   retVal = 47    // B2  == 47
    case kInst_Tuba:         retVal = 27    // Eb1 == 27
        
    case kInst_Trumpet:      fallthrough
    default:                 retVal = 55    // G3 == 55
    }
    return retVal
}

func getNoteOffsetForCurrentInstrument() -> Int {
    var retVal = 60
    
    switch gCurrentInstrument {
    case kInst_Trombone:     retVal = 39    // Eb2 == 39
    case kInst_Euphonium:    retVal = 39    // Eb2 == 39
    case kInst_FrenchHorn:   retVal = 47    // B2  == 47
    case kInst_Tuba:         retVal = 27    // Eb1 == 27
        
    case kInst_Trumpet:      fallthrough
    default:                 retVal = 60    // C4 == 60
    }
    return retVal
}


//////////////////////
// MOVE ME
extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}


