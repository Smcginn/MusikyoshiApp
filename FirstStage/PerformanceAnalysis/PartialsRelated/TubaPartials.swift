//
//  TubaPartials.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/28/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

///////////////////////////////////////////////////////////////////////////////
// This code identifies possible accidental overtones for different fingerings on
// the Tuba.
//
// See base class in BrassPartials.swift, for structs used here and the details
// about partials in general.
//
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////
//
//   The possible overtones for a each target note on the Tuba.
//
class TubaNotePartialsTable: BrassNotePartialsTable {

    static let instance = TubaNotePartialsTable()
    
    let noteToPositionRange =  NoteIDs.G1...NoteIDs.G3 // NoteIDs.G3...NoteIDs.G5

    /////////////////////////////////////////////////////////////////////////////
    // func isThisFreqAPartialOfThisNote() - this is what will be called externally
    //
    //   If the freqency is a partial of the note, the isPartialRetVal return value
    //   will be set as follows:
    //      .isPartial == true
    //      .partial   == the tNoteFreqRangeData of the identified partial
    //   If the freq is _not_ a partial of the note, the isPartialReturnValue return
    //   value will be set to kNotPartialForNote, which has the following values:
    //      .isPartial == false
    //      .partial   == kEmptyNoteFreqRangeData
    override func isThisFreqAPartialOfThisNote( freq: Double, note: NoteID ) -> isPartialRetVal {
        var isPartRetVal = kNotPartialForNote
            
        guard noteToPositionRange.contains(note) else { return isPartRetVal }
        guard let posForNote = noteToPositionTable[note]  else { return isPartRetVal }
            
        let tubaPartialsForPos: BrassPartialsForPosition =
                                        partialsForPositionsTable[posForNote]
        isPartRetVal = tubaPartialsForPos.thisFreqIsAPartial(frequency: freq)
            
        return isPartRetVal
    }
    
    override func buildPartialsForPositionsTable() {
        // For each of the seven positions (fingerings):
        //     1) Create a BrassPartialsForPosition object
        //     2) Populate it with the possible partials (notes)
        //     3) Add the BrassPartialsForPosition object to the
        //        partialsForPositionsTable
        
        partialsForPositionsTable.reserveCapacity(brassPosition.numPos)
        
        //---- firstPosition --------------------------------------------------
        var firstPosPartials = BrassPartialsForPosition()
        firstPosPartials.positionName = "First Position"
        let notesIn1stPos = [NoteIDs.C2, NoteIDs.G2, NoteIDs.C3, NoteIDs.E3,
                             NoteIDs.G3, NoteIDs.Bb3, NoteIDs.C4] // D6,too
        firstPosPartials.addPartialsForNotes(noteIDs: notesIn1stPos)
        self.partialsForPositionsTable.insert(firstPosPartials,
                                              at: brassPosition.first)
        //---- secondPosition -------------------------------------------------
        var secondPosPartials = BrassPartialsForPosition()
        secondPosPartials.positionName = "Second Position"
        let notesIn2ndPos = [NoteIDs.B1,  NoteIDs.Gb2, NoteIDs.B2, NoteIDs.Eb3,
                             NoteIDs.Gb3, NoteIDs.A3,  NoteIDs.B3] // Db6,too
        secondPosPartials.addPartialsForNotes(noteIDs: notesIn2ndPos)
        self.partialsForPositionsTable.insert(secondPosPartials,
                                              at: brassPosition.second)
        //---- thirdPosition---------------------------------------------------
        var thirdPosPartials = BrassPartialsForPosition()
        thirdPosPartials.positionName = "Third Position"
        let notesIn3rdPos = [NoteIDs.Bb1, NoteIDs.F2,  NoteIDs.Bb2, NoteIDs.D3,
                             NoteIDs.F3,  NoteIDs.Ab3, NoteIDs.Bb3, NoteIDs.C4]
        thirdPosPartials.addPartialsForNotes(noteIDs: notesIn3rdPos)
        self.partialsForPositionsTable.insert(thirdPosPartials,
                                              at: brassPosition.third)
        //---- fourthPosition -------------------------------------------------
        var fourthPosPartials = BrassPartialsForPosition()
        fourthPosPartials.positionName = "Fourth Position"
        let notesIn4thPos = [NoteIDs.A1, NoteIDs.E2, NoteIDs.A2, NoteIDs.Db3,
                             NoteIDs.E3, NoteIDs.G3, NoteIDs.A3, NoteIDs.B3]
        fourthPosPartials.addPartialsForNotes(noteIDs: notesIn4thPos)
        self.partialsForPositionsTable.insert(fourthPosPartials,
                                              at: brassPosition.fourth)
        //---- fifthPosition --------------------------------------------------
        var fifthPosPartials = BrassPartialsForPosition()
        fifthPosPartials.positionName = "Fifth Position"
        let notesIn5thPos = [NoteIDs.Ab1, NoteIDs.Eb2, NoteIDs.Ab2, NoteIDs.C3,
                             NoteIDs.Eb3, NoteIDs.Gb3, NoteIDs.Ab3,	NoteIDs.Bb3]
        fifthPosPartials.addPartialsForNotes(noteIDs: notesIn5thPos)
        self.partialsForPositionsTable.insert(fifthPosPartials,
                                              at: brassPosition.fifth)
        //---- sixthPosition --------------------------------------------------
        var sixthPosPartials = BrassPartialsForPosition()
        sixthPosPartials.positionName = "Sixth Position"
        let notesIn6thPos = [NoteIDs.G1, NoteIDs.D2, NoteIDs.G2, NoteIDs.B2,
                             NoteIDs.D3, NoteIDs.F3, NoteIDs.G3, NoteIDs.A3]
        sixthPosPartials.addPartialsForNotes(noteIDs: notesIn6thPos)
        self.partialsForPositionsTable.insert(sixthPosPartials,
                                              at: brassPosition.sixth)
        //---- seventhPosition ------------------------------------------------
        var seventhPosPartials = BrassPartialsForPosition()
        seventhPosPartials.positionName = "Seventh Position"
        let notesIn7thPos = [NoteIDs.Gb1, NoteIDs.Db2, NoteIDs.Gb2, NoteIDs.Bb2,
                             NoteIDs.Db3, NoteIDs.E3,  NoteIDs.Gb3, NoteIDs.Ab3]
        seventhPosPartials.addPartialsForNotes(noteIDs: notesIn7thPos)
        self.partialsForPositionsTable.insert(seventhPosPartials,
                                              at: brassPosition.seventh)
    }
    
