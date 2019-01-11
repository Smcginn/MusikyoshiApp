//
//  TrumpetPartials.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/1/17.
//  Modified on 12/28/18 - split original file into:
//      BrassPartials.swift   - contains the (new) base class and explanatory
//                              comments from original file
//      TrumpetPartials.swift - (this file) contains the (now) derived
//                              TrumpetNotePartialsTable class
//
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import Foundation

///////////////////////////////////////////////////////////////////////////////
// This code identifies possible accidental overtones for different fingerings on
// the trumpet.
//
// See base class in BrassPartials.swift, for structs used here and the details
// about partials in general.
//
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////
//
//   The possible overtones for a each target note on the trumpet.
//
class TrumpetNotePartialsTable: BrassNotePartialsTable {

    static let instance = TrumpetNotePartialsTable()
    
    let noteToPositionRange = NoteIDs.G3...NoteIDs.G5

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
            
        let trumpetPartialsForPos: BrassPartialsForPosition =
                                        partialsForPositionsTable[posForNote]
        isPartRetVal = trumpetPartialsForPos.thisFreqIsAPartial(frequency: freq)
            
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
        let notesIn1stPos = [NoteIDs.C4, NoteIDs.G4, NoteIDs.C5, NoteIDs.E5,
                             NoteIDs.G5, NoteIDs.Bb5, NoteIDs.C6] // D6,too
        firstPosPartials.addPartialsForNotes(noteIDs: notesIn1stPos)
        self.partialsForPositionsTable.insert(firstPosPartials,
                                              at: brassPosition.first)
        //---- secondPosition -------------------------------------------------
        var secondPosPartials = BrassPartialsForPosition()
        secondPosPartials.positionName = "Second Position"
        let notesIn2ndPos = [NoteIDs.B3,  NoteIDs.Gb4, NoteIDs.B4, NoteIDs.Eb5,
                             NoteIDs.Gb5, NoteIDs.A5,  NoteIDs.B5] // Db6,too
        secondPosPartials.addPartialsForNotes(noteIDs: notesIn2ndPos)
        self.partialsForPositionsTable.insert(secondPosPartials,
                                              at: brassPosition.second)
        //---- thirdPosition---------------------------------------------------
        var thirdPosPartials = BrassPartialsForPosition()
        thirdPosPartials.positionName = "Third Position"
        let notesIn3rdPos = [NoteIDs.Bb3, NoteIDs.F4,  NoteIDs.Bb4, NoteIDs.D5,
                             NoteIDs.F5,  NoteIDs.Ab5, NoteIDs.Bb5, NoteIDs.C6]
        thirdPosPartials.addPartialsForNotes(noteIDs: notesIn3rdPos)
        self.partialsForPositionsTable.insert(thirdPosPartials,
                                              at: brassPosition.third)
        //---- fourthPosition -------------------------------------------------
        var fourthPosPartials = BrassPartialsForPosition()
        fourthPosPartials.positionName = "Fourth Position"
        let notesIn4thPos = [NoteIDs.A3, NoteIDs.E4, NoteIDs.A4, NoteIDs.Db5,
                             NoteIDs.E5, NoteIDs.G5, NoteIDs.A5, NoteIDs.B5]
        fourthPosPartials.addPartialsForNotes(noteIDs: notesIn4thPos)
        self.partialsForPositionsTable.insert(fourthPosPartials,
                                              at: brassPosition.fourth)
        //---- fifthPosition --------------------------------------------------
        var fifthPosPartials = BrassPartialsForPosition()
        fifthPosPartials.positionName = "Fifth Position"
        let notesIn5thPos = [NoteIDs.Ab3, NoteIDs.Eb4, NoteIDs.Ab4, NoteIDs.C5,
                             NoteIDs.Eb5, NoteIDs.Gb5, NoteIDs.Ab5,	NoteIDs.Bb5]
        fifthPosPartials.addPartialsForNotes(noteIDs: notesIn5thPos)
        self.partialsForPositionsTable.insert(fifthPosPartials,
                                              at: brassPosition.fifth)
        //---- sixthPosition --------------------------------------------------
        var sixthPosPartials = BrassPartialsForPosition()
        sixthPosPartials.positionName = "Sixth Position"
        let notesIn6thPos = [NoteIDs.G3, NoteIDs.D4, NoteIDs.G4, NoteIDs.B4,
                             NoteIDs.D5, NoteIDs.F5, NoteIDs.G5, NoteIDs.A5]
        sixthPosPartials.addPartialsForNotes(noteIDs: notesIn6thPos)
        self.partialsForPositionsTable.insert(sixthPosPartials,
                                              at: brassPosition.sixth)
        //---- seventhPosition ------------------------------------------------
        var seventhPosPartials = BrassPartialsForPosition()
        seventhPosPartials.positionName = "Seventh Position"
        let notesIn7thPos = [NoteIDs.Gb3, NoteIDs.Db4, NoteIDs.Gb4, NoteIDs.Bb4,
                             NoteIDs.Db5, NoteIDs.E5,  NoteIDs.Gb5, NoteIDs.Ab5]
        seventhPosPartials.addPartialsForNotes(noteIDs: notesIn7thPos)
        self.partialsForPositionsTable.insert(seventhPosPartials,
                                              at: brassPosition.seventh)
    }
    
    override func buildNoteToPositionMap() {
        // Lookup table. Which Position is used for a given note?
        
        // Assign a position to each note in the range (a position is the 
        // fingering used to play the note). The position/fingering determines 
        // which overtones (partials) are possible for any note.
        
        self.noteToPositionTable[NoteIDs.G3]  = brassPosition.sixth
        self.noteToPositionTable[NoteIDs.Ab3] = brassPosition.fifth
        self.noteToPositionTable[NoteIDs.A3]  = brassPosition.fourth
        self.noteToPositionTable[NoteIDs.Bb3] = brassPosition.third
        self.noteToPositionTable[NoteIDs.B3]  = brassPosition.second
        
        self.noteToPositionTable[NoteIDs.C4]  = brassPosition.first
        self.noteToPositionTable[NoteIDs.Db4] = brassPosition.seventh
        self.noteToPositionTable[NoteIDs.D4]  = brassPosition.sixth
        self.noteToPositionTable[NoteIDs.Eb4] = brassPosition.fifth
        self.noteToPositionTable[NoteIDs.E4]  = brassPosition.fourth
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
        
        let trumpetPartialsForPos: BrassPartialsForPosition =
            partialsForPositionsTable[posForNote]
        
        trumpetPartialsForPos.printPartialsSummaryForThisNote(noteID: noteID)
    }

    override func printAllPartials() {
        guard kMKDebugOpt_PrintPerfAnalysisValues else { return }
        
        print ("\n------------------------------------------\n")
        print (" TRUMPET Positions, and their partials:\n")
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
            let trumpetPartialsForPos:BrassPartialsForPosition =
                    partialsForPositionsTable[posForNote]
            trumpetPartialsForPos.printAllPartialsForNote(noteID: oneNoteID)
        }
    }
}

