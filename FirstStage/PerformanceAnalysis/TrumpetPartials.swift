//
//  TrumpetPartials.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/1/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import Foundation

///////////////////////////////////////////////////////////////////////////////
// This code identifies possible accidental overtones for different fingerings on
// the trumpet.
//
// There are only 7 fingerings (also called positions) used on the trumpet, but many
// notes are possible with each fingering - the possibilities are called partials
// (or overtones); they are accomplished by changes in the lips, tounge, and force
// of air. It is therefore possible (easy?) for the beginning student to accidentally
// play one of these alternate notes (partials).
//
// When doing pitch analysis, _after_ the played note has defintiely been classified
// as the wrong pitch - well outside the expected pitch of the target note -  this
// code is used to detect if the played note is one of the possible partials. If so,
// feedback can be given to the student: how to change the mouth, etc., to get the
// right note.
//
// Lots of direction from Shawn.
//
// For a chart of the partials (overtones) and the fingerings check out the following:
// https://bobgillis.files.wordpress.com/2012/08/seven-overtone-series.pdf
//
///////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// To populate a trumpetPartialsForNote with note tNoteFreqRangeData's, could get
// them from PerformanceAnalysisMgr's FreqRangeTable. But those ranges can be
// determined with a very wide percentage, to give the student a lot of latitude
// to play quite flat or sharp etc.
// By creating separate tNoteFreqRangeData's directly, the range for partials is 
// fixed, and hopefully more accurate when determining that a wrong note _is_ a 
// partial.       
// Use this const to create these.
let kPartialFreqRangeTolerance = 0.97

typealias isPartialRetVal = (isPartial: Bool, partial: tNoteFreqRangeData)
let kNotPartialForNote = isPartialRetVal(false, kEmptyNoteFreqRangeData)

///////////////////////////////////////////////////////////////////////
//
//   The possible partials (overtones) for one position (fingering)
//   on the trumpet.
//
struct TrumpetPartialsForPosition
{
    var partials: [tNoteFreqRangeData] = [tNoteFreqRangeData]()
    var positionName = String()
    
    //////////////////////////////////////////////////////////
    // For adding partials by NoteID
    
    mutating func addPartialForNote( noteID: NoteID ) {
        let noteFRData =
            makeNoteFreqRange( noteID: noteID,
                               tolerancePercent: kPartialFreqRangeTolerance )
        partials.append(noteFRData)
    }
    
    mutating func addPartialsForNotes( noteIDs: [NoteID] ) {
        for oneNoteID in noteIDs {
            self.addPartialForNote( noteID: oneNoteID )
        }
    }
    
    // This func is the whole reason for this file. If the student is playing 
    // a wrong note, this will help determine if if they might be using the 
    // correct fingering but wrong tounge/lips/breath combo, thereby triggering 
    // one of the other notes of that position (fingering).
    func thisFreqIsAPartial( frequency: Double ) -> isPartialRetVal {
        var returnNoteFR = kNotPartialForNote
        
        for noteFR in partials {
            if noteFR.freqRange.contains( frequency ) {
                returnNoteFR = (true, noteFR)
                break
            }
        }
        return returnNoteFR
    }
    
    ////////////////////////////////////////////////////////////////////
    //
    //   Testing, Debugging from here down to end of class . . .
    //
    ////////////////////////////////////////////////////////////////////
    
    func printYourself() {
        guard kMKDebugOpt_PrintPerfAnalysisValues else { return }
        
        print ("  ------------------------------------------")
        print ("  Partials for Position: \(positionName)\n")
        for noteFR in partials {
            let lo = String(format: "%.3f", noteFR.freqRange.lowerBound)
            let hi = String(format: "%.3f", noteFR.freqRange.upperBound)
            print ("    Partial: \(noteFR.noteFullName)\t\t\t\t\t(Transposed Note Name)")
            print ("             \(lo) .. \(hi)\t\t(Frequency Range)")
            print ("                    (Concert Center Freq: \(noteFR.concertFreq))")
            print ("                    (Concert Note Name:   \(noteFR.concertNoteFullName))")
            print ("                    (Concert Note ID:     \(noteFR.concertNoteID))")
            print ("                    (Transposed Note ID:  \(noteFR.noteID))")
        }
    }
    
