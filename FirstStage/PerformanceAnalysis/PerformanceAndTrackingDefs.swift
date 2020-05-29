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
// SLIDERABLE ^

// For weighted scoring of the severity of a performance issue
struct IssueWeight {
    
    static let kCorrect:              Int  =  0
    
    // attack
    static let kSlightlyEarlyOrLate:  Int  =  6     // 20 // 6
    static let kVeryEarlyOrLate:      Int  =  12    // 60 // 12
    static let kMissed:               Int  =  19    // 92 // 18
    
    // pitch
    static let kSlightyFlatOrSharp:   Int  =  2     // 18 // 2
    static let kVeryFlatOrSharp:      Int  =  7     // 20 // 4

    static let kWaveringReasonable:   Int  =  4     // 18 // 2
    static let kWaveringAcceptable:   Int  =  7     // 18 // 2
    
    static let kFlatOrSharpWrongNote: Int  =  10    // 50 // 10
    
    static let kUpperPartial:         Int  =  13    // 60 // 12
    static let kLowerPartial:         Int  =  13    // 60 //12
    
    static let kNoteDuringRest:       Int  =  18    // 92 // 18

    // duration
    static let kSlightyLongOrShort:   Int  =  2     // 10 // 2
    static let kVeryLongOrShort:      Int  =  4     // 20 // 4
    static let kTooLongOrShort:       Int  =  8     // 30 // 6
    
    static let kNoSound:              Int  =  20    // 30 // 6

    // Question: Does a missed note also get weighted score in pitch category?
    // E.g., if rating by pitch alone, is a missed note worse than very low? Or 
    // just ignored? (It will be rated as Missed if rating by attack score)
    // static let kPitchMissed:       Int  =  9
}


let kLaunchVideoThreshold = Int(1) // (IssueWeight.kVeryEarlyOrLate)

enum starScoreGradation {
    case normalLenient
    case mediumLenient
    case veryLenient
}


// matched against average scores to determine start score
let kDefaultMaxScore_FourStars:  Int =  5
let kDefaultMaxScore_ThreeStars: Int =  8
let kDefaultMaxScore_TwoStars:   Int = 11
let kDefaultMaxScore_OneStars:   Int = 16

let kMediumMaxScore_FourStars:   Int =  6
let kMediumMaxScore_ThreeStars:  Int =  9
let kMediumMaxScore_TwoStars:    Int = 12
let kMediumMaxScore_OneStars:    Int = 17

let kVeryMaxScore_FourStars:     Int =  7
let kVeryMaxScore_ThreeStars:    Int = 10
let kVeryMaxScore_TwoStars:      Int = 13
let kVeryMaxScore_OneStars:      Int = 18

// SLIDERABLE ^

// Save samples into a collection in the sound object? (useful for debugging)
// If no, a running sum is used to determine average. (Performance improvement)
let kSavePitchSamples = true
let kNumSamplesToCollect = 300

//////   Signal Amplitude   ////////////////////////////
//
// Signal Amplitude used to determine if an actual sound, when creating or ending
// a PerformanceSound. (The sensitivity of the mic is very different for an actual 
// iOS device vs when using the simulator - which uses the Mac's mic. So this is
// set dynamically in PerformanceTrackingMgr.init, depending on the device.)
let kAmpThresholdForIsSound_Sim = 0.05 // 0.15  // before MicTracker: 0.07
let kAmpThresholdForIsSound_HW  = 0.100  // 0.02 before MicTracker: 0.02 ;  Mic Tracker: 0.12
var kAmplitudeThresholdForIsSound = kAmpThresholdForIsSound_HW
let kHW_to_SIM_SignalRatio = kAmpThresholdForIsSound_HW / kAmpThresholdForIsSound_Sim

let kUseDefaultHopSizeAndPeakCount = true

// Number of samples to let pass before before beginning to average the pitch, to
// consider it "stable". Without a little time to settle, pitch average is inaccurate
var gSamplesNeededToDeterminePitch = 22  // SLIDERABLE ?

// In legato playing: Number of consecutive samples consistantly not equal to established
// pitch before considered a different note. (One or two variants in a stable pitch is
// common, so must have a certain number in a row before commmiting to a new note.)
var gDifferentPitchSampleThreshold: Int  = 16 // 10   // SLIDERABLE ?

