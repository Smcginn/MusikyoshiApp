//
//  RuntimeEventManager.swift
//  FirstStage
//
//  Created by Scott Freshour on 8/29/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//

import Foundation

// E.g., RTEventMgr.Instance
typealias RTEventMgr = RuntimeEventManager

let kRuntimeEventType_NotSet        = 0
let kRuntimeEventType_SongStart     = 1
let kRuntimeEventType_Amplitude     = 2
let kRuntimeEventType_Pitch         = 3
let kRuntimeEventType_NewSound      = 4
let kRuntimeEventType_SoundEnded    = 5
let kRuntimeEventType_NewNote       = 6
let kRuntimeEventType_NoteEnded     = 7

let kRTEVDetail_NotSet              = 0
let kRTEVDetail_SoundEnd_Detected   = 1
let kRTEVDetail_SoundEnd_AmpRise    = 2
let kRTEVDetail_SoundEnd_Pitch      = 3
let kRTEVDetail_NewSound_Detected   = 4
let kRTEVDetail_NewSound_AmpRise    = 5
let kRTEVDetail_NewSound_Pitch      = 6

let kRTEVObjectType_NotSet          = 0
let kRTEVObjectType_NoSound         = 1
let kRTEVObjectType_Sound           = 2
let kRTEVObjectType_Note            = 3

let kNoSoundObject: Int32 = -1
// Song Start


struct tRuntimeEvent {
    
    var eventType:      Int
    var eventDetail1:   Int
    var objectType:     Int
    var associatedID:   Int32   // E.g., Note or Sound ID
    var timestamp:      TimeInterval
    var value:          Double // E.g., amplitude, frequency, etc.
    
    init( eventType:      Int,
          eventDetail1:   Int,
          objectType:     Int,
          associatedID:   Int32,
          timestamp:      TimeInterval,
          value:          Double
        ) {
        self.eventType       = eventType
        self.eventDetail1    = eventDetail1
        self.objectType      = objectType
        self.associatedID    = associatedID
        self.timestamp       = timestamp
        self.value           = value
    }
    
    init( eventType:      Int,
          eventDetail1:   Int,
          objectType:     Int,
          associatedID:   Int32,
          timestamp:      TimeInterval
        ) {
        self.eventType       = eventType
        self.eventDetail1    = eventDetail1
        self.objectType      = objectType
        self.associatedID    = associatedID
        self.timestamp       = timestamp
        self.value           = 0
    }
}

let tEmptyRuntimeEvent = tRuntimeEvent(eventType:      kRuntimeEventType_NotSet,
                                       eventDetail1:   kRTEVDetail_NotSet,
                                       objectType:     kRTEVObjectType_NotSet,
                                       associatedID:   0,
                                       timestamp:      0.0)

let kEventArrayCapacity = 15000

class RuntimeEventManager {
    
    static let sharedInstance = RuntimeEventManager()

    var largestAmpValue: Double = 0.0
    
    
    private var numEvents = 0
    private var eventQueue = [tRuntimeEvent]()
    var acceptEntries = false
    
    init() {
        self.eventQueue.reserveCapacity(kEventArrayCapacity)
    }
    
    func count() -> Int {
        return numEvents
    }
    
    func getEventAt(index: Int) -> tRuntimeEvent {
        var retEvent = tEmptyRuntimeEvent
        guard index < numEvents else { return retEvent }
        guard index < eventQueue.capacity else { return retEvent }

        retEvent = eventQueue[index]
        return retEvent
    }
    
    func clearAllEntries() {
        var numEntries  = eventQueue.count
        var cap         = eventQueue.capacity
        eventQueue.removeAll(keepingCapacity: true)
        numEntries  = eventQueue.count
        cap         = eventQueue.capacity
        numEvents = 0
        acceptEntries = false
        largestAmpValue = 0.0
    }
    
    func startAcceptingEntries() {
        acceptEntries = true
    }
    
