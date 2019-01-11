//
//  BrassPartials.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/28/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

///////////////////////////////////////////////////////////////////////////////
// This code identifies possible accidental overtones for different fingerings on
// the a brass instrument.
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
// To populate an instrument's Partials For Note with note tNoteFreqRangeData's,
// could get them from PerformanceAnalysisMgr's FreqRangeTable. But those ranges
// can be determined with a very wide percentage, to give the student a lot of
// latitude to play quite flat or sharp etc.
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
//   for a given brass instrument.
//
struct BrassPartialsForPosition
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
//   The possible overtones for a each target note on the instrument.
//
class BrassNotePartialsTable {

    //static let instance = BrassNotePartialsTable()
    
    struct brassPosition {
        static let first:Int   = 0
        static let second:Int  = 1
        static let third:Int   = 2
        static let fourth:Int  = 3
        static let fifth:Int   = 4
        static let sixth:Int   = 5
        static let seventh:Int = 6
        static let numPos:Int  = 7
    }
    
    // Must define noteToPositionRange for each instrument.  E.g., for Trumpet:
    //    let noteToPositionRange = NoteIDs.G3...NoteIDs.G5
    
    var noteToPositionTable = [NoteID : Int]()
    var partialsForPositionsTable = [BrassPartialsForPosition]()
    
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
        itsBad()  // Must override this func
        return kNotPartialForNote
    }
    
    func buildPartialsForPositionsTable() {
        // For each of the seven positions (fingerings):
        //     1) Create a BrassPartialsForPosition object
        //     2) Populate it with the possible partials (notes)
        //     3) Add the BrassPartialsForPosition object to the
        //        partialsForPositionsTable
        
        itsBad() // Must override this func
    }
    
    func buildNoteToPositionMap() {
        // Lookup table. Which Position is used for a given note?
        
        // Assign a position to each note in the range (a position is the 
        // fingering used to play the note). The position/fingering determines 
        // which overtones (partials) are possible for any note.

        itsBad() // Must override this func
    }
    
    ////////////////////////////////////////////////////////////////////
    //
    //   Testing, Debugging funcs from here down to end of class . . .
    //
    ////////////////////////////////////////////////////////////////////
    
    func printPartialsForThisNote( noteID: NoteID ) {
        itsBad() // Must override this func
    }

    func printAllPartials() {
        itsBad() // Must override this func
    }
    
    func printAllPartialsByNote() {
        itsBad() // Must override this func
    }
}

