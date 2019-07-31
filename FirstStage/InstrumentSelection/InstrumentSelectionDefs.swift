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
let kInst_Trumpet:      Int =  0
let kInst_Trombone:     Int =  1
let kInst_Euphonium:    Int =  2
let kInst_FrenchHorn:   Int =  3
let kInst_Tuba:         Int =  4
let kInst_NumBrass:     Int =  kInst_Tuba + 1

let kInst_Flute:        Int =  5
let kInst_Oboe:         Int =  6
let kInst_Clarinet:     Int =  7
let kInst_BassClarinet: Int =  8
let kInst_Bassoon:      Int =  9
let kInst_AltoSax:      Int = 10
let kInst_TenorSax:     Int = 11
let kInst_BaritoneSax:  Int = 12
let kInst_NumWoodwinds: Int =  8

let kInst_NumInstruments = kInst_NumBrass + kInst_NumWoodwinds

let kInst_LastAcceptableInst:  Int = kInst_BaritoneSax

let kInst_Piano:        Int = 13


////////////////////////////////////////////////////////////////
// MARK:- "Hard-Coded" per instument settings

let kTransposeFor_Trumpet:       Int =  -2
let kTransposeFor_Trombone:      Int =   0
let kTransposeFor_Euphonium:     Int =   kTransposeFor_Trombone
let kTransposeFor_FrenchHorn:    Int =   -7
let kTransposeFor_Tuba:          Int =   0

let kTransposeFor_Flute:         Int =   0
let kTransposeFor_Oboe:          Int =   0
let kTransposeFor_Clarinet:      Int =   -2
let kTransposeFor_BassClarinet:  Int =   0
let kTransposeFor_Bassoon:       Int =   0
let kTransposeFor_AltoSax:       Int =   0
let kTransposeFor_TenorSax:      Int =   0
let kTransposeFor_BaritoneSax:   Int =   0
// CHANGEHERE - real vales for above



let kSSTransposeFor_Trumpet:       Int32 =   0
let kSSTransposeFor_Trombone:      Int32 =   0
let kSSTransposeFor_Euphonium:     Int32 =   0
let kSSTransposeFor_FrenchHorn:    Int32 =   0
let kSSTransposeFor_Tuba:          Int32 =   0

let kSSTransposeFor_Flute:         Int32 =   24 // two octaves above the Trombone score
let kSSTransposeFor_Oboe:          Int32 =   12
let kSSTransposeFor_Clarinet:      Int32 =   0
let kSSTransposeFor_BassClarinet:  Int32 =   0
let kSSTransposeFor_Bassoon:       Int32 =   0
let kSSTransposeFor_AltoSax:       Int32 =   0
let kSSTransposeFor_TenorSax:      Int32 =   0
let kSSTransposeFor_BaritoneSax:   Int32 =   0
// CHANGEHERE - real vales for above

// sub directories, of bundles paths, for each instrument
let kTrumpetSubDir      = "Trumpet/"
let kTromboneSubDir     = "Trombone/"
let kEuphoniumSubDir    = "Trombone/"
let kFrenchHornSubDir   = "FrenchHorn/"
let kTubaSubDir         = "Tuba/"

let kFluteSubDir        = kTromboneSubDir // "Flute/"
let kOboeSubDir         = kTromboneSubDir // "Flute/"
let kClarinetSubDir     = "Trumpet/"
let kBassClarinetSubDir = "Tuba/"
let kBassoonSubDir      = "Trombone/"
let kAltoSaxSubDir      = "AltoSax/"
let kTenorSaxSubDir     = "TenorSax/"
let kBaritoneSaxSubDir  = "BariSax/"
// CHANGEHERE - real vales for above

// specific to Video directories
let kBrassVideos        = "/brass"
let kNoSpecificVideos   = ""

