//
//  PerformanceAnalysisMgr.swift
//  FirstStage
//
//  Created by Scott Freshour on 11/30/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import Foundation

let kMinCalcedRhthymTolSetting: Int = 0
let kMaxCalcedRhthymTolSetting: Int = 10
var gCalcedRhthymTolSetting:    Int = 0

///////////////////////////////////////////////////////////////////////////////
//  TODO: eventually . . .
//      enum of instruments, includes transpose offsets, etc.
//      enum of levels, with Pitch and Rhythm tolerance percentages for each
//

let kMKDebugOpt_PrintPerfAnalysisValues = false

struct pitchAndRhythmTolerances {
    /////////////////////////////////////////////////////////////////////////////
    // This struct is a param for rebuildAllAnalysisTables(), which rebuilds the
    // tables used for Performance Analysis. To be more or less forgiving when
    // grading a lesson level, set these pitch and rhythm percentages accordingly.
    /////////////////////////////////////////////////////////////////////////////
    
    /////////////////////////////////////////////////////////////////////////////
    // How forgiving is the app when grading rhythmic accuracy? This is the
    // fraction of a second on either side of the expected attack time that is 
    // still acceptable.)
    var rhythmTolerance: Double   // SLIDERABLE
    
    /////////////////////////////////////////////////////////////////////////////
    // There are five zones for grading pitch where the performed pitch is still
    // considered to be the desired note. These are determined by adjustable 
    // percentages, shown below. Initially they are set up to be very forgiving 
    // (the percentages are large, so the ranges are wide). As the student achieves
    // mastery of attaining correct pitch, these percentages tighten (get closer 
    // to 0%).
    //
    //   ---------------------------------------------------------------------
    //  |   Very Low  |  A Bit Low  |   Correct   |  A Bit High |   Very High |
    //  |     Zone    |    Zone     |     Zone    |    Zone     |     Zone    |
    //  | loFr...hiFr | loFr...hiFr | loFr...hiFr | loFr...hiFr | loFr...hiFr |
    //   ---------------------------------------------------------------------
    //  ^             ^             ^      ^      ^             ^             ^
    //  |             |             |      |      |             |             |
    //  |             |             |    target   |             |             |
    //  |             |             |     freq    |             |             |
    //  |             |             |             |             |             |
    //  |             |      -targetPitchPC   +targetPitchPC    |             | 
    //  |             |                                         |             |
    //  |        -aBitToVeryPC                           +aBitToVeryPC        |
    //  |                                                                     |
    // -veryBoundaryPC                                              +veryBoundaryPC
    
    // % above or below target pitch to be considered still in the "correct" zone
    var correctPitchPC: Double     // uses 0.97 vs 0.03, 0.98 vs 0.02, etc.   // SLIDERABLE
    
    // Used to define the lower bound for "a bit flat" zone, and the upper bound 
    // of the "a bit sharp" zone
    var aBitToVeryPC: Double  // SLIDERABLE
    
    // Used to define the lower bound for "very flat" zone, and the upper bound
    // of the "very sharp" zone. Outside of these two zones, the pitch is
    // considered a different note.
    var veryBoundaryPC: Double // SLIDERABLE
    
    init() {
        rhythmTolerance   = DefaultTolerancePCs.defaultRhythmTolerance
        correctPitchPC    = DefaultTolerancePCs.defaultCorrectPitchPC
        aBitToVeryPC      = DefaultTolerancePCs.defaultABitToVeryPC
        veryBoundaryPC    = DefaultTolerancePCs.defaultVeryBoundaryPC
        attackVariance_Correct  = 0.05 // assigned default values here,
        attackVariance_ABitOff  = rhythmTolerance / 2.0
        attackVariance_VeryOff  = rhythmTolerance
    }
    
