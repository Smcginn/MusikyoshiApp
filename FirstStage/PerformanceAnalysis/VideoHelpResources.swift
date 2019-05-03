//
//  VideoHelpResources.swift
//  FirstStage
//
//  Created by Scott Freshour on 1/5/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

///////////////////////////////////////////////////////////////////////////
//
//  Video Resource Management
//
///////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////
//
// As the number of videos grows, so will this file.
//
//   (It's sparse now b/c at this point there are only 3 vids, one covering 
//   two topics.)
//
// A future feature to add:
//   For many issues detected, there will be more than one video available. The
//   intent is to be able to offer different advice if one suggestion isn't
//   helping, but also to no barage the student with all of the advice at one
//   time (in a single video).
//   So we'll need to add something that keeps track of the last video played
//   for a given issue, and cycle through the possible vids.

// MARK: - Video IDs

///////////////////////////////////////////////////////////////////////////////
// ID of video to use. Assigned When VideoDlg is ready to map an issue to a video
struct vidIDs {
    // These are ints instead of enums, because can reuse some videos for different
    // issues, so need to do defs where two IDs have the same value, like:
    //     kVid_ABitHigh_RelaxAir = kVid_ABitHigh_CheckFingering
    
    static let kVid_NoVideoAvailable         : Int   = 0
    
    static let kVid_Attack_Early_WaitABit                   : Int   =  1
    static let kVid_Attack_Late_EnterEarlier                : Int   =  2
    static let kVid_Duration_ABitShort                      : Int   =  3
    static let kVid_Duration_VeryLong_512288                : Int   =  4
    static let kVid_Duration_TooLong                        : Int   =  5
    static let kVid_Duration_TooShort                       : Int   =  6
    
    static let kVid_Pitch_ABitHigh_CheckFingering           : Int   =  7
    static let kVid_Pitch_ABitHigh_RelaxEmbouchure          : Int   =  8
    static let kVid_Pitch_ABitHigh_SlowAirspeed             : Int   =  9
 
    static let kVid_Pitch_ABitlow_CheckFingering            : Int   = 10
    static let kVid_Pitch_ABitLow_FirmUpEmbouchure          : Int   = 11
    static let kVid_Pitch_ABitLow_SpeedUpAir                : Int   = 12
 
    static let kVid_Pitch_LowPartial_ChangeTongueArch       : Int   = 13
    static let kVid_Pitch_LowPartial_FirmUpEmbouchure       : Int   = 14
    static let kVid_Pitch_UpperPartial_RelaxEmbouchure      : Int   = 15
    static let kVid_Pitch_UpperPartial_SlowAir              : Int   = 16

    static let kVid_Pitch_VeryHigh_DoubleCheckFingering     : Int   = 17
    static let kVid_Pitch_VeryHigh_RelaxEembouchure         : Int   = 18

    static let kVid_Pitch_VeryLow_SpeedUpAir                : Int   = 19
    static let kVid_Pitch_VeryLow_CurveLipsIn               : Int   = 20
    static let kVid_Pitch_VeryLow_ResetWithBEmb_Mirror      : Int   = 21

    static let kVid_Sound_SoundDuringRest                   : Int   = 22
    static let kVid_NoSound_AreYouPlaying                   : Int   = 23
    static let kVid_NoSound_CheckMicSettings                : Int   = 24
    static let kVid_NoSound_FirmUpEmbouchure                : Int   = 25
    static let kVid_NoSound_RelaxEmbouchure                 : Int   = 26
    static let kVid_NoSound_WetLips                         : Int   = 27
}

// MARK: - external func, for mapping issue to a video to show

