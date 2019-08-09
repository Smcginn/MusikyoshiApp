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

/*
There are many demonds made by the way individual instruments are scored.
 
Some are simple:
 - Flute plays exactly as written; A C4 on the treble clef staff sounds like
   a C4 (concert pitch) when played.
 - Trombone plays as written; A C4 on the bass clef staff sounds like a C4
   when played.

Others are a little weird:
 - Trumpet plays back one whole step lower than displayed (it's a Bb instrument):
   A C4 on the treble clef staff has a Bb3 pitch
 - Clarinet is the same: A C4 on the treble clef staff plays back as a Bb3
 - Alto sax (Eb instrument), displays as a C4 on the treble clef, and plays as an Eb3

And others are ultra weird:
 - Baritone sax (Eb instrument), displays as a C4 on the treble clef, but plays as
   an Eb2 - that's almost 2 octaves lower (should be on the bass clef, I would think)

LongTone exercises are from the perspective of Trumpet (because it was the first
instrument for PlayTunes, and was at that time the only instrument). The exercises
need to be the same (or as close to as possible) for all instruments. For example,
if the first LongTone exercise for trumpet is to play a C4 (on the staff), then all
other instruments should play a C4 as well.
 
Except, that we really want is the same *pitch* across instruments. (This is almost
true. The octave might vary - e.g., flute vs bassoon - but we want all instruments
playing the same pitch, perhaps in different octaves.) The trumpet’s C4 has the concert
pitch of Bb3.  So non-transposing instruments need to show a Bb3 for the first LT
exercise. Eb instruments need to show G4 (which will sound like a Bb3.
 
So there needs to be two values so the program can react: One to say what the
relationship to Trumpet is, and another to say what the transposed concert pitch
is (to know if the student is playing the correct pitch).
 
But wait, there’s more:
 
It’s time-consuming to produce the XML files for all the exercises for al the
instruments (there are close to 300 per instrument). So where possible, some set
of files are shared between instruments.
 
In some cases, the mapping is exact - Clarinet is identical to Trumpet (both Bb,
same octave and clef), and can use its files; Bassoon is identical to Trombone
(non-transposing, same octave and clef), and can use its files; etc.).
 
In other cases, it’s just a question of a one octave difference, and/or a clef
difference. It’s possible to alter the score’s in-memory representation of the XML
document (NOT the actual on-disk file) prior to use by the target instrument,
changing the transpose setting (which affects the pitch, not the display), and the
clef used.
 
That’s what a lot of the stuff below accomplishes. These are run-time tweaks for
re-using XML files (both for TuneExercise and LongTone views).
*/

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

let kInst_Piano:        Int = 13

let kInst_LastAcceptableInst:  Int = kInst_BaritoneSax
let kInst_NumInstruments = kInst_NumBrass + kInst_NumWoodwinds

////////////////////////////////////////////////////////////////
// MARK:- "Hard-Coded" per instument settings

// run-time transpose. If the score says C4, what is the concert pitch?
let kTransposeFor_Trumpet:       Int =  -2     // (Bb instrument)
let kTransposeFor_Trombone:      Int =   0
let kTransposeFor_Euphonium:     Int =   kTransposeFor_Trombone
let kTransposeFor_FrenchHorn:    Int =  -7     // (F instrument)
let kTransposeFor_Tuba:          Int =   0

let kTransposeFor_Flute:         Int =   0
let kTransposeFor_Oboe:          Int =   0
let kTransposeFor_Clarinet:      Int =  -2     // (Bb instrument)
let kTransposeFor_BassClarinet:  Int = -14     // (Bb instrument)
let kTransposeFor_Bassoon:       Int =   0
let kTransposeFor_AltoSax:       Int =  -9     // (Eb instrument)
let kTransposeFor_TenorSax:      Int =   0  // NOT CORRECT ???  FIX
let kTransposeFor_BaritoneSax:   Int = -21     // (Eb instrument)
// CHANGEHERE - real vales for above

// sub directories, of bundles paths, for each instrument
let kTrumpetSubDir      = "Trumpet/"
let kTromboneSubDir     = "Trombone/"
let kEuphoniumSubDir    = "Trombone/"
let kFrenchHornSubDir   = "FrenchHorn/"
let kTubaSubDir         = "Tuba/"