// Turn on/off use of scanning for pitch change during legato playing
var gScanForPitchDuringLegatoPlaying = true // can toggle based on levels, etc.
// "Master" swtich. Overrides gScanForPitchDuringLegatoPlaying. Set in dialog.
var gScanForPitchDuringLegatoPlayingAbsolute = false

//////   Sound Start Adjustment   ////////////////////////////
//
// This is the apparent delay between a sound and the acquisition of the sound
// by the sound tracking code. (When the metronome is left on, this is the 
// difference between epected time and when the metronome sound registers in the 
// sample-scanning code.) Without this delay, students fight a 40ms delay to
// get the timing right.
// (This timing may be different for an actual iOS device vs when using the
// simulator - which uses the Mac's mic and is running in a virtual machine, etc. So
// this is set dynamically in PerformanceTrackingMgr.init, depending on the device.)
let kSoundStartAdjustment_MinValue: Float = 0.080
let kSoundStartAdjustment_MaxValue: Float = 0.220
let kSoundStartAdjustment_Sim = TimeInterval(0.180) // (0.130) // (0.080) // (0.180)// (0.120)
let kSoundStartAdjustment_HW  = TimeInterval(0.116) // (0.175) // (0.075)
var gSoundStartAdjustment = kSoundStartAdjustment_HW

//////   Metronome Adjustment   ////////////////////////////
let kMetronomeTimingAdjustment_Sim: Int32  = -175 // -175!!!!! // -170
let kMetronomeTimingAdjustment_HW:  Int32  = -100 // -175
var kMetronomeTimingAdjustment:     Int32  = kMetronomeTimingAdjustment_Sim

//////   Playback Volume   ////////////////////////////
let kPlaybackVolume_Sim: Double  = 0.0
let kPlaybackVolume_HW:  Double  = 1.0
var kPlaybackVolume:     Double  = kPlaybackVolume_HW

var gRunningInSim           = true

// Given the delay explained above (gSoundStartAdjustment), need to adjust the
// location of the beginning and end of sounds when displaying them.
let kOverlayPixelAdjustment = 4

let noScoreObjIDSet: Int32 =  0  // Score object: Note or Rest
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

enum performanceRating: Int { // for attack, duration, and pitch
    
    case notRated               =  0
    case missedNote             =  1
    
    // the associated score is the sum of the attack, duration, and pitch scores
    case cumulative             =  2
    
    // attack
    case veryEarly              =  3
    case slightlyEarly          =  4
    case timingOrRestGood       =  5
    case slightlyLate           =  6
    case veryLate               =  7
    
    case soundsDuringRest       =  8 // Only applies to rests. One or more sounds...
    
    // duration
    case tooShort               =  9
    case veryShort              = 10
    case slightlyShort          = 11
    case durationGood           = 12
    case slightlyLong           = 13
    case veryLong               = 14
    case tooLong                = 15
    
    // pitch
    case wrongNoteFlat          = 16
    case slightlyFlat           = 17
    case pitchGood              = 18
    case slightlySharp          = 19
    case wrongNoteSharp         = 20
    case isUpperPartial         = 21
    case isLowerPartial         = 22
    case fluctuatingReasonable  = 23
    case fluctuatingAcceptable  = 24

    case noSound                = 25
    
    static func displayStringForRating( _ rating : performanceRating,
                                        ratingText: inout String ) {
        switch( rating ) {
        case .notRated:       ratingText = "?"
        case .missedNote:     ratingText = "No Note Played"
        case .cumulative:     ratingText = "?"  // this should not be called . . .
            
        // start of note accuracy
        case .veryEarly:      ratingText = "Very Early"
        case .slightlyEarly:  ratingText = "A Bit Early"
        case .timingOrRestGood: ratingText = "Correct!"
        case .slightlyLate:   ratingText = "A Bit Late"
        case .veryLate:       ratingText = "Very Late"
        case .soundsDuringRest: ratingText = "Note over Rest"

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
        case .noSound:        ratingText = "No Sound"
        case .fluctuatingReasonable: ratingText = "Wavering OK"
        case .fluctuatingAcceptable: ratingText = "Wavering Bad"
       }
    }
}

// Used after post-performance analysis to determine which is the worst
// issue for all performed notes
var gPerfIssueSortCriteria: PerformanceIssueMgr.sortCriteria = .byIndividualRating
var gTesterDidOverridePerfIssueSortCriteria = false
func setPerfIssueSortCriteria(sortCrit: PerformanceIssueMgr.sortCriteria) {
    gPerfIssueSortCriteria = sortCrit
    print("\n  Just set gPerfIssueSortCriteria to \(gPerfIssueSortCriteria)\n")
}

