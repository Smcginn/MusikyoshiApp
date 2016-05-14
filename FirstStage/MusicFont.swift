//
//  MusicFont.swift
//  FirstFive
//
//  Created by Adam Kinney on 11/19/15.
//  Copyright © 2015 ADKINN, LLC. All rights reserved.
//

import UIKit

enum MusicFont : String{
    case AccidentalFlat = "\u{E260}"
    case AccidentalSharp = "\u{E262}"
    case BarlineSingle = "\u{E030}"
    case EighthNoteUp = "\u{E1D7}"
    case EighthNoteDown = "\u{E1D8}"
    case GClef = "\u{E050}"
    case NoteHeadBlack = "\u{E0A4}"
    case NoteHeadHalf = "\u{E0A3}"
    case NoteHeadWhole = "\u{E0A2}"
    case RestWhole = "\u{E4E3}"
    case RestHalf = "\u{E4E4}"
    case RestQuarter = "\u{E4E5}"
    case RestEighth = "\u{E4E6}"
    case Staff1LineWide = "\u{E016}"
    case Staff2LineWide = "\u{E017}"
    case Staff3LineWide = "\u{E018}"
    case Staff5LinesNarrow = "\u{E014}"
    case Stem = "\u{E210}"
    case Tie = "\u{E1FD}"
    case TimeSig4over4 = "\u{E09E}\u{E084}\u{E09F}\u{E084}" //uniE09E_uniE084_uniE09F_uniE084
    case SlurBegin = "\u{E8E4}"
    case SlurEnd = "\u{E8E5}"
}
