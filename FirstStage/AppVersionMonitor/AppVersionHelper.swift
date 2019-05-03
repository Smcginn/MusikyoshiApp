//
//  AppVersionHelper.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/4/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

struct MK_TimeIntervals {
    var kMK_1_second   = Int(0)
    var kMK_1_Minute   = Int(0)
    var kMK_2_Minutes  = Int(0)
    var kMK_3_Minutes  = Int(0)
    var kMK_5_Minutes  = Int(0)
    var kMK_10_Minutes = Int(0)
    var kMK_1_Hour     = Int(0)
    var kMK_1_Day      = Int(0)
    var kMK_1_Week     = Int(0)
    var kMK_2_Weeks    = Int(0)
    var kMK_3_Weeks    = Int(0)
    var kMK_1_Month    = Int(0)
    var kCheckForUpdateInterval = Int(0)
    init() {
        kMK_1_second   =  1
        kMK_1_Minute   = 60 * kMK_1_second
        kMK_2_Minutes  =  2 * kMK_1_Minute
        kMK_3_Minutes  =  3 * kMK_1_Minute
        kMK_5_Minutes  =  5 * kMK_1_Minute
        kMK_10_Minutes = 10 * kMK_1_Minute
        kMK_1_Hour     = 60 * kMK_1_Minute
        kMK_1_Day      = 24 * kMK_1_Hour
        kMK_1_Week     =  7 * kMK_1_Day
        kMK_2_Weeks    =  2 * kMK_1_Week
        kMK_3_Weeks    =  3 * kMK_1_Week
        kMK_1_Month    = 30 * kMK_1_Day
        kCheckForUpdateInterval = kMK_3_Weeks
    }
}

// MARK:- Methods supporting Last Time Checked For Updates

func setCheckForAppUpdateTimeIfFirstRun() {
    let lastChkAppUpdateKeyStr = Constants.Settings.LastCheckForAppUpdate
    let lastChkAppUpdateSince1970 = UserDefaults.standard.double(forKey: lastChkAppUpdateKeyStr)

    // Will be 0 if only has been set to default. If so, set it to "now" value.
    if lastChkAppUpdateSince1970 == 0 {
       setLastCheckForAppUpdateToNow()
    }
}

func setLastCheckForAppUpdateToNow() {
    let now = Date()
    let nowTimeIntSince1970 = now.timeIntervalSince1970
    
    UserDefaults.standard.set(
        Double(nowTimeIntSince1970),
        forKey: Constants.Settings.LastCheckForAppUpdate)
}

func shouldCheckForAppUpdate() -> Bool {
    let timeIntvls = MK_TimeIntervals()
    
    let lastChkAppUpdateKeyStr = Constants.Settings.LastCheckForAppUpdate
    let lastChkAppUpdateSince1970 = UserDefaults.standard.double(forKey: lastChkAppUpdateKeyStr)
    
    let now = Date()
    let nowTimeIntSince1970 = Double(now.timeIntervalSince1970)
    
    let elapsedSinceLastCheck = Int(nowTimeIntSince1970 - lastChkAppUpdateSince1970)
    if elapsedSinceLastCheck > timeIntvls.kCheckForUpdateInterval {
        return true
    } else {
        return false
    }
}

// MARK:- Methods to compare Current Version with App Store Version

func isUpdateAvailable() -> Bool {
    
    let appMarketingVers = AppVersion.marketingVersion
    useThisToSuppressWarnings(str: "\(appMarketingVers)")

    NetworkActivityIndicatorManager.networkOperationStarted()
    guard
        let info = Bundle.main.infoDictionary,
        let identifier = info["CFBundleIdentifier"] as? String,
        let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)"),
        let data = try? Data(contentsOf: url),
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
        let results = json?["results"] as? [[String: Any]],
        results.count > 0,
        let versionString = results[0]["version"] as? String
        else {
            NetworkActivityIndicatorManager.networkOperationFinished()
            return false
    }
    
    NetworkActivityIndicatorManager.networkOperationFinished()
    return AppVersion(versionString) > AppVersion.marketingVersion
}

// MARK:- Methods to compare Current Version with App Store Version

func checkForVersionUpgrade(_ act: UIAlertAction) {
    let newVersAvail = isUpdateAvailable()
    setLastCheckForAppUpdateToNow()

    var titleStr = ""
    var msgStr = ""
    if newVersAvail {
        titleStr = "There is a Newer Version of \nPlayTunes Available!"
        msgStr = "\n\nPlease go the AppStore for details about what's in the new release, and to get the latest version"
    } else {
        titleStr = "This is the latest version of PlayTunes"
        msgStr = "\n\nYou're good to go!\n\nWe will ask you \nagain in a few weeks."
    }
    
    let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    
    ac.show(animated: true, completion: nil)
}

func handleNoCheckForUpgrade(_ act: UIAlertAction) {
    setLastCheckForAppUpdateToNow()
    
    let titleStr = "Okay - Not checking for upgrades"
    let msgStr = "\n\nWe will ask you again in a few weeks."
    
    let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    
    ac.show(animated: true, completion: nil)
}

func presentWannaCheckForNewVersionAlert() {
    let titleStr = "Check For Newer Version of PlayTunes?"
    var msgStr = "\nWant to see if a Newer Version of PlayTunes is available?\n\n"
    msgStr += "A Newer Version may contain bug fixes or provide new Levels.\n\n"
    msgStr += "(Will only check; will not perform an upgrade.)\n\n"
    msgStr += "(Checking may take a few moments)"
    let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Yes",
                               style: .default,
                               handler: checkForVersionUpgrade))
    ac.addAction(UIAlertAction(title: "No Thanks",
                               style: .cancel,
                               handler: handleNoCheckForUpgrade))
    
    ac.show(animated: true, completion: nil)
}

func presentCheckForNewVersionAlert() {
    setLastCheckForAppUpdateToNow()
    
    let titleStr = "Remember to Check For Newer Versions of PlayTunes"
    var msgStr = "\nJust a reminder to check the App Store occasionally to see if a newer version of PlayTunes is available.\n\n"
    msgStr += "A Newer Version may provide new Levels or contain bug fixes.\n\n"
    let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK",
                               style: .default,
                               handler: nil))
    ac.show(animated: true, completion: nil)
}

