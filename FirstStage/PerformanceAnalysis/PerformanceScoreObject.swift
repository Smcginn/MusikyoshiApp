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
    
    enum perfObjStatus {
        case pendingStart
        case active
        case ended
    }
    var status: perfObjStatus = .pendingStart
    var completed: Bool = false
    
    var willEndSoon = false
    
    func hasEnded() -> Bool {
        return status == .ended ? true : false
    }
    
    func isActive() -> Bool {
        return status == .active ? true : false
    }

    ////////////////////////////////////////////////////////////////////////////
    //  ""Expected": values based on XML file: EXACTLY when the note/rest
    //  should start and end, and it's duration. These are used to determine if
    //  sound is associated with note/rest, and to grade performance, etc.
    //
    //  In TimeIntervals since the beginning of song playback
    //     (Sound times are intervals since analysis start)
    var _expectedStartTime      : TimeInterval = noTimeValueSet
    var _expectedStartTime_comp : TimeInterval = noTimeValueSet
    var _expectedEndTime        : TimeInterval = noTimeValueSet
    var _expectedEndTime_comp   : TimeInterval = noTimeValueSet
    var _expectedDuration       : TimeInterval = noTimeValueSet
    var _expectedDurAdjusted    : TimeInterval = noTimeValueSet
    
    // This will be used when evaluating Sounds that begin while
    // Rest supposedly still active
    var _expectedEndTimeMinusTolerance: TimeInterval = noTimeValueSet
    
    // Used by Scheduler
    var _deactivateTime         : TimeInterval = noTimeValueSet
    var _deactivateTime_comp    : TimeInterval = noTimeValueSet

    // The ammount to deduct when evaluating the performance duration. Notes
    // can't be exactly right next to each other. Some gap must be allowed.
    let kDurationAdjustment = 0.05 // milliseconds. Change this to dial in.

    func setExpectedTimes( startTime: TimeInterval, duration: TimeInterval ) {
        let soundStartOffset = getSoundStartOffset()
        _expectedStartTime      = startTime
        _expectedDuration       = duration
        _expectedDurAdjusted    = _expectedDuration - kDurationAdjustment
        _expectedEndTime        = _expectedStartTime + _expectedDuration
        _expectedStartTime_comp = _expectedStartTime + soundStartOffset // changed + to -
        _expectedEndTime_comp   = _expectedEndTime   + soundStartOffset // changed + to -
//        _expectedStartTime_comp = _expectedStartTime + gSoundStartAdjustment // changed + to -
//        _expectedEndTime_comp   = _expectedEndTime   + gSoundStartAdjustment // changed + to -

        _expectedEndTimeMinusTolerance =
            _expectedEndTime - PerformanceAnalysisMgr.instance.currTolerances.rhythmTolerance
        
//        _deactivateTime
//            = self.isNote() ? _expectedEndTimeMinusTolerance
//                            : _expectedStartTime + _expectedDurAdjusted
        _deactivateTime
            = self.isNote() ? (_expectedStartTime + _expectedDuration) - gAdjustAttackVar_VeryOff
                            : (_expectedStartTime + _expectedDuration) - gAdjustAttackVar_VeryOff

        
        //_deactivateTime_comp   = _deactivateTime // removed: - gSoundStartAdjustment
        
        _deactivateTime_comp
            = self.isNote() ? (_expectedStartTime + _expectedDuration) - (gAdjustAttackVar_ABitOff*0.33)
                            : (_expectedStartTime + _expectedDuration) - gAdjustAttackVar_VeryOff
    }
    
    var expectedStartTime   : TimeInterval {
        return _expectedStartTime
    }
    var expectedStartTime_comp   : TimeInterval {
        return _expectedStartTime_comp
    }
    var expectedEndTime   : TimeInterval {
        return _expectedEndTime
    }
    var expectedEndTime_comp   : TimeInterval {
        return _expectedEndTime_comp
    }
    var expectedEndTimeMinusTolerance   : TimeInterval {
        return _expectedEndTimeMinusTolerance
    }
    var expectedDuration   : TimeInterval {
        return _expectedDuration
    }
    var expectedDurAdjusted   : TimeInterval {
        return _expectedDurAdjusted
    }

    ////////////////////////////////////////////////////////////////////////////
    //  ""Actual": values based on performance: When the note/rest
    //  actually started, ended, and it's actual duration. These are compared to
    //  "expected" values to determine to grade performance, etc.
    //
    //  These are TimeIntervals since the beginning of song playback
    //     (Sound times are intervals since analysis start)
    var _actualStartTime_song:      TimeInterval = noTimeValueSet
    var _actualStartTime_comp: TimeInterval = noTimeValueSet
    var actualStartTime_song: TimeInterval {
        set {
            _actualStartTime_song = newValue
            let soundStartOffset = getSoundStartOffset()
            _actualStartTime_comp = _actualStartTime_song - soundStartOffset
            //_actualStartTime_comp = _actualStartTime_song - gSoundStartAdjustment
        }
        get {
            return _actualStartTime_song
        }
    }
    var actualStartTime_comp: TimeInterval {
        return _actualStartTime_comp
    }
    
    var _actualEndTime_abs:  TimeInterval = noTimeValueSet
    var _actualEndTime_song: TimeInterval = noTimeValueSet
    var _actualEndTime_comp: TimeInterval = noTimeValueSet
    // This is called by Sound, or Soundlinking, and therefore must take a
    // Sound-relative timestamp
    func setActualEndTimeAbs( endTimeAbs: TimeInterval) {
        _actualEndTime_abs  = endTimeAbs
        _actualEndTime_song = soundTimeToNoteTimeExt(soundStart: endTimeAbs)
        let soundStartOffset = getSoundStartOffset()
        _actualEndTime_comp = _actualEndTime_song - soundStartOffset
        // _actualEndTime_comp = _actualEndTime_song - gSoundStartAdjustment
        _actualDuration     = _actualEndTime_song - _actualStartTime_song
    }
    var actualEndTime_song: TimeInterval {
        return _actualEndTime_song
    }
    var actualEndTime_abs: TimeInterval {
        return _actualEndTime_abs
    }
    var actualEndTime_comp: TimeInterval {
        return _actualEndTime_comp
    }
    
    var _actualDuration : TimeInterval = noTimeValueSet
    var actualDuration  : TimeInterval {
        return _actualDuration
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

