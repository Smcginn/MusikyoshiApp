//
//  RealTimeSettingsGetters.swift
//  FirstStage
//
//  Created by Scott Freshour on 10/5/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//

import Foundation

// These globals can be set from a number of places in the app, and are used
// for dynaically adjusting realtime values that are used to determine when to
// break a current sound to create a new one.
var gCurrentlyInSlur = false
var gCurrSoundsLinkedNoteIsEnded = false
var gCurrSoundsLinkedNoteWillEndSoon = false
// "The current Sound is linked to a Note that has ended AND a new Note has started"
var gCurrSoundIsLinkedAndNewNoteStarted = false

var gCurrElapsedTime: TimeInterval = -1.0

var gAmpRiseCalced: Double {
    var retVal = 0.0
    
    if gCurrSoundsLinkedNoteWillEndSoon {
        retVal -= 0.05
    } else if gCurrSoundsLinkedNoteIsEnded {
        retVal -= 0.1
    }
    if gCurrSoundIsLinkedAndNewNoteStarted {
        retVal -= 0.1
    }
    
    if gCurrElapsedTime >= 0 {
        let deepCurrSoundIsLinkedAndNewNoteStarted =
            PerfTrkMgr.instance.deepCurrSoundLinkedAndNewNoteStarted(currTime: gCurrElapsedTime)
        if deepCurrSoundIsLinkedAndNewNoteStarted {
           retVal -= 0.05
        }
    }
    
    if gCurrentlyInSlur {
        if gCurrSoundIsLinkedAndNewNoteStarted {
            retVal -= 0.1
        } else {
            retVal -= 0.05
        }
    }

    return retVal
}



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
        if gCurrNoteID == 2 || gCurrNoteID == 6 || gCurrNoteID == 10 {
            //print ("yo")
        }
        var retVal = gRTSM_AmpRiseAnalysisWindow
        
        if gCurrSoundsLinkedNoteWillEndSoon {
            retVal += 1
        } else if gCurrSoundsLinkedNoteIsEnded {
            retVal += 3  // from 1 to 2
        }
        if gCurrSoundIsLinkedAndNewNoteStarted {
            retVal += 4 // 3
        }
        if gCurrentlyInSlur {
            retVal += 1
        }
//        print ("\nARAR - In getAmpRiseAnalysisWindow, using \(retVal), gCurrNoteID = \(gCurrNoteID)")

        print("   AmpRiseChangeWindow == \(retVal)")
        
        return retVal
        
        /*
        let arawStr = "\(gRTSM_AmpRiseAnalysisWindow)"
        print("\nARAR - In getAmpRiseAnalysisWindow, using new, Window == \(arawStr)\n")
        return gRTSM_AmpRiseAnalysisWindow
 */
    }
}

func currSoundShouldEndSoon() -> Bool {
    var retVal = false
//    let currInNote = false
    if gCurrSoundsLinkedNoteIsEnded || gCurrSoundsLinkedNoteWillEndSoon {
        retVal = true
    }
    return retVal
}


func getAmpRiseChangeValue() -> Double {
    
    var retVal = 0.434
    
    // Disable test for gCurrSoundsLinkedNoteWillEndSoon
    // to help eliminate early break?
    
    if gCurrSoundsLinkedNoteWillEndSoon {
        retVal -= 0.05
    } else if gCurrSoundsLinkedNoteIsEnded {
        retVal -= 0.1
    }
    if gCurrSoundIsLinkedAndNewNoteStarted {
        retVal -= 0.05
    }
    if gCurrentlyInSlur {
        retVal -= 0.05
    }
 
//    var outStr = "\nARAR - In getAmpRiseChangeValue, using \(retVal).  "
////    outStr += "\n  current Sound == \(PerfTrkMgr_CurrSoundID()),   current Note == \(PerfTrkMgr_CurrNoteID())"
//    outStr += "\n  gCurrSoundsLinkedNoteWillEndSoon == \(gCurrSoundsLinkedNoteWillEndSoon)"
//    outStr += "\n  gCurrSoundsLinkedNoteIsEnded == \(gCurrSoundsLinkedNoteIsEnded)"
//    outStr += "\n  gCurrSoundIsLinkedAndNewNoteStarted == \(gCurrSoundIsLinkedAndNewNoteStarted)"
//    outStr += "\n  gCurrentlyInSlur == \(gCurrentlyInSlur)\n"
//
//    print(outStr)
    
    print("   AmpRiseChangeValue  == \(retVal)")
    
    return  retVal
    
    /*
// RESTORE
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
 */
}

func getIsASoundThreshold() -> Double {
    let retVal = 0.3926
    var outStr = "\nISAS- In getIsASoundThreshold, using \(0.3926)"
    return retVal
    


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


/*
"instrument":"Euphonium",
"levelZones":[
{
"zone":"defaultsAllZones",
"isASoundThresholdLow":"0.511",
"isASoundThresholdMid":"0.511",
"isASoundThresholdHigh":"0.511",
"attackTolerance":"0.5",
"numSamplesToDeterminePitch":"13",
"numSamplesForLegatoPitchChange":"12",
"ampRise_SkipWindow":"10",
"ampRise_AnalysisWindow":"2",
"ampRise_RiseLowBPM":"0.440",
"ampRise_RiseMidBPM":"0.390",
"ampRise_RiseHighBPM":"0.340",
"soundStartOffSet":"0.116",
"rhythmPercent_correct":"0.3",
"rhythmPercent_aBit":"0.4",
"rhythmPercent_Very":"0.5",
"pitchcCorrectPC":"0.97",
"pitchABitToVeryPC":"0.915",
"pitchVeryBoundaryPC":"0.5"
}
]
}, {
*/
