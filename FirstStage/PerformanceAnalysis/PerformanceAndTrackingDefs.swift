//
//  PerformanceAndTrackingDefs.swift
//  FirstStage
//
//    Consts, enums, structs common to many files, used in numerous places.
// 
//    Or, consts we might want to tweak, so included here so easier to find,
//    instead of buried in other files.
//
//  Created by Scott Freshour on 12/11/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

/////////////////////////////////////////////////////////////////////////////
// Possible items to add to this file:
// 
// - Master "Slider" percentage that affects all other zone percentages
// - on/off switch for: detecting is Diff note when playing legato  
//

import Foundation

// Default Tolerance Percentages - these are the basis for pitch and rhythm analysis
//     (See explanatory comments for "the five pitch zones" (and the init() func) of
//     pitchAndRhythmTolerances struct of PerformanceAnalysisMgr.swift for a
//     detailed explanation of how these are used.)
struct DefaultTolerancePCs {
    static let defaultRhythmTolerance   = 0.2
    static let defaultCorrectPitchPC    = 0.97
    static let defaultABitToVeryPC      = 0.915
    static let defaultVeryBoundaryPC    = 0.05 // Shawn wants a very wide acceptance
}

////////////////////////////////////////////////////////////////////////////////
// Vars that define the attack rating zones (for both early and late) when 
// rating difference between expected attacktime and actual attack time
//    attackVariance_Correct:  diff < Correct is correct,           else
//    attackVariance_ABitOff:  diff < ABitOff is a bit late/early,  else
//    attackVariance_VeryOff:  diff < VeryOff is very late/early,   else
//                             diff > VeryOff is a missed note
//
//   -----------------------------------------------------------------------
//  |  Missed |  Very   |  A Bit  |  Correct  | A Bit   |  Very   | Missed  |
//  |   Note  |  Early  |  Early  |  Timing   | Late    |  Late   | Note    |
//   -----------------------------------------------------------------------
//            ^         ^         ^     ^     ^         ^         ^
//            |         |         |     |     |         |         |
//            |         |         |  Expected |         |         |
//            |         |-------->|   Attack  |<--------|         |
//            |-------->|         |           |         |<--------|
//   <--------|         |         | <-------> |         |         |-------->
//            |         |      Correct     Correct      |         |
//            |      ABitOff                         ABitOff      |
//         VeryOff                                             VeryOff
//
// Assigned default values here, but the actual values used are set when
// tolerances are assigned.
var attackVariance_Correct: Double = 0.05
var attackVariance_ABitOff: Double = DefaultTolerancePCs.defaultRhythmTolerance/2.0
var attackVariance_VeryOff: Double = DefaultTolerancePCs.defaultRhythmTolerance

// For weighted scoring of the severity of a performance issue
struct IssueWeight {
    
    static let kCorrect:              Int  =  0
    
    static let kSlightlyEarlyOrLate:  Int  =  3
    static let kVeryEarlyOrLate:      Int  =  6
    static let kMissed:               Int  =  9
    
    static let kSlightyLongOrShort:   Int  =  1
    static let kVeryLongOrShort:      Int  =  2
    static let kTooLongOrShort:       Int  =  3
    
    static let kSlightyFlatOrSharp:   Int  =  1
    static let kVeryFlatOrSharp:      Int  =  2
    static let kFlatOrSharpWrongNote: Int  =  5
    static let kUpperPartial:         Int  =  6
    static let kLowerPartial:         Int  =  6
    
    // Question: Does a missed note also get weighted score in pitch category?
    // E.g., if rating by pitch alone, is a missed note worse than very low? Or 
    // just ignored? (It will be rated as Missed if rating by attack score)
    // static let kPitchMissed:       Int  =  9
}

// Save samples into a collection in the sound object? (useful for debugging)
// If no, a running sum is used to determine average. (Performance improvement)
let kSavePitchSamples = false
let kNumSamplesToCollect = 300

// Signal Amplitude used to determine if an actual sound, when creating or ending
// a PerformanceSound. (The sensitivity of the mic is very different for an actual 
// iOS device vs when using the simulator - which uses the Mac's mic. So this is
// set dynamically in PerformanceTrackingMgr.init, depending on the device.)
let kAmpThresholdForIsSound_Sim = 0.05
let kAmpThresholdForIsSound_HW  = 0.01
var kAmplitudeThresholdForIsSound = kAmpThresholdForIsSound_HW

// Number of samples to let pass before before beginning to average the pitch, to
// consider it "stable". Without a little time to settle, pitch average is inaccurate
let kSamplesNeededToDeterminePitch = 10

