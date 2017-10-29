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
    struct Achievements {
        static let achievementsIDs:[InstrumentID:String] = [
            .fluteId : "FluteId",
            .clarinetId : "ClarinetId",
            .altoSaxophoneId : "AltoSaxId",
            .trumpetId : "TrumpetId",
            .tromboneId : "TromboneId",
            .baritoneEuphoniumId : "BaritoneEuphoniumId",
            .bassoonId : "BassonId",
            .baritoneSaxophoneId : "BarSaxId",
            .oboeId : "OboeId",
            .frenchHornId : "FrenchHornId",
            .tenorSaxophoneId : "TenorSaxId",
            .tubaId : "TubaId",
            ]
    }
    
    struct Hints
    {
        static let titles = [
            "A LOT Lower",
            "A Little Lower",
            "You Got it",
            "A Little Higher",
            "A LOT Higher",
            ]
        static let colors = [
            UIColor(red: 0.969, green: 0.149, blue: 0.078, alpha: 1.00),
            UIColor(red: 0.949, green: 0.643, blue: 0.020, alpha: 1.00),
            UIColor(red: 0.443, green: 0.769, blue: 0.310, alpha: 1.00),
            UIColor(red: 0.949, green: 0.643, blue: 0.020, alpha: 1.00),
            UIColor(red: 0.969, green: 0.149, blue: 0.078, alpha: 1.00),
            ]
    }
    
    struct FruitsImagesNames {
        static let imagesNames = ["Screen fruit-apple ","Screen fruit-orange ","Screen fruit-pineapple ","Screen fruit-banana ","Screen fruit-watermelon ","Screen fruit-strawberry ","Screen fruit-pear "]
    }
    
    struct GlobalFontName
    {
        static let fontName = "SF Slapstick Comic"
    }
    
    struct LeaderBoardIds
    {
        static let personalRecord = "pr_level"
        static let exercisePoints = "exercise_points"
    }
    
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
        static let SmallestNoteWidth = "smallestnotewidth"
        static let SignatureWidth = "signaturewidth"
        static let ScoreMagnification = "scoremagnification"
    }
    
    struct Exercises {
        static let maxNumberOfTries = 5
        static let exersicesCount = 56
    }
    
    // added from MT, different from 'Settings'?
    struct SettingsKeys
    {
        static let exerciseDict = "ExerciseDict"
        static let currentNoteId = "CurrentNoteId"
        static let currentDifficultyId = "CurrentDifficultyId"
        static let currentInstrumentId = "CurrentInstrumentId"
        static let exercisePoints = "exercisePoints"
        static let previousAppLaunchDay = "previousAppLaunchDay"
        static let notFirstLaunch =  "NotFirstLanuch"
        static let username =  "Username"
        static let userId =  "UserId"
        static let userMail =  "UserMail"
    }
    
    struct Title
    {
        static let cancel = "Cancel"
        static let learningTree = "Tone Progress"
        static let main = "Monkey Tones"
        static let settings = "Settings"
    }

}
