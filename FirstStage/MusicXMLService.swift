//
//  MusicXMLService.swift
//  FirstFive
//
//  Created by Adam Kinney on 11/17/15.
//  Changed by David S Reich - 2016.
//  Copyright © 2015 Musikyoshi. All rights reserved.
//

import UIKit

class MusicXMLService : NSObject, NSXMLParserDelegate {
    var xmlParser: NSXMLParser!
    
    var currentExercise = Exercise()
    var currentParsedElement = String()
    var currentStep = String()
    var currentOctave = Int()
    var weAreInsideAnItem = false

    func loadExercise(fileName: String) throws -> Exercise {
        
        guard let path = NSBundle.mainBundle().pathForResource(fileName, ofType: nil) else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: [ NSFilePathErrorKey : fileName ])
        }
        
        currentExercise = Exercise()
        
        self.xmlParser = NSXMLParser(contentsOfURL: NSURL(fileURLWithPath: path))
        self.xmlParser.delegate = self
        self.xmlParser.parse()
        
        return currentExercise
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        currentParsedElement = elementName
        
        if elementName == "measure"
        {
            let m = Measure()
            m.number = Int(attributeDict["number"]!)!
            m.width = Double(attributeDict["width"]!)!
            currentExercise.measures.append(m)
        }
        else if elementName == "note"
        {
            if currentExercise.measures.count > 0
            {
                let n = Note()
                if attributeDict.count > 0
                {
                    n.xPos = Double(attributeDict["default-x"]!)!
                }
                
                currentExercise.measures.last!.notes.append(n)
            }
        }
        else if elementName == "rest"
        {
            if let n = currentExercise.measures.last!.notes.last
            {
                n.isRest = true
            }
            else
            {
                let restNote = Note()
                restNote.isRest = true
                currentExercise.measures.last!.notes.append(restNote)
            }
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        switch currentParsedElement {
            case "movement-title":
                currentExercise.title = string
            case "step":
                currentStep = string
                break
            case "octave":
                currentOctave = Int(string)!
                break
            case "type":
                if let n = currentExercise.measures.last!.notes.last
                {
                    switch string
                    {
                        case "half":
                            n.length = .Half
                            break
                        case "quarter":
                            n.length = .Quarter
                            break
//                        case "eighth":
//                            n.length = .Eighth
//                            break
                        default:
                            break
                    }
                }
                break
            default:
                break
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "pitch"
        {
            if let sn = NoteService.getNote(currentStep, octave: currentOctave)
            {
                if let n = currentExercise.measures.last!.notes.last
                {
                    n.frequency = sn.frequency
                    n.flatName = sn.flatName
                    n.name = sn.name
                    n.octave = sn.octave
                    n.orderId = sn.orderId
                }
            }
        }        
        
        currentParsedElement = ""
    }
    
    func parserDidEndDocument(parser: NSXMLParser){

    }
}