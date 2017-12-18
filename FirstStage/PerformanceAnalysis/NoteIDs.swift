//
//  NoteIDs.swift
//  FirstStage
//
//  Created by Scott Freshour on 11/30/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import Foundation

// TODO: define a UInt8 type that safely checks and converts Int, Int32, etc.
typealias NoteID = UInt8

// These correspond to the MIDI Standard for note IDs, 0-127.

struct NoteIDs {
    // TODO - Post Alpha - add all possible notes for all instruments
    
    // Can't use "#" in variable name for enharmonic spellings for sharps
    
    static let Cminus1: NoteID  = 0    // C of Octave -1 in MIDI parlance - 8 Hz!
    static let noteUndefined    = Cminus1
    
    // Octave 2
    static let BSharp2: NoteID  = 48
    
    // Octave 3
    static let C3: NoteID       = BSharp2
    static let CSharp3: NoteID  = 49
    static let Db3: NoteID      = CSharp3
    static let D3: NoteID       = 50
    static let DSharp3: NoteID  = 51
    static let Eb3: NoteID      = DSharp3
    static let E3: NoteID       = 52
    static let ESharp3: NoteID  = 53
    static let F3: NoteID       = ESharp3
    static let FSharp3: NoteID  = 54
    static let Gb3: NoteID      = FSharp3
    static let G3: NoteID       = 55
    static let GSharp3: NoteID  = 56
    static let Ab3: NoteID      = GSharp3
    static let A3: NoteID       = 57
    static let ASharp3: NoteID  = 58
    static let Bb3: NoteID      = ASharp3
    static let B3: NoteID       = 59
    static let BSharp3: NoteID  = 60
    
    // Octave 4
    static let C4: NoteID       = BSharp3
    static let CSharp4: NoteID  = 61
    static let Db4: NoteID      = CSharp4
    static let D4: NoteID       = 62
    static let DSharp4: NoteID  = 63
    static let Eb4: NoteID      = DSharp4
    static let E4: NoteID       = 64
    static let ESharp4: NoteID  = 65
    static let F4: NoteID       = ESharp4
    static let FSharp4: NoteID  = 66
    static let Gb4: NoteID      = FSharp4
    static let G4: NoteID       = 67
    static let GSharp4: NoteID  = 68
    static let Ab4: NoteID      = GSharp4
    static let A4: NoteID       = 69
    static let ASharp4: NoteID  = 70
    static let Bb4: NoteID      = ASharp4
    static let B4: NoteID       = 71
    static let BSharp4: NoteID  = 72
    
    // Octave 5
    static let C5: NoteID       = BSharp4
    static let CSharp5: NoteID  = 73
    static let Db5: NoteID      = CSharp5
    static let D5: NoteID       = 74
    static let DSharp5: NoteID  = 75
    static let Eb5: NoteID      = DSharp5
    static let E5: NoteID       = 76
    static let ESharp5: NoteID  = 77
    static let F5: NoteID       = ESharp5
    static let FSharp5: NoteID  = 78
    static let Gb5: NoteID      = FSharp5
    static let G5: NoteID       = 79
    static let GSharp5: NoteID  = 80
    static let Ab5: NoteID      = GSharp5
    static let A5: NoteID       = 81
    static let ASharp5: NoteID  = 82
    static let Bb5: NoteID      = ASharp5
    static let B5: NoteID       = 83
    static let BSharp5: NoteID  = 84
    
    // Octave 6
    static let C6: NoteID       = BSharp5
    
    // Current valid Range consts for use within App (Alpha) (Just add more if needed)
    static let firstNoteID      = C3
    static let lastNoteID       = C6
    static let validNoteIDRange = firstNoteID...lastNoteID
}

/////////////////////////////////////////////////////////////////////////////
// For Transposed Instruments like Trumpet, get the instrument note ID whose
// frequency corresponds to the concert note's frequency.
// E.g., for a Bb Trumpet, an input of NoteIDs.Bb4, will return NoteIDs.C5
// (Works corectly for non-transposing instruments as well.)
func concertNoteIdToInstrumentNoteID(noteID: NoteID) -> NoteID {
    var returnNoteID = NoteIDs.noteUndefined
    let transOffset =
        UserDefaults.standard.integer(forKey: Constants.Settings.Transposition)
    let transNote  = Int(noteID) - transOffset
    if transNote >= Int(NoteID.min)  &&  transNote <= Int(NoteID.max) {
        returnNoteID = NoteID(transNote) // safe; will fit, tested above
    }
    return returnNoteID
}

/////////////////////////////////////////////////////////////////////////////
// For transposed Instruments like Trumpet, get back the Conecert Note ID whose
// frequncy corresponds to the instrument note's frequency
// E.g., for a Bb Trumpet, an input of NoteIDs.C5, will return NoteIDs.Bb4
// (Works corectly for non-transposing instruments as well.)
func instrumentNoteIdToConcertNoteID(transNote: NoteID) -> NoteID {
    var returnNoteID = NoteIDs.noteUndefined
    let transOffset =
        UserDefaults.standard.integer(forKey: Constants.Settings.Transposition)
    let concertNoteID = Int(transNote) + transOffset
    if concertNoteID >= Int(NoteID.min)  &&  concertNoteID <= Int(NoteID.max) {
        returnNoteID = NoteID(concertNoteID) // safe; will fit, tested above
    }
    return returnNoteID
}

/////////////////////////////////////////////////////////////////////////////
// Given a NoteID for the current instrument, get the Note object for that note,
// taking into account that it may be  a transposing instrument, like trumpet.
// (Works corectly for non-transposing instruments as well.)
func getConcertNoteForCurrInstrument(instrumentNoteID: NoteID) -> Note? {
    let noteID = instrumentNoteIdToConcertNoteID( transNote: instrumentNoteID )
    let note = NoteService.getNote(Int(noteID))
    return note
}
