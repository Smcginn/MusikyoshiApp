//
//  MusicXMLModifier.swift
//  FirstStage
//
//  Created by David S Reich on 8/5/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import Foundation
import AEXML

let kG_clef       =  0
let kTrebleClef   =  kG_clef
let kF_clef       =  1
let kBassClef     =  kF_clef

enum whichInstrument {
    case trumpet
    case trombone
}

struct MusicXMLInstrumentModifiers {
    
    var makeKeySig_C: Bool
    var transpose_Diatonic: Int
    var transpose_Chromatic: Int
    var clef: Int
    
    var instrument: whichInstrument

    //var key_Fifths: Int     // the number of flats or sharps in key: - == flats, + == sharps
    //var key_Mode: Int       // major or minor

    init( makeKeySig_C:         Bool = false,
          transpose_Diatonic:   Int = 0,
          transpose_Chromatic:  Int = 0,
          clef:                 Int = kTrebleClef
          //key_Fifths:           Int = 0,
          //key_Mode:             Int = 0,
        ) {
        self.makeKeySig_C           = makeKeySig_C
        self.transpose_Diatonic     = transpose_Diatonic
        self.transpose_Chromatic    = transpose_Chromatic
        self.clef                   = clef
//        self.key_Fifths             = key_Fifths
//        self.key_Mode               = key_Mode
        
        self.instrument = .trumpet
    }
    
    mutating func setForTrombone() {
        transpose_Diatonic  = 0
        transpose_Chromatic = 0
        clef = kBassClef
        self.instrument = .trombone
    }
    
    mutating func setForTrumpet() {
        transpose_Diatonic  = -1
        transpose_Chromatic = -2
        clef = kTrebleClef
        self.instrument = .trumpet
    }
}


class MusicXMLModifier {
    //doesn't work with 32nd notes or dotted 16th or triplets
    //and maybe will also fail with something like 3/2 time where all the bars are two dotted quarter notes.

    static let basicNoteDuration = 1
    static let sixteenthNoteDuration = basicNoteDuration
    static var sixteenthNoteWidth = Double(0)
    static var sixteenthsPerBeat = 0
    static var beats = 0