    func printPartialsSummaryForThisNote(noteID: NoteID) {
        guard kMKDebugOpt_PrintPerfAnalysisValues else { return }
        
        print ("           --------------------------------")
        let noteInfo = NoteService.getNote(Int(noteID))
        var noteName: String = "\(noteID)"
        if let noteInfo = noteInfo {
            noteName = noteInfo.fullName
        }
        print ("            Partials for: \(noteName)")
        for noteFR in partials {
            if noteFR.noteID == noteID { // ignore the note itself
                print ("                 ----- lower\\higher partials boundary -----" )
                continue
            }
            let centerF = String(format: "%.3f", noteFR.concertFreq)
            let lo      = String(format: "%.3f", noteFR.freqRange.lowerBound)
            let hi      = String(format: "%.3f", noteFR.freqRange.upperBound)
            print ("               \(noteFR.noteFullName),\t\tCenter: \(centerF),  \tRange: \(lo) .. \(hi))")
        }
    }

    func printAllPartialsForNote(noteID: NoteID) {
        guard kMKDebugOpt_PrintPerfAnalysisValues else { return }
        
        print ("  ------------------------------------------")
        let noteInfo = NoteService.getNote(Int(noteID))
        var noteName: String = "\(noteID)"
        if let noteInfo = noteInfo {
            noteName = noteInfo.fullName
        }
        print ("  Partials for Note: \(noteName)\n")
        for noteFR in partials {
            if noteFR.noteID == noteID { // ignore the note itself
                continue
            }
            let lo = String(format: "%.3f", noteFR.freqRange.lowerBound)
            let hi = String(format: "%.3f", noteFR.freqRange.upperBound)
            print ("    Partial: \(noteFR.noteFullName)\t\t\t\t\t(Transposed Note Name)")
            print ("             \(lo) .. \(hi)\t\t(Frequency Range)")
            print ("                    (Concert Center Freq: \(noteFR.concertFreq))")
            print ("                    (Concert Note Name:   \(noteFR.concertNoteFullName))")
            print ("                    (Concert Note ID:     \(noteFR.concertNoteID))")
            print ("                    (Transposed Note ID:  \(noteFR.noteID))")
        }
    }
}

///////////////////////////////////////////////////////////////////////
//
//   The possible overtones for a each target note on the trumpet.
//
struct TrumpetNotePartialsTable {

    static let instance = TrumpetNotePartialsTable()
    
    struct trumpetPosition {
        static let first:Int   = 0
        static let second:Int  = 1
        static let third:Int   = 2
        static let fourth:Int  = 3
        static let fifth:Int   = 4
        static let sixth:Int   = 5
        static let seventh:Int = 6
        static let numPos:Int  = 7
    }
    
    let noteToPositionRange = NoteIDs.G3...NoteIDs.G5
    var noteToPositionTable = [NoteID : Int]()
    var partialsForPositionsTable = [TrumpetPartialsForPosition]()
    
    init() {
        self.buildPartialsForPositionsTable()
        self.buildNoteToPositionMap()
    }

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
    func isThisFreqAPartialOfThisNote( freq: Double, note: NoteID ) -> isPartialRetVal {
        var isPartRetVal = kNotPartialForNote
            
        guard noteToPositionRange.contains(note) else { return isPartRetVal }
        guard let posForNote = noteToPositionTable[note]  else { return isPartRetVal }
            
        let trumpetPartialsForPos:TrumpetPartialsForPosition =
                                        partialsForPositionsTable[posForNote]
        isPartRetVal = trumpetPartialsForPos.thisFreqIsAPartial(frequency: freq)
            
        return isPartRetVal
    }
    
