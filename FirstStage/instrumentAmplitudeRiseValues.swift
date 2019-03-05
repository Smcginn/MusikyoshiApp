//
//  instrumentAmplitudeRiseValues.swift
//  FirstStage
//
//  Created by Scott Freshour on 2/4/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//

import Foundation

///////////////////////////////////////////////////////////////////////
// MARK:- Default vals

let kTrumpet_defSkipBeginningSamples:      UInt     = 15
let kTrumpet_defSamplesInAnalysisWindow:   UInt     = 2
let kTrumpet_defAmpRiseForNewSound:        Double   = 0.2

let kTrombone_defSkipBeginningSamples:     UInt     = 15
let kTrombone_defSamplesInAnalysisWindow:  UInt     = 2
let kTrombone_defAmpRiseForNewSound:       Double   = 0.2

let kEuphonium_defSkipBeginningSamples:    UInt     = 15
let kEuphonium_defSamplesInAnalysisWindow: UInt     = 2
let kEuphonium_defAmpRiseForNewSound:      Double   = 0.2

let kHorn_defSkipBeginningSamples:         UInt     = 15
let kHorn_defSamplesInAnalysisWindow:      UInt     = 2
let kHorn_defAmpRiseForNewSound:           Double   = 0.2

let kTuba_defSkipBeginningSamples:         UInt     = 15
let kTuba_defSamplesInAnalysisWindow:      UInt     = 2
let kTuba_defAmpRiseForNewSound:           Double   = 0.2

let kSkipBeginningSamples_min:             UInt     = 10
let kSkipBeginningSamples_max:             UInt     = 30
let kSamplesInAnalysisWindow_min:          UInt     = 2
let kSamplesInAnalysisWindow_max:          UInt     = 10
let kAmpRiseForNewSound_min:               Double   = 0.1
let kAmpRiseForNewSound_max:               Double   = 1.0

///////////////////////////////////////////////////////////////////////
// MARK:- Globsls used by app in realtime

let kNumSamplesForStillSound = 8

var gSkipBeginningSamples:      UInt     = 15
var gSamplesInAnalysisWindow:   UInt     =  2
var gAmpRiseForNewSound:        Double   = 0.2

func setCurrentAmpRiseValsForInstrument(forInstr: Int) {
    gSkipBeginningSamples    = getAmpRiseSamplesToSkip(forInstr: forInstr)
    gSamplesInAnalysisWindow = getNumSamplesInAnalysisWindow(forInstr: forInstr)
    gAmpRiseForNewSound      = getAmpRiseForNewSound(forInstr: forInstr)
}

///////////////////////////////////////////////////////////////////////
// MARK:- Getters

func getAmpRiseSamplesToSkip(forInstr: Int) -> UInt {
    var retVal: UInt = kTrumpet_defSkipBeginningSamples
    guard forInstr < kInst_NumBrass else {
        itsBad()
        return retVal
    }
    
    var key = ""
    switch forInstr {
    case kInst_Trombone:    key =  Constants.Settings.Trombone_SkipBeginningSamples
    case kInst_Euphonium:   key =  Constants.Settings.Euphonium_SkipBeginningSamples
    case kInst_FrenchHorn:  key =  Constants.Settings.Horn_SkipBeginningSamples
    case kInst_Tuba:        key =  Constants.Settings.Tuba_SkipBeginningSamples
    case kInst_Trumpet:     fallthrough
    default:                key =  Constants.Settings.Trumpet_SkipBeginningSamples
    }
    
    retVal = UInt(UserDefaults.standard.integer(forKey: key))

    return retVal
}

