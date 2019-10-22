//
//  RealTimeSettingsGetters.swift
//  FirstStage
//
//  Created by Scott Freshour on 10/5/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//

import Foundation


func getRealtimeAttackTolerance( _ perfNote: PerformanceNote ) -> TimeInterval {
    return RTSMgr.instance.getAdjustedAttackTolerance(perfNote)
    
//    if gUseOldRealtimeSettings {
//        ?
//    } else {
//        return RTSMgr.instance.getAdjustedAttackTolerance(perfNote)
//    }
}

func getAmpRiseSkipWindow(noteDur: Double) -> Int {
    if gUseOldRealtimeSettings {
        // trick here is that if not using auto-calc, then have to see if user settings
        // has been changed. If so, use the altered value. Portbably should do this in
        // RealTimeSettingsGetters!
        let currInst = getCurrentStudentInstrument()
        let skipCount = getAmpRiseSamplesToSkip(forInstr: currInst)
        print("\nARAR - In getAmpRiseSkipWindow, using old, Skip Samples == \(skipCount)\n")
        return Int(skipCount)
    } else {
        let retVal =
            RTSMgr.instance.getAdjustedAmpRiseSkipWindow(expNoteDur: noteDur)
        print("\nARAR - In getAmpRiseSkipWindow, using new, Skip Samples  == \(retVal)\n")
        return retVal
    }
}

func getAmpRiseAnalysisWindow() -> Int {
    if gUseOldRealtimeSettings {
        let currInst = getCurrentStudentInstrument()
        let analysisCount = getNumSamplesInAnalysisWindow(forInstr: currInst)
        print("\nARAR - In getAmpRiseAnalysisWindow, using old, Window == \(analysisCount)\n")
        return Int(analysisCount)
    } else {
        let arawStr = "\(gRTSM_AmpRiseAnalysisWindow)"
        print("\nARAR - In getAmpRiseAnalysisWindow, using new, Window == \(arawStr)\n")
        return gRTSM_AmpRiseAnalysisWindow
    }
}

func getAmpRiseChangeValue() -> Double {
    var outStr = "\nARAR - In getAmpRiseChangeValue, using "
    if gUseOldRealtimeSettings {
        if gUseAmpRiseChangeSlowFastValues {
            outStr += "old, use S/F, gRTSM_AmpRise == \(gRTSM_AmpRise)\n"
            print(outStr)
            return gRTSM_AmpRise
        } else {
            outStr += "old, Not Using S/F, gAmpRiseForNewSound == \(gAmpRiseForNewSound)\n"
            print(outStr)
            return gAmpRiseForNewSound
        }
    } else {
        outStr += "New, gAmpRiseForNewSound == \(gRTSM_AmpRise)\n"
        print(outStr)
        return gRTSM_AmpRise
    }
}

func getIsASoundThreshold() -> Double {
    if gUseOldRealtimeSettings {
        print("\nISAS- In getIsASoundThreshold, using old, Thresh == \(gUseOldRealtimeSettings)\n")
        return kAmplitudeThresholdForIsSound
    } else {
        print("\nISAS - In getIsASoundThreshold, using new, Thresh == \(gRTSM_IsASoundThreshold)\n")
        return gRTSM_IsASoundThreshold
    }
}

func getSoundStartOffset() -> Double {
    if gUseOldRealtimeSettings {
        return gSoundStartAdjustment
    } else {
        return gRTSM_SoundStartOffset
    }
}

func getSamplesToDeterminePitch() -> Int {
    if gUseOldRealtimeSettings {
        return gSamplesNeededToDeterminePitch
    } else {
        return gRTSM_SamplesDeterminePitch
    }
}

func getSamplesForLegatoPitchChange() -> Int {
    if gUseOldRealtimeSettings {
        return gDifferentPitchSampleThreshold
    } else {
        return gRTSM_SamplesLegatoPitchChange
    }
}


/*
 Issues:
    In some cases, there are UserDefs stored for some of these settings.
        - if it's been changed, stored value used.
        - if not, default value used.
        - not sure if all cases where this happens are being accounted for.
        - Need to see which of these Consts should be moved to new scheme
 
    First - eliminate this scheme.
        - Elminate user defs.
        - have one global (per vaslue), that uses a default value (for all instruments).
        - Have it overridden by current mechanism for diff instruments.
        - Editing alters this global only, not a user def.
 
 
 
 
    In some cases,
 
 
 
 
 */
