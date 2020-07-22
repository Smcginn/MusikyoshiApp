//
//  CKContextManager.swift
//  FirstStage
//
//  Created by Scott Freshour on 6/19/20.
//  Copyright © 2020 Musikyoshi. All rights reserved.
//


import Foundation
import ClassKit

// just for debugging; used in methods below to
// confirm contextPaths and context are valid
var gDoingAClassKitInvocation = false

var gHavePublishedCKContexts = false


// These are for classkit context IDs, and for displaying in SchoolWork
let kCK_LongTones_levelID       = "LongTones_Level"
let kCK_LipSlurs_levelID        = "LipSlurs_Level"
let kCK_Breaks_levelID          = "Breaks_Level"

// These are to identify the level numbers as they are actually loaded
// by the LevelsVC (e.g., as row indices in the Levels Table view).
let kCK_LongTones_levelIndex    = 30
let kCK_LipSlurs_levelIndex     = 31
let kCK_Breaks_levelIndex       = 31

// These are for the ClassKit order when displaying in SchoolWork
let kCK_LongTones_contextLevelIndex    = 30
let kCK_LipSlurs_contextLevelIndex     = 31
let kCK_Breaks_contextLevelIndex       = 32

// These are for classkit context IDs, and for displaying in SchoolWork
let kCK_LongTones_Day1ID        =  "6 Seconds"
let kCK_LongTones_Day2ID        = "10 Seconds"
let kCK_LongTones_Day3ID        = "20 Seconds"
let kCK_LongTones_Day4ID        = "30 Seconds"

//===========================================================
// There are three Lip Slur Days:
//   "Lip Slurs 1",  - 2 and 3 with same spelling, etc., just 2 and 3
//      Lip Slurs 1 contains Lip Slur 1 -  9
//      Lip Slurs 2 contains Lip Slur 10 - 18
//      Lip Slurs 3 contains Lip Slur 19 - 27
//
// These are for classkit context IDs, and for displaying in SchoolWork:
let kCK_LipSlurs1_ID            = "Lip Slurs 1"
let kCK_LipSlurs2_ID            = "Lip Slurs 2"
let kCK_LipSlurs3_ID            = "Lip Slurs 3"

//===========================================================
// There are three Break Days:
//   "Break Exercises 1",  - 2 and 3 with same spelling, etc., just 2 and 3
//      Day 1 contains Cross Break  1 -  9
//      Day 2 contains Cross Break 10 - 18
//      Day 3 contains Cross Break 19 - 27
//
// These are for classkit context IDs, and for displaying in SchoolWork:
let kCK_CrossBreaks1_ID            = "Cross Breaks 1"
let kCK_CrossBreaks2_ID            = "Cross Breaks 2"
let kCK_CrossBreaks3_ID            = "Cross Breaks 3"

func getCKNameForLevel(level: Int) -> String {
    return "Level \(level+1)"
}

func getCKNameForDay(day: Int) -> String {
    
    return "Day \(day+1)"
}

func getPrettyNameForLevelDay(level: Int, day: Int) -> String {
    
    let levelName = getCKNameForLevel(level: level)
    let dayName   = getCKNameForDay(day: day)

    let levDayName = levelName + ", " + dayName
    
    return levDayName
}

func getLevelNumFromCKTitle(ckTitle: String) -> Int32 {
    if ckTitle == kCK_LongTones_levelID {
        return Int32(kCK_LongTones_levelIndex)
    }
    
    if ckTitle == kCK_LipSlurs_levelID {
        return Int32(kCK_LipSlurs_levelIndex)
    }
    
    if ckTitle == kCK_Breaks_levelID {
        return Int32(kCK_Breaks_levelIndex)
    }
    
    // otherwise . . .

    guard ckTitle.count > 4 else {
        return 0 }
    
    // "Level "  - 6 chars
    let levelIdxStr = ckTitle.substring(fromIndex: 6)
    if let levelInt =  Int32(levelIdxStr) {
        return levelInt - 1
    }
    
    return 0
}
	
