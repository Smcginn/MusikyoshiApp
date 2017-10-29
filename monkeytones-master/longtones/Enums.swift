//
//  Enums.swift
//  longtones
//
//  Created by Adam Kinney on 6/7/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation

enum ExerciseState {
    case notStarted
    case inProgress
    case completed
    case feedbackProvided
}

enum MusicFont : String{
    case AccidentalFlat = "\u{E260}"
    case AccidentalSharp = "\u{E262}"
    case BarlineSingle = "\u{E030}"
    case GClef = "𝄞" //"\u{E050}"
    case BassClef = "𝄢"
    case NoteHeadBlack = "\u{E0A4}"
    case NoteHeadHalf = "\u{E0A3}"
    case NoteHeadWhole = "\u{E0A2}"
    case RestWhole = "\u{E4E3}"
    case Staff1LineWide = "\u{E016}"
    case Staff2LineWide = "\u{E017}"
    case Staff3LineWide = "\u{E018}"
    case Staff5LinesNarrow = "\u{E014}"
    case Stem = "\u{E210}"
    case TimeSig4over4 = "\u{E09E}\u{E084}\u{E09F}\u{E084}" //uniE09E_uniE084_uniE09F_uniE084
}

enum NoteLength {
    case half
    case quarter
    case whole
}