///////////////////////////////////////////////////////////////////////////////
// Called in post-analysis phase. Once an issue is identified, this maps the
// issue to the ID for a related video.
//     When multiple videos per issue are available, and the code is keeping
//     track of which vids have been played, this is perhaps the place to
//     determine which one to play next.
func mapPerfIssueToVideoID( _ issueCode: performanceRating ) -> Int {
    switch(issueCode) {
        
    // Attack
    case .veryEarly:            fallthrough         // NEW VIDEO NEEDED
    case .slightlyEarly:        return vidIDs.kVid_Attack_Early_WaitABit
    case .veryLate:             fallthrough        // NEW VIDEO NEEDED
    case .slightlyLate:         return vidIDs.kVid_Attack_Late_EnterEarlier
        
    // Rest related
    case .soundsDuringRest:     return vidIDs.kVid_Sound_SoundDuringRest

    // Duration
    case .tooShort:             return vidIDs.kVid_Duration_TooShort
    case .veryShort:            return vidIDs.kVid_Duration_TooShort
    case .slightlyShort:        return vidIDs.kVid_Duration_ABitShort
    case .slightlyLong:         return vidIDs.kVid_Duration_VeryLong_512288
    case .veryLong:             return vidIDs.kVid_Duration_VeryLong_512288
    case .tooLong:              return vidIDs.kVid_Duration_TooLong

    // Pitch
    case .wrongNoteFlat:        return getVeryLowIdx()
    case .slightlyFlat:         return getABitLowIdx()
    case .slightlySharp:        return getABitHighIdx()
    case .wrongNoteSharp:       return getVeryHighIdx()
        
    case .isUpperPartial:       return getUpperPartialIdx()
    case .isLowerPartial:       return getLowPartialIdx()
        
    case .noSound:              return getNoSoundIdx() // vidIDs.kVid_NoSound_AreYouPlaying

    default:                    return vidIDs.kVid_NoVideoAvailable
    }
}

// MARK: - Funcs for cycling through different videos for the same problem.

var gNoSoundIdx = vidIDs.kVid_NoSound_AreYouPlaying
func getNoSoundIdx() -> Int {
    let retIdx = gNoSoundIdx
    switch gNoSoundIdx {
    case vidIDs.kVid_NoSound_AreYouPlaying:
        gNoSoundIdx = vidIDs.kVid_NoSound_CheckMicSettings
    case vidIDs.kVid_NoSound_CheckMicSettings: fallthrough
    default:
        gNoSoundIdx = vidIDs.kVid_NoSound_AreYouPlaying
    }
    return retIdx
}

var gLowPartialIdx = vidIDs.kVid_Pitch_LowPartial_ChangeTongueArch
func getLowPartialIdx() -> Int {
    let retIdx = gLowPartialIdx
    switch gLowPartialIdx {
    case vidIDs.kVid_Pitch_LowPartial_ChangeTongueArch:
        gLowPartialIdx = vidIDs.kVid_Pitch_LowPartial_FirmUpEmbouchure
    case vidIDs.kVid_Pitch_LowPartial_FirmUpEmbouchure: fallthrough
    default:
        gLowPartialIdx = vidIDs.kVid_Pitch_LowPartial_ChangeTongueArch
    }
    return retIdx
}

var gUpperPartialIdx = vidIDs.kVid_Pitch_UpperPartial_SlowAir
func getUpperPartialIdx() -> Int {
    let retIdx = gUpperPartialIdx
    switch gUpperPartialIdx {
    case vidIDs.kVid_Pitch_UpperPartial_SlowAir:
        gUpperPartialIdx = vidIDs.kVid_Pitch_UpperPartial_RelaxEmbouchure
    case vidIDs.kVid_Pitch_UpperPartial_RelaxEmbouchure: fallthrough
    default:
        gUpperPartialIdx = vidIDs.kVid_Pitch_UpperPartial_SlowAir
    }
    return retIdx
}

var gVeryHighIdx = vidIDs.kVid_Pitch_VeryHigh_DoubleCheckFingering
func getVeryHighIdx() -> Int {
    let retIdx = gVeryHighIdx
    switch gVeryHighIdx {
    case vidIDs.kVid_Pitch_VeryHigh_DoubleCheckFingering:
        gVeryHighIdx = vidIDs.kVid_Pitch_VeryHigh_RelaxEembouchure
    case vidIDs.kVid_Pitch_VeryHigh_RelaxEembouchure: fallthrough
    default:
        gVeryHighIdx = vidIDs.kVid_Pitch_VeryHigh_DoubleCheckFingering
    }
    return retIdx
}

var gVeryLowIdx = vidIDs.kVid_Pitch_VeryLow_SpeedUpAir
func getVeryLowIdx() -> Int {
    let retIdx = gVeryLowIdx
    switch gVeryLowIdx {
    case vidIDs.kVid_Pitch_VeryLow_SpeedUpAir:
        gVeryLowIdx = vidIDs.kVid_Pitch_VeryLow_CurveLipsIn
    case vidIDs.kVid_Pitch_VeryLow_CurveLipsIn:
        gVeryLowIdx = vidIDs.kVid_Pitch_VeryLow_ResetWithBEmb_Mirror
    case vidIDs.kVid_Pitch_VeryLow_ResetWithBEmb_Mirror: fallthrough
    default:
        gVeryLowIdx = vidIDs.kVid_Pitch_VeryLow_SpeedUpAir
    }
    return retIdx
}