//////////////////////////////////////////////////////////////////////////////
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
    var isBrassInstrument:      Bool

    init( pitchTranspose:           Int,
          longToneTranspose:        Int,
          xmlDir:                   String,
          toneLibraryDir:           String,
          primaryVideoLibraryDir:   String,
          baseVideoLibraryDir:      String,
          isBrassInstrument:        Bool) {
        self.pitchTranspose         = pitchTranspose
        self.longToneTranspose      = longToneTranspose
        self.xmlDir                 = xmlDir
        self.toneLibraryDir         = toneLibraryDir
        self.primaryVideoLibraryDir = primaryVideoLibraryDir
        self.baseVideoLibraryDir    = baseVideoLibraryDir
        self.isBrassInstrument      = isBrassInstrument
    }
}

let kTrumpetInstrumentSettings =
    InstrumentSettings( pitchTranspose:         -2,
                        longToneTranspose:      0,
                        xmlDir:                 kTrumpetSubDir,
                        toneLibraryDir:         kTrumpetSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      true)

let kTromboneInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -14,
                        xmlDir:                 kTromboneSubDir,
                        toneLibraryDir:         kTromboneSubDir,
                        primaryVideoLibraryDir: kTromboneSubDir,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      true )

// Euphonium uses Trombone XML files and samples, but basic brass vids
let kEuphoniumInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -14,
                        xmlDir:                 kTromboneSubDir,
                        toneLibraryDir:         kTromboneSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      true )

let kFrenchHornInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      5,
                        xmlDir:                 kFrenchHornSubDir,
                        toneLibraryDir:         kFrenchHornSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      true )

let kTubaInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -26,
                        xmlDir:                 kTubaSubDir,
                        toneLibraryDir:         kTubaSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      true )

let kFluteInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -26,
                        xmlDir:                 kFluteSubDir,
                        toneLibraryDir:         kFluteSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      false )

let kOboeInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -26,
                        xmlDir:                 kOboeSubDir,
                        toneLibraryDir:         kOboeSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      false )

let kClarinetInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -26,
                        xmlDir:                 kClarinetSubDir,
                        toneLibraryDir:         kClarinetSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      false )

let kBassClarinetInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -26,
                        xmlDir:                 kBassClarinetSubDir,
                        toneLibraryDir:         kBassClarinetSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      false )

let kBassoonInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -26,
                        xmlDir:                 kBassoonSubDir,
                        toneLibraryDir:         kBassoonSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      false )

let kAltoSaxInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -26,
                        xmlDir:                 kAltoSaxSubDir,
                        toneLibraryDir:         kAltoSaxSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      false )

let kTenorSaxInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -26,
                        xmlDir:                 kTenorSaxSubDir,
                        toneLibraryDir:         kTenorSaxSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      false )

let kBaritoneSaxInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -26,
                        xmlDir:                 kBaritoneSaxSubDir,
                        toneLibraryDir:         kBaritoneSaxSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      false )


//private var gCurrentInstrument = kInst_Trumpet
private var gCurrentInstrument =
    UserDefaults.standard.integer(forKey: Constants.Settings.StudentInstrument)
var gInstrumentSettings: InstrumentSettings = kTrumpetInstrumentSettings

func getCurrentStudentInstrument() -> Int {
    return gCurrentInstrument
}

func currInstrumentIsBrass() -> Bool {
    return gInstrumentSettings.isBrassInstrument
}

func setCurrentStudentInstrument( instrument: Int ) {
    gCurrentInstrument = instrument
    UserDefaults.standard.set(
        Int(gCurrentInstrument),
        forKey: Constants.Settings.StudentInstrument)

    switch instrument {
    case kInst_Trombone:
        kUseWeightedPitchScore = false
        gInstrumentSettings = kTromboneInstrumentSettings
        UserDefaults.standard.set(kTransposeFor_Trombone,
                                  forKey: Constants.Settings.Transposition)
        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: kInst_Trombone )
        
    case kInst_Euphonium:
        kUseWeightedPitchScore = false
        gInstrumentSettings = kEuphoniumInstrumentSettings
        UserDefaults.standard.set(kTransposeFor_Euphonium,
                                  forKey: Constants.Settings.Transposition)
        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: kInst_Euphonium )
        
    case kInst_FrenchHorn:
        kUseWeightedPitchScore = false
        gInstrumentSettings = kFrenchHornInstrumentSettings
        UserDefaults.standard.set(kTransposeFor_FrenchHorn,
                                  forKey: Constants.Settings.Transposition)
        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: kInst_FrenchHorn )
        
    case kInst_Tuba:
        kUseWeightedPitchScore = true
        gInstrumentSettings = kTubaInstrumentSettings
        UserDefaults.standard.set(kTransposeFor_Tuba,
                                  forKey: Constants.Settings.Transposition)
        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: kInst_Tuba )

    case kInst_Flute:
        kUseWeightedPitchScore = false
        gInstrumentSettings = kFluteInstrumentSettings
        UserDefaults.standard.set(kTransposeFor_Flute,
                                  forKey: Constants.Settings.Transposition)
