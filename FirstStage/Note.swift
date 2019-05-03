//
//  Note.swift
//  Trumpet1
//
//  Created by Adam Kinney on 11/6/15.
//  Changed by David S Reich - 2016.
//  Copyright © 2015 Musikyoshi. All rights reserved.
//

import UIKit

class Note
{
    var frequency: Double!
    var name: String!
    var octave: Int!
    var orderId: Int!        // MIDI Number
    var flatName: String!
    
    var xPos = 0.0
    var isRest = false
    var length : NoteLength = .whole
    
    var friendlyName : String{
        get{
            if flatName != "" {
                return flatName
            } else {
                return name
            }
        }
    }
    
    var fullName : String{
        get{
            return friendlyName + String(octave)
        }
    }
    
    init(){
        
    }
    
    init(_ frequency: Double, _ name: String, _ octave: Int, _ orderId: Int) {
        self.frequency = frequency
        self.name = name
        self.octave = octave
        self.orderId = orderId
        self.flatName = ""
    }
    
    init(_ frequency: Double, _ name: String, _ octave: Int, _ orderId: Int, _ flatName: String) {
        self.frequency = frequency
        self.name = name
        self.octave = octave
        self.orderId = orderId
        self.flatName = flatName
    }
}