func addScoreItem(context: CLSContext?,
                  identifier: String,
                  title: String,
                  primary: Bool,
                  score: Double,
                  maxScore: Double) -> CLSScoreItem? {
    guard context != nil else { itsBad(); return nil }
    guard let activity = context?.currentActivity,
          activity.isStarted    else { itsBad(); return nil }

    // Create the score item and add it.
    let item = CLSScoreItem(identifier: identifier,   title: title,
                            score: score,   maxScore: maxScore)

    if primary {
        activity.primaryActivityItem = item
    } else {
        activity.addAdditionalActivityItem(item)
    }
    return item
}

func update(context: CLSContext?,progress: Double) {
    guard context != nil else { itsBad(); return }

    guard let activity = context?.currentActivity,
          progress > activity.progress,
          activity.isStarted   else { return }
        
    activity.addProgressRange(fromStart: 0, toEnd: progress)
}

func updateProgress(context: CLSContext?, progress: Double) {
    guard context != nil else { itsBad(); return }
    guard let activity = context?.currentActivity,
          progress > activity.progress,
          activity.isStarted else { return }
        
    activity.addProgressRange(fromStart: 0, toEnd: progress)
}




func addQuantityItem(context: CLSContext?,
                     identifier: String,
                     title: String,
                     primary: Bool,
                     value: Double) -> CLSQuantityItem? {
    guard context != nil else { itsBad(); return nil }
    guard let activity = context?.currentActivity,
          activity.isStarted    else { itsBad(); return nil }

    // Create the score item and add it.
    let item = CLSQuantityItem(identifier: identifier, title: title)

    if primary {
        activity.primaryActivityItem = item
    } else {
        activity.addAdditionalActivityItem(item)
    }
    item.quantity = value
    
    return item
}

func getActivityItems(exerContext: CLSContext?) -> [CLSActivityItem] {
    var activity: CLSActivity? = nil
    
    if let activ = exerContext?.currentActivity {
        activity = activ
    } else {
        activity = exerContext?.createNewActivity()
    }

    if activity != nil {
        let otherItems = activity!.additionalActivityItems
        return otherItems
    } else {
        return [CLSActivityItem]()
    }
}

func addBinaryItem(context: CLSContext?,
                   identifier: String,
                   title: String,
                   primary: Bool,
                   type: CLSBinaryValueType,
                   value: Bool) {
    guard context != nil else { itsBad(); return }
    guard let activity = context?.currentActivity,
          activity.isStarted    else { itsBad(); return }

    // Create the score item and add it.
    let item = CLSBinaryItem(identifier: identifier, title: title, type: type)

    if primary {
        activity.primaryActivityItem = item
    } else {
        activity.addAdditionalActivityItem(item)
    }
    
    item.value = value
}

func markAsDone(identifierPath: [String]) {
    if #available(iOS 12.2, *) {
//        os_log("%s Done", identifierPath.description)
        print("Calling completeAllAssignedActivities")
        CLSDataStore.shared.completeAllAssignedActivities(matching: identifierPath)
    } else {
        print("Unable to call completeAllAssignedActivities")
    }
}

func canIssueMarkAsDone() -> Bool {
    if #available(iOS 12.2, *) {
        return true
    } else {
        return false
    }
}

func getDayNumFromCKTitle(ckTitle: String) -> Int32 {
    
    switch (ckTitle) {
        case kCK_LipSlurs1_ID: return 0
        case kCK_LipSlurs2_ID: return 1
        case kCK_LipSlurs3_ID: return 2
        case kCK_CrossBreaks1_ID: return 0
        case kCK_CrossBreaks2_ID: return 1
        case kCK_CrossBreaks3_ID: return 2
        case kCK_LongTones_Day1ID: return 0
        case kCK_LongTones_Day2ID: return 1
        case kCK_LongTones_Day3ID: return 2
        case kCK_LongTones_Day4ID: return 3

        default: break
    }
    
    // otherwise . . .  Day from Level 1-30

    guard ckTitle.count > 4 else {
        return 0 }

    // "Day "  - 4 chars
    let dayIdxStr = ckTitle.substring(fromIndex: 4)
    if let dayInt =  Int32(dayIdxStr) {
        return dayInt - 1
    }
    
    return 0
}

