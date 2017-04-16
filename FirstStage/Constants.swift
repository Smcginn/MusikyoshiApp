//
//  Constants.swift
//  FirstStage
//
//  Created by Adam Kinney on 12/18/15.
//  Changed by David S Reich - 2016.
//  Copyright © 2015 Musikyoshi. All rights reserved.
//

import UIKit

struct Constants
{
    struct MusicLine
    {
        static let note2XOffset = 24.0
        static let note3XOffset = 48.0
        static let note4XOffset = 72.0
        static let yOffset = 75.0
    }
    
    struct Settings
    {
        static let BPM = "bpm"
        static let FrequencyThreshold = "frequencyThreshold"
        static let AmplitudeThreshold = "amplitudeThreshold"
        static let TimingThreshold = "timingThreshold"
        static let Transposition = "transposition"
        static let ShowNoteMarkers = "shownotemarkers"
        static let ShowAnalysis = "showanalysis"
        static let PlayTrumpet = "playtrumpet"
    }
}
