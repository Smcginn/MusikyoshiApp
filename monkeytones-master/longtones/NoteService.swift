//
//  NoteService.swift
//  longtones
//
//  Created by Adam Kinney on 6/7/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


struct NoteService {
    fileprivate static var notes = [Note]()
    
    static func getNote(_ step: String, octave: Int) -> Note? {
        let comparisionSet = notes.filter{ n in n.name == step }
        if comparisionSet.count == 1
        {
            return comparisionSet[0]
        }
        else
        {
            return nil
        }
    }
    
    /*
    static func getNote(_ frequency: Float) -> Note? {
        var orderId : Int = -1
        
        for n in notes{
            if(frequency < n.frequency)
            {
                orderId = n.orderId
                break
            }
        }
        
        if(orderId > -1)
        {
            let comparisionSet = notes.filter{ n in n.orderId == orderId || n.orderId == orderId-1 }.sorted(by: { $0.orderId < $1.orderId })
            if comparisionSet.count > 1
            {
                //                for n in comparisionSet
                //                {
                //                    print("comparision n: " + n.name)
                //                }
                
                let aValue = abs(comparisionSet[0].frequency - frequency)
                let bValue = abs(comparisionSet[1].frequency - frequency)
                //print(String(format: "aValue: %f bValue: %f", aValue, bValue))
                if aValue > bValue
                {
                    //print("return 1: " + comparisionSet[1].name)
                    return comparisionSet[1]
                }
                else
                {
                    //print("return 0: " + comparisionSet[0].name)
                    return comparisionSet[0]
                }
            }
            else if comparisionSet.count == 1
            {
                return comparisionSet[0]
            }
            else
            {
                print("getNote:: no note, freq: \(frequency)")
                return nil
            }
        }
        else
        {
            print("getNote:: no note, freq: \(frequency)")
            return nil
        }
    }
    */
    static func getNote(_ orderId: Int) -> Note? {
        if(orderId > -1)
        {
            let comparisionSet = notes.filter{ n in n.orderId == orderId}
            if comparisionSet.count == 1
            {
                return comparisionSet[0]
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    /*
    static func getNoteOffset(_ orderId: Int) -> NoteOffset? {
        
        let instrumentId = DataService.sharedInstance.currentInstrumentId
        let instrument = InstrumentService.getInstrument(instrumentId)

        //var no = NoteOffset(0, 0)
        //no.character = .Staff2LineWide
        
        //return no
        var no = NoteOffset(-3, 20)
        no.character = .Staff1LineWide
        return no

        switch orderId
        {
        case 42: //F3
            var no = NoteOffset(-3, 10)
            no.character = .Staff3LineWide
            return no
        case 44: //G3
            var no = NoteOffset(-3, 10)
            no.character = .Staff2LineWide
            return no
        case 46: //A3
            var no = NoteOffset(-3, 15)
            no.character = .Staff2LineWide
            return no
        case 47: //B♭3
            return NoteOffset(-3, 15)
        case 49: //C4
            return NoteOffset(-3, 20)
        default:
            return nil
        }
    }
 */
    
    static func getYPos(_ orderId: Int) -> Double{
        
        let instrumentId = DataService.sharedInstance.currentInstrumentId
        let instrument = InstrumentService.getInstrument(instrumentId)
        
        let notes = InstrumentService.getInstrumentNotes(instrumentId)
        var index = notes.index(where: {$0.orderId == DataService.sharedInstance.currentNoteId})
        index = index ?? 0

        var y = 0.0
        
        switch index!
        {
        case 0:
            y = 30
        case 1:
            y = 25
        case 2:
            y = 20
        case 3:
            y = 15
        case 4:
            y = 10
        case 5:
            y = 5
        case 6:
            y = 0
        case 7:
            y = -5
        case 8: 
            y = -10
        default:
            print(String(format: "missing getYPos %d", orderId))
            y = -50
        }
        
        if instrument?.name == InstrumentName.trombone || instrument?.name == InstrumentName.altoSaxophone || instrument?.name == InstrumentName.baritoneSaxophone
        {
            y -= 40
        }
        else if instrument?.name == InstrumentName.clarinet || instrument?.name == InstrumentName.trumpet
        {
            y -= 20
        }
        else if instrument?.name == InstrumentName.frenchHorn
        {
            y -= 35
        }
        else if instrument?.name == InstrumentName.tenorSaxophone
        {
            y -= 55
        }
        else if instrument?.name == InstrumentName.tuba
        {
            y -= 5
        }
        else
        {
            y -= 50
        }
        
        
        return y
    }
    
    static func initNotes(){
        //♯
        //♭
        
        notes.append(Note(116.54, "B♭", 35))
        notes.append(Note(130.81, "C", 37))
        notes.append(Note(146.83, "D", 39))
        notes.append(Note(155.56, "E♭", 40))
        notes.append(Note(174.61, "F", 42))
        notes.append(Note(196, "G", 44))
        notes.append(Note(220, "A", 46))
        
        notes.append(Note(233.08, "B♭",47))
        notes.append(Note(233.08, "C", 147))
        notes.append(Note(233.08, "G", 247))
        
        notes.append(Note(261.63, "C", 49))
        notes.append(Note(261.63, "D", 149))
        notes.append(Note(261.63, "A", 249))
        
        notes.append(Note(293.66, "D", 51))
        notes.append(Note(293.66, "E", 151))
        notes.append(Note(293.66, "B", 251))

        notes.append(Note(311.13, "F", 152))
        notes.append(Note(311.13, "C", 252))

        notes.append(Note(349.23, "F", 54))
        notes.append(Note(349.23, "G", 154))
        notes.append(Note(349.23, "D", 254))

        notes.append(Note(392, "G", 56))
        notes.append(Note(392, "A", 156))
        notes.append(Note(392, "E", 256))

        notes.append(Note(440, "A", 58))
        notes.append(Note(440, "B", 158))
        notes.append(Note(440, "F#", 258))

        
        notes.append(Note(466.16, "B♭", 59))
        notes.append(Note(466.16, "C", 159))
        notes.append(Note(466.16, "G", 259))

        
        notes.append(Note(493.88, "B", 60))
        notes.append(Note(523.25, "C", 61))
        notes.append(Note(587.33, "D", 63))
        notes.append(Note(622.25, "E♭", 64))
        notes.append(Note(659.25, "E", 65))
        notes.append(Note(698.46, "F", 66))
        notes.append(Note(783.99, "G", 68))
        notes.append(Note(880, "A", 70))
        
        notes.append(Note(932.33, "B♭", 71))
        notes.append(Note(1046.5, "C", 73))
        notes.append(Note(1318.51, "E", 77))

    }
    
}