//        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: kInst_Trumpet )
        
    case kInst_Oboe:
        kUseWeightedPitchScore = false
        gInstrumentSettings = kOboeInstrumentSettings
        UserDefaults.standard.set(kTransposeFor_Oboe,
                                  forKey: Constants.Settings.Transposition)
//        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: kInst_Trumpet )
        
    case kInst_Clarinet:
        kUseWeightedPitchScore = false
        gInstrumentSettings = kClarinetInstrumentSettings
        UserDefaults.standard.set(kTransposeFor_Clarinet,
                                  forKey: Constants.Settings.Transposition)
//        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: kInst_Trumpet )
        
    case kInst_BassClarinet:
        kUseWeightedPitchScore = false
        gInstrumentSettings = kBassClarinetInstrumentSettings
        UserDefaults.standard.set(kTransposeFor_BassClarinet,
                                  forKey: Constants.Settings.Transposition)
//        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: kInst_Trumpet )
        
    case kInst_Bassoon:
        kUseWeightedPitchScore = false
        gInstrumentSettings = kBassoonInstrumentSettings
        UserDefaults.standard.set(kTransposeFor_Bassoon,
                                  forKey: Constants.Settings.Transposition)
//        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: kInst_Trumpet )
        
    case kInst_AltoSax:
        kUseWeightedPitchScore = false
        gInstrumentSettings = kAltoSaxInstrumentSettings
        UserDefaults.standard.set(kTransposeFor_AltoSax,
                                  forKey: Constants.Settings.Transposition)
//        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: kInst_Trumpet )
        
    case kInst_TenorSax:
        kUseWeightedPitchScore = false
        gInstrumentSettings = kTenorSaxInstrumentSettings
        UserDefaults.standard.set(kTransposeFor_TenorSax,
                                  forKey: Constants.Settings.Transposition)
        //        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: kInst_Tuba )
        
    case kInst_BaritoneSax:
        kUseWeightedPitchScore = false
        gInstrumentSettings = kBaritoneSaxInstrumentSettings
        UserDefaults.standard.set(kTransposeFor_BaritoneSax,
                                  forKey: Constants.Settings.Transposition)
        //        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: kInst_Tuba )
        
        
    case kInst_Trumpet:      fallthrough
    default:
        kUseWeightedPitchScore = false
        gInstrumentSettings = kTrumpetInstrumentSettings
        UserDefaults.standard.set(kTransposeFor_Trumpet,
                                  forKey: Constants.Settings.Transposition)
        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: kInst_Trumpet )
    }
}

//////////////////////////////////////////////////////////////////////
// MARK:- File-related funcs

func getXMLInstrDirString() -> String {
    var retStr = kTrumpetSubDir
    
    switch gCurrentInstrument {
    case kInst_Trombone:     retStr = kTromboneSubDir
    case kInst_Euphonium:    retStr = kEuphoniumSubDir
    case kInst_FrenchHorn:   retStr = kFrenchHornSubDir
    case kInst_Tuba:         retStr = kTubaSubDir
        
    case kInst_Flute:        retStr = kFluteSubDir
    case kInst_Oboe:         retStr = kOboeSubDir
    case kInst_Clarinet:     retStr = kClarinetSubDir
    case kInst_BassClarinet: retStr = kBassClarinetSubDir
    case kInst_Bassoon:      retStr = kBassoonSubDir
    case kInst_AltoSax:      retStr = kAltoSaxSubDir
    case kInst_TenorSax:     retStr = kTenorSaxSubDir
    case kInst_BaritoneSax:  retStr = kBaritoneSaxSubDir

    case kInst_Trumpet:      fallthrough
    default:                 retStr = kTrumpetSubDir
    }
    
    return retStr
}

