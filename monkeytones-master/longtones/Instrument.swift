//
//  Instrument.swift
//  monkeytones
//
//  Created by Adam Kinney on 8/27/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation

enum InstrumentName:String
{
    case flute = "Flute"
    case clarinet = "Clarinet"
    case altoSaxophone = "Alto Saxophone"
    case trumpet = "Trumpet"
    case trombone = "Trombone"
    case baritoneEuphonium = "Baritone/Euphonium"
    case bassoon = "Bassoon"
    case baritoneSaxophone = "Baritone Saxophone"
    case oboe = "Oboe"
    case frenchHorn = "French Horn"
    case tenorSaxophone = "Tenor Saxophone"
    case tuba = "Tuba"
}

enum InstrumentID:Int
{
    case fluteId = 0
    case clarinetId = 1
    case altoSaxophoneId = 2
    case trumpetId = 3
    case tromboneId = 4
    case baritoneEuphoniumId = 5
    case bassoonId = 6
    case baritoneSaxophoneId = 7
    case oboeId = 8
    case frenchHornId = 9
    case tenorSaxophoneId = 10
    case tubaId = 11
}

class Instrument
{
    var name: InstrumentName!
    var orderId: InstrumentID!
    
    init(){
        
    }
    
    init(_ name: InstrumentName, _ orderId: InstrumentID) {
        self.name = name
        self.orderId = orderId
    }
}