// Used during post-performance analysis to debug other issues, as it's hard to
// stop a lesson without generating a missed note at the end. 
// Must be set to false for release
var kIgnoreMissedNotes = false

// "Ejector Seat". This is the error threshold that a given note or rest cannot
// exceed within a Tune or Rhythm exercise. If it does, the exercise is stopped
// and the student is notified of the error immediately.
let kStopPerformanceThresholdDefault: UInt = 5
let kStopPerformanceThresholdMax: UInt = 100
let kStopPerformanceThresholdNoStop = kStopPerformanceThresholdMax
var kStopPerformanceThreshold: UInt = kStopPerformanceThresholdDefault
var doEjectorSeat = false
// SLIDERABLE ^

// Severity -  How bad is the issue. Used to determine color of pulsing circle,
// Line colors for note display, and perhaps Text in the Video or Alert dialogs.
let kYellowSeverityThreshold = 10
let kGreenSeverityThreshold  =  6
let kSeverityNone     = 0
let kSeverityGreen    = 0
let kSeverityYellow   = 1
let kSeverityRed      = 2
// SLIDERABLE ^

///////////////   Weighted pitch score /////////////////////////

// For beginning Tuba, for example. Instead of calculating
// average pitch, this involves detecting the percentage of the time the student
// plays the correct pitch during the performance. (Also considers percentage
// playing in zones "near" the note, with lower weights, etc.)
var gUseWeightedPitchScore = true
// Ranges/Zones
let kWeightedPitch_NoteMatch_TolRange:        Double = 0.03
let kWeightedPitch_NoteBitLowHigh_TolRange:   Double = 0.045 // 0.06
let kWeightedPitch_NoteQuiteLowHigh_TolRange: Double = 0.08  // 0.13
// Weights, for hits within the different zones
let kWeightedPitch_NoteMatch_Weight:          Double = 1.0
let kWeightedPitch_NoteBitLowHigh_Weight:     Double = 0.65
let kWeightedPitch_NoteQuiteLowHigh_Weight:   Double = 0.4
// Percentage thresholds for scoring overall weighted score
let kWeightedPitch_Threshold_Correct:         Double = 0.75
let kWeightedPitch_Threshold_Reasonable:      Double = 0.60
let kWeightedPitch_Threshold_Acceptable:      Double = 0.35
// If the weighted pitch isn't the correct pitch, then need to check for partials.
// To do that, see if there is a most common note played (other than the target).
// To do *that*, see if *some* note was played a reasonable pecntage of the time.
let kWeightedPitch_MostCommonNotePlayedThreshold: Double = 0.6

// Student must have played at least this much of the time to not get Wrong Note
// (Will still not be correct, but gets different msg)
let kCorrectNotePlayedPercThreshold:          Double = 0.40

func noteIsEighthOrLess(dur: Double) -> Bool {
    let currBPM = getCurrBPM()
    let bpmRatio = 60.0 / currBPM
    let adjDur = dur / bpmRatio
    
    if adjDur <= 0.502 {
        return  true
    } else {
        return false
    }
}

let kTryAdjstWeights = true
let kWtMult = 1.5
func calcedWeightedPitch_Threshold_Correct(isEighth: Bool) -> Double {
    
    if isEighth && kTryAdjstWeights {
        let currBPM = getCurrBPM()
        let bpmRatio = 60.0 / currBPM
        let multValue = kWeightedPitch_Threshold_Correct * bpmRatio
        let calcedThreshold_Correct =
            ((kWtMult * kWeightedPitch_Threshold_Correct) + multValue) / (kWtMult + 1.0)
        
        print("*****>>>>> At \(currBPM) BPM, kWeightedPitch_Threshold_Correct = \(kWeightedPitch_Threshold_Correct), calcedThreshold_Correct = \(calcedThreshold_Correct)")
    
        return calcedThreshold_Correct
    } else {
        return kWeightedPitch_Threshold_Correct
    }
}

