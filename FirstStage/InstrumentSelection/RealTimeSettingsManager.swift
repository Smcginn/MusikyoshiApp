//
//  RealTimeSettingsManager.swift
//  FirstStage
//
//  Created by Scott Freshour on 10/4/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//

import Foundation


// MARK: - Globals

var gUseOldRealtimeSettings = false

var gRTSM_AmpRiseSkipWindow:Int          =   16
var gRTSM_AmpRiseAnalysisWindow:Int      =   16
var gRTSM_AmpRise:Double                 =    0.4
var gRTSM_IsASoundThreshold: Double      =    0.4
var gRTSM_SoundStartOffset: Double       =    0.145
var gRTSM_SamplesDeterminePitch: Int     =   22
var gRTSM_SamplesLegatoPitchChange: Int  =   22

/*
 
 TODO: realtime samps to determine pitch, samps for legato split

 
*/

/////////////////////////////////////////////////
// Amp Rise

var gUseAmpRiseChangeSlowFastValues = true
var gAmpRiseChangeValue_Slow = Double(0.44)
var gAmpRiseChangeValue_Fast = Double(0.34)

var kAmpRiseChangeSliderMinValue = Double(0.2)
var kAmpRiseChangeSliderMaxValue = Double(1.2)

/////////////////////////////////////////////////
// BPM Range

let kTempoRangeMin:Double =  40.0
let kTempoRangeMax:Double = 160.0
let kTempoRange = kTempoRangeMax - kTempoRangeMin
let kBPMMultiplier:Double = 1.0 / kTempoRange

let kDummyDur:Double = 0.0

typealias RTSMgr = RealTimeSettingsManager

class RealTimeSettingsManager {

    static let instance = RealTimeSettingsManager()

    let instrumentSettingsMgr = InstrumentSettingsManager()

    // call at app load and change of instrument
    func resetFor_CurrInst() {
        instrumentSettingsMgr.setupDefaultForCurrInstr()
        resetFor_CurrBPM_AndLevel()
    }
    
    // call when going to level or Day overview, of if settings change
    func resetFor_CurrBPM_AndLevel() {
        
        resetRTSMIsASoundThrshld()
        resetRTSMAmpRise()
//        resetRTSMSoundStartOffset()
        
        gRTSM_AmpRiseSkipWindow        =
            instrumentSettingsMgr.defaultLvlSettingsForInstr.ampRise_SkipWindow
        gRTSM_AmpRiseAnalysisWindow    =
            instrumentSettingsMgr.defaultLvlSettingsForInstr.ampRise_AnalysisWindow
        gRTSM_SoundStartOffset         =
            instrumentSettingsMgr.defaultLvlSettingsForInstr.soundStartOffSet
        gRTSM_SamplesDeterminePitch    =
            instrumentSettingsMgr.defaultLvlSettingsForInstr.numSamplesToDeterminePitch
        gRTSM_SamplesLegatoPitchChange =
            instrumentSettingsMgr.defaultLvlSettingsForInstr.numSamplesForLegatoPitchChange
    }
    
    
    ////////////////////////////////////////////////////////////
    // MARK: - - Attack Tolerance
    //
    
    // called on a per-note basis, realtime
    func getAdjustedAttackTolerance(_ perfNote: PerformanceNote) -> TimeInterval
    {
        var retVal = PerformanceAnalysisMgr.instance.currTolerances.rhythmTolerance
        
        let currBPM = getCurrBPM()
        guard currBPM > 0 else { return retVal }
        
        let expDur = perfNote.expectedDuration
        retVal = getAdjustedAttackToleranceImpl( currBPM: currBPM,
                                                 expDur: expDur )
        return retVal
    }
    
    func getAdjustedAttackToleranceImpl( currBPM: Double,
                                         expDur: Double ) -> TimeInterval
    {
        let attackTol = PerformanceAnalysisMgr.instance.currTolerances.rhythmTolerance
        var retVal = attackTol
        
        guard currBPM > 0 else {
            itsBad()
            return retVal
        }
        
        let halfDur = expDur/2.0
        let bpmRatio = Double(60/currBPM) * 1.2 // try a gentle adjustment
        
        retVal = retVal * bpmRatio
        if retVal > attackTol {   // too lenient
            retVal = attackTol
        }
        if retVal > halfDur { // e.g., 1/8 notes
            retVal = halfDur
        }
        
        return retVal
    }
    