    mutating func buildPartialsForPositionsTable() {
        // For each of the seven positions (fingerings):
        //     1) Create a TrumpetPartialsForPosition object
        //     2) Populate it with the possible partials (notes)
        //     3) Add the TrumpetPartialsForPosition object to the
        //        partialsForPositionsTable
        
        partialsForPositionsTable.reserveCapacity(trumpetPosition.numPos)
        
        //---- firstPosition --------------------------------------------------
        var firstPosPartials = TrumpetPartialsForPosition()
        firstPosPartials.positionName = "First Position"
        let notesIn1stPos = [NoteIDs.C4, NoteIDs.G4, NoteIDs.C5, NoteIDs.E5,
                             NoteIDs.G5, NoteIDs.Bb5, NoteIDs.C6] // D6,too
        firstPosPartials.addPartialsForNotes(noteIDs: notesIn1stPos)
        self.partialsForPositionsTable.insert(firstPosPartials,
                                              at: trumpetPosition.first)
        //---- secondPosition -------------------------------------------------
        var secondPosPartials = TrumpetPartialsForPosition()
        secondPosPartials.positionName = "Second Position"
        let notesIn2ndPos = [NoteIDs.B3,  NoteIDs.Gb4, NoteIDs.B4, NoteIDs.Eb5,
                             NoteIDs.Gb5, NoteIDs.A5,  NoteIDs.B5] // Db6,too
        secondPosPartials.addPartialsForNotes(noteIDs: notesIn2ndPos)
        self.partialsForPositionsTable.insert(secondPosPartials,
                                              at: trumpetPosition.second)
        //---- thirdPosition---------------------------------------------------
        var thirdPosPartials = TrumpetPartialsForPosition()
        thirdPosPartials.positionName = "Third Position"
        let notesIn3rdPos = [NoteIDs.Bb3, NoteIDs.F4,  NoteIDs.Bb4, NoteIDs.D5,
                             NoteIDs.F5,  NoteIDs.Ab5, NoteIDs.Bb5, NoteIDs.C6]
        thirdPosPartials.addPartialsForNotes(noteIDs: notesIn3rdPos)
        self.partialsForPositionsTable.insert(thirdPosPartials,
                                              at: trumpetPosition.third)
        //---- fourthPosition -------------------------------------------------
        var fourthPosPartials = TrumpetPartialsForPosition()
        fourthPosPartials.positionName = "Fourth Position"
        let notesIn4thPos = [NoteIDs.A3, NoteIDs.E4, NoteIDs.A4, NoteIDs.Db5,
                             NoteIDs.E5, NoteIDs.G5, NoteIDs.A5, NoteIDs.B5]
        fourthPosPartials.addPartialsForNotes(noteIDs: notesIn4thPos)
        self.partialsForPositionsTable.insert(fourthPosPartials,
                                              at: trumpetPosition.fourth)
        //---- fifthPosition --------------------------------------------------
        var fifthPosPartials = TrumpetPartialsForPosition()
        fifthPosPartials.positionName = "Fifth Position"
        let notesIn5thPos = [NoteIDs.Ab3, NoteIDs.Eb4, NoteIDs.Ab4, NoteIDs.C5,
                             NoteIDs.Eb5, NoteIDs.Gb5, NoteIDs.Ab5,	NoteIDs.Bb5]
        fifthPosPartials.addPartialsForNotes(noteIDs: notesIn5thPos)
        self.partialsForPositionsTable.insert(fifthPosPartials,
                                              at: trumpetPosition.fifth)
        //---- sixthPosition --------------------------------------------------
        var sixthPosPartials = TrumpetPartialsForPosition()
        sixthPosPartials.positionName = "Sixth Position"
        let notesIn6thPos = [NoteIDs.G3, NoteIDs.D4, NoteIDs.G4, NoteIDs.B4,
                             NoteIDs.D5, NoteIDs.F5, NoteIDs.G5, NoteIDs.A5]
        sixthPosPartials.addPartialsForNotes(noteIDs: notesIn6thPos)
        self.partialsForPositionsTable.insert(sixthPosPartials,
                                              at: trumpetPosition.sixth)
        //---- seventhPosition ------------------------------------------------
        var seventhPosPartials = TrumpetPartialsForPosition()
        seventhPosPartials.positionName = "Seventh Position"
        let notesIn7thPos = [NoteIDs.Gb3, NoteIDs.Db4, NoteIDs.Gb4, NoteIDs.Bb4,
                             NoteIDs.Db5, NoteIDs.E5,  NoteIDs.Gb5, NoteIDs.Ab5]
        seventhPosPartials.addPartialsForNotes(noteIDs: notesIn7thPos)
        self.partialsForPositionsTable.insert(seventhPosPartials,
                                              at: trumpetPosition.seventh)
    }
    
