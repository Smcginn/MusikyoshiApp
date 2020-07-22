//
//  DayCKActivityManager.swift
//  FirstStage
//
//  Created by Scott Freshour on 6/29/20.
//  Copyright © 2020 Musikyoshi. All rights reserved.
//
/*
    This class creates and updates the ClassKit Activity for the Day, as well
    as all of the ClassKit Activity Items below it (Longtones percent done,
    Longtones Avg Star Score, Tunes percent done, etc.).
 
    After each exercise is completed by the user, funcs in this file are called
    to scan the data for the exers in the current day, and ClassKit activity
    items are updated.
 */

import Foundation
import ClassKit

class DayCKActivityManager {
    
    var levelDay_LDCode: tLD_code
    var dayContext: CLSContext?
    var dayContextPath: [String]
    var dayScoreSummarizer: DayScoreSummarizer?
    
    init(levelDay_LDCode: tLD_code,
         dayContext: CLSContext?,
         dayContextPath: [String])
    {
        self.levelDay_LDCode    = levelDay_LDCode
        self.dayContext         = dayContext
        self.dayContextPath     = dayContextPath
        self.dayScoreSummarizer = DayScoreSummarizer(levelDay: levelDay_LDCode)
        self.dayScoreSummarizer?.recalcAndGetAllSummaries(summaryValues: &self.tempExerSumVals)
        self.createActivityAndItems()
        
    }
    deinit {
        saveCLSDataStore(insertText: "Updating Items from ScoreFile")
        dayActivity?.stop()
        dayContext?.resignActive()
    }
    
    // tempExerSumVals is used to just get the number of exers in each category.
    // We need to "throw away" these values the first time a comparison is done,
    // so that SchoolWork gets updated with previous asttempts. Otherwise, student's
    // previous work is not registered.
    var tempExerSumVals = categorySummaryValues()
    var prevExerSumVals = categorySummaryValues()

    var dayActivity: CLSActivity? = nil

    var allAvgStarScoreCKItem:        CLSQuantityItem?  = nil   // Primary ActivityItem
    var allPercentDoneCKItem:         CLSScoreItem?     = nil   // or CLSScoreItem ??
    var lowBPMCKItem:                 CLSQuantityItem?  = nil
    var highBPMCKItem:                CLSQuantityItem?  = nil

    var longtoneAvgStarScoreCKItem:   CLSQuantityItem?  = nil
    var longtonePercentDoneCKItem:    CLSScoreItem?     = nil
// KEEP:  May reinstate this
//    var longtoneAvgPercTargetCKItem:  CLSQuantityItem?  = nil

    var tuneAvgStarScoreCKItem:       CLSQuantityItem?  = nil
    var tunePercentDoneCKItem:        CLSScoreItem?     = nil

    var rythPrepAvgStarScoreCKItem:   CLSQuantityItem?  = nil
    var rythPrepPercentDoneCKItem:    CLSScoreItem?     = nil

    var rythPartyAvgStarScoreCKItem:  CLSQuantityItem?  = nil
    var rythPartyPercentDoneCKItem:   CLSScoreItem?     = nil

    var scaleAvgStarScoreCKItem:      CLSQuantityItem?  = nil

    var scalePercentDoneCKItem:       CLSScoreItem?     = nil

    var miscAvgStarScoreCKItem:       CLSQuantityItem?  = nil
    var miscPercentDoneCKItem:        CLSScoreItem?     = nil

    func updateLongToneActivtyItemsIfNeeded(latestExerVals: categorySummaryValues, doUpdate: Bool) {
        if doUpdate || latestExerVals.ltAvgStarScore != prevExerSumVals.ltAvgStarScore {
             updateQuantityItem(item: longtoneAvgStarScoreCKItem,
                                newQuantity: latestExerVals.ltAvgStarScore)
            let titleText = getAvgStarScoreText(avgScore: latestExerVals.ltAvgStarScore,
                                                numExersInCat: latestExerVals.ltNumExers,
                                                categoryText: "LONGTONES")
            resetActItemTitle(actItem: longtoneAvgStarScoreCKItem, title: titleText)
        }
        if doUpdate || latestExerVals.ltPercentDone != prevExerSumVals.ltPercentDone {
            let numDone = latestExerVals.ltPercentDone * Double(latestExerVals.ltNumExers)
            updateScoreItem(item: longtonePercentDoneCKItem,
                            newScore: Double(numDone),
                            maxScore: Double(latestExerVals.ltNumExers))
            let titleText = getPercentDoneText(numExersInCat: latestExerVals.ltNumExers,
                                               categoryText: "LONGTONES")
            resetActItemTitle(actItem: longtonePercentDoneCKItem, title: titleText)
        }
        // KEEP:  May reinstate this
//        if doUpdate || latestExerVals.ltAvgTargetTimePercentage != prevExerSumVals.ltAvgTargetTimePercentage {
//             updateQuantityItem(item: longtoneAvgPercTargetCKItem,
//                                newQuantity: latestExerVals.ltAvgTargetTimePercentage)
//        }
    }
    
