//
//  NoteService.swift
//  Trumpet1
//
//  Created by Adam Kinney on 11/6/15.
//  Changed by David S Reich - 2016.
//  Copyright © 2015 Musikyoshi. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
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
        let comparisionSet = notes.filter{ n in n.name == step && n.octave == octave }
        if comparisionSet.count == 1
        {
            return comparisionSet[0]
        }
        else
        {
            return nil
        }
    }

    static func getNote(_ frequency: Float) -> Note? {
        return NoteService.getNote(Double(frequency))
    }

    static func getNote(_ frequency: Double) -> Note? {
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
    
    static func getNoteOffset(_ orderId: Int) -> NoteOffset? {
        switch orderId
        {
            case 53: //F3
                var no = NoteOffset(-3, 10)
                no.character = .Staff3LineWide
                return no
            case 55: //G3
                var no = NoteOffset(-3, 10)
                no.character = .Staff2LineWide
                return no
            case 57: //A3
                var no = NoteOffset(-3, 15)
                no.character = .Staff2LineWide
                return no
            case 58: //B♭3
                return NoteOffset(-3, 15)
            case 60: //C4
                return NoteOffset(-3, 20)
            default:
                return nil
        }
    }
    
    //TODO: this doesn't work for #s
    //figure out a way to fix it
    static func getYPos(_ orderId: Int) -> Double{
        
        switch orderId
        {
            case 53: //F3
                return 30
            case 54: //G♭3
                return 25
            case 55: //G3
                return 25
            case 56: //A♭3
                return 20
            case 57: //A3
                return 20
            case 58: //B♭3
                return 15
            case 59: //B3
                return 15
            case 60: //C4
                return 10
            case 61: //D♭4
                return 5
            case 62: //D4
                return 5
            case 63: //E♭4
                return 0
            case 64: //E4
                return 0
            case 65: //F4
                return -5
            case 66: //G♭4
                return -10
            case 67: //G4
                return -10
            case 68: //A♭
                return -15
            case 69: //A4
                return -15
            case 70: //B♭4
                return -20
            case 71: //B4
                return -20
            case 72: //C5
                return -25
            case 73: //D♭5
                return -25
            case 74: //D5
                return -30
            case 75: //E♭5
                return -30
            case 76: //E5
                return -35
            case 77: //F5
                return -40
            case 78: //Gb5
                return -45
            case 79: //G5
                return -45
            case 80: //Ab5
                return -50
            case 81: //A5
                return -50
            default:
                print(String(format: "missing getYPos %d", orderId))
                return -50
        }
    }

    static func getLowestFrequency() -> Double {
        if let n = notes.first {
            return n.frequency
        }
        return 0
    }
    
    static func getHighestFrequency() -> Double {
        if let n = notes.last {
            return n.frequency
        }
        return 0
    }
    
    static func initNotes() {
        //♯
        //♭

        notes.append(Note(116.54, "A♯", 2, 46, "B♭"))
        notes.append(Note(123.47, "B", 2, 47))
        notes.append(Note(130.81, "C", 3, 48))
        notes.append(Note(138.59, "C♯", 3, 49, "D♭"))
        notes.append(Note(146.83, "D", 3, 50))
        notes.append(Note(155.56, "D♯", 3, 51, "E♭"))
        notes.append(Note(164.81, "E", 3, 52))
        notes.append(Note(174.61, "F", 3, 53))
        notes.append(Note(185, "F♯", 3, 54, "G♭"))
        notes.append(Note(196, "G", 3, 55))
        notes.append(Note(207.65, "G♯", 3, 56, "A♭"))
        notes.append(Note(220, "A", 3, 57))
        
        notes.append(Note(233.08, "A♯", 3, 58, "B♭"))
        notes.append(Note(246.94, "B", 3, 59))
        notes.append(Note(261.63, "C", 4, 60))
        notes.append(Note(277.18, "C♯", 4, 61, "D♭"))
        notes.append(Note(293.66, "D", 4, 62))
        notes.append(Note(311.13, "D♯", 4, 63, "E♭"))
        notes.append(Note(329.63, "E", 4, 64))
        notes.append(Note(349.23, "F", 4, 65))
        notes.append(Note(369.99, "F♯", 4, 66, "G♭"))
        notes.append(Note(392, "G", 4, 67))
        notes.append(Note(415.3, "G♯", 4, 68, "A♭"))
        notes.append(Note(440, "A", 4, 69))
        
        notes.append(Note(466.16, "A♯", 4, 70, "B♭"))
        notes.append(Note(493.88, "B", 4, 71))
        notes.append(Note(523.25, "C", 5, 72))
        notes.append(Note(554.37, "C♯", 5, 73, "D♭"))
        notes.append(Note(587.33, "D", 5, 74))
        notes.append(Note(622.25, "D♯", 5, 75, "E♭"))
        notes.append(Note(659.25, "E", 5, 76))
        notes.append(Note(698.46, "F", 5, 77))
        notes.append(Note(739.99, "F♯", 5, 78, "G♭"))
        notes.append(Note(783.99, "G", 5, 79))
        notes.append(Note(830.61, "G♯", 5, 80, "A♭"))
        notes.append(Note(880, "A", 5, 81))
        
        notes.append(Note(932.33, "A♯", 5, 82, "B♭"))
        notes.append(Note(987.77, "B", 5, 83))
        notes.append(Note(1046.5, "C", 6, 84))
        notes.append(Note(1108.73, "C♯", 6, 85, "D♭"))
        notes.append(Note(1174.66, "D", 6, 86))
        notes.append(Note(1244.51, "D♯", 6, 87, "E♭"))
        notes.append(Note(1318.51, "E", 6, 88))
        notes.append(Note(1396.91, "F", 6, 89))
        notes.append(Note(1479.98, "F♯", 6, 90, "G♭"))
        notes.append(Note(1567.98, "G", 6, 91))
        notes.append(Note(1661.22, "G♯", 6, 92, "A♭"))
        notes.append(Note(1760, "A", 6, 93))
    }
    
}