let kFluteSubDir        = "Flute/"
let kOboeSubDir         = "Flute/"
let kClarinetSubDir     = "Trumpet/"
let kBassClarinetSubDir = "Trumpet/"   //  ??  "Tuba/"
let kBassoonSubDir      = "Trombone/"
let kAltoSaxSubDir      = "AltoSax/"
let kTenorSaxSubDir     = "TenorSax/"   // NO!  Trumpet
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
    var secondaryXmlDir:        String
    var toneLibraryDir:         String
    var primaryVideoLibraryDir: String
    var baseVideoLibraryDir:    String
    var isBrassInstrument:      Bool

    init( pitchTranspose:           Int,
          longToneTranspose:        Int,
          xmlDir:                   String,
          secondaryXmlDir:          String,
          toneLibraryDir:           String,
          primaryVideoLibraryDir:   String,
          baseVideoLibraryDir:      String,
          isBrassInstrument:        Bool) {
        self.pitchTranspose         = pitchTranspose
        self.longToneTranspose      = longToneTranspose
        self.xmlDir                 = xmlDir
        self.secondaryXmlDir        = secondaryXmlDir
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
                        secondaryXmlDir:        kTrumpetSubDir,
                        toneLibraryDir:         kTrumpetSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      true)

let kTromboneInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -14,
                        xmlDir:                 kTromboneSubDir,
                        secondaryXmlDir:        kTrumpetSubDir,
                        toneLibraryDir:         kTromboneSubDir,
                        primaryVideoLibraryDir: kTromboneSubDir,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      true )

// Euphonium uses Trombone XML files and samples, but basic brass vids
let kEuphoniumInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -14,
                        xmlDir:                 kTromboneSubDir,
                        secondaryXmlDir:        kTrumpetSubDir,
                        toneLibraryDir:         kTromboneSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      true )

let kFrenchHornInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      5,
                        xmlDir:                 kFrenchHornSubDir,
                        secondaryXmlDir:        kTrumpetSubDir,
                        toneLibraryDir:         kFrenchHornSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      true )

let kTubaInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -26,
                        xmlDir:                 kTubaSubDir,
                        secondaryXmlDir:        kTrumpetSubDir,
                        toneLibraryDir:         kTubaSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      true )

let kFluteInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      10,
                        xmlDir:                 kFluteSubDir,
                        secondaryXmlDir:        kTrumpetSubDir,
                        toneLibraryDir:         kFluteSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      false )

let kOboeInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      10,
                        xmlDir:                 kOboeSubDir,
                        secondaryXmlDir:        kTrumpetSubDir,
                        toneLibraryDir:         kOboeSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      false )

let kClarinetInstrumentSettings =
    InstrumentSettings( pitchTranspose:         -2,
                        longToneTranspose:      0,
                        xmlDir:                 kClarinetSubDir,
                        secondaryXmlDir:        kTrumpetSubDir,
                        toneLibraryDir:         kClarinetSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      false )

let kBassClarinetInstrumentSettings =
    InstrumentSettings( pitchTranspose:         -2,
                        longToneTranspose:      -12,
                        xmlDir:                 kBassClarinetSubDir,
                        secondaryXmlDir:        kTrumpetSubDir,
                        toneLibraryDir:         kBassClarinetSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      false )

let kBassoonInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -26,
                        xmlDir:                 kBassoonSubDir,
                        secondaryXmlDir:        kTrumpetSubDir,
                        toneLibraryDir:         kBassoonSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      false )

let kAltoSaxInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      7,
                        xmlDir:                 kAltoSaxSubDir,
                        secondaryXmlDir:        kTrumpetSubDir,
                        toneLibraryDir:         kAltoSaxSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      false )

let kTenorSaxInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      -26,
                        xmlDir:                 kTenorSaxSubDir,
                        secondaryXmlDir:        kTrumpetSubDir,
                        toneLibraryDir:         kTenorSaxSubDir,
                        primaryVideoLibraryDir: kNoSpecificVideos,
                        baseVideoLibraryDir:    kBrassVideos,
                        isBrassInstrument:      false )

let kBaritoneSaxInstrumentSettings =
    InstrumentSettings( pitchTranspose:         0,
                        longToneTranspose:      7, // display transpose
                        xmlDir:                 kAltoSaxSubDir,
                        secondaryXmlDir:        kTrumpetSubDir,
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

// If a files can't be found in the primary dir, this is called.
// This allows some instruments to use most of another instruments XML files,
// but have dedicated files (e.g., LongTone XML files) in the primary dir
func getXMLInstrSecondaryDirString() -> String {
    var retStr = kTrumpetSubDir
    
    switch gCurrentInstrument {
    case kInst_Trombone:     retStr = kTromboneSubDir
    case kInst_Euphonium:    retStr = kEuphoniumSubDir
    case kInst_FrenchHorn:   retStr = kFrenchHornSubDir
    case kInst_Tuba:         retStr = kTubaSubDir
        
    case kInst_Flute:        retStr = kFluteSubDir
    case kInst_Oboe:         retStr = kFluteSubDir
    case kInst_Clarinet:     retStr = kClarinetSubDir
    case kInst_BassClarinet: retStr = kBassClarinetSubDir
    case kInst_Bassoon:      retStr = kBassoonSubDir
    case kInst_AltoSax:      retStr = kAltoSaxSubDir
    case kInst_TenorSax:     retStr = kTenorSaxSubDir
    case kInst_BaritoneSax:  retStr = kAltoSaxSubDir
        
    case kInst_Trumpet:      fallthrough
    default:                 retStr = kTrumpetSubDir
    }
    
    return retStr
}

func xmlFileExistsInInstrumentDir( filename: String ) -> Bool {
    
    if let filePath = Bundle.main.path(forResource: filename,
                                       ofType: "xml") {
        let fm = FileManager.default
        if fm.fileExists(atPath: filePath) {
            return true
        }
    }
    return false
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

// For altering the cleff of the in-memory rep of the XML file
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
    case kInst_TenorSax:     retVal = kG_ClefLine   // NOT CORRECT ???  FIX
    case kInst_BaritoneSax:  retVal = kG_ClefLine
        
    case kInst_Trumpet:      fallthrough
    default:                 retVal = kG_ClefLine
    }
    
    return retVal
}

