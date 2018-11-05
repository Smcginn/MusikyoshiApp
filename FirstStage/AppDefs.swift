//
//  AppDefs.swift
//  FirstStage
//
//  Created by Scott Freshour on 8/31/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//
//  App-wide defaults.  Mostly Color.
//

import Foundation

////////////////////////////////////////////////////////////
// Colors, or possible colors

let kTan0       = UIColor(hexString: "#E3CB92ff")
let kDarkGold   = UIColor(hexString: "#F28044ff")
let kGold       = UIColor(hexString: "#F0A761ff")
let kLightGold  = UIColor(hexString: "#FEC362ff")   

let kTanBackgroundColor2 = UIColor(red:   0.15,  green:  0.15,
                                   blue:  0.15,  alpha:  0.15)
let kTanBackgroundColor3 = UIColor(red:   1.0,   green:  0.93,
                                   blue:  0.66,  alpha:  0.15)

let kTanBackgroundColor                 = kTan0
let kLtTanBackgroundColor1              = UIColor(hexString: "#FFCC77ff")
let kLtTanBackgroundColor2              = UIColor(hexString: "#FFE6A7ff")
let kLtTanBackgroundColor3              = UIColor(hexString: "#FFDDAAff")
let kLtTanBackgroundColor4              = UIColor(hexString: "#E3CB924f")

// Sea Foam
let kSeaFoamBlue  = UIColor(red:   0.627,  green:  0.871,
                            blue:  0.834,  alpha:  1.0 )

// Button
let kBlueButton   = UIColor(red:   0.262,  green:  0.313,
                            blue:  1.0,    alpha:  1.0 )

// darker sky
let kDarkSkyBlue  = UIColor(red:   0.407,  green:  0.667,
                            blue:  1.0,    alpha:  1.0 )

// light sky
let kLightSkyBlue = UIColor(red:   0.521,  green:  0.813,
                            blue:  1.0,    alpha:  1.0 )


/////////////////////////////////////////////////////////////
// App-wide defaults

let kButtonTextColor                    = UIColor.black
let kButtonColor                        = kBlueButton

let kButtonTextOnClearBckgrndColor      = UIColor.black

let kDefaultViewBackgroundColor         = kLightSkyBlue // UIColor.white // kTanBackgroundColor

let kDefault_BackButtonTextColor        =  UIColor.blue

let kDefault_ButtonBckgrndColor         =  (kBlueButton).withAlphaComponent(0.4)
let kDefault_ButtonTextColor            =  UIColor.yellow

let kDefault_AlertBackgroundColor       =  (kSeaFoamBlue).withAlphaComponent(0.2)

let kDefault_LaunchingViewBackgroundColor = (kDarkSkyBlue).withAlphaComponent(0.7)



////////////////////////////////////////////////////////////
// Section/Cell colors
let kDefault_SectionBkgrndColor         =  (kBlueButton).withAlphaComponent(0.55)
let kDefault_SelectCellBkgrndColor      =  kDarkSkyBlue
let kDefault_CellBkgrndColor            =  kLightSkyBlue

////////////////////////////////////////////////////////////
// Day Overview
let kDayOverVw_BackgroundColor          =  kDefaultViewBackgroundColor
let kDayOverVw_DoSetCellBkgrndColor     =  true
let kDayOverVw_CellBkgrndColor          =  kDefaultViewBackgroundColor //kDefault_CellBkgrndColor

////////////////////////////////////////////////////////////
// TuneExerciseView
let kTuneExer_BackgroundColor           =  kDefaultViewBackgroundColor //kTanBackgroundColor//  kLtTanBackgroundColor3
let kTuneExer_ButtonBckgrndColor        =  kDefault_ButtonBckgrndColor
let kTuneExer_ButtonTextColor           =  kDefault_ButtonTextColor

////////////////////////////////////////////////////////////
// LongToneView
let kLongtone_BackgroundColor           =  kDefaultViewBackgroundColor // kLtTanBackgroundColor3
let kLongtone_DoSetVisPanelColor        =  true
let kLongtone_VisPanelBkgrndColor       =  kLightSkyBlue
let kLongtone_ButtonBckgrndColor        =  kDefault_ButtonBckgrndColor
let kLongtone_ButtonTextColor           =  kDefault_ButtonTextColor



/*
 
 /////////////////////////////////////////////////////////////
 // App-wide defaults
 
 let kButtonTextColor                    = UIColor.black
 let kButtonColor                        = UIColor.black
 
 let kButtonTextOnClearBckgrndColor      = UIColor.black
 
 let kDefaultViewBackgroundColor         = kTanBackgroundColor // UIColor.white // kTanBackgroundColor
 
 let kDefault_BackButtonTextColor        =  UIColor.blue
 
 let kDefault_ButtonBckgrndColor         =  (UIColor.black).withAlphaComponent(0.4)
 let kDefault_ButtonTextColor            =  UIColor.yellow
 
 let kDefault_AlertBackgroundColor       =  kLtTanBackgroundColor4
 
 
 
 ////////////////////////////////////////////////////////////
 // Section/Cell colors
 let kDefault_SectionBkgrndColor         =  kDarkGold
 let kDefault_CellBkgrndColor            =  kLightGold
 let kDefault_SelectCellBkgrndColor      =  kGold
 
 ////////////////////////////////////////////////////////////
 // Day Overview
 let kDayOverVw_BackgroundColor          =  kDefaultViewBackgroundColor
 let kDayOverVw_DoSetCellBkgrndColor     =  true
 let kDayOverVw_CellBkgrndColor          =  kDefaultViewBackgroundColor //kDefault_CellBkgrndColor
 
 ////////////////////////////////////////////////////////////
 // TuneExerciseView
 let kTuneExer_BackgroundColor           =  kDefaultViewBackgroundColor //kTanBackgroundColor//  kLtTanBackgroundColor3
 let kTuneExer_ButtonBckgrndColor        =  kDefault_ButtonBckgrndColor
 let kTuneExer_ButtonTextColor           =  kDefault_ButtonTextColor
 
 ////////////////////////////////////////////////////////////
 // LongToneView
 let kLongtone_BackgroundColor           =  kDefaultViewBackgroundColor // kLtTanBackgroundColor3
 let kLongtone_DoSetVisPanelColor        =  true
 let kLongtone_VisPanelBkgrndColor       =  kLtTanBackgroundColor1
 let kLongtone_ButtonBckgrndColor        =  kDefault_ButtonBckgrndColor
 let kLongtone_ButtonTextColor           =  kDefault_ButtonTextColor
 
*/