// This stuff isn't used as of the first multi-instrument pass checkin, but might
// be by LongTone exercises for translating notes from lesson json exercise code.

// POAS == "PitchOctaveAlterStep"
// octave:  The int part of C4, A5, etc.
// alter:   For flats (-) or sharps (+). E.g., step = "B", alter= -1 == Bb. Optional in the XML file
// step:    "C", "D", etc.
typealias tPOAS = (octave: NoteID, alter: Int, step: String)

func getShiftedPOAS(currPOAS: tPOAS, shift: Int) -> tPOAS {
    var retPOAS = tPOAS(octave: 4, alter: 0, step: "C")
    
    // Get MIDI note for current POAS
    //let currPOAS = tPOAS(octave: 4, alter: 0, step: "C")
    let currMidiNote = getMIDINoteFromPOAS(poas: currPOAS)
    
    // shift MIDI note
    var newMidiNote: NoteID = 0
    if shift >= 0 {
        newMidiNote = currMidiNote + NoteID(shift)
    } else {
        let negShift = NoteID(abs(shift))
        newMidiNote = currMidiNote - negShift
    }
    
    // Get POAS for shifted MIDI note
    retPOAS = getPOASFromMIDINote(midiNote: newMidiNote)
    
    return retPOAS
}

func getMIDINoteFromPOAS(poas: tPOAS) -> NoteID {
    var midiNote: NoteID =  12 * (poas.octave + 1)

    let noteInOctave = getOctaveNoteForNoteChar(noteChar: poas.step)
    midiNote += noteInOctave
    if poas.alter >= 0 {
        midiNote += NoteID(poas.alter)
    } else {
        let negShift = NoteID(abs(poas.alter))
        midiNote = midiNote - negShift
    }

    // midiNote += poas.alter
    
    return midiNote
}

func getPOASFromMIDINote(midiNote: NoteID) -> tPOAS  {
    let midiNoteInOct = midiNote % 12
    let midiOct = (midiNote/12)  - 1//////   BLAR

    // typealias tStepAndAlter = (step: String, alter: Int)
    let newStepAndAlter = getNoteCharAndALterFromOctaveNote(octaveNote: midiNoteInOct, goSharp:false)

    let retPOAS = tPOAS(octave: midiOct, alter: newStepAndAlter.alter, step: newStepAndAlter.step)

    return retPOAS
}

// "OctaveNote" means NoteID within a single octave, 1-11.
// returns 0 for "C", 4 for "E", 11 for "B", etc.
func getOctaveNoteForNoteChar(noteChar: String) -> NoteID {
    switch noteChar {
    case "D":   return 2
    case "E":   return 4
    case "F":   return 5
    case "G":   return 7
    case "A":   return 9
    case "B":   return 11

    case "C":   fallthrough
    default:    return 0
    }
}

typealias tStepAndAlter = (step: String, alter: Int)
func getNoteCharAndALterFromOctaveNote(octaveNote: NoteID, goSharp:Bool) -> tStepAndAlter {
    var noteChar = ""
    var alt = 0
    
    switch octaveNote {
    case 1:
        if goSharp {
            noteChar = "C"
            alt      =  1
        } else {
            noteChar = "D"
            alt      =  -1
        }
    case 2:
        noteChar = "D"
        alt      =  0
    case 3:
        if goSharp {
            noteChar = "D"
            alt      =  1
        } else {
            noteChar = "E"
            alt      =  -1
        }
    case 4:
        noteChar = "E"
        alt      =  0
    case 5:
        noteChar = "F"
        alt      =  0
    case 6:
        if goSharp {
            noteChar = "F"
            alt      =  1
        } else {
            noteChar = "G"
            alt      =  -1
        }
    case 7:
        noteChar = "G"
        alt      =  0
    case 8:
        if goSharp {
            noteChar = "G"
            alt      =  1
        } else {
            noteChar = "A"
            alt      =  -1
        }
    case 9:
        noteChar = "A"
        alt      =  0
    case 10:
        if goSharp {
            noteChar = "A"
            alt      =  1
        } else {
            noteChar = "B"
            alt      =  -1
        }
    case 11:
        noteChar = "B"
        alt      =  0

    case 0:  fallthrough
    default:
        noteChar = "C"
        alt      =  0
    }
    
    let retSA = tStepAndAlter(step: noteChar, alter: alt)

    return retSA
}