    mutating func buildNoteToPositionMap() {
        // Lookup table. Which Position is used for a given note?
        
        // Assign a position to each note in the range (a position is the 
        // fingering used to play the note). The position/fingering determines 
        // which overtones (partials) are possible for any note.
        
        self.noteToPositionTable[NoteIDs.G3]  = trumpetPosition.sixth
        self.noteToPositionTable[NoteIDs.Ab3] = trumpetPosition.fifth
        self.noteToPositionTable[NoteIDs.A3]  = trumpetPosition.fourth
        self.noteToPositionTable[NoteIDs.Bb3] = trumpetPosition.third
        self.noteToPositionTable[NoteIDs.B3]  = trumpetPosition.second
        
        self.noteToPositionTable[NoteIDs.C4]  = trumpetPosition.first
        self.noteToPositionTable[NoteIDs.Db4] = trumpetPosition.seventh
        self.noteToPositionTable[NoteIDs.D4]  = trumpetPosition.sixth
        self.noteToPositionTable[NoteIDs.Eb4] = trumpetPosition.fifth
        self.noteToPositionTable[NoteIDs.E4]  = trumpetPosition.fourth
        self.noteToPositionTable[NoteIDs.F4]  = trumpetPosition.third
        self.noteToPositionTable[NoteIDs.Gb4] = trumpetPosition.second
        self.noteToPositionTable[NoteIDs.G4]  = trumpetPosition.first
        self.noteToPositionTable[NoteIDs.Ab4] = trumpetPosition.fifth
        self.noteToPositionTable[NoteIDs.A4]  = trumpetPosition.fourth
        self.noteToPositionTable[NoteIDs.Bb4] = trumpetPosition.third
        self.noteToPositionTable[NoteIDs.B4]  = trumpetPosition.second
        
        self.noteToPositionTable[NoteIDs.C5]  = trumpetPosition.first
        self.noteToPositionTable[NoteIDs.Db5] = trumpetPosition.fourth
        self.noteToPositionTable[NoteIDs.D5]  = trumpetPosition.third
        self.noteToPositionTable[NoteIDs.Eb5] = trumpetPosition.second
        self.noteToPositionTable[NoteIDs.E5]  = trumpetPosition.first
        self.noteToPositionTable[NoteIDs.F5]  = trumpetPosition.third
        self.noteToPositionTable[NoteIDs.Gb5] = trumpetPosition.second
        self.noteToPositionTable[NoteIDs.G5]  = trumpetPosition.first
    }
    
    ////////////////////////////////////////////////////////////////////
    //
    //   Testing, Debugging funcs from here down to end of class . . .
    //
    ////////////////////////////////////////////////////////////////////
    
    func printPartialsForThisNote( noteID: NoteID ) {
        guard kMKDebugOpt_PrintPerfAnalysisValues else { return }
        guard noteToPositionRange.contains(noteID) else { return  }
        guard let posForNote = noteToPositionTable[noteID]  else { return  }
        
        let trumpetPartialsForPos: TrumpetPartialsForPosition =
            partialsForPositionsTable[posForNote]
        
        trumpetPartialsForPos.printPartialsSummaryForThisNote(noteID: noteID)
    }

    func printAllPartials() {
        guard kMKDebugOpt_PrintPerfAnalysisValues else { return }
        
        print ("\n------------------------------------------\n")
        print (" Positions, and their partials:\n")
        var ptlsForPos = self.partialsForPositionsTable[trumpetPosition.first]
        ptlsForPos.printYourself()
        
        ptlsForPos = self.partialsForPositionsTable[trumpetPosition.second]
        ptlsForPos.printYourself()
        
        ptlsForPos = self.partialsForPositionsTable[trumpetPosition.third]
        ptlsForPos.printYourself()
        
        ptlsForPos = self.partialsForPositionsTable[trumpetPosition.fourth]
        ptlsForPos.printYourself()
        
        ptlsForPos = self.partialsForPositionsTable[trumpetPosition.fifth]
        ptlsForPos.printYourself()
        
        ptlsForPos = self.partialsForPositionsTable[trumpetPosition.sixth]
        ptlsForPos.printYourself()
        
        ptlsForPos = self.partialsForPositionsTable[trumpetPosition.seventh]
        ptlsForPos.printYourself()
        print ("\n------------------------------------------\n")
    }
    
    func printAllPartialsByNote() {
        guard kMKDebugOpt_PrintPerfAnalysisValues else { return }
        
        for oneNoteID in noteToPositionRange {
            guard let posForNote = noteToPositionTable[oneNoteID]
                else { continue }
            let trumpetPartialsForPos:TrumpetPartialsForPosition =
                    partialsForPositionsTable[posForNote]
            trumpetPartialsForPos.printAllPartialsForNote(noteID: oneNoteID)
        }
    }
}

