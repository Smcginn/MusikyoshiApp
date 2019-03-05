//
//  FrenchHornPartials.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/28/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

///////////////////////////////////////////////////////////////////////////////
// This code identifies possible accidental overtones for different fingerings on
// the French Horn.
//
// See base class in BrassPartials.swift, for structs used here and the details
// about partials in general.
//
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////
//
//   The possible overtones for a each target note on the French Horn.
//
class FrenchHornPartialsTable: BrassNotePartialsTable {

    static let instance = FrenchHornPartialsTable()
    
    let noteToPositionRange = NoteIDs.C3...NoteIDs.C5

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
            
        let frenchHornPartialsForPos: BrassPartialsForPosition =
                                           partialsForPositionsTable[posForNote]
        isPartRetVal = frenchHornPartialsForPos.thisFreqIsAPartial(frequency: freq)
            
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
        let notesIn1stPos = [NoteIDs.C2, NoteIDs.C3, NoteIDs.G3, NoteIDs.C4,
                             NoteIDs.E4, NoteIDs.G4, NoteIDs.Bb4, NoteIDs.C5,
                             NoteIDs.D5]
        firstPosPartials.addPartialsForNotes(noteIDs: notesIn1stPos)
        self.partialsForPositionsTable.insert(firstPosPartials,
                                              at: brassPosition.first)
        //---- secondPosition -------------------------------------------------
        var secondPosPartials = BrassPartialsForPosition()
        secondPosPartials.positionName = "Second Position"
        let notesIn2ndPos = [NoteIDs.B1, NoteIDs.B2, NoteIDs.Gb3, NoteIDs.B3,
                             NoteIDs.Eb4, NoteIDs.Gb4, NoteIDs.A4,  NoteIDs.B4,
                             NoteIDs.Db4]
        secondPosPartials.addPartialsForNotes(noteIDs: notesIn2ndPos)
        self.partialsForPositionsTable.insert(secondPosPartials,
                                              at: brassPosition.second)
        //---- thirdPosition---------------------------------------------------
        var thirdPosPartials = BrassPartialsForPosition()
        thirdPosPartials.positionName = "Third Position"
        let notesIn3rdPos = [NoteIDs.Bb1, NoteIDs.Bb2, NoteIDs.F3,  NoteIDs.Bb3,
                             NoteIDs.D4, NoteIDs.F4,  NoteIDs.Ab4, NoteIDs.Bb4,
                             NoteIDs.C5]
        thirdPosPartials.addPartialsForNotes(noteIDs: notesIn3rdPos)
        self.partialsForPositionsTable.insert(thirdPosPartials,
                                              at: brassPosition.third)
        //---- fourthPosition -------------------------------------------------
        var fourthPosPartials = BrassPartialsForPosition()
        fourthPosPartials.positionName = "Fourth Position"
        let notesIn4thPos = [NoteIDs.A1,  NoteIDs.A2, NoteIDs.E3, NoteIDs.A3,
                             NoteIDs.Db4, NoteIDs.E4, NoteIDs.G4, NoteIDs.A4,
                             NoteIDs.B4]
        fourthPosPartials.addPartialsForNotes(noteIDs: notesIn4thPos)
        self.partialsForPositionsTable.insert(fourthPosPartials,
                                              at: brassPosition.fourth)
        //---- fifthPosition --------------------------------------------------
        var fifthPosPartials = BrassPartialsForPosition()
        fifthPosPartials.positionName = "Fifth Position"
        let notesIn5thPos = [NoteIDs.Ab1, NoteIDs.Ab2, NoteIDs.Eb3, NoteIDs.Ab3,
                             NoteIDs.C4,  NoteIDs.Eb4, NoteIDs.Gb4, NoteIDs.Ab4,
                             NoteIDs.Bb4]
        fifthPosPartials.addPartialsForNotes(noteIDs: notesIn5thPos)
        self.partialsForPositionsTable.insert(fifthPosPartials,
                                              at: brassPosition.fifth)
        //---- sixthPosition --------------------------------------------------
        var sixthPosPartials = BrassPartialsForPosition()
        sixthPosPartials.positionName = "Sixth Position"
        let notesIn6thPos = [NoteIDs.G1, NoteIDs.G2, NoteIDs.D3, NoteIDs.G3,
                             NoteIDs.B3, NoteIDs.D4, NoteIDs.F4, NoteIDs.G4,
                             NoteIDs.A4]
        sixthPosPartials.addPartialsForNotes(noteIDs: notesIn6thPos)
        self.partialsForPositionsTable.insert(sixthPosPartials,
                                              at: brassPosition.sixth)
        //---- seventhPosition ------------------------------------------------
        var seventhPosPartials = BrassPartialsForPosition()
        seventhPosPartials.positionName = "Seventh Position"
        let notesIn7thPos = [NoteIDs.Gb1, NoteIDs.Gb2, NoteIDs.Db3, NoteIDs.Gb3,
                             NoteIDs.Bb3, NoteIDs.Db4, NoteIDs.E4,  NoteIDs.Gb4,
                             NoteIDs.Ab4]
        seventhPosPartials.addPartialsForNotes(noteIDs: notesIn7thPos)
        self.partialsForPositionsTable.insert(seventhPosPartials,
                                              at: brassPosition.seventh)
    }
    
    override func buildNoteToPositionMap() {
        // Lookup table. Which Position is used for a given note?
        
        // Assign a position to each note in the range (a position is the 
        // fingering used to play the note). The position/fingering determines 
        // which overtones (partials) are possible for any note.
        
//        self.noteToPositionTable[NoteIDs.C2]  = brassPosition.sixth
//        self.noteToPositionTable[NoteIDs.Db2] = brassPosition.fifth
//        self.noteToPositionTable[NoteIDs.D2]  = brassPosition.fourth
//        self.noteToPositionTable[NoteIDs.Eb2] = brassPosition.third
//        self.noteToPositionTable[NoteIDs.E2]  = brassPosition.second
//        self.noteToPositionTable[NoteIDs.F2]  = brassPosition.first
        
        self.noteToPositionTable[NoteIDs.Gb2] = brassPosition.seventh
        self.noteToPositionTable[NoteIDs.G2]  = brassPosition.sixth
        self.noteToPositionTable[NoteIDs.Ab2] = brassPosition.fifth
        self.noteToPositionTable[NoteIDs.A2]  = brassPosition.fourth
        self.noteToPositionTable[NoteIDs.Bb2] = brassPosition.third
        self.noteToPositionTable[NoteIDs.B2]  = brassPosition.second
        
        self.noteToPositionTable[NoteIDs.C3]  = brassPosition.first
        self.noteToPositionTable[NoteIDs.Db3] = brassPosition.seventh
        self.noteToPositionTable[NoteIDs.D3]  = brassPosition.sixth
        self.noteToPositionTable[NoteIDs.Eb3] = brassPosition.fifth
        self.noteToPositionTable[NoteIDs.E3]  = brassPosition.fourth
        self.noteToPositionTable[NoteIDs.F3]  = brassPosition.third
        self.noteToPositionTable[NoteIDs.Gb3] = brassPosition.second
        self.noteToPositionTable[NoteIDs.G3]  = brassPosition.first
        self.noteToPositionTable[NoteIDs.Ab3] = brassPosition.fifth
        self.noteToPositionTable[NoteIDs.A3]  = brassPosition.fourth
        self.noteToPositionTable[NoteIDs.Bb3] = brassPosition.third
        self.noteToPositionTable[NoteIDs.B3]  = brassPosition.second
        
        self.noteToPositionTable[NoteIDs.C4]  = brassPosition.first
        self.noteToPositionTable[NoteIDs.Db4] = brassPosition.fourth
        self.noteToPositionTable[NoteIDs.D4]  = brassPosition.third
        self.noteToPositionTable[NoteIDs.Eb4] = brassPosition.second
        self.noteToPositionTable[NoteIDs.E4]  = brassPosition.first
        self.noteToPositionTable[NoteIDs.F4]  = brassPosition.third
        self.noteToPositionTable[NoteIDs.Gb4] = brassPosition.second
        self.noteToPositionTable[NoteIDs.G4]  = brassPosition.first
        self.noteToPositionTable[NoteIDs.Ab4] = brassPosition.fifth
        self.noteToPositionTable[NoteIDs.A4]  = brassPosition.fourth
        self.noteToPositionTable[NoteIDs.Bb4] = brassPosition.third
        self.noteToPositionTable[NoteIDs.B4]  = brassPosition.second
        
        self.noteToPositionTable[NoteIDs.C5]  = brassPosition.first
        self.noteToPositionTable[NoteIDs.Db5] = brassPosition.fourth
        self.noteToPositionTable[NoteIDs.D5]  = brassPosition.third
        self.noteToPositionTable[NoteIDs.Eb5] = brassPosition.second
        self.noteToPositionTable[NoteIDs.E5]  = brassPosition.first
        self.noteToPositionTable[NoteIDs.F5]  = brassPosition.third
        self.noteToPositionTable[NoteIDs.Gb5] = brassPosition.second
        self.noteToPositionTable[NoteIDs.G5]  = brassPosition.first
        self.noteToPositionTable[NoteIDs.Ab5] = brassPosition.fifth
        self.noteToPositionTable[NoteIDs.A5]  = brassPosition.fourth
        self.noteToPositionTable[NoteIDs.Bb5] = brassPosition.third
        self.noteToPositionTable[NoteIDs.B5]  = brassPosition.second
        self.noteToPositionTable[NoteIDs.C6]  = brassPosition.first
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
        
        let frenchHornPartialsForPos: BrassPartialsForPosition =
            partialsForPositionsTable[posForNote]
        
        frenchHornPartialsForPos.printPartialsSummaryForThisNote(noteID: noteID)
    }

    override func printAllPartials() {
        guard kMKDebugOpt_PrintPerfAnalysisValues else { return }
        
        print ("\n------------------------------------------\n")
        print (" FRENCH HORN Positions, and their partials:\n")
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
            let frenchHornPartialsForPos:BrassPartialsForPosition =
                    partialsForPositionsTable[posForNote]
            frenchHornPartialsForPos.printAllPartialsForNote(noteID: oneNoteID)
        }
    }
}

