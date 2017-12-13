//
//  NoteFreqRangeTable.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/1/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import Foundation

// A tFrequencyRange is used to define the acceptable range when a student
// performs an intended pitch. It is generated using a tolerance percentage.
// E.g., for A440 with a tolerance of 0.97, the range would be 426.8...453.6.
//
// A tFrequencyRange can also be used to identify:
//   - freq zones such as "pitch a bit flat/sharp" or "pitch very flat/sharp"
//   - the range of an instrument-specific problem, such as a Trumpet partial.
//
typealias tFrequencyRange = ClosedRange<Double>
let kEmptyNoteFreqRange = 0.0...0.0

// Since the current instrument could be a transposing instrument, in addition
// to the actual concert tFrequencyRange, tNoteFreqRangeData stores some
// identifying information for both the instrument's written score note and the
// actual concert pitch that is produced when the note is played.
typealias tNoteFreqRangeData = ( noteName: String,
                                 noteFullName: String,
                                 noteID: NoteID,
                                 concertNoteName: String,
                                 concertNoteFullName: String,
                                 concertNoteID: NoteID,
                                 concertFreq: Double,
                                 freqRange: tFrequencyRange )

let kEmptyNoteFreqRangeData =
    tNoteFreqRangeData( "", "", 0, "", "", 0, 0.0, 0.0...0.0 )

func makeNoteFreqRange( noteID: NoteID,
                        tolerancePercent: Double ) -> tNoteFreqRangeData {
    // This could be a tranposing Instrument: so will store info for both instrument
    // note and concert pitch note. Make sure both data sources are available.
    guard let concNote = getConcertNoteForCurrInstrument(instrumentNoteID: noteID),
          let note = NoteService.getNote(Int(noteID))
        else { return kEmptyNoteFreqRangeData }
    
    let freqLo = concNote.frequency*tolerancePercent
    let freqHi = concNote.frequency/tolerancePercent
    let oneNoteFR = tNoteFreqRangeData( note.name,
                                        note.fullName,
                                        NoteID(note.orderId),
                                        concNote.name,
                                        concNote.fullName,
                                        NoteID(concNote.orderId),
                                        concNote.frequency,
                                        freqLo...freqHi )
    return oneNoteFR
}

struct NoteFreqRangeTable {
    // These are, for now, for Trumpet (with some room on either end) according 
    // to Shawn's docs. In future, table should be built to include all possible 
    // notes for
    //    1) All possible instruments,    or
    //    2) Just the range for the current instrument
    
    var noteFreqRangeDataTable = [tNoteFreqRangeData]()
    var tableBasedOnThisTolerance = 0.0
    
    init() {
        rebuildTable( tolerancePercent: DefaultTolerancePCs.defaultCorrectPitchPC )
    }
    
    // As student proceeds through lessons, the tolerence will be tightened, and
    // when this happens the table of NoteFreqRangeData will need to be rebuilt
    mutating func rebuildTable( tolerancePercent: Double ) {
        noteFreqRangeDataTable.removeAll( keepingCapacity: true )
        tableBasedOnThisTolerance = tolerancePercent
        var currID  = PerfAnalysisDefs.kFirstTableNoteId
        repeat {  // create an entry for each valid note for current instrument
            let noteFR = makeNoteFreqRange( noteID: currID,
                                            tolerancePercent: tolerancePercent )
            noteFreqRangeDataTable.append(noteFR)
            currID += 1
        } while currID <= PerfAnalysisDefs.kLastTableNoteId
    }
    
    func getNoteFreqRangeData( noteID: NoteID ) -> tNoteFreqRangeData {
        guard (NoteIDs.F3...NoteIDs.C6).contains(noteID)
            else { return kEmptyNoteFreqRangeData }  // noteID out of range
        guard noteFreqRangeDataTable.count == PerfAnalysisDefs.kNumTableIDs
            else { return kEmptyNoteFreqRangeData }  // table wasn't built
        
        // normalize index to range that starts at 0
        let idx = Int(noteID - PerfAnalysisDefs.kFirstTableNoteId)
        guard idx < noteFreqRangeDataTable.count else { return kEmptyNoteFreqRangeData }
        
        return noteFreqRangeDataTable[idx]
    }
}