    func addEntry(newEvent: tRuntimeEvent) {
        guard acceptEntries else { return }
        guard numEvents < kEventArrayCapacity else { return }
        
        if numEvents < eventQueue.capacity {
            eventQueue.append(newEvent)
            //eventQueue[numEvents] = newEvent
//        } else {
//            eventQueue.append(newEvent)
        }
        numEvents += 1
        if numEvents % 50 == 0 {
            print("\nIn RuntimeEventManager.addEntry(), numEvents = \(numEvents)\n")
        }
        if newEvent.eventType == kRuntimeEventType_Amplitude &&
           newEvent.value > largestAmpValue  {
            largestAmpValue = newEvent.value
        }
    }
    
    func getDisplayStringForEntry(idx: Int) -> String {
        let entry = eventQueue[idx]
        
        var retStr = "---------------\n"
        
        switch entry.eventType {
        case kRuntimeEventType_SongStart:
            retStr +=  getDisplayStringForSongStart(event: entry)
        case kRuntimeEventType_Amplitude:
            retStr +=  getDisplayStringForAmpChange(event: entry)
        case kRuntimeEventType_NewSound:
            retStr +=  getDisplayStringForSoundStart(event: entry)
        case kRuntimeEventType_SoundEnded:
            retStr +=  getDisplayStringForSoundEnd(event: entry)
            
//        case kRuntimeEventType_NewNote:     return "New Note"
//        case kRuntimeEventType_NoteEnded:   return "Note Ended"
//        case kRuntimeEventType_Pitch:       return "Frequency"

        default:
            return ""
        }
        
        return retStr
    }
    
    func getDisplayStringForSongStart(event: tRuntimeEvent) -> String {
        
        var retStr = ""
        retStr += getEventTypeString(eventType: event.eventType)
        return retStr
    }
    
    func getDisplayStringForAmpChange(event: tRuntimeEvent) -> String {
        
        var retStr = "  "
        retStr += getEventTypeString(eventType: event.eventType)
        retStr += "\n    "
        
        
        let ampValStr   = String(format: "%.3f", event.value)
        let timeStr     = String(format: "%.3f", event.timestamp)
        retStr += "Time:  " + timeStr + "\n    "
        retStr += "Value: " + ampValStr
        
        return retStr
    }
    
    
    func getDisplayStringForSoundStart(event: tRuntimeEvent) -> String {
        
        var retStr = ""
        retStr += getEventTypeString(eventType: event.eventType)
        
        return retStr
    }
    
    func getDisplayStringForSoundEnd(event: tRuntimeEvent) -> String {
        
        var retStr = ""
        retStr += getEventTypeString(eventType: event.eventType)
         
        return retStr
    }
 
    
    func getEventTypeString(eventType: Int) -> String {
        switch eventType {
            case kRuntimeEventType_SongStart:   return "Song Start"
            case kRuntimeEventType_Amplitude:   return "Amplitude Change"
            case kRuntimeEventType_Pitch:       return "Frequency Change"
            case kRuntimeEventType_NewSound:    return "New Sound"
            case kRuntimeEventType_SoundEnded:  return "Sound Ended"
            case kRuntimeEventType_NewNote:     return "New Note"
            case kRuntimeEventType_NoteEnded:   return "Note Ended"

            default: return ""
        }
        
        return ""
    }
    
    func getEventDetailString(eventDetail: Int) -> String {
        switch eventDetail {
        case kRTEVDetail_SoundEnd_Detected: return "Sound Stopped"
        case kRTEVDetail_SoundEnd_AmpRise:  return "Amplitude Rise"
        case kRTEVDetail_SoundEnd_Pitch:    return "Legato Pitch Change"
        case kRTEVDetail_NewSound_Detected: return "Sound Detected"
        case kRTEVDetail_NewSound_AmpRise:  return "Amplitude Rise"
        case kRTEVDetail_NewSound_Pitch:    return "Legato Pitch Change"
            
        default: return ""
        }
        
        return ""
    }

}

/////////////////////////////////////////////////////
//
//  Convenience Funcs
//

