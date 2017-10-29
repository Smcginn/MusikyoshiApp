//
//  InstrumentService.swift
//  monkeytones
//
//  Created by Adam Kinney on 8/14/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
import UIKit

struct InstrumentService {
    fileprivate static var instruments = [Instrument]()
    
    static func getAllInstruments() -> [Instrument] {
        return instruments;
    }
    
    static func getInstrument(_ orderId: InstrumentID) -> Instrument? {
        let comparisionSet = instruments.filter{ d in d.orderId == orderId}
        if comparisionSet.count == 1
        {
            return comparisionSet[0]
        }
        else
        {
            return nil
        }
    }
    
    
    static func getInstrumentNotes(_ instrumentId: InstrumentID) -> [Note]
    {
        var notes:[Note] = [Note]()
        
        switch instrumentId {
        case .fluteId,.oboeId: // Flute
            notes = [NoteService.getNote(59)!, NoteService.getNote(61)!, NoteService.getNote(63)!, NoteService.getNote(64)!, NoteService.getNote(66)!,NoteService.getNote(68)!,NoteService.getNote(70)!,NoteService.getNote(71)!]
        case .clarinetId: // Clarinet
            notes = [NoteService.getNote(147)!,NoteService.getNote(149)!, NoteService.getNote(151)!, NoteService.getNote(152)!, NoteService.getNote(154)!, NoteService.getNote(156)!,NoteService.getNote(158)!,NoteService.getNote(159)!]
        case .altoSaxophoneId,.baritoneSaxophoneId: // Alto Saxophone
            notes = [NoteService.getNote(247)!, NoteService.getNote(249)!, NoteService.getNote(251)!, NoteService.getNote(252)!, NoteService.getNote(254)!,NoteService.getNote(256)!, NoteService.getNote(258)!,NoteService.getNote(259)!]
        case .trumpetId: // Trumpet
            notes = [NoteService.getNote(147)!,NoteService.getNote(149)!, NoteService.getNote(151)!, NoteService.getNote(152)!, NoteService.getNote(154)!, NoteService.getNote(156)!, NoteService.getNote(158)!, NoteService.getNote(159)!]
        case .tromboneId,.baritoneEuphoniumId,.bassoonId: // Trombone
            notes = [NoteService.getNote(35)!, NoteService.getNote(37)!, NoteService.getNote(39)!, NoteService.getNote(40)!, NoteService.getNote(42)!,NoteService.getNote(44)!, NoteService.getNote(46)!,NoteService.getNote(47)!]
        case .frenchHornId:
            notes = [NoteService.getNote(54)!, NoteService.getNote(56)!, NoteService.getNote(58)!, NoteService.getNote(59)!, NoteService.getNote(61)!,NoteService.getNote(63)!, NoteService.getNote(65)!,NoteService.getNote(66)!]
        case .tenorSaxophoneId :
            notes = [NoteService.getNote(49)!, NoteService.getNote(51)!, NoteService.getNote(77)!, NoteService.getNote(54)!, NoteService.getNote(56)!,NoteService.getNote(58)!, NoteService.getNote(60)!,NoteService.getNote(73)!]
        case .tubaId :
            notes = [NoteService.getNote(59)!, NoteService.getNote(49)!, NoteService.getNote(51)!, NoteService.getNote(40)!, NoteService.getNote(54)!,NoteService.getNote(56)!, NoteService.getNote(46)!,NoteService.getNote(71)!]

        }
        
        return notes
    }
    
