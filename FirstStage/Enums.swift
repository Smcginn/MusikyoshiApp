//
//  Enums.swift
//  FirstStage
//
//  Created by Adam Kinney on 12/11/15.
//  Changed by David S Reich - 2016.
//  Copyright © 2015 Musikyoshi. All rights reserved.
//

import UIKit

enum ExerciseState {
    case notStarted
    case inProgress
    case completed
    case feedbackProvided
}

enum NoteLength {
    case half
    case quarter
    case whole
//    case Eighth
}

enum LessonItemType: String {
    case informnationNode = "informationNode"
    case longTone = "longtone"
    case rhythm = "rhythm"
    case tune = "tune"
}

enum InstrumentType {
    case trumpet
    case piano
}