    func test_getAdjustedAttackToleranceImpl() {
        var testBPM = Double(60.0)
        var testHalfDur   =  Double(2.0)
        var testQtrDur    =  Double(1.0)
        var testEighthDur =  Double(0.5)
        
        var loopCount = 1
        
        print("\n\n=============================")
        print("   Testing getAdjustedAttackToleranceImpl\n")
        repeat {
            
            let BPMStr = String(format: "%.1f", testBPM)
            let halfDurStr = String(format: "%.2f", testHalfDur)
            let qrtrDurStr = String(format: "%.2f", testQtrDur)
            let eighthDurStr = String(format: "%.2f", testEighthDur)
            
            var attackTol = getAdjustedAttackToleranceImpl( currBPM: testBPM,
                                                            expDur: testHalfDur )
            var attackTolStr = String(format: "%.4f", attackTol)
            print("At \(BPMStr) BPM, \tHalf Dur = \t\(halfDurStr), and AttackTol = \(attackTolStr)")
            
            attackTol = getAdjustedAttackToleranceImpl( currBPM: testBPM,
                                                        expDur: testQtrDur )
            attackTolStr = String(format: "%.4f", attackTol)
            print("         \tQuarter Dur = \t\(qrtrDurStr), and AttackTol = \(attackTolStr)")
            
            attackTol = getAdjustedAttackToleranceImpl( currBPM: testBPM,
                                                        expDur: testEighthDur )
            attackTolStr = String(format: "%.4f", attackTol)
            print("         \tEighth  Dur = \t\(eighthDurStr), and AttackTol = \(attackTolStr)")
            
            
            testBPM += 1.0
            let ratio = 60.0/testBPM
            testHalfDur   = 2.0 * ratio
            testQtrDur    = 1.0 * ratio
            testEighthDur = testQtrDur * 0.5
            
            loopCount += 1
        } while testBPM < 160.0
        print("\n=============================\n")
    }
    
    
    ///////////////////////////////////////////////////////////////////////
    // MARK: - - Is A Sound Threshold
    //
    
//    func getRTSMIsASoundThrshld() -> TimeInterval {
//        return gRTSM_IsASoundThreshold
//    }
    
    func resetRTSMIsASoundThrshld() {
        let currBPM = getCurrBPM()
        gRTSM_IsASoundThreshold = getRTSMIsASoundThrshldImpl(currBPM: currBPM)
        
        print("\n  New gRTSM_IsASoundThreshold == \(gRTSM_IsASoundThreshold)\n")
    }
    
    func getRTSMIsASoundThrshldImpl(currBPM: Double) -> TimeInterval
    {
        let minIASVal =
            instrumentSettingsMgr.defaultLvlSettingsForInstr.isASoundThresholdLow
        let midIASVal =
            instrumentSettingsMgr.defaultLvlSettingsForInstr.isASoundThresholdMid
        let maxIASVal =
            instrumentSettingsMgr.defaultLvlSettingsForInstr.isASoundThresholdHigh

        let adjustedVal = getInterpolatedValue(
            valInRange: currBPM,
            valAtMin: minIASVal, valAtMid: midIASVal, valAtMax: maxIASVal,
            rangeMin: 60.0, rangeMid: 110.0, rangeMax: 160.0 )
        
        return adjustedVal
    }
    
    func test_getRTSMIsASoundThrshldImpl() {
        var testBPM = Double(40.0)
        var loopCount = 1
        
        print("\n\n test_getRTSMIsASoundThrshldImpl \n")
        
        testBPM = Double(40.0)
        loopCount = 1
        repeat {
            
            let BPMStr = String(format: "%.1f", testBPM)
            
            let isASoundThrshld = getRTSMIsASoundThrshldImpl(currBPM: testBPM)
            let isASoundThrshldStr = String(format: "%.4f", isASoundThrshld)
            print("At \(BPMStr) BPM, \tIsASound Threshold = \t\(isASoundThrshldStr)")
            
            testBPM += 5.0
            
            loopCount += 1
        } while testBPM < 180.0
        
        print("\n=============================\n\n")
        
    }
    
