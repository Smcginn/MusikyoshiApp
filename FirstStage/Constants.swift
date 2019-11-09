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
        static let StudentInstrument = "studentInstrument"
        
        static let SubsriptionOverridePswdSet = "subsriptionOverridePswdSet"

        
        // Amplitude Rise vars, for each instrument
        static let Trumpet_AmpRiseForNewSound        = "trumpet_AmpRiseForNewSound"
        static let Trumpet_SkipBeginningSamples      = "trumpet_SkipBeginningSamples"
        static let Trumpet_SamplesInAnalysisWindow   = "trumpet_SamplesInAnalysisWindow"
        static let Trombone_AmpRiseForNewSound       = "trombone_AmpRiseForNewSound"
        static let Trombone_SkipBeginningSamples     = "trombone_SkipBeginningSamples"
        static let Trombone_SamplesInAnalysisWindow  = "trombone_SamplesInAnalysisWindow"
        static let Euphonium_AmpRiseForNewSound      = "euphonium_AmpRiseForNewSound"
        static let Euphonium_SkipBeginningSamples    = "euphonium_SkipBeginningSamples"
        static let Euphonium_SamplesInAnalysisWindow = "euphonium_SamplesInAnalysisWindow"
        static let Horn_AmpRiseForNewSound           = "horn_AmpRiseForNewSound"
        static let Horn_SkipBeginningSamples         = "horn_SkipBeginningSamples"
        static let Horn_SamplesInAnalysisWindow      = "horn_SamplesInAnalysisWindow"
        static let Tuba_AmpRiseForNewSound           = "tuba_AmpRiseForNewSound"
        static let Tuba_SkipBeginningSamples         = "tuba_SkipBeginningSamples"
        static let Tuba_SamplesInAnalysisWindow      = "tuba_SamplesInAnalysisWindow"
        
        // Amplitude Rise vars, for woodwinds
        static let Flute_AmpRiseForNewSound             = "flute_AmpRiseForNewSound"
        static let Flute_SkipBeginningSamples           = "flute_SkipBeginningSamples"
        static let Flute_SamplesInAnalysisWindow        = "flute_SamplesInAnalysisWindow"
        static let Oboe_AmpRiseForNewSound              = "oboe_AmpRiseForNewSound"
        static let Oboe_SkipBeginningSamples            = "oboe_SkipBeginningSamples"
        static let Oboe_SamplesInAnalysisWindow         = "oboe_SamplesInAnalysisWindow"
        static let Clarinet_AmpRiseForNewSound          = "clarinet_AmpRiseForNewSound"
        static let Clarinet_SkipBeginningSamples        = "clarinet_SkipBeginningSamples"
        static let Clarinet_SamplesInAnalysisWindow     = "clarinet_SamplesInAnalysisWindow"
        static let BassClarinet_AmpRiseForNewSound      = "bassClarinet_AmpRiseForNewSound"
        static let BassClarinet_SkipBeginningSamples    = "bassClarinet_SkipBeginningSamples"
        static let BassClarinet_SamplesInAnalysisWindow = "bassClarinet_SamplesInAnalysisWindow"

        static let Bassoon_AmpRiseForNewSound           = "bassoon_AmpRiseForNewSound"
        static let BassoonTuba_SkipBeginningSamples     = "bassoon_SkipBeginningSamples"
        static let Bassoon_SamplesInAnalysisWindow      = "bassoon_SamplesInAnalysisWindow"
        static let AltoSax_AmpRiseForNewSound           = "altoSax_AmpRiseForNewSound"
        static let AltoSax_SkipBeginningSamples         = "altoSax_SkipBeginningSamples"
        static let AltoSax_SamplesInAnalysisWindow      = "altoSax_SamplesInAnalysisWindow"
        static let TenorSax_AmpRiseForNewSound          = "tenorSax_AmpRiseForNewSound"
        static let TenorSax_SkipBeginningSamples        = "tenorSax_SkipBeginningSamples"
        static let TenorSax_SamplesInAnalysisWindow     = "tenorSax_SamplesInAnalysisWindow"
        static let BaritoneSax_AmpRiseForNewSound       = "baritoneSax_AmpRiseForNewSound"
        static let BaritoneSax_SkipBeginningSamples     = "baritoneSax_SkipBeginningSamples"
        static let BaritoneSax_SamplesInAnalysisWindow  = "baritoneSax_SamplesInAnalysisWindow"
        
        static let Mallet_AmpRiseForNewSound            = "mallet_AmpRiseForNewSound"
        static let Mallet_SkipBeginningSamples          = "mallet_SkipBeginningSamples"
        static let Mallet_SamplesInAnalysisWindow       = "mallet_SamplesInAnalysisWindow"
    }
}
