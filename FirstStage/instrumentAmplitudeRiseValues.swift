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

// Woodwinds
let kFlute_defSkipBeginningSamples:             UInt     = 15
let kFlute_defSamplesInAnalysisWindow:          UInt     = 2
let kFlute_defAmpRiseForNewSound:               Double   = 0.2

let kOboe_defSkipBeginningSamples:              UInt     = 15
let kOboe_defSamplesInAnalysisWindow:           UInt     = 2
let kOboe_defAmpRiseForNewSound:                Double   = 0.2

let kClarinet_defSkipBeginningSamples:          UInt     = 15
let kClarinet_defSamplesInAnalysisWindow:       UInt     = 2
let kClarinet_defAmpRiseForNewSound:            Double   = 0.2

let kBassClarinet_defSkipBeginningSamples:      UInt     = 15
let kBassClarinet_defSamplesInAnalysisWindow:   UInt     = 2
let kBassClarinet_defAmpRiseForNewSound:        Double   = 0.2

let kBassoon_defSkipBeginningSamples:           UInt     = 15
let kBassoon_defSamplesInAnalysisWindow:        UInt     = 2
let kBassoon_defAmpRiseForNewSound:             Double   = 0.2

let kAltoSax_defSkipBeginningSamples:           UInt     = 15
let kAltoSax_defSamplesInAnalysisWindow:        UInt     = 2
let kAltoSax_defAmpRiseForNewSound:             Double   = 0.2

let kTenorSax_defSkipBeginningSamples:          UInt     = 15
let kTenorSax_defSamplesInAnalysisWindow:       UInt     = 2
let kTenorSax_defAmpRiseForNewSound:            Double   = 0.2

let kBaritoneSax_defSkipBeginningSamples:       UInt     = 15
let kBaritoneSax_defSamplesInAnalysisWindow:    UInt     = 2
let kBaritoneSax_defAmpRiseForNewSound:         Double   = 0.2

let kMallet_defSkipBeginningSamples:            UInt     = 15
let kMallet_defSamplesInAnalysisWindow:         UInt     = 2
let kMallet_defAmpRiseForNewSound:              Double   = 0.2

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
    guard forInstr < kInst_NumInstruments else {
        itsBad()
        return retVal
    }
    
    var key = ""
    switch forInstr {
    case kInst_Trombone:    key =  Constants.Settings.Trombone_SkipBeginningSamples
    case kInst_Euphonium:   key =  Constants.Settings.Euphonium_SkipBeginningSamples
    case kInst_FrenchHorn:  key =  Constants.Settings.Horn_SkipBeginningSamples
    case kInst_Tuba:        key =  Constants.Settings.Tuba_SkipBeginningSamples
        
    case kInst_Flute:       key =  Constants.Settings.Flute_SkipBeginningSamples
    case kInst_Oboe:        key =  Constants.Settings.Oboe_SkipBeginningSamples
    case kInst_Clarinet:    key =  Constants.Settings.Clarinet_SkipBeginningSamples
    case kInst_BassClarinet: key = Constants.Settings.BassClarinet_SkipBeginningSamples
    case kInst_Bassoon:     key =  Constants.Settings.BassoonTuba_SkipBeginningSamples
    case kInst_AltoSax:     key =  Constants.Settings.AltoSax_SkipBeginningSamples
    case kInst_TenorSax:    key =  Constants.Settings.TenorSax_SkipBeginningSamples
    case kInst_BaritoneSax: key =  Constants.Settings.BaritoneSax_SkipBeginningSamples
        
    case kInst_Mallet:      key =  Constants.Settings.Mallet_SkipBeginningSamples
        
    case kInst_Trumpet:     fallthrough
    default:                key =  Constants.Settings.Trumpet_SkipBeginningSamples
    }
    
    retVal = UInt(UserDefaults.standard.integer(forKey: key))

    return retVal
}

