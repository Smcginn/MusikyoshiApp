//
//  NoteService.swift
//  Trumpet1
//
//  Created by Adam Kinney on 11/6/15.
//  Changed by David S Reich - 2016.
//  Copyright © 2015 Musikyoshi. All rights reserved.
//

import UIKit

struct NoteService {
    private static var notes = [Note]()

    static func getNote(step: String, octave: Int) -> Note? {
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

    static func getNote(frequency: Double) -> Note? {
        return NoteService.getNote(Float(frequency))
    }

    static func getNote(frequency: Float) -> Note? {
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
            let comparisionSet = notes.filter{ n in n.orderId == orderId || n.orderId == orderId-1 }.sort({ $0.orderId < $1.orderId })
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
    
    static func getNote(orderId: Int) -> Note? {
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
    
    static func getNoteOffset(orderId: Int) -> NoteOffset? {
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
    
    static func getYPos(orderId: Int) -> Double{
        
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
            default:
                print(String(format: "missing getYPos %d", orderId))
                return -50
        }
    }
    
    static func initNotes(){
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