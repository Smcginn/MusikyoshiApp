//
//  Note.swift
//  longtones
//
//  Created by Adam Kinney on 6/7/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation

class Note
{
    var name: String!
    var orderId: Int!
    
    var xPos = 0.0
    var isRest = false
    var length : NoteLength = .whole
    
    var friendlyName : String{
        get{
            return name
        }
    }
    
    /*
    var fullName : String{
        get{
            return friendlyName + String(octave)
        }
    }
     */
    
    init(){
        
    }
    
    
    init(_ frequency: Float, _ name: String,  _ orderId: Int) {
        self.name = name
        self.orderId = orderId
    }
}