var gABitHighIdx = vidIDs.kVid_Pitch_ABitHigh_SlowAirspeed
func getABitHighIdx() -> Int {
    let retIdx = gABitHighIdx
    switch gABitHighIdx {
    case vidIDs.kVid_Pitch_ABitHigh_SlowAirspeed:
        gABitHighIdx = vidIDs.kVid_Pitch_ABitHigh_CheckFingering
    case vidIDs.kVid_Pitch_ABitHigh_CheckFingering:
        gABitHighIdx = vidIDs.kVid_Pitch_ABitHigh_RelaxEmbouchure
    case vidIDs.kVid_Pitch_ABitHigh_RelaxEmbouchure: fallthrough
    default:
        gABitHighIdx = vidIDs.kVid_Pitch_ABitHigh_SlowAirspeed
    }
    return retIdx
}

var gABitLowIdx = vidIDs.kVid_Pitch_ABitLow_SpeedUpAir
func getABitLowIdx() -> Int {
    let retIdx = gABitLowIdx
    switch gABitLowIdx {
    case vidIDs.kVid_Pitch_ABitLow_SpeedUpAir:
        gABitLowIdx = vidIDs.kVid_Pitch_ABitlow_CheckFingering
    case vidIDs.kVid_Pitch_ABitlow_CheckFingering:
        gABitLowIdx = vidIDs.kVid_Pitch_ABitLow_FirmUpEmbouchure
    case vidIDs.kVid_Pitch_ABitLow_FirmUpEmbouchure: fallthrough
    default:
        gABitLowIdx = vidIDs.kVid_Pitch_ABitLow_SpeedUpAir
    }
    return retIdx
}

// MARK: - URL info for a given Video ID

///////////////////////////////////////////////////////////////////////////////
// URL components for videos.
//   These can be either in-app or remote resources

// Attack

let kVidURL_Attack_Early_WaitABit
            = ("Attack - Early - wait a bit before entering_512Kbps_288p", "mp4")
let kVidURL_Attack_Late_EnterEarlier
            = ("Attack - Late - Enter earlier", "mp4")
// Duration

let kVidURL_Dur_TooShort
            = ("Duration - Too short_512Kbps_288p", "mp4")
let kVidURL_Dur_ABitShort
            = ("Duration - A bit short", "mp4")
let kVidURL_Dur_VeryLong
            = ("Duration - Very Long_512Kbps_288p", "mp4")
let kVidURL_Dur_TooLong
            = ("Duration - Too Long", "mp4")

// Pitch

let kVidURL_Pitch_VeryLow_SpeedUpAir
    = ("Pitch - Very Low - Speed up air", "mp4")
let kVidURL_Pitch_VeryLow_CurveLipsIn
    = ("Ptich - Very Low, Curve lips in_512Kbps_288p", "mp4")
let kVidURL_Pitch_Verylow_ResetWithBEmb_Mirror
    = ("Ptich - Very Low, Reset with B embouchure, use a mirror_512Kbps_288p", "mp4")

let kVidURL_Pitch_ABitlow_CheckFingering
    = ("Pitch - A bit low - check fingering", "mp4")
let kVidURL_Pitch_ABitLow_FirmUpEmbouchure
    = ("Pitch - A bit low - firm up embouchure", "mp4")
let kVidURL_Pitch_ABitLow_SpeedUpAir
    = ("Pitch - A Bit Low, Speed Up Air_512Kbps_288p", "mp4")

let kVidURL_Pitch_ABitHigh_CheckFingering
    = ("Pitch - A Bit High, check fingering_512Kbps_288p", "mp4")
let kVidURL_Pitch_ABitHigh_RelaxEmbouchure
    = ("Pitch - A Bit High, Relax embouchure_512Kbps_288p", "mp4")
let kVidURL_Pitch_ABitHigh_SlowAirspeed
    = ("Pitch - A Bit High, Slow Airspeed_512Kbps_288p", "mp4")

let kVidURL_Pitch_VeryHigh_RelaxEmbouchure
    = ("Pitch - Very High - relax embouchure_512Kbps_288p", "mp4")
let kVidURL_Pitch_VeryHigh_DoubleCheckFingering
    = ("Pitch - Very High - Double Check fingering", "mp4")

let kVidURL_PossLowPart1_FirmEmb
    = ("Pitch - Low Partial, Firm Up Embouchure_512Kbps_288p", "mp4")