    ///////////////////////////////////////////////////////////////////////
    // MARK: - - AmpRise
    //
    
    func getAdjustedAmpRise() -> TimeInterval {
        return gRTSM_AmpRise
    }
    
    func resetRTSMAmpRise() {
        let currBPM = getCurrBPM()
        gRTSM_AmpRise = getRTSMAmpRiseImpl(currBPM: currBPM)
        
        print("\n  New gAdjustedAmprRise == \(gRTSM_AmpRise)\n")
    }
    
    func getRTSMAmpRiseImpl(currBPM: Double) -> TimeInterval
    {
        var minARCVal = Double(0.0)
        var midARCVal = Double(0.0)
        var maxARCVal = Double(0.0)
        if gUseOldRealtimeSettings {
            minARCVal = gAmpRiseChangeValue_Slow
            midARCVal = (gAmpRiseChangeValue_Slow+gAmpRiseChangeValue_Fast)/2.0
            maxARCVal = gAmpRiseChangeValue_Fast
        } else {
            minARCVal =
                instrumentSettingsMgr.defaultLvlSettingsForInstr.ampRise_RiseLowBPM
            midARCVal =
                instrumentSettingsMgr.defaultLvlSettingsForInstr.ampRise_RiseMidBPM
            maxARCVal =
                instrumentSettingsMgr.defaultLvlSettingsForInstr.ampRise_RiseHighBPM
        }
        
        let adjustedVal = getInterpolatedValue(
            valInRange: currBPM,
            valAtMin: minARCVal, valAtMid: midARCVal, valAtMax: maxARCVal,
            rangeMin: 60.0, rangeMid: 110.0, rangeMax: 160.0 )
        
        return adjustedVal
    }
    
    func test_getRTSMAmpRiseImpl() {
        var testBPM = Double(40.0)
        var loopCount = 1
        
        print("\n\n test_getRTSMAmpRiseImpl \n")
        
        testBPM = Double(40.0)
        loopCount = 1
        repeat {
            
            let BPMStr = String(format: "%.1f", testBPM)
            
            let ampRise = getRTSMAmpRiseImpl(currBPM: testBPM)
            let ampRiseStr = String(format: "%.4f", ampRise)
            print("At \(BPMStr) BPM, \tAmp Rise = \t\(ampRiseStr)")
            
            testBPM += 5.0
            
            loopCount += 1
        } while testBPM < 180.0
        
        print("\n=============================\n\n")
        
    }
    

     
    ///////////////////////////////////////////////////////////////////////
    // MARK: - - SoundStartOffset
    //
     
//    func getRTSMSoundStartOffset() -> TimeInterval {
//        return gRTSM_SoundStartOffset
//    }

    func resetRTSMSoundStartOffset() {
        let currBPM = getCurrBPM()
        gRTSM_SoundStartOffset = getRTSMSoundStartOffsetImpl(currBPM: currBPM)

        print("\n  New gPLS_SoundStartOffset == \(gRTSM_SoundStartOffset)\n")
    }

    func getRTSMSoundStartOffsetImpl(currBPM: Double) -> TimeInterval
    {
        let adjustedVal = getInterpolatedDoubleValue(
                valInRange: currBPM,
                valAtMin: gAmpRiseChangeValue_Slow, valAtMax: gAmpRiseChangeValue_Fast,
                rangeMin: 60.0, rangeMax: 160.0 )

        return adjustedVal
    }

