//
//  Difficulty.swift
//  longtones
//
//  Created by Adam Kinney on 7/3/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation

enum DifficultyName:String
{
    case beginning = "Beginning"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    case virtuoso = "Virtuoso"
    case master = "Master"
    case personalRecord = "Personal Record"
}


class Difficulty
{
    var name: DifficultyName!
    var orderId: Int!
    
    init(){
        
    }
    
    init(_ name: DifficultyName, _ orderId: Int) {
        self.name = name
        self.orderId = orderId
    }
}
