//
//  NoteOffset.swift
//  longtones
//
//  Created by Adam Kinney on 6/7/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation

struct NoteOffset{
    var x = 0.0
    var y = 0.0
    var character : MusicFont = .Staff1LineWide
    
    init(_ x : Double, _ y : Double){
        self.x = x
        self.y = y
    }
}