    func updateTuneActivtyItemsIfNeeded(latestExerVals: categorySummaryValues, doUpdate: Bool) {
        if doUpdate || latestExerVals.tuneAvgStarScore != prevExerSumVals.tuneAvgStarScore {
            updateQuantityItem(item: tuneAvgStarScoreCKItem,
                               newQuantity: latestExerVals.tuneAvgStarScore)
            let titleText = getAvgStarScoreText(avgScore: latestExerVals.tuneAvgStarScore,
                                                numExersInCat: latestExerVals.tuneNumExers,
                                                categoryText: "TUNES")
            resetActItemTitle(actItem: tuneAvgStarScoreCKItem, title: titleText)
        }
        if doUpdate || latestExerVals.tunePercentDone != prevExerSumVals.tunePercentDone {
            let numDone = latestExerVals.tunePercentDone * Double(latestExerVals.tuneNumExers)
            updateScoreItem(item: tunePercentDoneCKItem,
                            newScore: Double(numDone),
                            maxScore: Double(latestExerVals.tuneNumExers))
            
            let titleText = getPercentDoneText(numExersInCat: latestExerVals.tuneNumExers,
                                                categoryText: "TUNES")
             resetActItemTitle(actItem: tunePercentDoneCKItem, title: titleText)
        }
    }
    
    func updateRhythmPrepActivtyItemsIfNeeded(latestExerVals: categorySummaryValues, doUpdate: Bool) {
        if doUpdate || latestExerVals.rythPrepAvgStarScore != prevExerSumVals.rythPrepAvgStarScore {
             updateQuantityItem(item: rythPrepAvgStarScoreCKItem,
                                newQuantity: latestExerVals.rythPrepAvgStarScore)
            let titleText = getAvgStarScoreText(avgScore: latestExerVals.rythPrepAvgStarScore,
                                                numExersInCat: latestExerVals.rythPrepNumExers,
                                                categoryText: "RHYTHM PREP")
            resetActItemTitle(actItem: rythPrepAvgStarScoreCKItem, title: titleText)
        }
        if doUpdate || latestExerVals.rythPrepPercentDone != prevExerSumVals.rythPrepPercentDone {
            let numDone = latestExerVals.rythPrepPercentDone * Double(latestExerVals.rythPrepNumExers)
            updateScoreItem(item: rythPrepPercentDoneCKItem,
                            newScore: Double(numDone),
                            maxScore: Double(latestExerVals.rythPrepNumExers))
            
            let titleText = getPercentDoneText(numExersInCat: latestExerVals.rythPrepNumExers,
                                               categoryText: "RHYTHM PREP")
            resetActItemTitle(actItem: rythPrepPercentDoneCKItem, title: titleText)
        }
    }

    func updateRhythmPartyActivtyItemsIfNeeded(latestExerVals: categorySummaryValues, doUpdate: Bool) {
        if doUpdate || latestExerVals.rythPartyAvgStarScore != prevExerSumVals.rythPartyAvgStarScore {
             updateQuantityItem(item: rythPartyAvgStarScoreCKItem,
                                newQuantity: latestExerVals.rythPartyAvgStarScore)
            let titleText = getAvgStarScoreText(avgScore: latestExerVals.rythPartyAvgStarScore,
                                                numExersInCat: latestExerVals.rythPartyNumExers,
                                                categoryText: "RHYTHM PARTY")
            resetActItemTitle(actItem: rythPartyAvgStarScoreCKItem, title: titleText)
        }
        if doUpdate || latestExerVals.rythPartyPercentDone != prevExerSumVals.rythPartyPercentDone {
            let numDone = latestExerVals.rythPartyPercentDone * Double(latestExerVals.rythPartyNumExers)
            updateScoreItem(item: rythPartyPercentDoneCKItem,
                            newScore: Double(numDone),
                            maxScore: Double(latestExerVals.rythPartyNumExers))
            
            let titleText = getPercentDoneText(numExersInCat: latestExerVals.rythPartyNumExers,
                                               categoryText: "RHYTHM PARTY")
            resetActItemTitle(actItem: rythPartyPercentDoneCKItem, title: titleText)
        }
    }