    // Set using internal form (e.g., 0.97 vs 0.03)
    mutating func set( rhythmTolerance: Double,
                       correctPitchPercentage: Double,
                       aBitToVeryPercentage: Double,
                       veryBoundaryPercentage: Double ) {
        self.rhythmTolerance   = rhythmTolerance
        
//        attackVariance_Correct = 0.05
//        attackVariance_ABitOff = rhythmTolerance / 2.0
        
        calcTolerancesBySetting(baseRhythmTol: rhythmTolerance)
        attackVariance_Correct = calculatedCorrectBoundary
        attackVariance_ABitOff = calculatedABitLateBoundary
        attackVariance_VeryOff = rhythmTolerance

        self.correctPitchPC    = correctPitchPercentage
        self.aBitToVeryPC      = aBitToVeryPercentage
        self.veryBoundaryPC    = veryBoundaryPercentage
    }
    
    // Converts percentages to the form used internally. Probably easier to 
    // visualize how the values will affect the frequency range.
    //   E.g.,
    //     Supply 0.03,  this will convert to 0.97
    //     Supply 0.022, this will convert to 0.978
    mutating func setWithInverse( rhythmTolerance: Double,
                                  correctPitchPercentage: Double,
                                  aBitToVeryPercentage: Double,
                                  veryBoundaryPercentage: Double ) {
        self.rhythmTolerance   = rhythmTolerance
        
//        attackVariance_Correct = 0.05
//        attackVariance_ABitOff = rhythmTolerance / 2.0
        
        calcTolerancesBySetting(baseRhythmTol: rhythmTolerance)
        attackVariance_Correct = calculatedCorrectBoundary
        attackVariance_ABitOff = calculatedABitLateBoundary
        attackVariance_VeryOff = rhythmTolerance

        self.correctPitchPC    = 1.0 - correctPitchPercentage
        self.aBitToVeryPC      = 1.0 - aBitToVeryPercentage
        self.veryBoundaryPC    = 1.0 - veryBoundaryPercentage
    }
    
    var calculatedCorrectBoundary: Double  = 0.0
    var calculatedABitLateBoundary: Double = 0.0
    
    // FRIDAYNIGHT
    mutating func calcTolerancesBySetting(baseRhythmTol: Double) {
        switch gCalcedRhthymTolSetting {
        case 10:
            calculatedCorrectBoundary  = 0.1
            calculatedABitLateBoundary = baseRhythmTol / 2.0
        case 9:
            calculatedCorrectBoundary  = 0.095
            calculatedABitLateBoundary = baseRhythmTol / 2.0
        case 8:
            calculatedCorrectBoundary  = 0.09
            calculatedABitLateBoundary = baseRhythmTol / 2.0
        case 7:
            calculatedCorrectBoundary  = 0.085
            calculatedABitLateBoundary = baseRhythmTol / 2.0
        case 6:
            calculatedCorrectBoundary  = 0.08
            calculatedABitLateBoundary = baseRhythmTol / 2.0
        case 5:
            calculatedCorrectBoundary  = 0.075
            calculatedABitLateBoundary = baseRhythmTol / 2.0
        case 4:
            calculatedCorrectBoundary  = 0.07
            calculatedABitLateBoundary = baseRhythmTol / 2.0
        case 3:
            calculatedCorrectBoundary  = 0.065
            calculatedABitLateBoundary = baseRhythmTol / 2.0
        case 2:
            calculatedCorrectBoundary  = 0.06
            calculatedABitLateBoundary = baseRhythmTol / 2.0
        case 1:
            calculatedCorrectBoundary  = 0.055
            calculatedABitLateBoundary = baseRhythmTol / 2.0
        default: // case 0
            calculatedCorrectBoundary  = 0.05
            calculatedABitLateBoundary = baseRhythmTol / 2.0
        }
    }
    
    
    
    
}

struct PerfAnalysisDefs {
    // These are, for now, after discussions with Shawn, the range for Alpha. 
    // These are for Trumpet (with some room on either end) according to Shawn's 
    // docs. In future, the tables should be built to include all possible notes for
    //    1) All possible instruments,    or
    //    2) Just the range for the current instrument
    static let kFirstTableNoteId = NoteIDs.F3  // first noteID for building tables
    static let kLastTableNoteId  = NoteIDs.C6  // last  noteID for building tables
    static let kTableNoteIdRange = kFirstTableNoteId...kLastTableNoteId
    static let kNumTableIDs =  // tables will have this many members
        Int((PerfAnalysisDefs.kLastTableNoteId-PerfAnalysisDefs.kFirstTableNoteId)+1)
}

