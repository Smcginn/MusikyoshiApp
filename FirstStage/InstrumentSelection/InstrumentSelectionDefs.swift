//
//  InstrumentSelectionDefs.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/21/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

let kInst_Trumpet: Int      = 0
let kInst_Trombone: Int     = 1
let kInst_Euphonium: Int    = 2
let kInst_FrenchHorn: Int   = 3
let kInst_Tuba: Int         = 4

// sub directories, of bundles paths, for each instrument
let kTrumpetSubDir      = "Trumpet/"
let kTromboneSubDir     = "Trombone/"
let kEuphoniumSubDir    = "Trombone/"
let kFrenchHornSubDir   = "FrenchHorn/"
let kTubaSubDir         = "Tuba/"

// specific to Video directories
let kBrassVideos        = "/brass"
let kNoSpecificVideos   = ""

// - pitchTranspose: as varies from note pitch in score, E.g., Bb Trumpet will
//     be -2 (the note is written as C, but the pitch is Bb)
// - dir fields: appended to bundle path to locate instrument-specific files
// - baseVideoLibraryDir: where to look for a video if not found in
//     primaryVideoLibraryDir. For example, Base Brass videos will use the term
//     "fingering", and this will apply to all but trombone. Trombone will have
//     a few videos that use the term "slide position" instead of "fingering",
//     and the app should look in the Trombone dir first if Trombone.
// ToDo:
//    Partials offset?
struct InstrumentSettings {
    var pitchTranspose:         Int
    var xmlDir:                 String
    var toneLibraryDir:         String
    var primaryVideoLibraryDir: String
    var baseVideoLibraryDir:    String

    init( pitchTranspose:           Int,
          xmlDir:                   String,
          toneLibraryDir:           String,
          primaryVideoLibraryDir:   String,
          baseVideoLibraryDir:      String ) {
        self.pitchTranspose         = pitchTranspose
        self.xmlDir                 = xmlDir
        self.toneLibraryDir         = toneLibraryDir
        self.primaryVideoLibraryDir = primaryVideoLibraryDir
        self.baseVideoLibraryDir    = baseVideoLibraryDir
    }
}


let kTrumpetInstrumentSettings =
    InstrumentSettings( pitchTranspose:         -2,
                        xmlDir:                 kTrumpetSubDir,
                        toneLibraryDir:         kTrumpetSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos )

let kTromboneInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        xmlDir:                 kTromboneSubDir,
                        toneLibraryDir:         kTromboneSubDir,
                        primaryVideoLibraryDir: kTromboneSubDir,
                        baseVideoLibraryDir:    kBrassVideos )

// Euphonium uses Trombone XML files and samples, but basic brass vids
let kEuphoniumInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        xmlDir:                 kTromboneSubDir,
                        toneLibraryDir:         kTromboneSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos )

let kFrenchHornInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        xmlDir:                 kFrenchHornSubDir,
                        toneLibraryDir:         kFrenchHornSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos )

let kTubaInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        xmlDir:                 kTubaSubDir,
                        toneLibraryDir:         kTubaSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos )


var gCurrentInstrument = kInst_Trumpet
var gInstrumentSettings: InstrumentSettings = kTrumpetInstrumentSettings

func setCurrentInstrument( instrument: Int ) {
    gCurrentInstrument = instrument
    UserDefaults.standard.set(
        Int(gCurrentInstrument),
        forKey: Constants.Settings.StudentInstrument)

    switch instrument {
    case kInst_Trombone:     gInstrumentSettings = kTromboneInstrumentSettings
    case kInst_Euphonium:    gInstrumentSettings = kEuphoniumInstrumentSettings
    case kInst_FrenchHorn:   gInstrumentSettings = kFrenchHornInstrumentSettings
    case kInst_Tuba:         gInstrumentSettings = kTubaInstrumentSettings
        
    case kInst_Trumpet:      fallthrough
    default:            gInstrumentSettings = kTrumpetInstrumentSettings
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