    func updateScaleActivtyItemsIfNeeded(latestExerVals: categorySummaryValues, doUpdate: Bool) {
        if doUpdate || latestExerVals.scaleAvgStarScore != prevExerSumVals.scaleAvgStarScore {
             updateQuantityItem(item: scaleAvgStarScoreCKItem,
                                newQuantity: latestExerVals.scaleAvgStarScore)
            let titleText = getAvgStarScoreText(avgScore: latestExerVals.scaleAvgStarScore,
                                                numExersInCat: latestExerVals.scaleNumExers,
                                                categoryText: "SCALES")
            resetActItemTitle(actItem: scaleAvgStarScoreCKItem, title: titleText)
        }
        if doUpdate || latestExerVals.scalePercentDone != prevExerSumVals.scalePercentDone {
            let numDone = latestExerVals.scalePercentDone * Double(latestExerVals.scaleNumExers)
            updateScoreItem(item: scalePercentDoneCKItem,
                            newScore: Double(numDone),
                            maxScore: Double(latestExerVals.scaleNumExers))
            
            let titleText = getPercentDoneText(numExersInCat: latestExerVals.scaleNumExers,
                                               categoryText: "SCALES")
            resetActItemTitle(actItem: scalePercentDoneCKItem, title: titleText)
        }
    }

    func updateMiscActivtyItemsIfNeeded(latestExerVals: categorySummaryValues, doUpdate: Bool) {
        if doUpdate || latestExerVals.miscAvgStarScore != prevExerSumVals.miscAvgStarScore {
             updateQuantityItem(item: miscAvgStarScoreCKItem,
                                newQuantity: latestExerVals.miscAvgStarScore)
            let titleText = getAvgStarScoreText(avgScore: latestExerVals.miscAvgStarScore,
                                                numExersInCat: latestExerVals.miscNumExers,
                                                categoryText: "MISC EXERS")
            resetActItemTitle(actItem: miscAvgStarScoreCKItem, title: titleText)
        }
        if doUpdate || latestExerVals.miscPercentDone != prevExerSumVals.miscPercentDone {
            let numDone = latestExerVals.miscPercentDone * Double(latestExerVals.miscNumExers)
            updateScoreItem(item: miscPercentDoneCKItem,
                            newScore: Double(numDone),
                            maxScore: Double(latestExerVals.miscNumExers))
            
            let titleText = getPercentDoneText(numExersInCat: latestExerVals.miscNumExers,
                                               categoryText: "MISC EXERS")
            resetActItemTitle(actItem: miscPercentDoneCKItem, title: titleText)
        }
    }