class PerformanceAnalysisMgr {
    
    // Central point for managing post-performance analysis of pitch and rhythm 
    // accuracy, including the tables of frequency ranges, criteria for determining 
    // pitch accuracy (and the various frequencies for different zones of acceptance), 
    // and instrument-specific issues such as trumpet partials; also manages
    // rebuilding these tables if the tolereance changes due to proceeding deeper
    // into lessons (and therefore should be able to hit pitches beeter.
    
    static let instance = PerformanceAnalysisMgr()
    
    var noteFreqRangeTable = NoteFreqRangeTable()

    var notePitchAnlsysCritTable = NotePitchAnalysisCriteriaTable()

    ///////////////////////////////////////////////////////////////////////////
    // TODO: The trumpetPartialsTable below is Trumpet-specific.
    //
    //  When there is time, there should be a scheme involving a base class (or
    //  protocol extension)  for "Instrument Specific Criteria", with derived
    //  classes (or protocol implementations, etc.) for each individual instrument.
    //
    //  Part of the problem is that doing the checks for each Instrument probably
    //  involves completely different issues possibly to be invoked at different
    //  times within the overall note pitch analysis, so having a specific slot
    //  for "DoInstrumentSpecificChecks_Now" will be hard to define, as will
    //  "TablesForInstrumentSpecificChecking".
    //
    //  So: TrumpetPartials is implemented directly here for Alpha, but needs
    //  to be redesigned for Beta and onward.
    var trumpetPartialsTable = TrumpetNotePartialsTable()
    
    var tablesBuilt = false;
    
    init() {
//        resetTranspoitionOffset()
    }
    
    func printThresholdsInUse() {
        print("\n--------------------------------------------")
        print("Tolerances in use by PerformanceAnalysisMgr:")
        print("  correctPitchPC:            \(currTolerances.correctPitchPC)")
        print("  aBitToVeryPC:              \(currTolerances.aBitToVeryPC)")
        print("  veryBoundaryPC:            \(currTolerances.veryBoundaryPC)")
        print("  rhythmTolerance - correct: \(attackVariance_Correct)")
        print("  rhythmTolerance - a bit:   \(attackVariance_ABitOff)")
        print("  rhythmTolerance - very:    \(attackVariance_VeryOff)")
        print("  rhythmTolerance - base:    \(currTolerances.rhythmTolerance)")
        print("  Ejector Seat:      \(kStopPerformanceThreshold)")
        print("--------------------------------------------\n")
    }
    
    func getNotePitchAnalyzer() {}
    func getNoteRhythmAnalyzer() {}
    
    // Store the percentages for each zone used for the current build of the tables
    var currTolerances = pitchAndRhythmTolerances()
    
    func rebuildAllAnalysisTables(_ prTols: pitchAndRhythmTolerances = pitchAndRhythmTolerances()) {
        
        currTolerances = prTols
        
        noteFreqRangeTable.rebuildTable( tolerancePercent: currTolerances.correctPitchPC )
        notePitchAnlsysCritTable.rebuildTable( tolPercents: currTolerances,
                                               noteFreqRngTable: noteFreqRangeTable )
        
        tablesBuilt = true
        
        // Testing, debugging
        testPartials()
        if kMKDebugOpt_PrintPerfAnalysisValues {
            notePitchAnlsysCritTable.printAllPitchAnalysisCritera()
        }
    }
    
    // returns the "Correct" freq zone range for a given note
    func getNoteFreqRangeData( noteID: NoteID ) -> tNoteFreqRangeData {
        if !tablesBuilt { // tables are lazy-built; need to be created before this call
            let tols = pitchAndRhythmTolerances() // use default vals
            rebuildAllAnalysisTables( tols )
        }
        return noteFreqRangeTable.getNoteFreqRangeData( noteID: noteID)
    }
    
