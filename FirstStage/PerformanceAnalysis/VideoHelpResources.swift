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

///////////////////////////////////////////////////////////////////////////////
// ID of video to use. Assigned at post-performance analysis time.
struct vidIDs {
    // These are ints instead of enums, because can reuse some videos for different
    // issues, so need to do defs where two IDs have the same value, like:
    //     kVid_ABitHigh_RelaxAir = kVid_ABitHigh_CheckFingering
    
    static let kVid_NoVideoAvailable         : Int   = 0
    
    static let kVid_UpperPartial             : Int   = 1
    static let kVid_ABitHigh_CheckFingering  : Int   = 2
    static let kVid_ABitHigh_RelaxAir        : Int   = kVid_ABitHigh_CheckFingering
    static let kVid_ABitLow_SpeedUpAir       : Int   = 3
}

///////////////////////////////////////////////////////////////////////////////
// Called in post-analysis phase. Once an issue is identified, this maps the
// issue to the ID for a related video.
//     When multiple videos per issue are available, and the code is keeping
//     track of which vids have been played, this is perhaps the place to
//     determine which one to play next.
func mapPerfIssueToVideoID( _ issueCode: performanceRating ) -> Int {
    switch(issueCode) {
    case .slightlySharp:   return vidIDs.kVid_ABitHigh_RelaxAir
    case .slightlyFlat:    return vidIDs.kVid_ABitLow_SpeedUpAir
    case .isUpperPartial:  return vidIDs.kVid_UpperPartial
        
    default:               return vidIDs.kVid_NoVideoAvailable
    }
}

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
    
    static let kAlt_ABitEarly                : Int   =  5
    static let kAlt_VeryEarly                : Int   =  6
    static let kAlt_ABitLate                 : Int   =  7
    static let kAlt_VeryLate                 : Int   =  8
    
    static let kAlt_TooShort                 : Int   =  9
    static let kAlt_VeryShort                : Int   = 10
    static let kAlt_ABitShort                : Int   = 11
    static let kAlt_ABitLong                 : Int   = 12
    static let kAlt_VeryLong                 : Int   = 13
    static let kAlt_TooLong                  : Int   = 14
}

func mapPerfIssueToAlertID( _ issueCode: performanceRating ) -> Int {
    switch(issueCode) {
    case .missedNote:       return alertIDs.kAlt_MissedNote
        
    case .isLowerPartial:   return alertIDs.kAlt_LowerPartial
    case .wrongNoteFlat:    return alertIDs.kAlt_VeryLow
    case .wrongNoteSharp:   return alertIDs.kAlt_VeryHigh
        
    case .slightlyEarly:    return alertIDs.kAlt_ABitEarly
    case .veryEarly:        return alertIDs.kAlt_VeryEarly
    case .slightlyLate:     return alertIDs.kAlt_ABitLate
    case .veryLate:         return alertIDs.kAlt_VeryLate
        
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
        
    case alertIDs.kAlt_ABitEarly:
        retStr = "You played that note a bit early"
    case alertIDs.kAlt_VeryEarly:
        retStr = "You played that note a very early"
    case alertIDs.kAlt_ABitLate:
        retStr = "You played that note a bit late"
    case alertIDs.kAlt_VeryLate:
        retStr = "You played that note a very late"
        
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

///////////////////////////////////////////////////////////////////////////////
// URL components for videos.
//   These can be either in-app or remote resources
let kVidURL_PossUpperPartial          = ("UpperPartial", "mp4")
let kVidURL_ABitHigh_CheckFingering   = ("ABitHigh", "mp4")
let kVidURL_ABitHigh_RelaxAir         = ("ABitHigh", "mp4")
let kVidURL_ABitLow_SpeedUpAir        = ("ABitLow", "mp4")

///////////////////////////////////////////////////////////////////////////////
// Called by the video popup.
func getURLForVideoID(_ vidID: Int ) -> URL? {
    var retURL: URL? = nil
    
    switch vidID {
    case vidIDs.kVid_UpperPartial:
        retURL = Bundle.main.url( forResource:   kVidURL_PossUpperPartial.0,
                                  withExtension: kVidURL_PossUpperPartial.1 )
    case vidIDs.kVid_ABitHigh_CheckFingering:
        retURL = Bundle.main.url( forResource:   kVidURL_ABitHigh_CheckFingering.0,
                                  withExtension: kVidURL_ABitHigh_CheckFingering.1 )
    case vidIDs.kVid_ABitHigh_RelaxAir:
        retURL = Bundle.main.url( forResource:   kVidURL_ABitHigh_RelaxAir.0,
                                  withExtension: kVidURL_ABitHigh_RelaxAir.1 )
    case vidIDs.kVid_ABitLow_SpeedUpAir:
        retURL = Bundle.main.url( forResource:   kVidURL_ABitLow_SpeedUpAir.0,
                                  withExtension: kVidURL_ABitLow_SpeedUpAir.1 )
    default: retURL = nil
    }
    
    return retURL
}