    func updateClassKitActivtyItems() {
        guard dayScoreSummarizer != nil else {
            itsBad();  return }
        
        var doTheUpdate = true
        var latestExerVals = categorySummaryValues()
        dayScoreSummarizer!.recalcAndGetAllSummaries(summaryValues: &latestExerVals)
        
        /// / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / /
        //  Overall
        if doTheUpdate || latestExerVals.overallAvgStarScore != prevExerSumVals.overallAvgStarScore {
            updateQuantityItem(item: allAvgStarScoreCKItem,
                               newQuantity: latestExerVals.overallAvgStarScore)
            let titleText = getAvgStarScoreText(avgScore: latestExerVals.overallAvgStarScore,
                                                numExersInCat: latestExerVals.overallNumExers,
                                                categoryText: "Average Star Score, ALL EXERS ")
            resetActItemTitle(actItem: allAvgStarScoreCKItem, title: titleText)
        }
        
        if doTheUpdate || latestExerVals.overallNumComplete != prevExerSumVals.overallNumComplete {
            let numExers = latestExerVals.overallNumExers
            let numDone  = latestExerVals.overallNumComplete
            updateScoreItem(item: allPercentDoneCKItem,
                            newScore: Double(numDone),
                            maxScore: Double(numExers))
            let titleText = getPercentDoneText(numExersInCat: latestExerVals.overallNumExers,
                                               categoryText: "ALL EXERS")
            resetActItemTitle(actItem: allPercentDoneCKItem, title: titleText)

            // Low BPM
            if latestExerVals.lowestBPM == kDefaultLowBPMValue {
                updateQuantityItem(item: lowBPMCKItem,
                                   newQuantity: Double(0))
                resetActItemTitle(actItem: lowBPMCKItem,
                                  title: "BPM Unknown - no Tempo-related exer done")
            } else {
                updateQuantityItem(item: lowBPMCKItem,
                                   newQuantity: Double(latestExerVals.lowestBPM))
                resetActItemTitle(actItem: lowBPMCKItem,
                                  title: "BPM - Lowest used - All Exercises")
            }
            
            // High BPM
            if latestExerVals.highestBPM < 5 {
                updateQuantityItem(item: highBPMCKItem,
                                   newQuantity: Double(0))
                resetActItemTitle(actItem: highBPMCKItem,
                                  title: "BPM Unknown - no Tempo-related exer done")
            } else {
                updateQuantityItem(item: highBPMCKItem,
                                   newQuantity: Double(latestExerVals.highestBPM))
                    resetActItemTitle(actItem: highBPMCKItem,
                                      title: "BPM - Highest used - All Exercises")
            }

            let percentExersDone = numExers > 0 ? Double(numDone)/Double(numExers) : 0.0
            
            if dayActivity != nil {
                dayActivity!.addProgressRange(fromStart: 0,
                                              toEnd: percentExersDone)
            }
        }
        
        // Now do the rest
        updateLongToneActivtyItemsIfNeeded(latestExerVals: latestExerVals, doUpdate: doTheUpdate)
        updateTuneActivtyItemsIfNeeded(latestExerVals: latestExerVals, doUpdate: doTheUpdate)
        updateRhythmPrepActivtyItemsIfNeeded(latestExerVals: latestExerVals, doUpdate: doTheUpdate)
        updateRhythmPartyActivtyItemsIfNeeded(latestExerVals: latestExerVals, doUpdate: doTheUpdate)
        updateScaleActivtyItemsIfNeeded(latestExerVals: latestExerVals, doUpdate: doTheUpdate)
        updateMiscActivtyItemsIfNeeded(latestExerVals: latestExerVals, doUpdate: doTheUpdate)
         
        // Finally, save everythinng
        saveCLSDataStore(insertText: "Updating Items from ScoreFile")
        
//        if latestExerVals.overallNumExers == latestExerVals.overallNumComplete &&
//            dayContext != nil &&
//            dayContextPath.count == 3 {
//            var noRootPath = [String]()
//            noRootPath.append(dayContextPath[1])
//            noRootPath.append(dayContextPath[2])
//            markAsDone(identifierPath: noRootPath)
//        }
        
        // NOTE: If Done, mark as Done
        prevExerSumVals = latestExerVals
    }
    

    func updateScoreItem(item: CLSScoreItem?, newScore: Double, maxScore: Double) {
        guard item != nil else {
            itsBad();   return
        }
        item!.score = newScore
        item!.maxScore = maxScore
    }
    
    func updateQuantityItem(item: CLSQuantityItem?, newQuantity: Double) {
        guard item != nil else {
            itsBad();   return
        }
        item!.quantity = newQuantity
    }
    
    func saveCLSDataStore(insertText: String) {
        CLSDataStore.shared.save { error in
            if let error = error {
                print("Could not Save \(insertText)")
                print(error.localizedDescription)
                itsBad()
            } else {
                print("Save of \(insertText) worked without Errors")
            }
        }
    }
    
    func debug_checkActItemForNonNil(item: CLSActivityItem?) {
        if gDoingAClassKitInvocation {
            if item == nil {
                itsBad()
            }
        }
    }

    func reactivateIfNeeded() {
        if gDoingAClassKitInvocation {
            if !dayContext!.isActive {
                dayContext!.becomeActive()
                dayActivity?.start()
            }
        }
    }
    