//

// For altering the per-part transpose setting of the in-memory rep of the XML file
typealias tTransDiaChrm = (diatonic: Int, chromatic: Int)
let kNoTransDiaChrmChange =  (diatonic: 0, chromatic: 0)
let kBariTransDiaChrm = (diatonic: -8, chromatic: -12)
func getTransDiaChrmForInstr(instr: Int) -> tTransDiaChrm {
    
    var retVal = kNoTransDiaChrmChange
    
    switch instr {
    case kInst_BaritoneSax:  retVal = kBariTransDiaChrm
        
    case kInst_Trumpet:      fallthrough
    default:                 retVal = kNoTransDiaChrmChange
    }
    
    return retVal
}

// Not usre these kSSTranspose values, and func below, are needed.
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
let kSSTransposeFor_AltoSax:       Int32 =  -9
let kSSTransposeFor_TenorSax:      Int32 =   0
let kSSTransposeFor_BaritoneSax:   Int32 =   0
// CHANGEHERE - real vales for above

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

// For altering the per-note octave of the in-memory rep of the XML file
func getOctaveChangeForInstr(instr: Int) -> Int {
    var retVal : Int = 0
    
    switch instr {
    case kInst_Trombone:     retVal = 0
    case kInst_Euphonium:    retVal = 0
    case kInst_FrenchHorn:   retVal = 0
    case kInst_Tuba:         retVal = 0
        
    case kInst_Flute:        retVal = 0
    case kInst_Oboe:         retVal = 0
    case kInst_Clarinet:     retVal = 0
    case kInst_BassClarinet: retVal = 0
    case kInst_Bassoon:      retVal = 0
    case kInst_AltoSax:      retVal = 0
    case kInst_TenorSax:     retVal = 0  // NOT CORRECT ???  FIX
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

// This is for the LongTone files. There are n-parts in each file, each part is
// 1 measure long, and is only on whole note. THe notes rise chromatically.
// LongTOnes view uses this method to determine which part to use to display
// the target note of the execise.
func getFirstNoteInXMLForCurrentInstrument() -> Int {
    var retVal = 55  // G3 == 55
    
    switch gCurrentInstrument {
    case kInst_Trombone:     retVal = 39    // Eb2 == 39
    case kInst_Euphonium:    retVal = 39    // Eb2 == 39
    case kInst_FrenchHorn:   retVal = 47    // B2  == 47
    case kInst_Tuba:         retVal = 27    // Eb1 == 27

    case kInst_Flute:        retVal = 55    // G3  == 55  to G5  needs to go to F6
    case kInst_Oboe:         retVal = 55    // G3  == 55
    case kInst_Clarinet:     retVal = 55    // G3  == 55 - FIXME ?
    case kInst_BassClarinet: retVal = 27    // Eb1 == 27 - FIXME
    case kInst_Bassoon:      retVal = 39    // Eb2 == 39 - FIXME ?
    case kInst_AltoSax:      retVal = 55    // G3  == 55
    case kInst_TenorSax:     retVal = 27    // Eb1 == 27 - FIXME
    case kInst_BaritoneSax:  retVal = 55 // using alto file 43    // G2  == 43 - FIXME

    case kInst_Trumpet:      fallthrough
    default:                 retVal = 55    // G3  == 55
    }
    return retVal
}

// Not sure this is needed
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
    case kInst_AltoSax:      retVal = 62    // Eb1 == 27 - FIXME
    case kInst_TenorSax:     retVal = 27    // Eb1 == 27 - FIXME
    case kInst_BaritoneSax:  retVal = 27    // Eb1 == 27 - FIXME
        
    case kInst_Trumpet:      fallthrough
    default:                 retVal = 60    // C4 == 60
    }
    return retVal
}