let kVidURL_PossLowPart2_TongueArch
    = ("Pitch - Low Partial, Change Tongue Arch_512Kbps_288p", "mp4")

let kVidURL_PossUpPart1_RelEmb
            = ("Pitch - Upper Partial - Relax embouchure_512Kbps_288p", "mp4")
let kVidURL_PossUpPart2_SlowAir
            = ("Pitch - Upper Partial, Slow air", "mp4")

// Rest related

let kVidURL_Sound_SoundDuringRest
    = ("Sound during rest - _512Kbps_288p", "mp4")

// No Sound

let kVidURL_NoSound_AreYouPlaying
    = ("No Sound - Are You Playing_512Kbps_288p", "mp4")
let kVidURL_NoSound_CheckMicSettings
    = ("No Sound - Check Mic Settings", "mp4")

// MARK: - Called by the Video Popup, to map an ID to the actual video file

///////////////////////////////////////////////////////////////////////////////
// Called by the video popup.
func getURLForVideoID(_ vidID: Int ) -> URL? {
    var retURL: URL? = nil
    
    // For debugging, always reutrns a specific video file.
    //    retURL = Bundle.main.url( forResource:   kVidURL_Dur_TooShort.0,
    //                              withExtension: kVidURL_Dur_TooShort.1 )
    //    return retURL
    
    switch vidID {
    case vidIDs.kVid_Attack_Early_WaitABit:
        retURL = Bundle.main.url( forResource:   kVidURL_Attack_Early_WaitABit.0,
                                  withExtension: kVidURL_Attack_Early_WaitABit.1 )
    case vidIDs.kVid_Attack_Late_EnterEarlier:
        retURL = Bundle.main.url( forResource:   kVidURL_Attack_Late_EnterEarlier.0,
                                  withExtension: kVidURL_Attack_Late_EnterEarlier.1 )
    case vidIDs.kVid_Attack_Early_WaitABit:
        retURL = Bundle.main.url( forResource:   kVidURL_Dur_ABitShort.0,
                                  withExtension: kVidURL_Dur_ABitShort.1 )
    case vidIDs.kVid_Attack_Late_EnterEarlier:
        retURL = Bundle.main.url( forResource:   kVidURL_Dur_ABitShort.0,
                                  withExtension: kVidURL_Dur_ABitShort.1 )
        
    case vidIDs.kVid_Duration_TooShort:
        retURL = Bundle.main.url( forResource:   kVidURL_Dur_TooShort.0,
                                  withExtension: kVidURL_Dur_TooShort.1 )
    case vidIDs.kVid_Duration_ABitShort:
        retURL = Bundle.main.url( forResource:   kVidURL_Dur_ABitShort.0,
                                  withExtension: kVidURL_Dur_ABitShort.1 )
    case vidIDs.kVid_Duration_VeryLong_512288:
        retURL = Bundle.main.url( forResource:   kVidURL_Dur_VeryLong.0,
                                  withExtension: kVidURL_Dur_VeryLong.1 )
    case vidIDs.kVid_Duration_TooLong:
        retURL = Bundle.main.url( forResource:   kVidURL_Dur_TooLong.0,
                                  withExtension: kVidURL_Dur_TooLong.1 )
        
    // Pitch - A bit high
    case vidIDs.kVid_Pitch_ABitHigh_CheckFingering:
        retURL = Bundle.main.url( forResource:   kVidURL_Pitch_ABitHigh_CheckFingering.0,
                                  withExtension: kVidURL_Pitch_ABitHigh_CheckFingering.1 )
    case vidIDs.kVid_Pitch_ABitHigh_RelaxEmbouchure:
        retURL = Bundle.main.url( forResource:   kVidURL_Pitch_ABitHigh_RelaxEmbouchure.0,
                                  withExtension: kVidURL_Pitch_ABitHigh_RelaxEmbouchure.1 )
    case vidIDs.kVid_Pitch_ABitHigh_SlowAirspeed:
        retURL = Bundle.main.url( forResource:   kVidURL_Pitch_ABitHigh_SlowAirspeed.0,
                                  withExtension: kVidURL_Pitch_ABitHigh_SlowAirspeed.1 )
        
    // Pitch - A bit low
    case vidIDs.kVid_Pitch_ABitlow_CheckFingering:
        retURL = Bundle.main.url( forResource:   kVidURL_Pitch_ABitlow_CheckFingering.0,
                                  withExtension: kVidURL_Pitch_ABitlow_CheckFingering.1 )
    case vidIDs.kVid_Pitch_ABitLow_FirmUpEmbouchure:
        retURL = Bundle.main.url( forResource:   kVidURL_Pitch_ABitLow_FirmUpEmbouchure.0,
                                  withExtension: kVidURL_Pitch_ABitLow_FirmUpEmbouchure.1 )
    case vidIDs.kVid_Pitch_ABitLow_SpeedUpAir:
        retURL = Bundle.main.url( forResource:   kVidURL_Pitch_ABitLow_SpeedUpAir.0,
                                  withExtension: kVidURL_Pitch_ABitLow_SpeedUpAir.1 )
        
    case vidIDs.kVid_Pitch_LowPartial_ChangeTongueArch:
        retURL = Bundle.main.url( forResource:   kVidURL_PossLowPart2_TongueArch.0,
                                  withExtension: kVidURL_PossLowPart2_TongueArch.1 )
    case vidIDs.kVid_Pitch_LowPartial_FirmUpEmbouchure:
        retURL = Bundle.main.url( forResource:   kVidURL_PossLowPart1_FirmEmb.0,
                                  withExtension: kVidURL_PossLowPart1_FirmEmb.1 )
 
    case vidIDs.kVid_Pitch_UpperPartial_RelaxEmbouchure:
        retURL = Bundle.main.url( forResource:   kVidURL_PossUpPart1_RelEmb.0,
                                  withExtension: kVidURL_PossUpPart1_RelEmb.1 )
    case vidIDs.kVid_Pitch_UpperPartial_SlowAir:
        retURL = Bundle.main.url( forResource:   kVidURL_PossUpPart2_SlowAir.0,
                                  withExtension: kVidURL_PossUpPart2_SlowAir.1 )
        
        
    case vidIDs.kVid_Pitch_VeryHigh_DoubleCheckFingering:
        retURL = Bundle.main.url( forResource:   kVidURL_Pitch_VeryHigh_DoubleCheckFingering.0,
                                  withExtension: kVidURL_Pitch_VeryHigh_DoubleCheckFingering.1 )
    case vidIDs.kVid_Pitch_VeryHigh_RelaxEembouchure:
        retURL = Bundle.main.url( forResource:   kVidURL_Pitch_VeryHigh_RelaxEmbouchure.0,
                                  withExtension: kVidURL_Pitch_VeryHigh_RelaxEmbouchure.1 )

    case vidIDs.kVid_Pitch_VeryLow_SpeedUpAir:
        retURL = Bundle.main.url( forResource:   kVidURL_Pitch_VeryLow_SpeedUpAir.0,
                                  withExtension: kVidURL_Pitch_VeryLow_SpeedUpAir.1 )
    case vidIDs.kVid_Pitch_VeryLow_CurveLipsIn:
        retURL = Bundle.main.url( forResource:   kVidURL_Pitch_VeryLow_CurveLipsIn.0,
                                  withExtension: kVidURL_Pitch_VeryLow_CurveLipsIn.1 )
    case vidIDs.kVid_Pitch_VeryLow_ResetWithBEmb_Mirror:
        retURL = Bundle.main.url( forResource:   kVidURL_Pitch_Verylow_ResetWithBEmb_Mirror.0,
                                  withExtension: kVidURL_Pitch_Verylow_ResetWithBEmb_Mirror.1 )
        
    case vidIDs.kVid_Sound_SoundDuringRest:
        retURL = Bundle.main.url( forResource:   kVidURL_Sound_SoundDuringRest.0,
                                  withExtension: kVidURL_Sound_SoundDuringRest.1 )
        
    case vidIDs.kVid_NoSound_AreYouPlaying:
        retURL = Bundle.main.url( forResource:   kVidURL_NoSound_AreYouPlaying.0,
                                  withExtension: kVidURL_NoSound_AreYouPlaying.1 )
    case vidIDs.kVid_NoSound_CheckMicSettings:
        retURL = Bundle.main.url( forResource:   kVidURL_NoSound_CheckMicSettings.0,
                                  withExtension: kVidURL_NoSound_CheckMicSettings.1 )

        
    default: retURL = nil
    }
    
    return retURL
}

