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
    
    // SFUserDefs
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
        static let MaxPlayingVolume = "maxPlayingVolume"
        static let PlayingVolumeSoundThreshold = "playingVolumeSoundThreshold"
        static let LastPlayingVolumeCheckDate = "lastPlayingVolumeCheckDate"
        static let UserNoteThresholdOverride = "userNoteThresholdOverride"
        static let UserHopSizeOverride = "userHopSizeOverride"
        static let UserPeakCountOverride = "userPeakCountOverride"
        static let UserLatencyOffsetThresholdOverride = "userLatencyOffsetThresholdOverride"
        static let SubsriptionStatusConfirmed = "subsriptionStatusConfirmed"
        static let SubsriptionHasBeenPurchased = "subsriptionHasBeenPurchased"
        static let ConfirmedSubsExpiryDateAfter1970 = "confirmedSubsExpiryDateAfter1970"
        static let CheckForAppUpdateInterval = "checkForAppUpdateInterval"
        static let LastCheckForAppUpdate = "lastCheckForAppUpdate"
    }
}
