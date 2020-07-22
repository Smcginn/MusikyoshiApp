//
//  FreeTrialPeriodMisc.swift
//  FirstStage
//
//  Created by Scott Freshour on 3/19/20.
//  Copyright © 2020 Musikyoshi. All rights reserved.
//

import Foundation

// Set when the trial period has expired. Several places in the code
// refer to this.
var gTrialPeriodExpired = false


// Temp for testing
var gTestExpirationCount = 0


// These vars control if the app is all-level-access enabled
func setTrialExpiredVars() {
    gTrialPeriodExpired = true
    gDoOverrideSubsPresent = false
}

func setTrialNotExpiredVars() {
    gTrialPeriodExpired = false
    gDoOverrideSubsPresent = true
}

func daysUntilFreePeriodEndDate() -> Int {
//    if gTestExpirationCount > 3 {
//        return 19
//    }
    
    guard let endDate = getFreePeriodEndDate() else {
        itsBad()
        return 0
    }
    let today = Date()
    
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = .current
    dateFormatter.dateFormat = "dd/MM/yyyy"
    
    print( dateFormatter.string(from: endDate))
    print(dateFormatter.string(from: today))
    
    let numDays = endDate.days(from: today)
    return numDays
}

/*
func localDate() -> Date {
    let nowUTC = Date()
    let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
    guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}

    return localDate
}
*/

// Need to add 2 to day so math works out, hence the 17.   (1 day so won't return 0 when
// get to transition day, and 1 day to allow for extra hours due to locale differences).
let June_15_2020_text = "06/17/2020"
let July_07_2020_text = "07/09/2020"
let Aug_01_2020_text  = "08/01/2020"

let testDate_text     = "03/20/2020"

func getFreePeriodEndDate() -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    if let June15_2020 = dateFormatter.date(from: Aug_01_2020_text) {
        return June15_2020
    } else {
        return nil
    }
}

func getStoredDayCountToDisplay_6_15_2020_FreeTrialExpiryWarning() -> Int {
    let dayCount =
        UserDefaults.standard.integer(forKey: Constants.Settings.FreeTrial_6_15_2020_NumDaysLeft)
    return dayCount
}

func getDayCountForNextWarning() -> Int {
    let numDaysLeft = daysUntilFreePeriodEndDate()
    if numDaysLeft > 31 {
        return 31
    } else if numDaysLeft > 14 {
        return 14
    } else if numDaysLeft > 7 {
        return 7
    } else {
        return numDaysLeft - 1
    }
}

// Sets the user-data "NumDaysTillNextAlert" entry, and decides if to show
// alert and when next warning alert should pop up,
func displayFreeTrialExpiryWarningIfNeeded(parentVC: UIViewController) {
    var doDisplay = false
    
    let storedNextDayToDisplay =
        getStoredDayCountToDisplay_6_15_2020_FreeTrialExpiryWarning()
    if storedNextDayToDisplay < 0 { // never was set; first time
        doDisplay = true
    }
    
    let numDaysLeft = daysUntilFreePeriodEndDate()
    if numDaysLeft <= storedNextDayToDisplay || doDisplay {
        let nextWarningDay = getDayCountForNextWarning()
        UserDefaults.standard.set(nextWarningDay,
                                  forKey: Constants.Settings.FreeTrial_6_15_2020_NumDaysLeft)
        showEndDateAlert(parentVC: parentVC)
    }
}

////////////////////////////////////////////////////////////
// Alert-displaying funcs

func showEndDateAlert(parentVC: UIViewController) {   // JUNE15 JULY07 AUGUST1
    let numDaysLeft = daysUntilFreePeriodEndDate()
    let titleStr = "Extended! Use PlayTunes for Free until August 1, 2020!\n\n\(numDaysLeft) days remaining - Enjoy!"
    var msgStr = ""
    var okText = ""

    if numDaysLeft > 21 {
        msgStr += "\nYou do not have to sign up for anything, and your use of PlayTunes does not commit you in any way to a purchase.  Stay Safe!"
        okText = "Okay - Got it"
    } else { //  JULY07 AUGUST1 AUGUST1
        msgStr += "\nAfter August 1, 2020, if you wish to continue, you can purchase a subscription. (Subscriptions are explained on the Help screen, or go to Settings > Purchase Options.)\n\n(For the next \(numDaysLeft) days, you do not have to sign up for anything, and your use of PlayTunes does not commit you in any way to a purchase.)"
        okText = "Okay"
   }
    let ac = MyUIAlertController(title: titleStr,
                                 message: msgStr,
                                 preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: okText,
                               style: .default,
                               handler: nil))
    ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor
    
    parentVC.present(ac, animated: true, completion: nil)
}

func showEndDateExpiredAlert(parentVC: UIViewController) {   // JUNE15 JULY07
    let titleStr = "PlayTunes All-Level access\nis no longer free"
    var msgStr = "\nThe Spring 2020 Free trial period ended on August 1.\n\n"
    msgStr += "Many Levels/Days are still free for tryout. To get full-level access, "
    msgStr += "you will need to purchase a subscription. Go to Settings > Purchase Options to view our current offerings, or to the Help screen to see a general discussion of Subscriptions."
    msgStr += "\n\n(You should first make sure you have the latest version of PlayTunes.)"

    //msgStr += "(You may also visit Musikyoshi.com for more details.)"
    
    let ac = MyUIAlertController(title: titleStr,
                                 message: msgStr,
                                 preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK",
                               style: .default,
                               handler: nil))
    ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor
    
    parentVC.present(ac, animated: true, completion: nil)
}

func quickCheckUserHasValidSub() -> Bool {
    
    if PlayTunesIAPProducts.store.userDefsStoredSubscStatusIsKnown() &&
       PlayTunesIAPProducts.store.userDefsStoredSubscIsGoodToGo() {
        return true
    } else {
        return false
    }
}

/*
 //Ref date
 let dateFormatter = NSDateFormatter()
 dateFormatter.dateFormat = "MM/dd/yyyy"
 let someDate = dateFormatter.dateFromString("03/10/2015")
 
 //Get calendar
 let calendar = NSCalendar.currentCalendar()
 
 //Get just MM/dd/yyyy from current date
 let flags = NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear
 let components = calendar.components(flags, fromDate: NSDate())
 
 //Convert to NSDate
 let today = calendar.dateFromComponents(components)
 
 if someDate!.timeIntervalSinceDate(today!).isSignMinus {
 //someDate is berofe than today
 } else {
 //someDate is equal or after than today
 }
 */
