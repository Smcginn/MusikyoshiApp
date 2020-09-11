//
//  TryOutLevelsManager.swift
//  FirstStage
//
//  Created by Scott Freshour on 9/23/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//

import Foundation

struct levelEntry: Codable {
    var levelTitle: String
    var dayTitle: String
    
    init() {
        self.levelTitle = ""
        self.dayTitle   = ""
    }
}

extension levelEntry: Equatable {
    static func == (lhs: levelEntry, rhs: levelEntry) -> Bool {
        return lhs.levelTitle == rhs.levelTitle  &&
               lhs.dayTitle   == rhs.dayTitle
    }
}

struct tryoutEntries: Codable {
    var enabledEntries: [levelEntry]
}

class TryOutLevelsManager {
    
    static let sharedInstance = TryOutLevelsManager()

    init() {
        self.loadLevelSettingsData()
    }
    
    var tryoutJsonData: Data? = nil
    var tryoutLevelsAndDays: tryoutEntries? = nil
        
    func loadLevelSettingsData() {
        if let file = Bundle.main.path(forResource: "TryOutLevelsManager",
                                       ofType: "json") {
            tryoutJsonData = try? Data(contentsOf: URL(fileURLWithPath: file))
        }
        
        guard tryoutJsonData != nil else {
            print ("Could not load TryOutLevelsManager as jsonData")
            itsBad()
            return
        }
        
        let jsonDecoder = JSONDecoder()
        tryoutLevelsAndDays =
            try? jsonDecoder.decode(tryoutEntries.self,
                                    from: tryoutJsonData!)
        if tryoutLevelsAndDays != nil {
            print("Created tryoutLevelsAndDays from json file data")

        } else {
            itsBad()
            print("Error - Unable to create tryoutLevelsAndDays from json file data")
        }
    }
    
    func isLevelEnabled(levelTitle: String) -> Bool {
        // Implement:
        // if Valid Subscription {
        //    return true
        // }
        
        // JUNE15 - Disabling subscription status lookup; ALL LEVELS FREE
//        if !gTrialPeriodExpired {
//            return true
//        }
        
        // Are we in a debug mode that supports showing all Levels/Days?
        if gDoOverrideSubsPresent  ||
           gMKDebugOpt_ShowDebugSettingsBtn  {
            return true
        }
        
        // Attempt to access json entries for Tryout Levels and Days
        var isEnabled = false
        guard tryoutLevelsAndDays != nil else {
            return isEnabled
        }
        for oneLevel in tryoutLevelsAndDays!.enabledEntries{
            let oneLevelTitle = oneLevel.levelTitle
            if oneLevelTitle == levelTitle {
                isEnabled = true
                break
            }
        }
        
        return isEnabled
    }

    func isDayEnabled(levelTitle: String, dayTitle: String) -> Bool {
        // Implement:
        // if Valid Subscription {
        //    return true
        // }
        
        // Are we in a debug mode that supports showing all Levels/Days?
        if gDoOverrideSubsPresent  ||
            gMKDebugOpt_ShowDebugSettingsBtn  {
            return true
        }
        
        // Attempt to access json entries for Tryout Levels and Days
        var isEnabled = false
        guard tryoutLevelsAndDays != nil else {
            return isEnabled
        }
        
        for oneLevel in tryoutLevelsAndDays!.enabledEntries{
            //            for oneLevel in enabledLevels.all! {
            let oneLevelTitle = oneLevel.levelTitle
            if oneLevelTitle == levelTitle { // Level is enabled, check day
                let oneDayTitle = oneLevel.dayTitle
                if oneDayTitle == dayTitle || oneDayTitle == "All"{
                    isEnabled = true
                    break
                }
            }
        }

        return isEnabled
    }
}
