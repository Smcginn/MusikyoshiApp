//
//  Instrument.swift
//  FirstStage
//
//  Created by Monday Ayewa on 12/4/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import UIKit

class Instrument {
    
    var type: InstrumentType?
    
    init(type: InstrumentType){
        self.type = type
    }
    
    static func getInstruments() -> [Instrument]{
        return [Instrument]()
    }
    
}