func createAmplitudeEvent( currSoundID:   Int32 = kNoSoundObject,
                           timestamp:     TimeInterval,
                           amplitude:     Double ) -> tRuntimeEvent {
    
    let objType   = currSoundID == kNoSoundObject ? kRTEVObjectType_NoSound
        : kRTEVObjectType_Sound
    
    //    let evtDetail = currSoundID == kNoSoundObject ? kRTEVDetail_NoSoundObj
    //                                                  : kRTEVDetail_CurrSoundObj
    
    let event = tRuntimeEvent(eventType:    kRuntimeEventType_Amplitude,
                              eventDetail1: kRTEVDetail_NotSet,
                              objectType:   objType,
                              associatedID: currSoundID,
                              timestamp:    timestamp,
                              value:        amplitude    )
    return event
}

func createSoundStartEvent( newSoundID:    Int32 = kNoSoundObject,
                            timestamp:     TimeInterval,
                            reason:        Int ) -> tRuntimeEvent {
    
    //    let objType   = currSoundID == kNoSoundObject ? kRTEVObjectType_NoSound
    //        : kRTEVObjectType_Sound
    //
    //    let evtDetail = currSoundID == kNoSoundObject ? kRTEVDetail_NoSoundObj
    //        : kRTEVDetail_CurrSoundObj
    
    let event = tRuntimeEvent(eventType:    kRuntimeEventType_NewSound,
                              eventDetail1: reason,
                              objectType:   kRTEVObjectType_Sound,
                              associatedID: newSoundID,
                              timestamp:    timestamp
    )
    print("\n   YO - Created SoundStarted Event")
    return event
}

func createSoundEndEvent( soundID:       Int32 = kNoSoundObject,
                          timestamp:     TimeInterval,
                          reason:        Int ) -> tRuntimeEvent {
    
    //    let objType   = currSoundID == kNoSoundObject ? kRTEVObjectType_NoSound
    //        : kRTEVObjectType_Sound
    //
    //    let evtDetail = currSoundID == kNoSoundObject ? kRTEVDetail_NoSoundObj
    //        : kRTEVDetail_CurrSoundObj
    
    let event = tRuntimeEvent(eventType:    kRuntimeEventType_SoundEnded,
                              eventDetail1: reason,
                              objectType:   kRTEVObjectType_Sound,
                              associatedID: soundID,
                              timestamp:    timestamp
    )
    print("\n   YO - Created SoundEnded Event")
    return event
}


func createNoteStartEvent( newNoteID:     Int32 = kNoSoundObject,
                           timestamp:     TimeInterval ) -> tRuntimeEvent {
    
    //    let objType   = currSoundID == kNoSoundObject ? kRTEVObjectType_NoSound
    //        : kRTEVObjectType_Sound
    //
    //    let evtDetail = currSoundID == kNoSoundObject ? kRTEVDetail_NoSoundObj
    //        : kRTEVDetail_CurrSoundObj
    
    let event = tRuntimeEvent(eventType:    kRuntimeEventType_NewNote,
                              eventDetail1: kRTEVDetail_NotSet,
                              objectType:   kRTEVObjectType_Sound,
                              associatedID: newNoteID,
                              timestamp:    timestamp
    )
    print("\n   YO - Created NoteStarted Event")
    return event
}

func createNoteEndEvent( noteID:        Int32 = kNoSoundObject,
                         timestamp:     TimeInterval ) -> tRuntimeEvent {
    
    //    let objType   = currSoundID == kNoSoundObject ? kRTEVObjectType_NoSound
    //        : kRTEVObjectType_Sound
    //
    //    let evtDetail = currSoundID == kNoSoundObject ? kRTEVDetail_NoSoundObj
    //        : kRTEVDetail_CurrSoundObj
    
    let event = tRuntimeEvent(eventType:    kRuntimeEventType_NoteEnded,
                              eventDetail1: kRTEVDetail_NotSet,
                              objectType:   kRTEVObjectType_Sound,
                              associatedID: noteID,
                              timestamp:    timestamp
    )
    print("\n   YO - Created NoteEnded Event")
    return event
}



/*
 func you() {
 let event = tRuntimeEvent(eventType:    kRuntimeEventType_Amplitude,
 eventDetail1: kRTEVDetail_CurrSoundObj,
 objectType:   0,
 associatedID: 3,
 timestamp:    TimeInterval()
 )
 
 }
 */

