//
//  LongtonePersonalBestSupport.swift
//  FirstStage
//
//  Created by Scott Freshour on 8/28/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

// DATA_BASE_CONVERT
//   was:
//      let kLTPersBestKey_First: Int =  0
//      let kLTPersBestKey_G3:    Int =  0
//        . . .
//      let kLTPersBestKey_Last:  Int = 24
//      let kLTPersBestKey_NumKeys:  Int = 24

// Ids for accessing fields in longtonePersonalRecords
let kLTPersBestKey_First: Int =  0
let kLTPersBestKey_G3:    Int =  0
let kLTPersBestKey_Ab3:   Int =  1
let kLTPersBestKey_A3:    Int =  2
let kLTPersBestKey_Bb3:   Int =  3
let kLTPersBestKey_B3:    Int =  4
let kLTPersBestKey_C4:    Int =  5
let kLTPersBestKey_Db4:   Int =  6
let kLTPersBestKey_D4:    Int =  7
let kLTPersBestKey_Eb4:   Int =  8
let kLTPersBestKey_E4:    Int =  9
let kLTPersBestKey_F4:    Int = 10
let kLTPersBestKey_Gb4:   Int = 11
let kLTPersBestKey_G4:    Int = 12
let kLTPersBestKey_Ab4:   Int = 13
let kLTPersBestKey_A4:    Int = 14
let kLTPersBestKey_Bb4:   Int = 15
let kLTPersBestKey_B4:    Int = 16
let kLTPersBestKey_C5:    Int = 17
let kLTPersBestKey_Db5:   Int = 18
let kLTPersBestKey_D5:    Int = 19
let kLTPersBestKey_Eb5:   Int = 20
let kLTPersBestKey_E5:    Int = 21
let kLTPersBestKey_F5:    Int = 22
let kLTPersBestKey_Gb5:   Int = 23
let kLTPersBestKey_G5:    Int = 24
let kLTPersBestKey_Last:  Int = 24
let kLTPersBestKey_NumKeys:  Int = 24

// DATA_BASE_CONVERT
func mapNoteIDToPBKey(noteID: Int) -> Int {
    var retKey = kLTPersBestKey_C4
    let noteID_Uint8 = NoteID(noteID)
    switch noteID_Uint8 {
    case NoteIDs.G3:    retKey = kLTPersBestKey_G3
    case NoteIDs.Ab3:   retKey = kLTPersBestKey_Ab3
    case NoteIDs.A3:    retKey = kLTPersBestKey_A3
    case NoteIDs.Bb3:   retKey = kLTPersBestKey_Bb3
    case NoteIDs.B3:    retKey = kLTPersBestKey_B3
    case NoteIDs.C4:    retKey = kLTPersBestKey_C4
    case NoteIDs.Db4:   retKey = kLTPersBestKey_Db4
    case NoteIDs.D4:    retKey = kLTPersBestKey_D4
    case NoteIDs.Eb4:   retKey = kLTPersBestKey_Eb4
    case NoteIDs.E4:    retKey = kLTPersBestKey_E4
    case NoteIDs.F4:    retKey = kLTPersBestKey_F4
    case NoteIDs.Gb4:   retKey = kLTPersBestKey_Gb4
    case NoteIDs.G4:    retKey = kLTPersBestKey_G4
    case NoteIDs.Ab4:   retKey = kLTPersBestKey_Ab4
    case NoteIDs.A4:    retKey = kLTPersBestKey_A4
    case NoteIDs.Bb4:   retKey = kLTPersBestKey_Bb4
    case NoteIDs.B4:    retKey = kLTPersBestKey_B4
    case NoteIDs.C5:    retKey = kLTPersBestKey_C5
    default:
        itsBad()
        retKey = kLTPersBestKey_C4 // something's not right
    }
    
    return retKey
}

func verifyPersBestKey(persBestKey: Int) -> Bool {
    guard persBestKey >= kLTPersBestKey_First,
          persBestKey <= kLTPersBestKey_Last  else { return false }
 
    return true
}