func getNumSamplesInAnalysisWindow(forInstr: Int) -> UInt {
    var retVal: UInt = kTrumpet_defSamplesInAnalysisWindow
    guard forInstr < kInst_NumBrass else {
        itsBad()
        return retVal
    }
    
    var key = ""
    switch forInstr {
    case kInst_Trombone:    key =  Constants.Settings.Trombone_SamplesInAnalysisWindow
    case kInst_Euphonium:   key =  Constants.Settings.Euphonium_SamplesInAnalysisWindow
    case kInst_FrenchHorn:  key =  Constants.Settings.Horn_SamplesInAnalysisWindow
    case kInst_Tuba:        key =  Constants.Settings.Tuba_SamplesInAnalysisWindow
    case kInst_Trumpet:     fallthrough
    default:                key =  Constants.Settings.Trumpet_SamplesInAnalysisWindow
    }

    retVal = UInt(UserDefaults.standard.integer(forKey: key))
    
    return retVal
}

func getAmpRiseForNewSound(forInstr: Int) -> Double {
    var retVal: Double = kTrumpet_defAmpRiseForNewSound
    guard forInstr < kInst_NumBrass else {
        itsBad()
        return retVal
    }
    
    var key = ""
    switch forInstr {
    case kInst_Trombone:    key =  Constants.Settings.Trombone_AmpRiseForNewSound
    case kInst_Euphonium:   key =  Constants.Settings.Euphonium_AmpRiseForNewSound
    case kInst_FrenchHorn:  key =  Constants.Settings.Horn_AmpRiseForNewSound
    case kInst_Tuba:        key =  Constants.Settings.Tuba_AmpRiseForNewSound
    case kInst_Trumpet:     fallthrough
    default:                key =  Constants.Settings.Trumpet_AmpRiseForNewSound
    }

    retVal = UserDefaults.standard.double(forKey: key)
    
    return retVal
}

///////////////////////////////////////////////////////////////////////
// MARK:- Support for calls from Settings Window (when in debug mode)

func setAmpRiseSamplesToSkip(forInstr: Int, numSamples: UInt) {
    guard forInstr >= kInst_Trumpet && forInstr < kInst_NumBrass else {
        itsBad()
        return
    }
    
    var key = ""
    switch forInstr {
    case kInst_Trombone:    key =  Constants.Settings.Trombone_SkipBeginningSamples
    case kInst_Euphonium:   key =  Constants.Settings.Euphonium_SkipBeginningSamples
    case kInst_FrenchHorn:  key =  Constants.Settings.Horn_SkipBeginningSamples
    case kInst_Tuba:        key =  Constants.Settings.Tuba_SkipBeginningSamples
    case kInst_Trumpet:     fallthrough
    default:                key =  Constants.Settings.Trumpet_SkipBeginningSamples
    }
    
    UserDefaults.standard.set(numSamples, forKey: key)
}

func setNumSamplesInAnalysisWindow(forInstr: Int, numSamples: UInt) {
    guard forInstr < kInst_NumBrass else {
        itsBad()
        return
    }
    var key = ""
    switch forInstr {
    case kInst_Trombone:    key =  Constants.Settings.Trombone_SamplesInAnalysisWindow
    case kInst_Euphonium:   key =  Constants.Settings.Euphonium_SamplesInAnalysisWindow
    case kInst_FrenchHorn:  key =  Constants.Settings.Horn_SamplesInAnalysisWindow
    case kInst_Tuba:        key =  Constants.Settings.Tuba_SamplesInAnalysisWindow
    case kInst_Trumpet:     fallthrough
    default:                key =  Constants.Settings.Trumpet_SamplesInAnalysisWindow
    }
    
    UserDefaults.standard.set(numSamples, forKey: key)
}

func setAmpRiseForNewSound(forInstr: Int, rise: Double) {
    guard forInstr < kInst_NumBrass else {
        itsBad()
        return
    }
    var key = ""
    switch forInstr {
    case kInst_Trombone:    key =  Constants.Settings.Trombone_AmpRiseForNewSound
    case kInst_Euphonium:   key =  Constants.Settings.Euphonium_AmpRiseForNewSound
    case kInst_FrenchHorn:  key =  Constants.Settings.Horn_AmpRiseForNewSound
    case kInst_Tuba:        key =  Constants.Settings.Tuba_AmpRiseForNewSound
    case kInst_Trumpet:     fallthrough
    default:                key =  Constants.Settings.Trumpet_AmpRiseForNewSound
    }
    
    UserDefaults.standard.set(rise, forKey: key)
}