func debug_checkForNonNil(context: CLSContext?) {
    if gDoingAClassKitInvocation {
        if context == nil {
            itsBad()
        }
    }
}

func debug_checkForNonEmpty(contextPath: [String]) {
    if gDoingAClassKitInvocation {
        if contextPath.count == 0 {
            itsBad()
        }
    }
}

func getAppHasBeenInvokedBySchoolWork() -> Bool {
    let hasBeen =
        UserDefaults.standard.bool(forKey: Constants.Settings.AppHasBeenInvokedBySchoolWork)
    return hasBeen
}

func displayMustInvokedFromSchoolWorkAlert(fromVC: UIViewController) {
    let title = "There was an issue\nlinking to your\nSchoolWork Assignment\n"
    var msg   = "\nYou must begin this Day assignment \nfrom SchoolWork.\n\n"
    msg += "If you did, then we've lost the connection to SchoolWork, and you'll have to reestablish it. (You haven't lost any work.)\n\n"
    msg += "Otherwise your score may not be recorded in SchoolWork.\n\n"
    msg += "Please go to the SchoolWork App, select the Day within the assignment, and press Start or Continue.\n\n"
    msg += "PlayTunes will appear again. (You do not have to quit PlayTunes.)\n\n"
    showOKAlert(title: title, message: msg, presentingVC: fromVC)
}

func displayMustInvokedADayAlert(fromVC: UIViewController) {
    let title = "Select a Day in SchoolWork, not a Level\n"
    var msg   = "\nIt appears your teacher has assigned an entire Level in SchoolWork, and you have selected it to work on.\n\n"
    msg += "For PlayTunes to work properly, you must select an individual Day within the Level, not the entire Level.\n\n"
    msg += "Please go to the SchoolWork App, select a Day within the Level assigned, and press Start or Continue.\n\n"
    msg += "PlayTunes will appear again. (You do not have to quit PlayTunes.)"
    showOKAlert(title: title, message: msg, presentingVC: fromVC)
}

func ctxIsAppropriateForCurrInstr(contextPath: [String]) -> Bool {
    guard contextPath.count == 3 else {
        itsBad(); return false }

    let levelID = contextPath[1]

    if levelID == kCK_LipSlurs_levelID {
        if !currInstrumentIsBrass() {
            return false
        }
    }

    if levelID == kCK_Breaks_levelID {
        if !currInstIsAClarinet() {
            return false
        }
    }

    return true
}
  
  
  

class CKContextManager {
    