// MARK: - Alert related: If there is no Video for an issue, an Alert is displayed

struct alertIDs {
    // TODO: implement
    //   Temporary, used until all videos are available, to be able to tell
    //   if the rest of system is working. Video window displays text
    //   saying "Video about blah, blah, blah available soon".
    
    static let kAlt_NoAlertMsgAvailable      : Int   =  0
    
    static let kAlt_MissedNote               : Int   =  1
    
    static let kAlt_LowerPartial             : Int   =  2
    static let kAlt_VeryLow                  : Int   =  3
    static let kAlt_VeryHigh                 : Int   =  4
    static let kAlt_WaveringBad              : Int   =  5
    static let kAlt_WaveringOK               : Int   =  6

    static let kAlt_ABitEarly                : Int   =  7
    static let kAlt_VeryEarly                : Int   =  8
    static let kAlt_ABitLate                 : Int   =  9
    static let kAlt_VeryLate                 : Int   = 10
    
    static let kAlt_TooShort                 : Int   = 11
    static let kAlt_VeryShort                : Int   = 12
    static let kAlt_ABitShort                : Int   = 13
    static let kAlt_ABitLong                 : Int   = 14
    static let kAlt_VeryLong                 : Int   = 15
    static let kAlt_TooLong                  : Int   = 16
    