///////////////////////////////////////////////////////////////////////
// MARK:- Called from Settings Window (when in debug mode)

func changeAmpRiseSamplesToSkip(forInstr: Int, numSamples: UInt) {
    setAmpRiseSamplesToSkip(forInstr: forInstr, numSamples: numSamples)
    setCurrentAmpRiseValsForInstrument(forInstr: forInstr)
}

func changeNumSamplesInAnalysisWindow(forInstr: Int, numSamples: UInt) {
    setNumSamplesInAnalysisWindow(forInstr: forInstr, numSamples: numSamples)
    setCurrentAmpRiseValsForInstrument(forInstr: forInstr)
}

func changeAmpRiseForNewSound(forInstr: Int, rise: Double) {
    setAmpRiseForNewSound(forInstr: forInstr, rise: rise)
    setCurrentAmpRiseValsForInstrument(forInstr: forInstr)
}

func resetAmpRiseValesToDefaults(forInstr: Int) {
    
    switch forInstr {
    case kInst_Trombone:
        changeAmpRiseSamplesToSkip(forInstr: kInst_Trombone,
                                   numSamples: kTrombone_defSkipBeginningSamples)
        changeNumSamplesInAnalysisWindow(forInstr: kInst_Trombone,
                                         numSamples: kTrombone_defSamplesInAnalysisWindow)
        changeAmpRiseForNewSound(forInstr: kInst_Trombone,
                                 rise: kTrombone_defAmpRiseForNewSound)
        
    case kInst_Euphonium:
        changeAmpRiseSamplesToSkip(forInstr: kInst_Euphonium,
                                   numSamples: kEuphonium_defSkipBeginningSamples)
        changeNumSamplesInAnalysisWindow(forInstr: kInst_Euphonium,
                                         numSamples: kEuphonium_defSamplesInAnalysisWindow)
        changeAmpRiseForNewSound(forInstr: kInst_Euphonium,
                                 rise: kEuphonium_defAmpRiseForNewSound)
        
    case kInst_FrenchHorn:
        changeAmpRiseSamplesToSkip(forInstr: kInst_FrenchHorn,
                                   numSamples: kHorn_defSkipBeginningSamples)
        changeNumSamplesInAnalysisWindow(forInstr: kInst_FrenchHorn,
                                         numSamples: kHorn_defSamplesInAnalysisWindow)
        changeAmpRiseForNewSound(forInstr: kInst_FrenchHorn,
                                 rise: kHorn_defAmpRiseForNewSound)
        
    case kInst_Tuba:
        changeAmpRiseSamplesToSkip(forInstr: kInst_Tuba,
                                   numSamples: kTuba_defSkipBeginningSamples)
        changeNumSamplesInAnalysisWindow(forInstr: kInst_Tuba,
                                         numSamples: kTuba_defSamplesInAnalysisWindow)
        changeAmpRiseForNewSound(forInstr: kInst_Tuba,
                                 rise: kTuba_defAmpRiseForNewSound)
        
    case kInst_Trumpet:     fallthrough
    default:
        changeAmpRiseSamplesToSkip(forInstr: kInst_Trumpet,
                                   numSamples: kTrumpet_defSkipBeginningSamples)
        changeNumSamplesInAnalysisWindow(forInstr: kInst_Trumpet,
                                         numSamples: kTrumpet_defSamplesInAnalysisWindow)
        changeAmpRiseForNewSound(forInstr: kInst_Trumpet,
                                 rise: kTrumpet_defAmpRiseForNewSound)
   }
}


