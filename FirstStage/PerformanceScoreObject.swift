//
//  PerformanceScoreObject.swift
//  FirstStage
//
//  Created by Scott Freshour on 7/20/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

enum scoreObjectType {
    case note
    case rest
}

public class PerformanceScoreObject
{
    var scoreObjType : scoreObjectType  = .note
    func isNote() -> Bool {
        if ( scoreObjType == .note ) {
            return true
        } else {
            return false
        }
    }
    func isRest() -> Bool {
        if ( scoreObjType == .rest ) {
            return true
        } else {
            return false
        }
    }
    
    var perfScoreObjectID   = noScoreObjIDSet
    var perfNoteOrRestID    = noScoreObjIDSet
    var isLinkedToSound     = false
    var linkedToSoundID     = noSoundIDSet
    public weak var linkedSoundObject : PerformanceSound?
    func linkToSound( soundID : Int32, sound: PerformanceSound? ) {
        linkedToSoundID = soundID
        isLinkedToSound = true
        linkedSoundObject = sound
    }
    
    // The X-Coord of where on the scrolling view the XMLMusic note is diaplayed.
    // Used to specify where to draw note-related factoids (debug or otherwise).
    var xPos : Int32 = 0
    var yPos : Int32 = 0
    
    // the performance issue for each category, if there was one
    var attackRating: performanceRating   = .notRated
    var durationRating: performanceRating = .notRated
    var pitchRating: performanceRating    = .notRated
    
    // the weighted score, or severity of the issue for each category
    var attackScore:   Int =  0  // 0 is the best, 1 next best, etc.
    var durationScore: Int =  0
    var pitchScore:    Int =  0
    var weightedScore: Int =  0  // Overall; combined of the above
    
    // class functions/var; ID to uniquely identify PerformanceNote objects
    static private var currUniqueScoreObjectID : Int32 = noScoreObjIDSet
    static private var currUniqueNoteID : Int32 = noScoreObjIDSet
    static private var currUniqueRestID : Int32 = noScoreObjIDSet
    static func getUniqueScoreObjectID() -> Int32 {
        PerformanceScoreObject.currUniqueScoreObjectID += 1
        return PerformanceScoreObject.currUniqueScoreObjectID
    }
    static func getUniqueNoteID() -> Int32 {
        PerformanceScoreObject.currUniqueNoteID += 1
        return PerformanceScoreObject.currUniqueNoteID
    }
    static func getUniqueRestID() -> Int32 {
        PerformanceScoreObject.currUniqueRestID += 1
        return PerformanceScoreObject.currUniqueRestID
    }
    
    static func resetUniqueIDs() {
        PerformanceScoreObject.currUniqueScoreObjectID = noScoreObjIDSet
        PerformanceScoreObject.currUniqueNoteID = noScoreObjIDSet
        PerformanceScoreObject.currUniqueRestID = noScoreObjIDSet
    }
    
    init (noteOrRest : scoreObjectType) {
        scoreObjType = noteOrRest
        perfScoreObjectID = PerformanceScoreObject.getUniqueScoreObjectID()
    }
    
    deinit {
        // here for debugging, making sure there are no reference cycles
        if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput {
            print ( "De-initing Perf Score Object \(perfScoreObjectID)" )
        }
    }
    
    // Used by an Alert to populate the messageString with data about this Note.
    //  (The Alert is a debug feature. It is not visible in release mode.)
    func constructSummaryMsgString( msgString: inout String )
    {
    }
}