    override func buildNoteToPositionMap() {
        // Lookup table. Which Position is used for a given note?
        
        // Assign a position to each note in the range (a position is the 
        // fingering used to play the note). The position/fingering determines 
        // which overtones (partials) are possible for any note.
        
        self.noteToPositionTable[NoteIDs.G1]  = brassPosition.sixth
        self.noteToPositionTable[NoteIDs.Ab1] = brassPosition.fifth
        self.noteToPositionTable[NoteIDs.A1]  = brassPosition.fourth
        self.noteToPositionTable[NoteIDs.Bb1] = brassPosition.third
        self.noteToPositionTable[NoteIDs.B1]  = brassPosition.second
        
        self.noteToPositionTable[NoteIDs.C2]  = brassPosition.first
        self.noteToPositionTable[NoteIDs.Db2] = brassPosition.seventh
        self.noteToPositionTable[NoteIDs.D2]  = brassPosition.sixth
        self.noteToPositionTable[NoteIDs.Eb2] = brassPosition.fifth
        self.noteToPositionTable[NoteIDs.E2]  = brassPosition.fourth
        self.noteToPositionTable[NoteIDs.F2]  = brassPosition.third
        self.noteToPositionTable[NoteIDs.Gb2] = brassPosition.second
        self.noteToPositionTable[NoteIDs.G2]  = brassPosition.first
        self.noteToPositionTable[NoteIDs.Ab2] = brassPosition.fifth
        self.noteToPositionTable[NoteIDs.A2]  = brassPosition.fourth
        self.noteToPositionTable[NoteIDs.Bb2] = brassPosition.third
        self.noteToPositionTable[NoteIDs.B2]  = brassPosition.second
        
        self.noteToPositionTable[NoteIDs.C3]  = brassPosition.first
        self.noteToPositionTable[NoteIDs.Db3] = brassPosition.fourth
        self.noteToPositionTable[NoteIDs.D3]  = brassPosition.third
        self.noteToPositionTable[NoteIDs.Eb3] = brassPosition.second
        self.noteToPositionTable[NoteIDs.E3]  = brassPosition.first
        self.noteToPositionTable[NoteIDs.F3]  = brassPosition.third
        self.noteToPositionTable[NoteIDs.Gb3] = brassPosition.second
        self.noteToPositionTable[NoteIDs.G3]  = brassPosition.first
    }
    
    ////////////////////////////////////////////////////////////////////
    //
    //   Testing, Debugging funcs from here down to end of class . . .
    //
    ////////////////////////////////////////////////////////////////////
    
    override func printPartialsForThisNote( noteID: NoteID ) {
        guard kMKDebugOpt_PrintPerfAnalysisValues else { return }
        guard noteToPositionRange.contains(noteID) else { return  }
        guard let posForNote = noteToPositionTable[noteID]  else { return  }
        
        let tubaPartialsForPos: BrassPartialsForPosition =
            partialsForPositionsTable[posForNote]
        
        tubaPartialsForPos.printPartialsSummaryForThisNote(noteID: noteID)
    }

    override func printAllPartials() {
        guard kMKDebugOpt_PrintPerfAnalysisValues else { return }
        
        print ("\n------------------------------------------\n")
        print (" TUBA Positions, and their partials:\n")
        var ptlsForPos = self.partialsForPositionsTable[brassPosition.first]
        ptlsForPos.printYourself()
        
        ptlsForPos = self.partialsForPositionsTable[brassPosition.second]
        ptlsForPos.printYourself()
        
        ptlsForPos = self.partialsForPositionsTable[brassPosition.third]
        ptlsForPos.printYourself()
        
        ptlsForPos = self.partialsForPositionsTable[brassPosition.fourth]
        ptlsForPos.printYourself()
        
        ptlsForPos = self.partialsForPositionsTable[brassPosition.fifth]
        ptlsForPos.printYourself()
        
        ptlsForPos = self.partialsForPositionsTable[brassPosition.sixth]
        ptlsForPos.printYourself()
        
        ptlsForPos = self.partialsForPositionsTable[brassPosition.seventh]
        ptlsForPos.printYourself()
        print ("\n------------------------------------------\n")
    }
    
    override func printAllPartialsByNote() {
        guard kMKDebugOpt_PrintPerfAnalysisValues else { return }
        
        for oneNoteID in noteToPositionRange {
            guard let posForNote = noteToPositionTable[oneNoteID]
                else { continue }
            let tubaPartialsForPos:BrassPartialsForPosition =
                    partialsForPositionsTable[posForNote]
            tubaPartialsForPos.printAllPartialsForNote(noteID: oneNoteID)
        }
    }
}