func getNumSamplesInAnalysisWindow(forInstr: Int) -> UInt {
    var retVal: UInt = kTrumpet_defSamplesInAnalysisWindow
    guard forInstr < kInst_NumInstruments else {
        itsBad()
        return retVal
    }
    
    var key = ""
    switch forInstr {
    case kInst_Trombone:    key =  Constants.Settings.Trombone_SamplesInAnalysisWindow
    case kInst_Euphonium:   key =  Constants.Settings.Euphonium_SamplesInAnalysisWindow
    case kInst_FrenchHorn:  key =  Constants.Settings.Horn_SamplesInAnalysisWindow
    case kInst_Tuba:        key =  Constants.Settings.Tuba_SamplesInAnalysisWindow
        
    case kInst_Flute:       key =  Constants.Settings.Flute_SamplesInAnalysisWindow
    case kInst_Oboe:        key =  Constants.Settings.Oboe_SamplesInAnalysisWindow
    case kInst_Clarinet:    key =  Constants.Settings.Clarinet_SamplesInAnalysisWindow
    case kInst_BassClarinet: key = Constants.Settings.BassClarinet_SamplesInAnalysisWindow
    case kInst_Bassoon:     key =  Constants.Settings.Bassoon_SamplesInAnalysisWindow
    case kInst_AltoSax:     key =  Constants.Settings.AltoSax_SamplesInAnalysisWindow
    case kInst_TenorSax:    key =  Constants.Settings.TenorSax_SamplesInAnalysisWindow
    case kInst_BaritoneSax: key =  Constants.Settings.BaritoneSax_SamplesInAnalysisWindow

    case kInst_Trumpet:     fallthrough
    default:                key =  Constants.Settings.Trumpet_SamplesInAnalysisWindow
    }

    retVal = UInt(UserDefaults.standard.integer(forKey: key))
    
    return retVal
}

func getAmpRiseForNewSound(forInstr: Int) -> Double {
    var retVal: Double = kTrumpet_defAmpRiseForNewSound
    guard forInstr < kInst_NumInstruments else {
        itsBad()
        return retVal
    }
    
    var key = ""
    switch forInstr {
    case kInst_Trombone:    key =  Constants.Settings.Trombone_AmpRiseForNewSound
    case kInst_Euphonium:   key =  Constants.Settings.Euphonium_AmpRiseForNewSound
    case kInst_FrenchHorn:  key =  Constants.Settings.Horn_AmpRiseForNewSound
    case kInst_Tuba:        key =  Constants.Settings.Tuba_AmpRiseForNewSound
        
    case kInst_Flute:       key =  Constants.Settings.Flute_AmpRiseForNewSound
    case kInst_Oboe:        key =  Constants.Settings.Oboe_AmpRiseForNewSound
    case kInst_Clarinet:    key =  Constants.Settings.Clarinet_AmpRiseForNewSound
    case kInst_BassClarinet: key = Constants.Settings.BassClarinet_AmpRiseForNewSound
    case kInst_Bassoon:     key =  Constants.Settings.Bassoon_AmpRiseForNewSound
    case kInst_AltoSax:     key =  Constants.Settings.AltoSax_AmpRiseForNewSound
    case kInst_TenorSax:    key =  Constants.Settings.TenorSax_AmpRiseForNewSound
    case kInst_BaritoneSax: key =  Constants.Settings.BaritoneSax_AmpRiseForNewSound
        
    case kInst_Mallet:      key =  Constants.Settings.Mallet_AmpRiseForNewSound

    case kInst_Trumpet:     fallthrough
    default:                key =  Constants.Settings.Trumpet_AmpRiseForNewSound
    }

    retVal = UserDefaults.standard.double(forKey: key)
    
    return retVal
}

///////////////////////////////////////////////////////////////////////
// MARK:- Support for calls from Settings Window (when in debug mode)

func setAmpRiseSamplesToSkip(forInstr: Int, numSamples: UInt) {
    guard forInstr >= kInst_Trumpet && forInstr < kInst_NumInstruments else {
        itsBad()
        return
    }
    
    var key = ""
    switch forInstr {
    case kInst_Trombone:    key =  Constants.Settings.Trombone_SkipBeginningSamples
    case kInst_Euphonium:   key =  Constants.Settings.Euphonium_SkipBeginningSamples
    case kInst_FrenchHorn:  key =  Constants.Settings.Horn_SkipBeginningSamples
    case kInst_Tuba:        key =  Constants.Settings.Tuba_SkipBeginningSamples
        
    case kInst_Flute:       key =  Constants.Settings.Flute_SkipBeginningSamples
    case kInst_Oboe:        key =  Constants.Settings.Oboe_SkipBeginningSamples
    case kInst_Clarinet:    key =  Constants.Settings.Clarinet_SkipBeginningSamples
    case kInst_BassClarinet: key = Constants.Settings.BassClarinet_SkipBeginningSamples
    case kInst_Bassoon:     key =  Constants.Settings.BassoonTuba_SkipBeginningSamples
    case kInst_AltoSax:     key =  Constants.Settings.AltoSax_SkipBeginningSamples
    case kInst_TenorSax:    key =  Constants.Settings.TenorSax_SkipBeginningSamples
    case kInst_BaritoneSax: key =  Constants.Settings.BaritoneSax_SkipBeginningSamples
        
    case kInst_Mallet:      key =  Constants.Settings.Mallet_SkipBeginningSamples
        
    case kInst_Trumpet:     fallthrough
    default:                key =  Constants.Settings.Trumpet_SkipBeginningSamples
    }
    
    UserDefaults.standard.set(numSamples, forKey: key)
}