    // returns All freq zone ranges for a given note
    func getNotePitchAnalysisCriteria( noteID: NoteID ) -> NotePitchAnalysisCriteria {
        if !tablesBuilt {
            let tols = pitchAndRhythmTolerances() // use default vals
            rebuildAllAnalysisTables( tols )
        }
        return notePitchAnlsysCritTable.getPitchAnalysisCriteria( noteID: noteID)
    }
    
    // Is this frequency an (accidentally played) overtone of the target note?
    //  freq:   the actual frequency played.
    //  noteID: This is the expected transposed note (not the expected concert note)
    //  return value: isPartialRetVal is a tuple of Bool and tNoteFreqRangeData
    func isThisFreqAPartialOfThisNote(freq: Double, noteID: NoteID)
        -> isPartialRetVal {
        if !tablesBuilt {
            let tols = pitchAndRhythmTolerances() // use default vals
            rebuildAllAnalysisTables( tols )
        }
        return trumpetPartialsTable.isThisFreqAPartialOfThisNote( freq: freq,
                                                                  note: noteID )
    }
    
    // If working with a transposing instrument . . .
    var haveSetTransOffset = false
    private var transpositionOffset: Int = 0
    func getTranspositionOffset() -> Int {
        if !haveSetTransOffset {
            resetTranspoitionOffset()
            haveSetTransOffset = true
        }
        return transpositionOffset
    }
    
    func resetTranspoitionOffset() {
        // This won't happen for Alpha, but if a different Instrument is selected,
        // it may or may not be transposing, and in either case might have a different
        // transposition offset. So this needs to be reset for the code that goes
        // back and forth from the Concert Pitch world and the Transposed Pitch world.
        // Maybe some sort of KVO observer calls this? 
        transpositionOffset =
            UserDefaults.standard.integer(forKey: Constants.Settings.Transposition)
    }

    ///////////////////////////////////////////////////////////////////////////
    //
    //    For Debugging and Testing from here to end of class
    //
    ///////////////////////////////////////////////////////////////////////////
    
    func printPartialsForThisNote( noteID: NoteID )
    {
        if kMKDebugOpt_PrintPerfAnalysisValues {
            trumpetPartialsTable.printPartialsForThisNote( noteID: noteID )
        }
    }
    
    func testPartials() {
        var isPartRV =
            trumpetPartialsTable.isThisFreqAPartialOfThisNote(freq: 196.0, // g3
                                                              note: NoteIDs.E4)
        
        if kMKDebugOpt_PrintPerfAnalysisValues {
            if isPartRV.isPartial {
                print ("Partial Test: \(isPartRV.partial.noteFullName) is a partial of \(NoteIDs.E4)" )
            } else {
                print ("Partial Test: 196Hz is not a partial of \(NoteIDs.Bb4)" )
            }
        }
        
        isPartRV = trumpetPartialsTable.isThisFreqAPartialOfThisNote(freq: 392.0, // g4
                                                                     note: NoteIDs.E4)
        if kMKDebugOpt_PrintPerfAnalysisValues {
            if isPartRV.isPartial {
                print ("Partial Test: \(isPartRV.partial.noteFullName) is a partial of \(NoteIDs.E4)" )
            } else {
                print ("Partial Test: 392Hz is not a partial of \(NoteIDs.Bb4)" )
            }
        }
        
        isPartRV = trumpetPartialsTable.isThisFreqAPartialOfThisNote(freq: 233.0, // Bb3
                                                                     note: NoteIDs.G5)
        if kMKDebugOpt_PrintPerfAnalysisValues {
            if isPartRV.isPartial {
                print ("Partial Test: \(isPartRV.partial.noteFullName) is a partial of \(NoteIDs.F5)" )
            } else {
                print ("Partial Test: 233Hz is not a partial of \(NoteIDs.F5)" )
            }
        }
    }
}