//var gWeightedPitch_Threshold_Reasonable: Double {
func calcedWeightedPitch_Threshold_Reasonable(isEighth: Bool) -> Double {
    if isEighth && kTryAdjstWeights {
        let currBPM = getCurrBPM()
        let bpmRatio = 60.0 / currBPM
        let multValue = kWeightedPitch_Threshold_Reasonable * bpmRatio
        let calcedThreshold_Reasonable =
            ((kWtMult * kWeightedPitch_Threshold_Reasonable) + multValue) / (kWtMult + 1.0)
        
        print("*****>>>>> At \(currBPM) BPM, kWeightedPitch_Threshold_Reasonable = \(kWeightedPitch_Threshold_Reasonable), calcedThreshold_Reasonable = \(calcedThreshold_Reasonable)")
        
        return calcedThreshold_Reasonable
    } else {
        return kWeightedPitch_Threshold_Reasonable
    }
}

//var gWeightedPitch_Threshold_Acceptable: Double {
func calcedWeightedPitch_Threshold_Acceptable(isEighth: Bool) -> Double {
    if isEighth && kTryAdjstWeights {
        let currBPM = getCurrBPM()
        let bpmRatio = 60.0 / currBPM
        let multValue = kWeightedPitch_Threshold_Acceptable * bpmRatio
        let calcedThreshold_Accecptable =
            ((kWtMult * kWeightedPitch_Threshold_Acceptable) + multValue) / (kWtMult + 1.0)
        
        print("*****>>>>> At \(currBPM) BPM, kWeightedPitch_Threshold_Acceptable = \(kWeightedPitch_Threshold_Acceptable), calcedThreshold_Accecptable = \(calcedThreshold_Accecptable)")
        
        return calcedThreshold_Accecptable
    } else {
        return kWeightedPitch_Threshold_Acceptable
    }
}


/////////////////////////////////////////////////////////////////////////
//  Video help, or not
//
let kVideoHelpMode_Video        = 0
let kVideoHelpMode_Text         = 1
let kVideoHelpMode_None         = 2
var gVideoHelpMode = kVideoHelpMode_Video
func getVideoHelpMode() -> Int { return gVideoHelpMode }
func setVideoHelpMode(newMode: Int) { gVideoHelpMode = newMode }

// For some instruments (Mallet) we don't want to show the videos, as they are too
// specific to woodwinds or brass.
var gUseTextNotVideoScore = false

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

// Debug buttons on Home Screen
var gMKDebugOpt_IsSoundAndLatencySettingsEnabled = false
var gMKDebugOpt_HomeScreenDebugOptionsEnabled = false

var gMKDebugOpt_ShowDebugSettingsBtn = true   // To turn "DebugMode" on
var gMKDebugOpt_SendPerfDataEnabled = false
var gMKDebugOpt_ShowSlidersBtn = false
var gMKDebugOpt_ShowFakeScoreInLTAlert = false
var gMKDebugOpt_ShowResetBtnInMicCalibScene = false
var gMKDebugOpt_TestVideoViewInLessonOverview = false

let kMKDebugOpt_PrintStudentPerformanceDataDebugOutput = false
let kMKDebugOpt_PrintStudentPerformanceDataDebugSamplesOutput = false
let kMKDebugOpt_PrintPerfAnalysisResults = false
let kMKDebugOpt_PrintMinimalNoteAndSoundResults = true
var kMKDebugOpt_PrintMinimalNoteAnalysis        = true

let kDoPrintAmplitude = true
let kDoPrintFrequency = true
let kAmplitudePrintoutMultiplier_Sim =  12.0
let kAmplitudePrintoutMultiplier_HW  =  70.0
var gAmplitudePrintoutMultiplier = kAmplitudePrintoutMultiplier_Sim

var gDoAmplitudeRiseChecking = true

let kMinEighthIsSoundThreshold: Double = 0.01
let kMaxEighthIsSoundThreshold: Double = 0.7 // 0.15 // 0.4
let kEighthIsSoundThresholdOff: Double = 0.03 // on/off.  Lower than this val == off

// Alternative to gIsSoundThreshold, for the end of notes only. This will
// cause a new sound to be generated if the level drops below this.
// Only used at end of note, if note is eighth and fast tempo
var gEighthIsSoundThreshold = kMinEighthIsSoundThreshold
var gUseEighthIsSoundThresholdInGeneral = false
let gUseEighthIsSoundThresholdNow = AtomicInteger()
// Any duration less than this will use gEighthIsSoundThreshold
let kEighthIsSoundThresholdDurationCutoff = 0.4

var gNumAccidentalsInScore: Int = 0