    func test_getRTSMSoundStartOffsetImpl() {
        var testBPM = Double(40.0)
        var loopCount = 1

        print("\n\n test_getRTSMSoundStartOffsetImpl \n")

        testBPM = Double(40.0)
        loopCount = 1
        repeat {

            let BPMStr = String(format: "%.1f", testBPM)

            let soundStartOffset = getRTSMSoundStartOffsetImpl(currBPM: testBPM)
            let soundStartOffsetStr = String(format: "%.4f", soundStartOffset)
            print("At \(BPMStr) BPM, \tSound Start Offset = \t\(soundStartOffsetStr)")

            testBPM += 5.0

            loopCount += 1
        } while testBPM < 180.0

        print("\n=============================\n\n")

    }
    
    ///////////////////////////////////////////////////////////////////////
    // MARK: - - AmpRise Skip Window
    //
    
    // called on a per-note basis, realtime
    func getAdjustedAmpRiseSkipWindow(expNoteDur: Double) -> Int {
        var retVal  = 0
        
        let currBPM = getCurrBPM()
        guard currBPM > 0 else { return retVal }
        
        //let expDur = perfNote.expectedDuration
        retVal = getAdjustedAmpRiseSkipWindowImpl( currBPM: currBPM,
                                                   expDur: expNoteDur )
        
        return retVal
    }
    
    func getAdjustedAmpRiseSkipWindowImpl( currBPM: Double,
                                           expDur: Double ) -> Int
    {
        let currInst = getCurrentStudentInstrument()
        var ampRiseSkipSamples = Int(getAmpRiseSamplesToSkip(forInstr: currInst))
        let ampRiseWindowSamples = Int(getNumSamplesInAnalysisWindow(forInstr: currInst))
        
        let samplesInDur = Int(round(expDur*100.0))
        let padding = 2
        let ampRiseSettingsSum =
                ampRiseSkipSamples + ampRiseWindowSamples + padding
        
        if ampRiseSettingsSum+padding > samplesInDur {
            let diff = ampRiseSettingsSum - samplesInDur
            ampRiseSkipSamples -= diff
        }
        
        return ampRiseSkipSamples
        
        /*
         let bpmRatio = Double(60/currBPM) * 1.2 // try a gentle adjustment
         
         
         
         
         
         retVal = retVal * bpmRatio
         if retVal > attackTol {   // too lenient
         retVal = attackTol
         }
         if retVal > halfDur { // e.g., 1/8 notes
         retVal = halfDur
         }
         
         
         return 0
         */
        
    }
    
    ///////////////////////////////////////////////////////////////////////
    // MARK: - - Samples To Determine Pitch
    //
    
    
    func getAdjustedSamplesToDetPitch( _ perfNote: PerformanceNote ) -> Int {
        
        return 0
    }
    func getAdjustedSamplesToDetPitchImpl( currBPM: Double,
                                           expDur: Double ) -> TimeInterval
    {
        return 0.0
    }
    
    //    func getCurrBPM() -> TimeInterval {
    //        let currBPM = UserDefaults.standard.double(forKey: Constants.Settings.BPM)
    //        guard currBPM > 0 else {
    //            itsBad()
    //            return currBPM
    //        }
    //
    //        return currBPM
    //    }
    
}


/*
 
 To Do:
 
 Set values for each instrument in json
 
 retrieve per-instrumernt global Adjusted values or value ranges
  DONE - - In AppDelegate - for current instrument
  DONE - - when new instrument is chosen
 
  DONE - reset adjustable vales whenever Level is entered.
 
 Find every place previous vals were used in app, and substitute adjusted vals.
 
 
 clear any values that chould be cleared at SongStart
 
 
 
 Add old/new switch
 
 
 
 
 
 
 To edit in place:
 
 OPTION 1:
 
 Switch betweeen old vars and new vars
 
 - Would have to have switch on Internal Settings Screen
 - RealTimeSettingdMgr would have to implement Getters (but not Setters?),
   instead of simple Globals
 - RealTimeSettingdMgr would have to switch internally between the
   two sets for Getters
 -
 
 OPTION 2:
 
 Editor mode uses new system
 
   BETTER in long run, but more difficult in short term
 
 - Would have to alter what Sliders load and save to.
 - Would have to add new sliders
 - Print values dialog would have to be altered
 
 
 */