func setNumSamplesInAnalysisWindow(forInstr: Int, numSamples: UInt) {
    guard forInstr < kInst_NumInstruments else {
        itsBad()
        return
    }
    var key = ""
    switch forInstr {
    case kInst_Trombone:    key =  Constants.Settings.Trombone_SamplesInAnalysisWindow
    case kInst_Euphonium:   key =  Constants.Settings.Euphonium_SamplesInAnalysisWindow
    case kInst_FrenchHorn:  key =  Constants.Settings.Horn_SamplesInAnalysisWindow
    case kInst_Tuba:        key =  Constants.Settings.Tuba_SamplesInAnalysisWindow
        
    case kInst_Flute:       key =  Constants.Settings.Flute_SamplesInAnalysisWindow
    case kInst_Oboe:        key =  Constants.Settings.Oboe_SamplesInAnalysisWindow
    case kInst_Clarinet:    key =  Constants.Settings.Clarinet_SamplesInAnalysisWindow
    case kInst_BassClarinet: key = Constants.Settings.BassClarinet_SamplesInAnalysisWindow
    case kInst_Bassoon:     key =  Constants.Settings.Bassoon_SamplesInAnalysisWindow
    case kInst_AltoSax:     key =  Constants.Settings.AltoSax_SamplesInAnalysisWindow
    case kInst_TenorSax:    key =  Constants.Settings.TenorSax_SamplesInAnalysisWindow
    case kInst_BaritoneSax: key =  Constants.Settings.BaritoneSax_SamplesInAnalysisWindow

    case kInst_Mallet:      key =  Constants.Settings.Mallet_SamplesInAnalysisWindow
        
    case kInst_Trumpet:     fallthrough
    default:                key =  Constants.Settings.Trumpet_SamplesInAnalysisWindow
    }
    
    UserDefaults.standard.set(numSamples, forKey: key)
}