    func createActivityAndItems() {
        guard dayContextPath.count > 0,
              dayContext != nil    else {
            itsBad(); return }

        
        // Activate DayContext, then get or add Activity and start it
        dayContext!.becomeActive()
        
        if !dayContext!.isActive {
            itsBad() }
         

        
        if dayContext!.currentActivity != nil {
            dayActivity = dayContext!.currentActivity
        } else {
            dayActivity = dayContext!.createNewActivity()
        }
        guard dayActivity != nil    else {
            itsBad(); return }
        dayActivity?.start()
        
        // Save state so far
        saveCLSDataStore(insertText: "dayActivity")
        
        //// / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / /
        // Overall Stati
        
        allAvgStarScoreCKItem =
            addQuantityItem(context: dayContext,
                            identifier: "All_AvgStarScore",
                            title: "* - ALL - Avg Star Score (out of 4 Stars)",
                            primary: true,
                            value: Double(0.0))
        debug_checkActItemForNonNil(item: allAvgStarScoreCKItem)
        
        let numAllExers = tempExerSumVals.overallNumExers
        allPercentDoneCKItem =
            addScoreItem(context: dayContext,
                         identifier: "All_PercentDone",
                         title: "% - Percent Done -  ALL  (out of \(numAllExers) exers)",
                         primary: false,
                         score: Double(0.0),
                         maxScore: Double(numAllExers)) // 20.0)
        debug_checkActItemForNonNil(item: allPercentDoneCKItem)
       
        lowBPMCKItem =
                  addQuantityItem(context: dayContext,
                                  identifier: "All_LowBPM",
                                  title: "BPM - Lowest used - All Exercises",
                                  primary: false,
                                  value: Double(0.0))
        debug_checkActItemForNonNil(item: lowBPMCKItem)

        highBPMCKItem =
                  addQuantityItem(context: dayContext,
                                  identifier: "All_HighBPM",
                                  title: "BPM - Highest used - All Exercises",
                                  primary: false,
                               value: Double(0.0))
        debug_checkActItemForNonNil(item: highBPMCKItem)

        //// / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / /
        // LONGTONE
        
        longtoneAvgStarScoreCKItem =
                  addQuantityItem(context: dayContext,
                                  identifier: "LT_AvgStarScore",
                                  title: "* - LONGTONES - Avg Star Score (out of 4)",
                                  primary: false,
                                  value: Double(0.0))
        debug_checkActItemForNonNil(item: longtoneAvgStarScoreCKItem)
                
        let numLTExers = tempExerSumVals.ltNumExers
        longtonePercentDoneCKItem =
                    addScoreItem(context: dayContext,
                                 identifier: "LT_PercentDone",
                                 title: "% - LONGTONES - % Done (out of \(numLTExers) exers)",
                                 primary: false,
                                 score: Double(0.0),
                                 maxScore: Double(numAllExers)) // 20.0)

        debug_checkActItemForNonNil(item: longtonePercentDoneCKItem)
          
// KEEP:  May reinstate this
//        longtoneAvgPercTargetCKItem =
//                  addQuantityItem(context: dayContext,
//                                  identifier: "All_AvgTargetTime",
//                                  title: "LONGTONES - Avg % of Target Time",
//                                  primary: false,
//                                  value: Double(0.0))
//        debug_checkActItemForNonNil(item: longtoneAvgPercTargetCKItem)
          
        //// / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / /
          // TUNE
          
        tuneAvgStarScoreCKItem =
                addQuantityItem(context: dayContext,
                                identifier: "Tune_AvgStarScore",
                                title: "* - TUNES - Avg Star Score (out of 4)",
                                primary: false,
                                value: Double(0.0))
        debug_checkActItemForNonNil(item: tuneAvgStarScoreCKItem)
              
        
        let numTuneExers = tempExerSumVals.tuneNumExers
        tunePercentDoneCKItem =
                addScoreItem(context: dayContext,
                             identifier: "Tune_PercentDone",
                             title: "% - TUNES - % Done (out of \(numTuneExers) exers)",
                             primary: false,
                             score: Double(0.0),
                             maxScore: Double(numAllExers))
        debug_checkActItemForNonNil(item: tunePercentDoneCKItem)

        //// / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / /
        // RHYTHM PREP

        rythPrepAvgStarScoreCKItem =
                addQuantityItem(context: dayContext,
                                identifier: "RPrep_AvgStarScore",
                                title: "* - RHYTHM PREP - Avg Star Score",
                                primary: false,
                                value: Double(0.0))
        debug_checkActItemForNonNil(item: rythPrepAvgStarScoreCKItem)
              
        let numRPrepExers = tempExerSumVals.rythPrepNumExers
        rythPrepPercentDoneCKItem =
                    addScoreItem(context: dayContext,
                                 identifier: "RPrep_PercentDone",
                                 title: "% - RHYTHM PREP - % Done (out of \(numRPrepExers) exers)",
                                 primary: false,
                                 score: Double(0.0),
                                 maxScore: Double(numAllExers))
        
        debug_checkActItemForNonNil(item: rythPrepPercentDoneCKItem)

        //// / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / /
        // RHYTHM PARTY

        rythPartyAvgStarScoreCKItem =
                addQuantityItem(context: dayContext,
                                identifier: "RParty_AvgStarScore",
                                title: "* - RHYTHM PARTY - Avg Star Score",
                                primary: false,
                                value: Double(0.0))
        debug_checkActItemForNonNil(item: rythPartyAvgStarScoreCKItem)
              
        let numRrPartyExers = tempExerSumVals.rythPartyNumExers
        rythPartyPercentDoneCKItem =
                addScoreItem(context: dayContext,
                             identifier: "RParty_PercentDone",
                             title: "% - RHYTHM PARTY - % Done (out of \(numRrPartyExers) exers)",
                             primary: false,
                             score: Double(0.0),
                             maxScore: Double(numAllExers))
        
        debug_checkActItemForNonNil(item: rythPartyPercentDoneCKItem)

        //// / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / /
        // SCALE

        scaleAvgStarScoreCKItem =
                addQuantityItem(context: dayContext,
                                identifier: "Scale_AvgStarScore",
                                title: "* - SCALES - Avg Star Score",
                                primary: false,
                                value: Double(0.0))
        debug_checkActItemForNonNil(item: scaleAvgStarScoreCKItem)
              
        let numScaleExers = tempExerSumVals.scaleNumExers
        scalePercentDoneCKItem =
                addScoreItem(context: dayContext,
                             identifier: "Scale_PercentDone",
                             title: "% - SCALES - % Done (out of \(numScaleExers) exers)",
                             primary: false,
                             score: Double(0.0),
                             maxScore: Double(numAllExers))

        
        
        
        debug_checkActItemForNonNil(item: scalePercentDoneCKItem)

        //// / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / /
         // MISC

        miscAvgStarScoreCKItem =
             addQuantityItem(context: dayContext,
                             identifier: "Misc_AvgStarScore",
                             title: "* - MISC EXERS - Avg Star Score",
                             primary: false,
                             value: Double(0.0))
        debug_checkActItemForNonNil(item: miscAvgStarScoreCKItem)
               
        let numMiscExers = tempExerSumVals.miscNumExers
        miscPercentDoneCKItem =
                addScoreItem(context: dayContext,
                             identifier: "Misc_PercentDone",
                             title: "% - MISC EXERS - % Done (out of \(numMiscExers) exers)",
                             primary: false,
                             score: Double(0.0),
                             maxScore: Double(numAllExers))

        
        debug_checkActItemForNonNil(item: miscPercentDoneCKItem)


//        updateProgress(context: ckExerContext,
//                       progress: 1.0)
//
//
//        markAsDone(identifierPath: classKitExerPath)
//
//        ckExerActivity?.stop()
//        ckExerContext?.resignActive()
                        
        saveCLSDataStore(insertText: "Activity Items")
    }
    
    func resetActItemTitle(actItem: CLSActivityItem?, title: String) {
        actItem?.title = title
    }
    
    func getAvgStarScoreText(avgScore: Double,
                             numExersInCat: Int,
                             categoryText: String) -> String {
        // example use:      * - TUNES  -> Avg 3.6 out of 4 Stars
        var retStr = "* - "
        retStr += categoryText + " -> "

        if numExersInCat > 0 {
            let avgScoreStr = String(format: "%.1f",avgScore)
            
            retStr += "Avg \(avgScoreStr) out of 4 Stars"
        } else {
            // retStr += "(no exers of this type)"
            retStr += "(none in this Day)"
        }
        
        return retStr
    }
    
    func getPercentDoneText(numExersInCat: Int,
                            categoryText: String) -> String {
        // example use:      * - TUNES  -> % Done (out of 6 exers)
        var retStr = "% - "
        retStr += categoryText + " -> "

        if numExersInCat > 0 {
            let numExersStr = String(numExersInCat)
            
            retStr += "% Done (out of \(numExersStr))"
        } else {
//            retStr += "(no exers of this type)"
//            retStr += "(none of this type)"
            retStr += "(none in this Day)"
        }
        
        return retStr
    }
}