// In legato playing: Number of consecutive samples consistantly not equal to established
// pitch before considered a different note. (One or two variants in a stable pitch is
// common, so must have a certain number in a row before commmiting to a new note.)
let kDifferentPitchSampleThreshold  = 10

// This is the apparent delay between a sound and the acquisition of the sound
// by the sound tracking code. (When the metronome is left on, this is the 
// difference between epected time and when the metronome sound registers in the 
// sample-scanning code.) Without this delay, students fight a 40ms delay to
// get the timing right.
let kSoundStartAdjustment = TimeInterval(0.040)

// Given the delay explained above (kSoundStartAdjustment), need to adjust the
// location of the beginning and end of sounds when displaying them.
let kOverlayPixelAdjustment = 4

let noNoteIDSet: Int32     =  0
let noSoundIDSet: Int32    =  0
let noTimeValueSet         =  0.0
let noPitchValueSet        =  0.0

let secsPerMin : TimeInterval = 60.0
let musicXMLUnitsPerQuarterNote : Int32 = 1000

enum InstrumentSpecificError {
    case none
    case upperPartial
    case lowerPartial
}

enum performanceRating { // for attack, duration, and pitch
    
    case notRated
    case missedNote
    
    // the associated score is the sum of the attack, duration, and pitch scores
    case cumulative
    
    // attack
    case veryEarly
    case slightlyEarly
    case timingGood
    case slightlyLate
    case veryLate
    
    // duration
    case tooShort
    case veryShort
    case slightlyShort
    case durationGood
    case slightlyLong
    case veryLong
    case tooLong
    
    // pitch
    case wrongNoteFlat
    case slightlyFlat
    case pitchGood
    case slightlySharp
    case wrongNoteSharp
    case isUpperPartial
    case isLowerPartial
    
    static func displayStringForRating( _ rating : performanceRating,
                                        ratingText: inout String ) {
        switch( rating ) {
        case .notRated:       ratingText = "?"
        case .missedNote:     ratingText = "No Note Played"
        case .cumulative:     ratingText = "?"  // this should not be called . . .
            
        // start of note accuracy
        case .veryEarly:      ratingText = "Very Early"
        case .slightlyEarly:  ratingText = "A Bit Early"
        case .timingGood:     ratingText = "Correct!"
        case .slightlyLate:   ratingText = "A Bit Late"
        case .veryLate:       ratingText = "Very Late"
            
        // duration accuracy
        case .tooShort:       ratingText = "Too Short"
        case .veryShort:      ratingText = "Very Short"
        case .slightlyShort:  ratingText = "A Bit Short"
        case .durationGood:   ratingText = "Correct!"
        case .slightlyLong:   ratingText = "A Bit Long"
        case .veryLong:       ratingText = "Very Long"
        case .tooLong:        ratingText = "Too Long"

        // pitch
        case .wrongNoteFlat:  ratingText = "Very Low"
        case .slightlyFlat:   ratingText = "A Bit Low"
        case .pitchGood:      ratingText = "Correct!"
        case .slightlySharp:  ratingText = "A Bit High"
        case .wrongNoteSharp: ratingText = "Very High"
        case .isUpperPartial: ratingText = "Upper Partial"
        case .isLowerPartial: ratingText = "Lower Partial"
        }
    }
}

// Used after post-performance analysis to determine which is the worst
// issue for all performed notes
var kPerfIssueSortCriteria: PerformanceIssueMgr.sortCriteria = .byIndividualRating

// Used during post-performance analysis to debug other issues, as it's hard to
// stop a lesson without generating a missed note at the end. 
// Must be set to false for release
var kIgnoreMissedNotes = false

///////////////////////////////////////////////////////////////////////////////
// Consts that control debug info display and printing (lots of printing) to 
// the debug console.
//
//   Do a search on "kMKDebugOpt_" for other consts, in other files, that can 
//   turn on/off debugging features. Some are in Objective C files, which can't
//   easily access this file.
//
//   In particular:
//      kMKDebugOpt_ShowNotesAnalysis           // Display on AnalysisOverlayView
//      kMKDebugOpt_ShowSoundsAnalysis          // Display on AnalysisOverlayView
//
let kMKDebugOpt_ShowDebugSettingsBtn = true

let kMKDebugOpt_PrintStudentPerformanceDataDebugOutput = false
let kMKDebugOpt_PrintStudentPerformanceDataDebugSamplesOutput = false
let kMKDebugOpt_PrintPerfAnalysisResults = false