func setAmpRiseForNewSound(forInstr: Int, rise: Double) {
    guard forInstr < kInst_NumInstruments else {
        itsBad()
        return
    }
    var key = ""
    switch forInstr {
    case kInst_Trombone:    key =  Constants.Settings.Trombone_AmpRiseForNewSound
    case kInst_Euphonium:   key =  Constants.Settings.Euphonium_AmpRiseForNewSound
    case kInst_FrenchHorn:  key =  Constants.Settings.Horn_AmpRiseForNewSound
    case kInst_Tuba:        key =  Constants.Settings.Tuba_AmpRiseForNewSound
        
    case kInst_Flute:       key =  Constants.Settings.Flute_AmpRiseForNewSound
    case kInst_Oboe:        key =  Constants.Settings.Oboe_AmpRiseForNewSound
    case kInst_Clarinet:    key =  Constants.Settings.Clarinet_AmpRiseForNewSound
    case kInst_BassClarinet: key = Constants.Settings.BassClarinet_AmpRiseForNewSound
    case kInst_Bassoon:     key =  Constants.Settings.Bassoon_AmpRiseForNewSound
    case kInst_AltoSax:     key =  Constants.Settings.AltoSax_AmpRiseForNewSound
    case kInst_TenorSax:    key =  Constants.Settings.TenorSax_AmpRiseForNewSound
    case kInst_BaritoneSax: key =  Constants.Settings.BaritoneSax_AmpRiseForNewSound
        
    case kInst_Mallet:      key =  Constants.Settings.Mallet_AmpRiseForNewSound
        
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
    
    // CHANGEHERE
    switch forInstr {
    case kInst_Trombone:
        resetAmpRiseValuesToDefaultsUsing(instr:  kInst_Trombone,
              numSkipSamples:  kTrombone_defSkipBeginningSamples,
              samplesInWindow: kTrombone_defSamplesInAnalysisWindow,
              ampRise:         kTrombone_defAmpRiseForNewSound )
        
    case kInst_Euphonium:
        resetAmpRiseValuesToDefaultsUsing(instr:  kInst_Euphonium,
              numSkipSamples:  kEuphonium_defSkipBeginningSamples,
              samplesInWindow: kEuphonium_defSamplesInAnalysisWindow,
              ampRise:         kEuphonium_defAmpRiseForNewSound )
        
    case kInst_FrenchHorn:
        resetAmpRiseValuesToDefaultsUsing(instr:  kInst_Tuba,
              numSkipSamples:  kHorn_defSkipBeginningSamples,
              samplesInWindow: kHorn_defSamplesInAnalysisWindow,
              ampRise:         kHorn_defAmpRiseForNewSound )
        
    case kInst_Tuba:
        resetAmpRiseValuesToDefaultsUsing(instr:  kInst_Tuba,
              numSkipSamples:  kTuba_defSkipBeginningSamples,
              samplesInWindow: kTuba_defSamplesInAnalysisWindow,
              ampRise:         kTuba_defAmpRiseForNewSound )
        
        
    case kInst_Flute:
        resetAmpRiseValuesToDefaultsUsing(instr:  kInst_Tuba,
              numSkipSamples:  kFlute_defSkipBeginningSamples,
              samplesInWindow: kFlute_defSamplesInAnalysisWindow,
              ampRise:         kFlute_defAmpRiseForNewSound )
        
    case kInst_Oboe:
        resetAmpRiseValuesToDefaultsUsing(instr:  kInst_Oboe,
                                          numSkipSamples:  kOboe_defSkipBeginningSamples,
                                          samplesInWindow: kOboe_defSamplesInAnalysisWindow,
                                          ampRise:         kOboe_defAmpRiseForNewSound )
        
    case kInst_Clarinet:
        resetAmpRiseValuesToDefaultsUsing(instr:  kInst_Clarinet,
              numSkipSamples:  kClarinet_defSkipBeginningSamples,
              samplesInWindow: kClarinet_defSamplesInAnalysisWindow,
              ampRise:         kClarinet_defAmpRiseForNewSound )
        
    case kInst_BassClarinet:
        resetAmpRiseValuesToDefaultsUsing(instr:  kInst_BassClarinet,
              numSkipSamples:  kBassClarinet_defSkipBeginningSamples,
              samplesInWindow: kBassClarinet_defSamplesInAnalysisWindow,
              ampRise:         kBassClarinet_defAmpRiseForNewSound )
        
    case kInst_Bassoon:
        resetAmpRiseValuesToDefaultsUsing(instr:  kInst_Bassoon,
              numSkipSamples:  kBassoon_defSkipBeginningSamples,
              samplesInWindow: kBassoon_defSamplesInAnalysisWindow,
              ampRise:         kBassoon_defAmpRiseForNewSound )
        
    case kInst_AltoSax:
        resetAmpRiseValuesToDefaultsUsing(instr:  kInst_AltoSax,
              numSkipSamples:  kAltoSax_defSkipBeginningSamples,
              samplesInWindow: kAltoSax_defSamplesInAnalysisWindow,
              ampRise:         kAltoSax_defAmpRiseForNewSound )
        
    case kInst_TenorSax:
        resetAmpRiseValuesToDefaultsUsing(instr:  kInst_TenorSax,
              numSkipSamples:  kTenorSax_defSkipBeginningSamples,
              samplesInWindow: kTenorSax_defSamplesInAnalysisWindow,
              ampRise:         kTenorSax_defAmpRiseForNewSound )
        
    case kInst_BaritoneSax:
        resetAmpRiseValuesToDefaultsUsing(instr:  kInst_BaritoneSax,
              numSkipSamples:  kBaritoneSax_defSkipBeginningSamples,
              samplesInWindow: kBaritoneSax_defSamplesInAnalysisWindow,
              ampRise:         kBaritoneSax_defAmpRiseForNewSound )
        
    case kInst_Mallet:
        resetAmpRiseValuesToDefaultsUsing(instr:  kInst_Mallet,
              numSkipSamples:  kMallet_defSkipBeginningSamples,
              samplesInWindow: kMallet_defSamplesInAnalysisWindow,
              ampRise:         kMallet_defAmpRiseForNewSound )

    case kInst_Trumpet:     fallthrough
    default:
        resetAmpRiseValuesToDefaultsUsing(instr:  kInst_Trumpet,
              numSkipSamples:  kTrumpet_defSkipBeginningSamples,
              samplesInWindow: kTrumpet_defSamplesInAnalysisWindow,
              ampRise:         kTrumpet_defAmpRiseForNewSound )
   }
}

func resetAmpRiseValuesToDefaultsUsing(instr: Int,
                                       numSkipSamples: UInt,
                                       samplesInWindow: UInt,
                                       ampRise: Double ) {
    changeAmpRiseSamplesToSkip(forInstr: instr, numSamples: numSkipSamples)
    changeNumSamplesInAnalysisWindow(forInstr: instr, numSamples: samplesInWindow)
    changeAmpRiseForNewSound(forInstr: instr, rise: ampRise)
}