    static let kAlt_NotesDuringRest          : Int   = 17
}

func mapPerfIssueToAlertID( _ issueCode: performanceRating ) -> Int {
    switch(issueCode) {
    case .missedNote:       return alertIDs.kAlt_MissedNote
        
    case .isLowerPartial:   return alertIDs.kAlt_LowerPartial
    case .wrongNoteFlat:    return alertIDs.kAlt_VeryLow
    case .wrongNoteSharp:   return alertIDs.kAlt_VeryHigh
    case .fluctuatingAcceptable:   return alertIDs.kAlt_WaveringBad
    case .fluctuatingReasonable:   return alertIDs.kAlt_WaveringOK

    case .slightlyEarly:    return alertIDs.kAlt_ABitEarly
    case .veryEarly:        return alertIDs.kAlt_VeryEarly
    case .slightlyLate:     return alertIDs.kAlt_ABitLate
    case .veryLate:         return alertIDs.kAlt_VeryLate
        
    case .soundsDuringRest: return alertIDs.kAlt_NotesDuringRest
        
    case .tooShort:         return alertIDs.kAlt_TooShort
    case .veryShort:        return alertIDs.kAlt_VeryShort
    case .slightlyShort:    return alertIDs.kAlt_ABitShort
    case .slightlyLong:     return alertIDs.kAlt_ABitLong
    case .veryLong:         return alertIDs.kAlt_VeryLong
    case .tooLong:          return alertIDs.kAlt_TooLong
        
    default:                return alertIDs.kAlt_NoAlertMsgAvailable
    }
}

func getMsgTextForAlertID( _ alertID: Int ) -> String {
    var retStr = ""
    
    switch(alertID) {
    case alertIDs.kAlt_MissedNote:
        retStr = "You Missed that note entirely, perhaps way too early or late"
        
    case alertIDs.kAlt_LowerPartial:
        retStr = "You're Playing a Lower Partial"
    case alertIDs.kAlt_VeryLow:
        retStr = "The Note is Very Flat"
    case alertIDs.kAlt_VeryHigh:
        retStr = "The Note is Very Sharp"
    case alertIDs.kAlt_WaveringBad:
        retStr = "The pitch fluctuates considerably, but you are hitting the note"
    case alertIDs.kAlt_WaveringOK:
        retStr = "The pitch fluctuates, but you are mostly hitting the note"

    case alertIDs.kAlt_ABitEarly:
        retStr = "You played that note a bit early"
    case alertIDs.kAlt_VeryEarly:
        retStr = "You played that note very early"
    case alertIDs.kAlt_ABitLate:
        retStr = "You played that note a bit late"
    case alertIDs.kAlt_VeryLate:
        retStr = "You played that note very late"
        
    case alertIDs.kAlt_NotesDuringRest:
        retStr = "You played one or more notes (or made a sound) during a rest"
        
    case alertIDs.kAlt_TooShort:
        retStr = "You played that note way too short"
    case alertIDs.kAlt_VeryShort:
        retStr = "You played that note very short"
    case alertIDs.kAlt_ABitShort:
        retStr = "You played that note bit short"
    case alertIDs.kAlt_ABitLong:
        retStr = "You played that note a bit long"
    case alertIDs.kAlt_VeryLong:
        retStr = "You played that note very long"
    case alertIDs.kAlt_TooLong:
        retStr = "You played that note way too long"
        
    default:  retStr = "Unknown Issue . . ."
    }
    
    return retStr
}