    class func modifyXMLToData(musicXMLUrl: URL,
                               smallestWidth: Double,
                               signatureWidth: Double,
                               InstrMods: MusicXMLInstrumentModifiers) -> Data? {
    
//    class func modifyXMLToData(musicXMLUrl: URL, smallestWidth: Double, signatureWidth: Double) -> Data? {

        var currNoteID = 1
        MusicXMLNoteTracker.instance.clearAllEntries()
        
        var accidentalOnFirstNoteOfBar = false
        gNumAccidentalsInScore = 0
        
        guard let data = try? Data(contentsOf: musicXMLUrl) else {
            print("Cannot convert XML file to Data!!")
            return nil
        }

        guard let document = try? AEXMLDocument(xml: data) else {
            print("Cannot convert Data to AEXMLDocument!!")
            return nil
        }
        
        let currInst = getCurrentStudentInstrument()

//        print("doc1:\n\(document.xml)\n")

/* added ~ 8/12/19    leave out
        for measure in document["score-partwise"]["part"]["measure"].all! {
            var isFirstElem = true
            for note in measure["note"].all! {
                if isFirstElem {
                    let notePitch = note["pitch"]
                    if notePitch.error == nil {
                        let alterInt  = notePitch["alter"]
                        if alterInt.error == nil {
                            accidentalOnFirstNoteOfBar = true
                        }
                    }
                }
                isFirstElem = false
            }
        }
        
        if accidentalOnFirstNoteOfBar {
            for measure in document["score-partwise"]["part"]["measure"].all! {
                //        <print>
                //          <system-layout>
                //              <system-margins>
                //                  <left-margin>70</left-margin>
                //                  <right-margin>0</right-margin>
                //              </system-margins>
                //              <top-system-distance>185</top-system-distance>
                //          </system-layout>
                //          <measure-numbering>system</measure-numbering>
                //        </print>
                let measureLayout = measure["print"]["measure-layout"]
                if measureLayout.error == nil {
                    let yo = "yo"
                    let no = "no"
                } else {
                    measure["print"]["measure-layout"]["measure-distance"].value =
                    "<measure-layout><measure-distance>70<//measure-distance></measure-layout>"
                    //                  <left-margin>70</left-margin>
                    //                  <right-margin>0</right-margin>
                    //              </system-margins>
                    //              <top-system-distance>185</top-system-distance>
                    //          </measure-layout>
                    print("\(measure)")
                }
                
                let systemMargins = measure["print"]["system-layout"]["system-margins"]
                if systemMargins.error == nil {
                    let leftMargin  = systemMargins["left-margin"].int
                    // if leftMargin == nil {
                    if leftMargin != nil {
                        let newLeftMargin = leftMargin! + 130
                        systemMargins["left-margin"].value = String(newLeftMargin)
                    }
                }
            }
        }
*/
        //find shortest duration note
        var firstBar = true
        var beatType = 0    //as in notation 2,4,8, or 16
        var shortestNoteDuration = 32    //in 16th notes
        //var numFifths = Int(0)

        // number of sixteenths in note:
        //16 = whole, 8 = half, 4 = quarter, 2 = eighth, 12 = dotted half, etc.
        for measure in document["score-partwise"]["part"]["measure"].all! {
//            if let beatsInt = measure["attributes"]["time"]["beats"].int {
//                beats = beatsInt
//            }
            
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

// Added ~ 8/12/19   var isFirstElem = true
            for note in measure["note"].all! {
                let thisNoteDuration = getNoteDuration(note: note, dotted: false)
                if shortestNoteDuration > thisNoteDuration {
                    shortestNoteDuration = thisNoteDuration
                }
    
// Added ~ 8/12/19
//                if isFirstElem {
//                    let notePitch = note["pitch"]
//                    if notePitch.error == nil {
//                        let alterInt  = notePitch["alter"]
//                        if alterInt.error == nil {
//                            accidentalOnFirstNoteOfBar = true
//                        }
//                    }
//                }
//
//                isFirstElem = false
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
        let sigWidth = Double(60.0)
//        var measureWidth = signatureWidth + basicMeasureWidth
        var measureWidth = sigWidth + basicMeasureWidth
        //var noteX = signatureWidth + (smallestWidth / 2)
        var noteX = sigWidth + (smallestWidth / 2)


        var loopCount = 0
        for part in document["score-partwise"]["part"].all! {
            
            //let measures = part["measure"].all!
            var avgMeasureWd = 0
            var avgFirstXOffset = Double(0)
            
            getAveragesFor2Thru4(part: part,
                                 avgMeasureWidth: &avgMeasureWd,
                                 avgFirstX: &avgFirstXOffset)
            
            var maxMeasureWd = 0
            var maxFirstXOffset = Double(0)
            getMaximumssFor2Thru4(part: part,
                                  maxMeasureWidth: &maxMeasureWd,
                                  maxFirstX: &maxFirstXOffset)

            loopCount += 1
            for measure in part["measure"].all! {
                let measureAttributes =  measure["attributes"]
                if measureAttributes.error == nil { // attibutes present
                    var measureTranspose = measureAttributes["transpose"]
                    if measureTranspose.error != nil { // transpose not present; add it
                        measureAttributes.addChild(name: "transpose")
                        measureTranspose = measureAttributes["transpose"]
                        if measureTranspose.error == nil {
                            measureTranspose.addChild(name: "diatonic") // add children
                            measureTranspose.addChild(name: "chromatic")
                            measureTranspose["diatonic"].value  = "0" // set default vals
                            measureTranspose["chromatic"].value = "0"
                        }
                    }
                    if measureTranspose.error == nil {
                        let transDiaChrm = getTransDiaChrmForInstr(instr: currInst)
                        if transDiaChrm != kNoTransDiaChrmChange {
                            var diatonic  = measureTranspose["diatonic"].int
                            var chromatic = measureTranspose["chromatic"].int
                            if diatonic != nil && chromatic != nil {
                                print("In modifyXMLData,  old diatonic = \(diatonic!), old chrom: \(chromatic!)")
                                diatonic!  += transDiaChrm.diatonic
                                chromatic! += transDiaChrm.chromatic
                                measureTranspose["diatonic"].value  = String(diatonic!)
                                measureTranspose["chromatic"].value = String(chromatic!)
                                diatonic  = measureTranspose["diatonic"].int
                                chromatic = measureTranspose["chromatic"].int
                                print("In modifyXMLData,  new diatonic = \(diatonic!), new chrom: \(chromatic!)")
                            }
                        }
                    }
                }
            }
        }


// Added ~ 8/12/19        loopCount = 0
        
        for measure in document["score-partwise"]["part"]["measure"].all! {

            // adjust the first measure width based on number of sharps/flats in key sig
            let measureKey = measure["attributes"]["key"]
            if measureKey.error == nil {
                if InstrMods.makeKeySig_C { // negate any key signature info, make it "C"
                    print("\nIn modifyXMLToData; Forcing Key signature to C\n")
                    if measureKey["fifths"].int != nil {
                        measureKey["fifths"].value = "0"
                    }
                    if measureKey["mode"].int != nil {
                        measureKey["mode"].value = "major"
                    }
                } else {
                    if let numFifths = measureKey["fifths"].int {
                        // Add 10 pix for general spacing, plus 10 pix for every s/f
                        let xAdjustFactor = Double(abs(numFifths)) + 1.0
                        measureWidth += xAdjustFactor * 10.0
                        noteX += xAdjustFactor * 10.0
                    }
                }
            }

            
            
/* Added ~ 8/12/19
            let clefLine = getClefLineForInstr(instr: currInst)
            
            if InstrMods.instrument != .trumpet {
                let measureClef = measure["attributes"]["clef"]
                if measureClef.error == nil {
                    measureClef["sign"].value = clefLine.clef //"F"
                    measureClef["line"].value = clefLine.line //"4"
                    let sign = measureClef["sign"].string
                    let line = measureClef["line"].string
                    print ("\n\n@@@@  Clef sign = \(sign), line = \(line)")
                }
            }
 */
            
//            typealias tTransDiaChrm = (diatonic: Int, chromatic: Int)
//            let kNoTransDiaChrmChange =  (diatonic: 0, chromatic: 0)
//            let kBariTransDiaChrm = (diatonic: -8, chromatic: -12)
            

// Added ~ 8/12/19            loopCount += 1
            
//            let measureTranspose =  measure["attributes"]["transpose"]
//            if measureTranspose.error == nil {
//                let transDiaChrm = getTransDiaChrmForInstr(instr: currInst)
//                if transDiaChrm != kNoTransDiaChrmChange {
//                    var diatonic  = measureTranspose["diatonic"].int
//                    var chromatic = measureTranspose["chromatic"].int
//                    if diatonic != nil && chromatic != nil {
//                        print("In modifyXMLData,  old diatonic = \(diatonic!), old chrom: \(chromatic!)")
//                        diatonic!  += transDiaChrm.diatonic
//                        chromatic! += transDiaChrm.chromatic
//                        measureTranspose["diatonic"].value  = String(diatonic!)
//                        measureTranspose["chromatic"].value = String(chromatic!)
//                        diatonic  = measureTranspose["diatonic"].int
//                        chromatic = measureTranspose["chromatic"].int
//                        print("In modifyXMLData,  new diatonic = \(diatonic!), new chrom: \(chromatic!)")
//                    }
//                }
//            }
            
            //turn off new-system!!!!
            let measurePrint = measure["print"]
            if measurePrint.error == nil {
                if measurePrint.attributes["new-system"] != nil {
                    measurePrint.attributes["new-system"] = "no"
                }
            }

            let mWd = measure.attributes["width"]

//            measureWidth *= 2
            measure.attributes["width"] = "\(measureWidth)"

            var loopCount = 0
            var isFirstElem = true
            var measureDiff: Double = 0.0
            for note in measure["note"].all! {
                
                loopCount += 1
                
                var isRest = false
                let rest = note["rest"]
                if rest.error   == nil {
                    isRest = true
                }
                
                if !isRest {
                    // Check for slurs, and if found, notate
                    var noteData = NoteData()
                    noteData.noteID = currNoteID
                    let noteNotations = note["notations"]
                    if noteNotations.error == nil {
                        if let typeStr = noteNotations["slur"].attributes["type"] {
                            if typeStr == "start" {
                                noteData.beginSlur = true
                            } else if typeStr == "stop" {
                                noteData.endSlur = true
                            }
                        }
                    }
                    MusicXMLNoteTracker.instance.addNoteEntry(noteData)
                    currNoteID += 1
                }
                
                // Fix for accidentals on measure line
                if isFirstElem {
                    let notePitch = note["pitch"]
                    if notePitch.error == nil {
                        let alterInt  = notePitch["alter"]
                        if alterInt.error == nil {
                            accidentalOnFirstNoteOfBar = true
                            gNumAccidentalsInScore += 1
                        }
                    }
                    if accidentalOnFirstNoteOfBar, let defNoteXStr = note.attributes["default-x"] {
                        let defNoteX = Double(defNoteXStr)!
                        if defNoteX > noteX {
                            measureDiff = defNoteX - noteX
                            noteX = defNoteX
                        }
                    }
                }
                isFirstElem = false
                if measureDiff != 0 {
                    measureWidth += measureDiff
                    measure.attributes["width"] = "\(measureWidth)"    //YO
                }
                
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
                
                let octChange = getOctaveChangeForInstr(instr: currInst)
                if octChange != 0 {
                    let notePitch = note["pitch"]
                    if notePitch.error == nil {
                        let octaveInt = notePitch["octave"].int
                        if octaveInt != nil {
                            let newOctInt = octaveInt! + octChange
                            notePitch["octave"].value = String(newOctInt)
                            let testInt = notePitch["octave"].string
                            print ("testInt! = \(testInt)")
                        }
                    }
                }

                
//                let notePitch = note["pitch"]
//                if notePitch.error == nil {
//                    let octaveInt = notePitch["octave"].int
//                    let alterInt  = notePitch["alter"].int
//                    let step      = notePitch["step"].string
//                    if octaveInt != nil {
//                        let octv = NoteID(octaveInt!)
//                        let alt  = alterInt != nil ? alterInt! : 0
//                        let currPoas: tPOAS = (octave: octv, alter: alt, step: step)
//
//                        let kTromboneShift = -14
//                        let kTubaShift     = -26
//
//                        let newPoas = getShiftedPOAS(currPOAS: currPoas, shift: kTromboneShift) // tuba
//                        notePitch["step"].value = newPoas.step
//
//                        // TODO: if alter not present, must do an addchild call
//
//                        if alterInt == nil { // alter key not present, must add one
//                            notePitch["octave"].removeFromParent()
//                            notePitch.addChild(name: "alter")
//                            notePitch.addChild(name: "octave")
//                            notePitch["alter"].value = String(newPoas.alter)
//                        }
//
//                        if newPoas.alter != 0 {
//                            let accidental = note["accidental"].string
//                            if accidental.isEmpty {
//                                note.addChild(name: "accidental")
//                            }
//                            if newPoas.alter > 0 {
//                                note["accidental"].value = String("sharp")
//                            } else {
//                                note["accidental"].value = String("flat")
//                            }
//                        }
//
//
////                                               value: String(newPoas.alter),
////                                               attributes: nil )
//                                           //attributes: ["xmlns:m" : "http://www.w3schools.com/transaction/", "soap:mustUnderstand" : "1"])
//                        //} else {
//                        notePitch["octave"].value = String(newPoas.octave)
//                       //}
//
//                        let newOctave = octaveInt! - 1
////                        notePitch["octave"].value = String(newOctave)
//                    }
//                }
                
            }

            //reset first note (and measure width) in measure position
            measureWidth = basicMeasureWidth
            noteX = smallestWidth / 2
            accidentalOnFirstNoteOfBar = false
        }

        for part in document["score-partwise"]["part"].all! {
            lookForAndFixUnusuallyLongMeasures(part: part)
        }
        
//        print("doc2:\n==============================\n\n\(document.xml)\n===============================\n\n")
        return document.xml.data(using: .utf8)
    }

    func suggestedNoteWidth() -> Int {
        var hasAccidental = false
        var hasDot        = false

        return 0
    }
    
    func minMeasureWidth() -> Int {
        var numNotes = 0
        var numRests = 0
        var noteWidthSum = 0
        
        
        
        
        return 0
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

    //let measures = part["measure"].all!

    class func getAveragesFor2Thru4(part: AEXMLElement,
                                    avgMeasureWidth: inout Int,
                                    avgFirstX: inout Double) {
        avgMeasureWidth = 0
        avgFirstX = 0
        var firstXSum: Double = 0
        
        var m1Wd = 0
        var m2Wd = 0
        var m3Wd = 0
        var m4Wd = 0
        var measCount = 0
        
        var numNotesAccessed = 0
        
//        var idx = 0
        for measure in part["measure"].all! {
            measCount += 1
            if measCount == 1 {
                continue  // skip because of Time and Key signature makes it longer
            }
            
            let mWdStr = measure.attributes["width"]
            //let mWd = measure["attributes"]["width"].int

            if mWdStr == nil {
                itsBad()
            } else {
                let mWdInt = Int(mWdStr!)!
                switch measCount {
//                    case 0: m1Wd = mWdInt
//                            avgMeasureWidth = mWdInt
                    case 2: m2Wd = mWdInt
                            avgMeasureWidth = m2Wd
                    case 3: m3Wd = mWdInt
                            avgMeasureWidth = (m2Wd + m3Wd) / 2
                    
                    case 4: m4Wd = mWdInt
                            avgMeasureWidth  = (m2Wd + m3Wd + m4Wd) / 3
                    default:
                        ()
                }
            }
            
            for note in measure["note"].all! {
                if let defNoteXStr = note.attributes["default-x"] {
                    let defNoteX = Double(defNoteXStr)!
                    numNotesAccessed += 1
                    firstXSum += defNoteX
                }
                break // only do first note in measure
            }
            
            if measCount > 1 { // no divide by 0
                avgFirstX = firstXSum / Double(measCount-1)
            }
            
            
//            measCount += 1
//            idx += 1
            if measCount >= 4 {
//                avgFirstX = 0
//                var firstXSum: Double = 0

                break
            }
        }
    }

    
    
    
    
    
    class func getMaximumssFor2Thru4(part: AEXMLElement,
                                     maxMeasureWidth: inout Int,
                                     maxFirstX: inout Double) {
        maxMeasureWidth = 0
        maxFirstX = 0
        var measCount = 0
        
        for measure in part["measure"].all! {
            measCount += 1
            if measCount == 1 {
                continue  // skip because of Time and Key signature makes it longer
            }
            
            if let mWdStr = measure.attributes["width"] {
                var mWdInt: Int = Int(mWdStr) ?? 0
                if mWdInt == 0 {
                    let mWdD = Double(mWdStr) ?? 0.0
                    mWdInt = Int(mWdD)
                }
                if mWdInt > maxMeasureWidth {
                    maxMeasureWidth = mWdInt
                }

                
//            //let mWd = measure["attributes"]["width"].int
//
////            if mWdStr == nil {
////                itsBad()
////            } else {
//                if let mWdInt = Int(mWdStr) {
//                    if mWdInt > maxMeasureWidth {
//                        maxMeasureWidth = mWdInt
//                    }
//                }
//            }
            }
  
//            var measureWidth = 0
//            if let mWdStr: String = measure.attributes["width"] {
//                //let tempIntStr = mWdStr
//                var mWdInt: Int = Int(mWdStr) ?? 0
//                if mWdInt == 0 {
//                    let mWdD = Double(mWdStr) ?? 0.0
//                    mWdInt = Int(mWdD)
//                }
//                measureWidth = mWdInt
//            }
//
//
            
            
            
            
            var defNoteX = Double(0)
            for note in measure["note"].all! {
                if let defNoteXStr = note.attributes["default-x"] {
                    defNoteX = Double(defNoteXStr)!
                }
                break // only do first note in measure
            }
            
            if defNoteX > maxFirstX {
                maxFirstX = defNoteX
            }

            if measCount >= 4 {
                 break
            }
        }
    }
    
    class func lookForAndFixUnusuallyLongMeasures(part: AEXMLElement) {
        var measCount = 0
        var maxMeasureWd = 0
        var maxFirstXOffset = Double(0)
        getMaximumssFor2Thru4(part: part,
                              maxMeasureWidth: &maxMeasureWd,
                              maxFirstX: &maxFirstXOffset)
        
        for measure in part["measure"].all! {
            if measCount == 0 {
                measCount += 1
                continue  // skip because of Time and Key signature makes it longer
            }
            
//            var measureWidth = 0
//            let mWdStr = measure.attributes["width"]
//            if mWdStr == nil {
//                itsBad()
//            } else {
//                measureWidth = Int(mWdStr!)!
//            }00
 
            var measureWidth = 0
            if let mWdStr: String = measure.attributes["width"] {
                //let tempIntStr = mWdStr
                var mWdInt: Int = Int(mWdStr) ?? 0
                if mWdInt == 0 {
                    let mWdD = Double(mWdStr) ?? 0.0
                    mWdInt = Int(mWdD)
                }
                measureWidth = mWdInt
            }
            
            var defNoteX = Double(0)
            for note in measure["note"].all! {
                if let defNoteXStr = note.attributes["default-x"] {
                    defNoteX = Double(defNoteXStr)!
                }
                break // only test first note in measure
            }
            
            if measureWidth > 0 && defNoteX > 0 &&  // got valid vals for both
               Double(measureWidth) > Double(maxMeasureWd)*1.5 &&
               defNoteX > maxFirstXOffset*1.5     {
                
                adjustMeasureToAverageVals(measure: measure,
                                           maxMeasureWidth: maxMeasureWd,
                                           maxFirstX: maxFirstXOffset)

//                var yomaxFirstX = defNoteX
//                print ("\(yomaxFirstX)")
            }
            
            measCount += 1
        }
    }
    
    class func adjustMeasureToAverageVals(measure: AEXMLElement,
                                          maxMeasureWidth: Int,
                                          maxFirstX: Double) {
        
        var xDiff: Double = 0.0
        
        var couldGetFirstElemOffset = false
        var isFirstElem = true
        for note in measure["note"].all! {
            if let defNoteXStr = note.attributes["default-x"] {
                let defNoteX = Double(defNoteXStr) ?? 0.0
                if defNoteX != 0
                {
                    if isFirstElem {
                        xDiff = defNoteX - maxFirstX
                        xDiff *= 0.9 // just to make sure it isn't too close
                        couldGetFirstElemOffset = true
                        isFirstElem = false
                    }
                    
                    let newX = defNoteX - xDiff
                    note.attributes["default-x"] = "\(newX)"
                }
            }
            if isFirstElem && !couldGetFirstElemOffset {
                break // no point in continuing
            }
        }

        if couldGetFirstElemOffset && xDiff != 0 {
            // add 10% to give a little space at end . . .
            let adjustedMeasWd = Int(Double(maxMeasureWidth) * 1.10)
            measure.attributes["width"] = "\(adjustedMeasWd)"
        }
    }
}
