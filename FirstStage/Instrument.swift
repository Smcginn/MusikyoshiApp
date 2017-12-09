//
//  Instrument.swift
//  FirstStage
//
//  Created by Monday Ayewa on 12/4/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import UIKit

class Instrument{
    
    var author: String?
    var title: String?
    var type: InstrumentType?
    
    init(author: String, title: String, type: InstrumentType){
        self.author = author
        self.title = title
        self.type = type
    }
    
    
    static func getInstruments() -> [Instrument]{
        
        let instruments = [Instrument]()
        return instruments
        
    
    }
    
}