    static func getFrequencyRanges(_ orderId: Int) -> [Float] {
        var ranges: [Float]!
        
        let instrumentId = DataService.sharedInstance.currentInstrumentId
        
        switch instrumentId {
        
        case .fluteId,.oboeId: // Flute
            switch orderId
            {
            case 59:
                ranges = [511,480,453,430]
            case 61:
                ranges = [571,554,508,480]
            case 63:
                ranges = [641,604,570,545]
            case 64:
                ranges = [686,642,603,562]
            case 66:
                ranges = [764,721,676,636]
            case 68:
                ranges = [861,811,760,720]
            case 70:
                ranges = [971,915,855,800]
            case 71:
                ranges = [1024,963,900,830]
            default:
                ranges = [0,0,0,0]
            }
        case .clarinetId: // Clarinet
            switch orderId
            {
            case 147:
                ranges = [341,241,226,207]
            case 149:
                ranges = [321,268,254,183]
            case 151:
                ranges = [385,299,280,240]
            case 152:
                ranges = [401,317,302,280]
            case 154:
                ranges = [378,356,338,310]
            case 156:
                ranges = [421,401,384,365]
            case 158:
                ranges = [479,456,428,407]
            case 159:
                ranges = [503,480,453,430]
            default:
                ranges = [0,0,0,0]
            }
        case .altoSaxophoneId,.baritoneSaxophoneId: // Alto Saxophone
            switch orderId
            {
            case 247:
                ranges = [251,241,225,215]
            case 249:
                ranges = [281,270,253,240]
            case 251:
                ranges = [331,308,280,260]
            case 252:
                ranges = [346,321,299,280]
            case 254:
                ranges = [391,365,335,315]
            case 256:
                ranges = [421,401,384,365]
            case 258:
                ranges = [479,456,428,407]
            case 259:
                ranges = [503,480,453,430]
            default:
                ranges = [0,0,0,0]
            }
        case .trumpetId: // Trumpet
            switch orderId
            {
            case 147:
                ranges = [341,245,226,207]
            case 149:
                ranges = [321,272,254,183]
            case 151:
                ranges = [385,301,280,240]
            case 152:
                ranges = [401,321,302,280]
            case 154:
                ranges = [378,361,338,310]
            case 156:
                ranges = [421,401,384,365]
            case 158:
                ranges = [479,456,428,407]
            case 159:
                ranges = [503,480,453,430]
            default:
                ranges = [0,0,0,0]
            }
        case .tromboneId,.baritoneEuphoniumId,.bassoonId: // Trombone
            switch orderId
            {
            case 35:
                ranges = [125,120,112,104]
            case 37:
                ranges = [138,134,124,120]
            case 39:
                ranges = [158,150,141,135]
            case 40:
                ranges = [168,161,151,144]
            case 42:
                ranges = [189,180,169,160]
            case 44:
                ranges = [215,202,190,177]
            case 46:
                ranges = [241,228,214,202]
            case 47:
                ranges = [254,241,226,212]
            default:
                ranges = [0,0,0,0]
            }
        case .frenchHornId:
            switch orderId
            {
            case 54:
                ranges = [341,245,226,207]
            case 56:
                ranges = [321,272,254,183]
            case 58:
                ranges = [385,301,280,240]
            case 59:
                ranges = [401,321,302,280]
            case 61:
                ranges = [378,361,338,310]
            case 63:
                ranges = [421,401,384,365]
            case 65:
                ranges = [479,456,428,407]
            case 66:
                ranges = [503,480,453,430]
            default:
                ranges = [0,0,0,0]
            }
        case .tenorSaxophoneId:
            switch orderId
            {
            case 49:
                ranges = [125,120,112,104]
            case 51:
                ranges = [138,134,124,120]
            case 77:
                ranges = [158,150,141,135]
            case 54:
                ranges = [168,161,151,144]
            case 56:
                ranges = [189,180,169,160]
            case 58:
                ranges = [215,202,190,177]
            case 60:
                ranges = [241,228,214,202]
            case 73:
                ranges = [254,241,226,212]
            default:
                ranges = [0,0,0,0]
            }
        case .tubaId:
            switch orderId {
            case 59:
                ranges = [64.1,60.1,56,52]
            case 49:
                ranges = [71.1,67.1,63,60]
            case 51:
                ranges = [80.1,76.1,72,69]
            case 40:
                ranges = [85.1,80.1,75.5,70]
            case 54:
                ranges = [94.1,90.1,84,80]
            case 56:
                ranges = [105.1,101.1,95,91]
            case 46:
                ranges = [118.1,113.1,106,100]
            case 71:
                ranges = [127.1,121.1,112,106]
            default:
                ranges = [0,0,0,0]
            }
            
        }
        
        return ranges
    }
    
    static func tipsYCorrection(instrumentId:InstrumentID) -> CGFloat
    {
        switch instrumentId {
        case .tubaId:
            return -80.0
        default:
            return 0
        }
    }
    
    /*
    static func getFrequencyTips() -> [String] {
        //Tap when you're ready to start
        var tips: [String]!
        
        let instrumentId = DataService.sharedInstance.currentInstrumentId
        
        switch instrumentId {
        case 0,8:
            //flute
            tips = ["Control the air stream; don't over blow, check fingering", "Roll in a little, control air stream", "Speed up air - Roll out a little", "More Air!, Smaller whistle hole, roll out a little, check fingering"]
            break
        case 1:
            //clarinet
            tips = ["Check Fingering, keep trying!", "Almost! Check Fingering", "Almost! Check fingering, Speed up air. Check reed (replace if chipped)", "Speed up air, check fingering, cover holes completely and press firmly"]
            break
        case 2,7:
            //alto sax
            tips = ["Check Fingering, keep trying! If it's a really high sound, take some mouthpiece out.", "Almost! Perhaps pull out mouthpiece a little.", "Almost! Check fingering, Speed up air.", "Speed up air, check fingering, cover holes completely and press firmly."]
            break
        case 3:
            //trumpet
            tips = ["Curve lips out - think \"mm\". Open throat - say \"Oh\"", "Might be pinching, relax lips. Say \"Ohhh\"", "Almost there! Faster Air! Curve lips in slightly", "Firm lip setting. Use more air. Check fingering"]
            break
        case 4,5,6:
            //trombone
            tips = ["Move mouthpiece up a little", "Open teeth, say \"Daah\", check slide to see if it's out enough.", "Almost there! More air!", "Speed up air, check slide position to see if it's in enough."]

            break
        default: break
            
        }
        
        return tips
    }
 */ 
    
    static func initInstruments(){
        
        instruments.append(Instrument(.flute, .fluteId))
        instruments.append(Instrument(.oboe, .oboeId))
        instruments.append(Instrument(.bassoon, .bassoonId))
        instruments.append(Instrument(.clarinet, .clarinetId))
        instruments.append(Instrument(.altoSaxophone, .altoSaxophoneId))
        instruments.append(Instrument(.tenorSaxophone , .tenorSaxophoneId))
        instruments.append(Instrument(.baritoneSaxophone, .baritoneSaxophoneId))
        instruments.append(Instrument(.trumpet, .trumpetId))
        instruments.append(Instrument(.frenchHorn, .frenchHornId))
        instruments.append(Instrument(.trombone, .tromboneId))
        instruments.append(Instrument(.baritoneEuphonium, .baritoneEuphoniumId))
        instruments.append(Instrument(.tuba, .tubaId))
        
        //instruments.append(Instrument("Trumpet", 0))
        //instruments.append(Instrument("Clarinet", 1))
        //instruments.append(Instrument("Trombone", 2))
        //instruments.append(Instrument("Flute", 3))
        //instruments.append(Instrument("Alto Sax", 4))
    }
    
}
