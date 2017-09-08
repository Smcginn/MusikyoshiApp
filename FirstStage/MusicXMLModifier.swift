//
//  MusicXMLModifier.swift
//  FirstStage
//
//  Created by David S Reich on 8/5/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import Foundation
import AEXML

class MusicXMLModifier {
    //doesn't work with 32nd notes or dotted 16th or triplets
    //and maybe will also fail with something like 3/2 time where all the bars are two dotted quarter notes.

    static let basicNoteDuration = 1
    static let sixteenthNoteDuration = basicNoteDuration
    static var sixteenthNoteWidth = Double(0)
    static var sixteenthsPerBeat = 0
    static var beats = 0

    class func modifyXMLToData(musicXMLUrl: URL, smallestWidth: Double, signatureWidth: Double) -> Data? {

        guard let data = try? Data(contentsOf: musicXMLUrl) else {
            print("Cannot convert XML file to Data!!")
            return nil
        }

        guard let document = try? AEXMLDocument(xml: data) else {
            print("Cannot convert Data to AEXMLDocument!!")
            return nil
        }

//        print("doc1:\n\(document.xml)\n")

        //find shortest duration note
        var firstBar = true
        var beatType = 0    //as in notation 2,4,8, or 16
        var shortestNoteDuration = 32    //in 16th notes

        // number of sixteenths in note:
        //16 = whole, 8 = half, 4 = quarter, 2 = eighth, 12 = dotted half, etc.
        for measure in document["score-partwise"]["part"]["measure"].all! {

            if firstBar {
                firstBar = false
                if let beatsInt = measure["attributes"]["time"]["beats"].int {
                    beats = beatsInt
                }
                if let beatTypeInt = measure["attributes"]["time"]["beat-type"].int {
                    beatType = beatTypeInt
                }

                guard beats > 0 && beatType > 0 else {
                    print("OH NO - no beats, no beat-type!!!")
                    return nil
                }

                sixteenthsPerBeat = 16 / beatType
            }

            for note in measure["note"].all! {
                let thisNoteDuration = getNoteDuration(note: note, dotted: false)
                if shortestNoteDuration > thisNoteDuration {
                    shortestNoteDuration = thisNoteDuration
                }
            }
        }

        guard shortestNoteDuration > 0 else {
            print("OH NO - no shortest note!!!")
            return nil
        }

        /*
         2 == 8
         4 == 4
         8 == 2
         16 == 1
         sixteenthsPerBeat = 16 / beatType
         smallestNotesPerBeat = sixteenthsPerBeat / shortestNoteDuration
        */

        let smallNotesPerBeat = Double(sixteenthsPerBeat) / Double(shortestNoteDuration)    //can be a fraction ... so make it Double
        let basicMeasureWidth = smallNotesPerBeat * Double(beats) * smallestWidth

        sixteenthNoteWidth = smallestWidth / Double(shortestNoteDuration)

        //set first note (and measure width) in first measure position
        var measureWidth = signatureWidth + basicMeasureWidth
        var noteX = signatureWidth + (smallestWidth / 2)

        for measure in document["score-partwise"]["part"]["measure"].all! {

            //turn off new-system!!!!
            let measurePrint = measure["print"]
            if measurePrint.error == nil {
                if measurePrint.attributes["new-system"] != nil {
                    measurePrint.attributes["new-system"] = "no"
                }
            }

            measure.attributes["width"] = "\(measureWidth)"

            for note in measure["note"].all! {
                note.attributes["default-x"] = "\(noteX)"
                noteX += getNoteWidth(note: note, dotted: true)

                //try to deal with whole rests!
                if note["type"].value == nil {
                    let rest = note["rest"]
                    if rest.error == nil {
                        //       <rest measure="yes"/>
                        if rest.attributes["measure"] != nil {
                            if rest.attributes["measure"] == "yes" {
                                rest.attributes["measure"] = "no"
                                note["type"].value = "whole"
                            }
                        }                        
                    }
                }
            }

            //reset first note (and measure width) in measure position
            measureWidth = basicMeasureWidth
            noteX = smallestWidth / 2
        }

//        print("doc2:\n\(document.xml)\n")
        return document.xml.data(using: .utf8)
    }

    //note duration in 16th note equivalents
    private class func getNoteDuration(note: AEXMLElement, dotted: Bool) -> Int {
        var thisNoteDuration = 0
        // could maybe use note["duration"] here instead of type + dotted or <rest measure="yes">
        // but we don't know if the units of "duration" are always the same

        if let noteValue = note["type"].value {
            switch noteValue {
            case "whole":
                thisNoteDuration = 16 * sixteenthNoteDuration
            case "half":
                thisNoteDuration = 8 * sixteenthNoteDuration
            case "quarter":
                thisNoteDuration = 4 * sixteenthNoteDuration
            case "eighth":
                thisNoteDuration = 2 * sixteenthNoteDuration
            case "sixteenth":
                thisNoteDuration = 1 * sixteenthNoteDuration
            default:
                thisNoteDuration = 1 * sixteenthNoteDuration
            }

            if dotted {
                let dot = note["dot"]
                if dot.error == nil {
                    thisNoteDuration = (thisNoteDuration * 3) / 2
                }
            }
        } else {
            let rest = note["rest"]
            if rest.error == nil {
                //       <rest measure="yes"/>
                if rest.attributes["measure"] != nil {
                    if rest.attributes["measure"] == "yes" {
                        thisNoteDuration = sixteenthsPerBeat * beats
                    }
                }

            }
        }

        if thisNoteDuration == 0 {
            print("Oh NO - note has no duration!!")
        }
        return thisNoteDuration
    }

    private class func getNoteWidth(note: AEXMLElement, dotted: Bool) -> Double {
        return sixteenthNoteWidth * Double(getNoteDuration(note: note, dotted: dotted))
    }
}
