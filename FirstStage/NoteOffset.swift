//
//  NoteOffset.swift
//  FirstFive
//
//  Created by Adam Kinney on 11/19/15.
//  Changed by David S Reich - 2016.
//  Copyright © 2015 Musikyoshi. All rights reserved.
//

import UIKit

struct NoteOffset{
    var x = 0.0
    var y = 0.0
    var character : MusicFont = .Staff1LineWide
    
    init(_ x : Double, _ y : Double){
        self.x = x
        self.y = y
    }
}