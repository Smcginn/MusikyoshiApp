//
//  LevelSettingsInterpolating.swift
//  FirstStage
//
//  Created by Scott Freshour on 10/3/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//

import Foundation

/*
 AmpRise -
 
 
 BPM -
 
 Some thing (RiseWindow, RiseValue, Skip Window, etc.) -
 
 Changes over a range of two values (Low, High)  as Level increases
 Changes over a range of two values (Low, High)  as Tempo increases
 Changes over a range of two values (Low, High)  as Level & Tempo vary
 
Extrapolate the value of Some Thing (RiseWindow, Skip Window, etc.)
- given three values (Low, Mid, High)
- over two ranges (Low-Mid, Mid-High)
Given something changes
- as Level increases
- as Tempo increases
- as Level AND Tempo vary
 
 
 Changes over a range of two values (Low, High)  as Tempo increases
 Changes over a range of two values (Low, High)  as Level & Tempo vary
 

 Changes as Tempo increases
 
 Changes as the combo of Level & Tempo increases
 
 */

// Double version
func getInterpolatedDoubleValue(
            valInRange: Double,
            valAtMin: Double, valAtMax: Double,
            rangeMin: Double, rangeMax: Double ) -> Double  {
   
    guard valInRange >= rangeMin else {
        return valAtMin
    }
    guard valInRange <= rangeMax else {
        return valAtMax
    }
    guard rangeMin != rangeMax else { // avoid divide by 0
        return valAtMin
    }

    // E.g., Range would be BPM, with 60 and 160 for min/max vals.
    let rangeRange = rangeMax - rangeMin
    let rangeFraction: Double = 1.0 / rangeRange
    let rangeOffset = valInRange - rangeMin
    let rangeMult   = rangeOffset * rangeFraction

    let valueRange = valAtMax - valAtMin
    let amtToAdd = rangeMult * valueRange
    let adjustedVal = valAtMin + amtToAdd
    
    return adjustedVal
}

// Double version
func getInterpolatedValue(
            valInRange: Double,
            valAtMin: Double, valAtMid: Double, valAtMax: Double,
            rangeMin: Double, rangeMid: Double, rangeMax: Double ) -> Double {
    
    guard valInRange >= rangeMin else {
        return valAtMin
    }
    guard valInRange <= rangeMax else {
        return valAtMax
    }
    
    if valInRange <= rangeMid {
        return getInterpolatedDoubleValue( valInRange: valInRange,
                                          valAtMin: valAtMin, valAtMax: valAtMid,
                                          rangeMin: rangeMin, rangeMax: rangeMid )
    } else {
        return getInterpolatedDoubleValue( valInRange: valInRange,
                                          valAtMin: valAtMid, valAtMax: valAtMax,
                                          rangeMin: rangeMid, rangeMax: rangeMax )
    }
}

// Int Version
func getInterpolatedValue(
    valInRange: Int,
    valAtMin: Int, valAtMax: Int,
    rangeMin: Int, rangeMax: Int ) -> Int  {
    
    let retVal = getInterpolatedDoubleValue(
        valInRange: Double(valInRange),
        valAtMin: Double(valAtMin), valAtMax: Double(valAtMax),
        rangeMin: Double(rangeMin), rangeMax: Double(rangeMin) )
    
    let retValInt = Int(round(retVal))
    return retValInt
}

// Int Version
func getInterpolatedValue(
                valInRange: Int,
                valAtMin: Int, valAtMid: Int, valAtMax: Int,
                rangeMin: Int, rangeMid: Int, rangeMax: Int ) -> Int {

    let retVal = getInterpolatedValue(
        valInRange: Double(valInRange),
        valAtMin: Double(valAtMin), valAtMid: Double(valAtMid), valAtMax: Double(valAtMax),
        rangeMin: Double(rangeMin), rangeMid: Double(rangeMid), rangeMax: Double(rangeMin) )
    
    let retValInt = Int(round(retVal))
    return retValInt
}

