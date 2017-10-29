//
//  DataService.swift
//  monkeytones
//
//  Created by Adam Kinney on 8/27/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    
    
    static let sharedInstance = DataService()
    
    fileprivate var _currentDifficultyId:Int!
    var currentDifficultyId:Int {
        get {
            return _currentDifficultyId
        }
        set (newVal) {
            _currentDifficultyId = newVal
            UserDefaults.standard.set(_currentDifficultyId, forKey: Constants.SettingsKeys.currentDifficultyId)
        }
    }
    
    fileprivate var _currentInstrumentId:InstrumentID!
    var currentInstrumentId:InstrumentID {
        get {
            return _currentInstrumentId
        }
        set (newVal) {
            _currentInstrumentId = newVal
            UserDefaults.standard.set(_currentInstrumentId.rawValue, forKey: Constants.SettingsKeys.currentInstrumentId)
        }
    }
    
    fileprivate var _currentNoteId:Int!
    var currentNoteId:Int {
        get {
            return _currentNoteId
        }
        set (newVal) {
            _currentNoteId = newVal
            UserDefaults.standard.set(_currentNoteId, forKey: Constants.SettingsKeys.currentNoteId)
        }
    }
    
    
    var exersicePoints:Int {
        get {
            return UserDefaults.standard.integer(forKey: Constants.SettingsKeys.exercisePoints)
            
        }
        set (newVal) {
            UserDefaults.standard.set(newVal, forKey: Constants.SettingsKeys.exercisePoints)
            GCHelper.sharedInstance.reportLeaderboardIdentifier(Constants.LeaderBoardIds.exercisePoints, score: newVal)
        }
    }
    
    var previousAppLaunchDay:Date {
        get {
            let date:Date = UserDefaults.standard.object(forKey: Constants.SettingsKeys.previousAppLaunchDay) as! Date? ?? Date()
            
            return date 
        }
        set (newVal) {
            UserDefaults.standard.set(newVal, forKey: Constants.SettingsKeys.previousAppLaunchDay)
        }
    }
    
    
    fileprivate init(){
        
        let today = Date()
        
        if !Calendar.current.isDate(today, inSameDayAs: previousAppLaunchDay)
        {
            exersicePoints += 10
        }
        
        previousAppLaunchDay = today
        
        setDefaultKeys()
    }
    
    fileprivate func setDefaultKeys(){
        _currentDifficultyId = UserDefaults.standard.integer(forKey: Constants.SettingsKeys.currentDifficultyId)
        _currentInstrumentId = InstrumentID(rawValue:UserDefaults.standard.integer(forKey: Constants.SettingsKeys.currentInstrumentId))
        _currentNoteId = UserDefaults.standard.integer(forKey: Constants.SettingsKeys.currentNoteId)
        
        if _currentNoteId == 0 {
            
            currentNoteId = InstrumentService.getInstrumentNotes(_currentInstrumentId).first!.orderId
        }
    }
    
    /*
    func getExerciseId() -> String {
        return getExerciseId(self.currentInstrumentId, noteId: self.currentNoteId, difficultyId: self.currentDifficultyId)
    }
    
    func getExerciseId(_ instrumentId: InstrumentID, noteId: Int, difficultyId: Int) -> String {
        return exercisePrefix + String(format: "%02d", instrumentId.rawValue) + String(format: "%02d", noteId) + String(format: "%02d", difficultyId)
    }
    
    func getExerciseCompletion(_ exId: String) -> Bool
    {
        return UserDefaults.standard.bool(forKey: exId)
    }
    */
    
    
    
    func exerciseDictionary() -> NSDictionary
    {
        return UserDefaults.standard.value(forKey: Constants.SettingsKeys.exerciseDict) as? NSDictionary ?? NSDictionary()
    }
    
    func exerciseValueFor(instrumentId:String, noteId:String, difficultyId:String) -> Float
    {
        
        let instrumentDict = exerciseDictionary().value(forKey: instrumentId) as? NSDictionary
        let noteDict = instrumentDict?.value(forKey: noteId) as? NSDictionary
        
        let valueNum = (noteDict?.value(forKey: difficultyId) as? NSNumber) ?? 0
        let value = valueNum.floatValue

        return value
    }
    
    func setExerciseCompletion(instrumentId:InstrumentID, noteId:String, difficultyId:Int, time:Float)
    {
        let instrumentIdStr = "\(instrumentId.rawValue)"
        var dict = NSMutableDictionary()
        let existingDict = UserDefaults.standard.value(forKey: "ExerciseDict")
        if existingDict != nil
        {
            dict = NSMutableDictionary(dictionary: existingDict as! NSDictionary)
        }
        
        var instrumentDict = NSMutableDictionary()
        let instrumentDictBuf = dict[instrumentIdStr] as? NSDictionary
        if instrumentDictBuf == nil
        {
            dict[instrumentIdStr] = instrumentDict
        }
        else
        {
            instrumentDict = NSMutableDictionary(dictionary: instrumentDictBuf!)
            dict[instrumentIdStr] = instrumentDict
        }
        
        var noteDict = NSMutableDictionary()
        let noteDictBuf = instrumentDict[noteId] as? NSDictionary
        if noteDictBuf == nil
        {
            instrumentDict[noteId] = noteDict
        }
        else
        {
            noteDict = NSMutableDictionary(dictionary: noteDictBuf!)
            instrumentDict[noteId] = noteDict
        }
        
        // Write actual value
        let difficultyIdStr = "\(difficultyId)"
        let prevValue = (noteDict[difficultyIdStr] as? NSNumber)?.floatValue
        
        if prevValue != nil && prevValue! >= time
        {
            return
        }
        
        noteDict[difficultyIdStr] = time
        UserDefaults.standard.set(dict, forKey: "ExerciseDict")
        UserDefaults.standard.synchronize()
        
        
        // Check if achievent needs to pop out
        
        
        let maxTasks = Constants.Exercises.exersicesCount
        let curTasks = numbersOfCompletedTask(for: instrumentId)
        
        if maxTasks == curTasks
        {
            let achId = Constants.Achievements.achievementsIDs[instrumentId]!        
            GCHelper.sharedInstance.reportAchievementIdentifier(achId, percent: 100, showsCompletionBanner: true)
        }

        // Save to remote database
        
        if let userId = UserDefaults.standard.string(forKey: Constants.SettingsKeys.userId)
        {
            let difName = DifficultyService.getDifficulty(difficultyId)?.name
            let date = Date()
            FirebaseService.shared.saveExerciseDate(userId: userId, difName: difName?.rawValue, date: date)
        }
    }
    
    func numbersOfCompletedTask(for instrumentId:InstrumentID) -> Int
    {
        
        //return 56
        
        let data = self.exerciseDictionary()
        
        let instrumentStr = String(instrumentId.rawValue)
        let instrument = InstrumentService.getInstrument(instrumentId)
        let instrumentDict = data[instrumentStr] as? NSDictionary
        
        var count = 0
        if instrumentDict != nil
        {
        
            for (_,valueNote) in instrumentDict!
            {
                for (key,valueDif) in (valueNote as! NSDictionary)
                {
                    let difId = (key as? NSNumber)?.intValue ?? 1
                    let starsTimes = DifficultyService.getTargetStarsTimes(difId, instrument: instrument!)
                    let actualVal = (valueDif as? NSNumber)?.floatValue ?? 0
                    
                    if actualVal >= starsTimes[0]
                    {
                        count += 1
                    }
                }
            }
            
        }
        
        return count
    }
    
    
    func resetAllKeys(){
        
        
        UserDefaults.standard.removeObject(forKey: Constants.SettingsKeys.exerciseDict)
        
        setDefaultKeys()
    }
}