    static let instance = CKContextManager()

    
    func publishContextsIfNeeded(completion: ((Error?) -> Void)? = nil) {
        
        guard !gHavePublishedCKContexts else {
            return }
        
        var levelContextsToCreate: [String : CLSContext] = [:]
        
        var curLev = 0
        for lev in 0..<30 {
            let levelID = getCKNameForLevel(level: lev)
            let levelCtx = CLSContext(type: .level, identifier:levelID, title: levelID)
            levelCtx.displayOrder = lev
                
            levelContextsToCreate[levelCtx.identifier] = levelCtx
            curLev = lev
        }
        
        // Add LongTones Level
        let ltLevelCtx = CLSContext(type: .level,
                                  identifier:kCK_LongTones_levelID,
                                  title: "LongTones Level")
        ltLevelCtx.displayOrder = kCK_LongTones_contextLevelIndex
        levelContextsToCreate[ltLevelCtx.identifier] = ltLevelCtx
        
        
        // Add LipSlurs Level
        let lsLevelCtx = CLSContext(type: .level,
                                    identifier:kCK_LipSlurs_levelID,
                                    title: "Lip Slurs Level - Brass Only")
        lsLevelCtx.displayOrder = kCK_LipSlurs_contextLevelIndex
        levelContextsToCreate[lsLevelCtx.identifier] = lsLevelCtx
        
        // Add Breaks Level
        let brksLevelCtx = CLSContext(type: .level,
                                    identifier:kCK_Breaks_levelID,
                                    title: "Breaks Level - Clarinets Only")
        brksLevelCtx.displayOrder = kCK_Breaks_contextLevelIndex
        levelContextsToCreate[brksLevelCtx.identifier] = brksLevelCtx
        
        // Loop through Levels and add the Day contexts to each Level context
        let parent = CLSDataStore.shared.mainAppContext
        let predicate = NSPredicate(format: "parent = %@", parent)
        CLSDataStore.shared.contexts(matching: predicate) { contexts, error in
            // see if any already there
            for context in contexts {
                levelContextsToCreate.removeValue(forKey: context.identifier)
            }
            
            print("In publishContextsIfNeeded() - about to create contexts")
            for (_, levContext) in levelContextsToCreate {
                print("In publishContextsIfNeeded(), processing \(levContext.identifier)")
                let levelStr = levContext.title
                parent.addChildContext(levContext)        // Add Level Context
                print(" About to ")
                if levContext.identifier == kCK_LongTones_levelID {
                    print("In publishContextsIfNeeded(), adding to  \(levContext.identifier)")
                    self.addLongToneDays(levContext: levContext)
                                        
                } else if levContext.identifier == kCK_LipSlurs_levelID {
                    print("In publishContextsIfNeeded(), adding to  \(levContext.identifier)")
                    self.addLipSlurDays(levContext: levContext)
                    
                } else if levContext.identifier == kCK_Breaks_levelID {
                    print("In publishContextsIfNeeded(), adding to  \(levContext.identifier)")
                    self.addCrossBreaksDays(levContext: levContext)
                    
                } else { // one of the first Level-1 thru Level-30 levels
                    for dayIdx in 0..<5 {                     // Add Day Contexts
//                        let levelStr = levContext.title
                        let dayID = getCKNameForDay(day: dayIdx)
                        let title = levelStr + ", " + dayID
                        let dayCtx = CLSContext(type: .lesson, identifier: dayID, title: title)
                        dayCtx.displayOrder = dayIdx
                        levContext.addChildContext(dayCtx)
                         print("In publishContextsIfNeeded(), created  \(levelStr), \(dayID)")
                    }
                }
                delay(0.01) {}
            }
            
            CLSDataStore.shared.save { (error) in
                completion?(error)
                
                if let error = error {
//                    print(error._userInfo?[1].value[0])  // ==
//                        .CLSErrorCodeClassKitUnavailable
                    print(error.localizedDescription)
                } else {
                    print("ClassKit initialized without errors!")
                }
            }
            sleep(1)
        }
        gHavePublishedCKContexts = true
    }

    func addLongToneDays(levContext: CLSContext?) {
        guard levContext != nil else {
            itsBad(); return  }
        
        let day1Ctx = CLSContext(type: .lesson,
                                 identifier: kCK_LongTones_Day1ID,
                                 title: kCK_LongTones_Day1ID)
         day1Ctx.displayOrder = 0
         levContext!.addChildContext(day1Ctx)
         print("   In addLongToneDays(), created  \(kCK_LongTones_Day1ID)")

         let day2Ctx = CLSContext(type: .lesson,
                                  identifier: kCK_LongTones_Day2ID,
                                  title: kCK_LongTones_Day2ID)
         day2Ctx.displayOrder = 1
         levContext!.addChildContext(day2Ctx)
         print("   In addLongToneDays(), created  \(kCK_LongTones_Day2ID)")

         let day3Ctx = CLSContext(type: .lesson,
                                  identifier: kCK_LongTones_Day3ID,
                                  title: kCK_LongTones_Day3ID)
         day3Ctx.displayOrder = 2
         levContext!.addChildContext(day3Ctx)
         print("   In addLongToneDays(), created  \(kCK_LongTones_Day3ID)")

         let day4Ctx = CLSContext(type: .lesson,
                                  identifier: kCK_LongTones_Day4ID,
                                  title: kCK_LongTones_Day4ID)
         day4Ctx.displayOrder = 3
         levContext!.addChildContext(day4Ctx)
         print("   In addLongToneDays(), created  \(kCK_LongTones_Day4ID)")
    }