// E.g., the "_Trumpet" part of "UserScore_Trumpet"
func getScoreFileSubNameForInstr(instr: Int) -> String {
    var retStr = "_Trumpet"
    
    switch instr {
    case kInst_Trombone:     retStr = "_Trombone"
    case kInst_Euphonium:    retStr = "_Euphonium"
    case kInst_FrenchHorn:   retStr = "_FrenchHorn"
    case kInst_Tuba:         retStr = "_Tuba"
        
    case kInst_Flute:        retStr = "_Flute"
    case kInst_Oboe:         retStr = "_Oboe"
    case kInst_Clarinet:     retStr = "_Clarinet"
    case kInst_BassClarinet: retStr = "_BassClarinet"
    case kInst_Bassoon:      retStr = "_Bassoon"
    case kInst_AltoSax:      retStr = "_AltoSax"
    case kInst_TenorSax:     retStr = "_TenorSax"
    case kInst_BaritoneSax:  retStr = "_BariSax"
        
    case kInst_Trumpet:      fallthrough
    default:                 retStr = "_Trumpet"
    }
    
    return retStr
}

typealias tClefLine = (clef: String, line: String)
let kG_ClefLine =  (clef: "G", line: "2")
let kF_ClefLine =  (clef: "F", line: "4")

func getClefLineForInstr(instr: Int) -> tClefLine {
    
    var retVal = kG_ClefLine
    
    switch instr {
    case kInst_Trombone:     retVal = kF_ClefLine
    case kInst_Euphonium:    retVal = kF_ClefLine
    case kInst_FrenchHorn:   retVal = kG_ClefLine
    case kInst_Tuba:         retVal = kF_ClefLine
        
    case kInst_Flute:        retVal = kG_ClefLine
    case kInst_Oboe:         retVal = kG_ClefLine
    case kInst_Clarinet:     retVal = kG_ClefLine
    case kInst_BassClarinet: retVal = kG_ClefLine
    case kInst_Bassoon:      retVal = kG_ClefLine
    case kInst_AltoSax:      retVal = kG_ClefLine
    case kInst_TenorSax:     retVal = kG_ClefLine
    case kInst_BaritoneSax:  retVal = kG_ClefLine
        
    case kInst_Trumpet:      fallthrough
    default:                 retVal = kG_ClefLine
    }
    
    return retVal
}


// E.g., the "_Trumpet" part of "UserScore_Trumpet"
func getSSTransposeForInstr(instr: Int) -> Int32 {
    var retVal : Int32 = kSSTransposeFor_Trumpet
    
    switch instr {
    case kInst_Trombone:     retVal = kSSTransposeFor_Trumpet
    case kInst_Euphonium:    retVal = kSSTransposeFor_Euphonium
    case kInst_FrenchHorn:   retVal = kSSTransposeFor_FrenchHorn
    case kInst_Tuba:         retVal = kSSTransposeFor_Tuba
        
    case kInst_Flute:        retVal = kSSTransposeFor_Flute
    case kInst_Oboe:         retVal = kSSTransposeFor_Oboe
    case kInst_Clarinet:     retVal = kSSTransposeFor_Clarinet
    case kInst_BassClarinet: retVal = kSSTransposeFor_BassClarinet
    case kInst_Bassoon:      retVal = kSSTransposeFor_Bassoon
    case kInst_AltoSax:      retVal = kSSTransposeFor_AltoSax
    case kInst_TenorSax:     retVal = kSSTransposeFor_TenorSax
    case kInst_BaritoneSax:  retVal = kSSTransposeFor_BaritoneSax
        
    case kInst_Trumpet:      fallthrough
    default:                 retVal = kSSTransposeFor_Trumpet
    }
    
    return retVal
}

