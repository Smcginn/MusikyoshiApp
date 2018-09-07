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

let kTanBackgroundColor                 = kTan0
let kLtTanBackgroundColor1              = UIColor(hexString: "#FFCC77ff")
let kLtTanBackgroundColor2              = UIColor(hexString: "#FFE6A7ff")
let kLtTanBackgroundColor3              = UIColor(hexString: "#FFDDAAff")

/////////////////////////////////////////////////////////////
// App-wide defaults

let kButtonTextColor                    = UIColor.black
let kButtonColor                        = UIColor.black

let kButtonTextOnClearBckgrndColor      = UIColor.black

let kDefaultViewBackgroundColor         = kTanBackgroundColor // UIColor.white // kTanBackgroundColor

let kDefault_BackButtonTextColor        =  UIColor.blue

let kDefault_ButtonBckgrndColor         =  (UIColor.black).withAlphaComponent(0.4)
let kDefault_ButtonTextColor            =  UIColor.yellow

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