    func addLipSlurDays(levContext: CLSContext?) {
        guard levContext != nil else {
            itsBad(); return  }
        
        let day1Ctx = CLSContext(type: .lesson,
                                identifier: kCK_LipSlurs1_ID,
                                title: kCK_LipSlurs1_ID)
        day1Ctx.displayOrder = 0
        levContext!.addChildContext(day1Ctx)
        print("   In addLipSlurDays(), created  \(kCK_LipSlurs1_ID)")

        let day2Ctx = CLSContext(type: .lesson,
                                 identifier: kCK_LipSlurs2_ID,
                                 title: kCK_LipSlurs2_ID)
        day2Ctx.displayOrder = 1
        levContext!.addChildContext(day2Ctx)
        print("   In addLipSlurDays(), created  \(kCK_LipSlurs2_ID)")

        let day3Ctx = CLSContext(type: .lesson,
                                 identifier: kCK_LipSlurs3_ID,
                                 title: kCK_LipSlurs3_ID)
        day3Ctx.displayOrder = 2
        levContext!.addChildContext(day3Ctx)
        print("   In addLipSlurDays(), created  \(kCK_LipSlurs3_ID)")
    }

    func addCrossBreaksDays(levContext: CLSContext?) {
        guard levContext != nil else {
            itsBad(); return  }
        
        let day1Ctx = CLSContext(type: .lesson,
                                identifier: kCK_CrossBreaks1_ID,
                                title: kCK_CrossBreaks1_ID)
        day1Ctx.displayOrder = 0
        levContext!.addChildContext(day1Ctx)
        print("   In addCrossBreaksDays(), created  \(kCK_CrossBreaks1_ID)")

        let day2Ctx = CLSContext(type: .lesson,
                                 identifier: kCK_CrossBreaks2_ID,
                                 title: kCK_CrossBreaks2_ID)
        day2Ctx.displayOrder = 1
        levContext!.addChildContext(day2Ctx)
        print("   In addCrossBreaksDays(), created  \(kCK_CrossBreaks2_ID)")

        let day3Ctx = CLSContext(type: .lesson,
                                 identifier: kCK_CrossBreaks3_ID,
                                 title: kCK_CrossBreaks3_ID)
        day3Ctx.displayOrder = 2
        levContext!.addChildContext(day3Ctx)
        print("   In addCrossBreaksDays(), created  \(kCK_CrossBreaks3_ID)")
    }
    
    /*
    // NEVER CALLED
    func createExerciseContext(dayPath: [String],
                               //dayTitle: String,
                               exerTitle: String,
                               dayContext: CLSContext?,
                               displayPos: Int) -> CLSContext? {
        guard //dayTitle.count > 0,
              dayContext != nil,
              dayPath.count > 0,
              exerTitle.count > 0 else {
                return nil
        }
        
        var exerCtx: CLSContext? = nil
        
        var title = ""
        for oneStr in dayPath {
            title += oneStr + ", "
        }
        
        title += exerTitle
        exerCtx = CLSContext(type: .exercise, identifier: exerTitle, title: title)
        if exerCtx != nil {
            exerCtx!.displayOrder = displayPos
            dayContext!.addChildContext(exerCtx!)
            
            CLSDataStore.shared.save { error in
                if let error = error {
                    print("Could not Save New Exer Context")
                    print(error.localizedDescription)
                    itsBad()
                } else {
                    print("Save Exer Context worked without Errors")
                }
            }
        }
        return exerCtx
    }
    */
    
  }
