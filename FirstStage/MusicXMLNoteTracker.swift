//
//  MusicXMLNoteTracker.swift
//  FirstStage
//
//  Created by Scott Freshour on 9/19/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//
//  Some Note data contained within the XML score is reported when the "start"
//  event occurs within TuneExer view, but some important info is not; for
//  the first implementation of this file, the only piece of data missing is
//  whether the note is part of a slur. This is important when deciding how to
//  treat changes in pitch: as a new note played within a slur, or just bad
//  technique.
//
//  This class, whose methods are called by MusicXMLModifier while it parses a
//  MusicXML file, stores this info on a per-note basis. The info is retrieved
//  in realtime while deciding to end a sound due to a pitch change while
//  playing legato.
//

import Foundation

let kNodNoteEntyryID = 0
struct NoteData {
    var noteID:    Int
    var beginSlur: Bool   // either first note of, or in middle of, a slur
    var endSlur:   Bool // is the last note of a slur
    
    init() {
        self.noteID     = kNodNoteEntyryID
        self.beginSlur  = false
        self.endSlur    = false
    }
}

class MusicXMLNoteTracker {
    
    static let instance = MusicXMLNoteTracker()

    var currentlyInSlur  = false
    var onLastNoteOfSlur = false
    var currentNoteID    = kNodNoteEntyryID
    
    var noteDataArray = [NoteData]()
    
    init() {
        self.noteDataArray.reserveCapacity(300)
    }

    /////////////////////////////////////////////////////////
    // Pre-processing methods
    func clearAllEntries() {
        noteDataArray.removeAll(keepingCapacity: true)
    }
    
    func addNoteEntry( _ data: NoteData) {
        noteDataArray.append(data)
    }

    /////////////////////////////////////////////////////////
    // Performance-time methods.
    
    // call just before performance begins
    func aboutToBeginPerformance() {
        currentNoteID    = kNodNoteEntyryID
        currentlyInSlur  = false
        onLastNoteOfSlur = false
    }
    
    func nowOnNote(noteID: Int) {
        currentNoteID += 1
        if !ASSUME(currentNoteID == noteID) {
            itsBad() }
        
        guard noteID <= noteDataArray.count else {
            itsBad()
            return
        }
        
        let oneEntry = noteDataArray[noteID-1]
        if oneEntry.beginSlur {
            currentlyInSlur = true
        }
        if oneEntry.endSlur {
            currentlyInSlur = false
            onLastNoteOfSlur = true
        }
    }
    
    func endingCurrentNote() {
        onLastNoteOfSlur = false
    }
    
    func isNoteWithinASlur() -> Bool {
        return currentlyInSlur
        /*
        // this SHOULD work, but cause all sorts of issues.  Revisit.
        if currentlyInSlur || onLastNoteOfSlur {
            return true
        } else {
            return false
        }
        */
    }
    
    func isNoteLastNoteOfASlur() -> Bool {
        return onLastNoteOfSlur
    }
}
