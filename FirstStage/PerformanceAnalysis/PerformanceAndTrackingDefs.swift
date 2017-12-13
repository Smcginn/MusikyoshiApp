//
//  PerformanceAndTrackingDefs.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/11/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import Foundation

let kMKDebugOpt_PrintStudentPerformanceDataDebugOutput = true
let kMKDebugOpt_PrintStudentPerformanceDataDebugSamplesOutput = false
let kMKDebugOpt_PrintPerfAnalysisResults = true

// Save samples into a collection in the sound object? (useful for debugging)
// If no, a running sum is used to determine average. (Performance improvement)
let kSavePitchSamples = false
let kNumSamplesToCollect = 300

// Number of samples to let pass before before beginning to average the pitch, to
// consider it "stable". Without a little time to settle, pitch average is inaccurate
let kSamplesNeededToDeterminePitch = 10

// In legato playing: Number of consecutive samples consistantly not equal to established
// pitch before considered a different note. (One or two variants in a stable pitch is
// common, so must have a certain number in a row before commmiting to a new note.)
let kDifferentPitchSampleThreshold  = 10




let noNoteIDSet : Int32    =  0
let noSoundIDSet : Int32   =  0
let noTimeValueSet         =  0.0
let noPitchValueSet        =  0.0

let secsPerMin : TimeInterval = 60.0
let musicXMLUnitsPerQuarterNote : Int32 = 1000

let kPitchIssue_SlightyFlat     = 0x0000000000000001
let kPitchIssue_SlightySharp    = 0x0000000000000001
let kPitchIssue_VeryFlat        = 0x0000000000000001
let kPitchIssue_VerySharp       = 0x0000000000000001
let kPitchIssue_WrongNote       = 0x0000000000000001
let kPitchIssue_WrongNoteInstrSpecific = 0x0000000000000001

enum InstrumentSpecificError {
    case none
    case C4_G3_LipSlur
}

enum timingRating { // for timingScore
    case notRated
    
    // attack
    case missed
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
    
    static func displayStringForRating( _ timingAccuracyRating : timingRating,
                                        ratingText: inout String ) {
        switch( timingAccuracyRating ) {
        case .notRated:       ratingText = "?"
        case .missed:         ratingText = "No Sound Match"
            
        // atart of note accuracy
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
        }
    }
}

enum pitchAccuracyRating { // for pitchRating
    case notRated
    case missedNote
    case wrongNote_InstSpecificIssue // Lip Slur, etc.
    case wrongNoteFlat
    case slightlyFlat
    case pitchVeryGood
    case slightlySharp
    case wrongNoteSharp
    
    static func displayStringForRating( _ pitchRating : pitchAccuracyRating,
                                        ratingText: inout String ) {
        switch( pitchRating ) {
        case .notRated:       ratingText = "?"
        case .missedNote:     ratingText = "No Note Played"
        case .wrongNoteFlat:  ratingText = "Very Low"
        case .slightlyFlat:   ratingText = "A Bit Low"
        case .pitchVeryGood:  ratingText = "Correct!"
        case .slightlySharp:  ratingText = "A Bit High"
        case .wrongNoteSharp: ratingText = "Very High"
        case .wrongNote_InstSpecificIssue: ratingText = "Instrument Specific Issue"
        }
    }
}