func getOctaveChangeForInstr(instr: Int) -> Int {
    var retVal : Int = 0
    
    switch instr {
    case kInst_Trombone:     retVal = 0
    case kInst_Euphonium:    retVal = 0
    case kInst_FrenchHorn:   retVal = 0
    case kInst_Tuba:         retVal = 0
        
    case kInst_Flute:        retVal = 2
    case kInst_Oboe:         retVal = 2
    case kInst_Clarinet:     retVal = 0
    case kInst_BassClarinet: retVal = 0
    case kInst_Bassoon:      retVal = 0
    case kInst_AltoSax:      retVal = 0
    case kInst_TenorSax:     retVal = 0
    case kInst_BaritoneSax:  retVal = 0
        
    case kInst_Trumpet:      fallthrough
    default:                 retVal = 0
    }
    
    return retVal
}


// E.g., the "_Trumpet" part of "UserScore_Trumpet"
func getScoreFileSubNameForCurrInstr() -> String {
    let retStr = getScoreFileSubNameForInstr(instr: gCurrentInstrument)
    return retStr
}

//////////////////////////////////////////////////////////////////////
// MARK:- Per-instrument LongTone related funcs

func getLongToneExerNote(origNoteStr: String) -> String {
    // CHANGEHERE - don't quickly remember what this does . . .
    
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

//////////////////////////////////////////////////////////////////////
// MARK:- Per-instrument Range-related funcs

func getFirstNoteForCurrentInstrument() -> Int {
    // CHANGEHERE

    var retVal = 55  // G3 == 55
    
    switch gCurrentInstrument {
    case kInst_Trombone:     retVal = 39    // Eb2 == 39
    case kInst_Euphonium:    retVal = 39    // Eb2 == 39
    case kInst_FrenchHorn:   retVal = 47    // B2  == 47
    case kInst_Tuba:         retVal = 27    // Eb1 == 27

    case kInst_Flute:        retVal = 27    // Eb1 == 27 - FIXME
    case kInst_Oboe:         retVal = 27    // Eb1 == 27 - FIXME
    case kInst_Clarinet:     retVal = 55    // G3  == 55 - FIXME ?
    case kInst_BassClarinet: retVal = 27    // Eb1 == 27 - FIXME
    case kInst_Bassoon:      retVal = 39    // Eb2 == 39 - FIXME ?
    case kInst_AltoSax:      retVal = 27    // Eb1 == 27 - FIXME
    case kInst_TenorSax:     retVal = 27    // Eb1 == 27 - FIXME
    case kInst_BaritoneSax:  retVal = 27    // Eb1 == 27 - FIXME

    case kInst_Trumpet:      fallthrough
    default:                 retVal = 55    // G3 == 55
    }
    return retVal
}

func getNoteOffsetForCurrentInstrument() -> Int {
    // CHANGEHERE
    var retVal = 60
    
    switch gCurrentInstrument {
    case kInst_Trombone:     retVal = 39    // Eb2 == 39
    case kInst_Euphonium:    retVal = 39    // Eb2 == 39
    case kInst_FrenchHorn:   retVal = 47    // B2  == 47
    case kInst_Tuba:         retVal = 27    // Eb1 == 27
        
    case kInst_Flute:        retVal = 27    // Eb1 == 27 - FIXME
    case kInst_Oboe:         retVal = 27    // Eb1 == 27 - FIXME
    case kInst_Clarinet:     retVal = 60    // C4  == 60 - FIXME ?
    case kInst_BassClarinet: retVal = 27    // Eb1 == 27 - FIXME
    case kInst_Bassoon:      retVal = 39    // Eb2 == 39 - FIXME ?
    case kInst_AltoSax:      retVal = 27    // Eb1 == 27 - FIXME
    case kInst_TenorSax:     retVal = 27    // Eb1 == 27 - FIXME
    case kInst_BaritoneSax:  retVal = 27    // Eb1 == 27 - FIXME
        
    case kInst_Trumpet:      fallthrough
    default:                 retVal = 60    // C4 == 60
    }
    return retVal
}
