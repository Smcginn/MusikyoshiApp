//
//  PATest_FreqAndPitchSampleSim.swift
//  FirstStage
//
//  Created by Scott Freshour on 10/28/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

let kDoingPitchAmplitudePitchSimTest = false

class PATestFreqAndPitchSampleSim {
    
    var canBeginTesting = false
    var lastSampleIndex: Int = 0

    func numSamples() -> Int {
        return pitchSamples.count
    }
    
    var pitchSamples: [Double] = []
    var amplitudeSamples: [Double] = []

    init() {
    }
    
    func getPitchAt(index: Int) -> Double {
        if index == 81 || index == 145 || index == 196
            {
            print("--> Begin pitch change")
        }
        if index == 92 || index == 146 || index == 203  {
            print("--> End pitch change")
        }

        if index < pitchSamples.count {
            return pitchSamples[index]
        } else {
            return  230.8 // C4
        }
    }
    
    func getAmplitudeAt(index: Int) -> Double {
        if index < amplitudeSamples.count {
            return amplitudeSamples[index]
        } else {
            return  0.0
        }
    }
    
    func SetupLegatoPitchTest1() {
        let numSamps = setupPitchDataFor_Test1()
        autofillAmpSamples_1(numSamples: numSamps)
        
        print("\n-----------------------------------------------------")
        print("\n  PATestFreqAndPitchSampleSim Test, Pitch samples:")
        for i in 0...numSamps {
            print("  For pitchSamples[\(i)], \tPitch == \(pitchSamples[i])")
        }
        
        print("\n  -------------------------------------------")
        print("\n  PATestFreqAndPitchSampleSim Test, Amplitude samples:")
        for i in 0...numSamps {
            print("  For amplitudeSamples[\(i)], \tAmplitude == \(amplitudeSamples[i])")
        }
    }
    
    
    let kAutoFill_AmpVal = Double(0.8)
    let kAutoFill_SlightDip_AmpVal = Double(0.76)
    func autofillAmpSamples_1(numSamples: Int) {
        amplitudeSamples = [Double](repeating: 0.0, count: 500)
        
        // rise
        amplitudeSamples[0] = 0.0
        amplitudeSamples[1] = 0.01
        amplitudeSamples[2] = 0.02
        amplitudeSamples[3] = 0.03
        amplitudeSamples[4] = 0.04
        amplitudeSamples[5] = 0.05
        amplitudeSamples[6] = 0.06
        amplitudeSamples[7] = 0.07
        amplitudeSamples[8] = kAutoFill_AmpVal
//        amplitudeSamples[9] = 0.09
//        amplitudeSamples[10] = 0.10
//        amplitudeSamples[11] = 0.11
//        amplitudeSamples[12] = 0.12
//        amplitudeSamples[13] = kAutoFill_AmpVal
        
        // const amplitude
        for i in 9...numSamples {
            amplitudeSamples[i] = kAutoFill_AmpVal
        }
        amplitudeSamples[50]  = kAutoFill_SlightDip_AmpVal
        amplitudeSamples[100] = kAutoFill_SlightDip_AmpVal
        amplitudeSamples[150] = kAutoFill_SlightDip_AmpVal
        amplitudeSamples[200]  = kAutoFill_SlightDip_AmpVal
        amplitudeSamples[250]  = kAutoFill_SlightDip_AmpVal
        amplitudeSamples[300]  = kAutoFill_SlightDip_AmpVal

    }
    
    func setupPitchDataFor_Test1() -> Int  {
        
        pitchSamples = [Double](repeating: 0.0, count: 500)
        
        // Sound # 1 -  G4
        // Lots of G4
        for i in 0...80 {
            pitchSamples[i] = 350.0
        }

        // Sound # 2 - C4
        // Wobbly transition from G4 to C4
        pitchSamples[81] = 1373.5
        pitchSamples[82] = 1373.5
        pitchSamples[83] = 1373.5
        pitchSamples[84] = 1373.5
        pitchSamples[85] = 1373.5
        pitchSamples[86] = 914.8
        pitchSamples[87] = 914.8
        pitchSamples[88] = 914.8
        pitchSamples[89] = 914.8
        pitchSamples[90] = 914.8
        pitchSamples[91] = 914.8

        // Lots of C4
        pitchSamples[92] = 140.8
        for i in 93...145 {
            pitchSamples[i] = 230.8
        }
        
        // Sound # 3 - G4
        // Lots of G4 - Intsant transition!
        pitchSamples[146] = 300.8
        for i in 147...195 {
            pitchSamples[i] = 350.0
        }
        
        // Sound # 4 - C4
        // 2nd Wobbly transition from G4 to C4
        pitchSamples[196] = 360.1
        pitchSamples[192] = 360.1
        pitchSamples[193] = 273.1
        pitchSamples[194] = 273.1
        pitchSamples[195] = 273.1
        pitchSamples[196] = 273.1
        pitchSamples[197] = 705.9
        pitchSamples[198] = 705.9
        pitchSamples[199] = 705.9
        pitchSamples[200] = 705.9
        pitchSamples[201] = 705.9
        pitchSamples[202] = 705.9
        
        // Lots of C4
        pitchSamples[203] = 230.8
        for i in 204...270 {
            pitchSamples[i] = 230.8
        }
        
        return 340
    }
}