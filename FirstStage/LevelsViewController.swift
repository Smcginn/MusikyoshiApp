//
//  LevelsViewController.swift
//  PlayTunes-debug
//
//  Created by turtle on 7/1/19.
//  Modified by Scott Freshour
//
//      (Based on the original LessonSeriesViewController.swift
//       Created by Caitlyn Chen on 1/22/18.
//       Modified by Scott Freshour)
//
//  Copyright © 2019 Musikyoshi. All rights reserved.
//

import UIKit
import SwiftyJSON
import AudioKit

//var gDoOverrideSubsPresent = false     // CHECK_THIS_FOR_SUBMIT
//var gDoLimitLevels = true              // CHECK_THIS_FOR_SUBMIT
//let kNumberOfLevelsToShow: Int = 11
//
//// This is the artificial level number to display the tryout section at (it is not
//// the order in the json file). We show this if they don't have a subscription.
//let kSectionToDisplayTryoutAt: Int = 2
//
//// In the JSON file, this is the number of Tryout Level
//let kTryoutUpperValInJson: Int = 1000


// ********* REPLACEMENT FOR LevelSeriesViewController (old files saved though) ********* 

class LevelsViewController: UIViewController {

    var classKitPath = [String]()
    var CK_Level = Int32(-1)
    var CK_Day   = Int32(-1)

    @IBOutlet weak var levelsTableView: UITableView!
    @IBOutlet weak var daysTableView: UITableView!
    @IBOutlet weak var levelsTableViewFooter: UIView!
    
    @IBOutlet weak var daysBackgroundView: UIView!
    
    let particleEmitter = CAEmitterLayer()
    
    // is there a subscription?
    //   - this affects Tryout AND showing upper levels
    var subscriptionGood   = false

//    var showingTryoutLevel = true
    var isSlursLevel = false
    var selectedLevelIsEnabled = true
    var selectedLevelTitleStr = ""

    var loadedFromHomeScreen = true
    
    let kLipSlurLevel = 31
    var activeLevelIsLipSlur = false
    var activeLevel = 0 {
        didSet {
            activeLevelIsLipSlur = activeLevel == kLipSlurLevel ? true : false
            
            if oldValue != activeLevel {
                 let oldCell: LevelTableViewCell? = levelsTableView.cellForRow(at: IndexPath(row: oldValue, section: 0)) as? LevelTableViewCell
                oldCell?.isActive = false
                
                let newCell: LevelTableViewCell? = levelsTableView.cellForRow(at: IndexPath(row: activeLevel, section: 0)) as? LevelTableViewCell
                newCell?.isActive = true
                
                daysTableView.reloadData()
                
            }
        }
    }
    
    func numLevelsToShow() -> Int {
        var retNumToShow = 1
        
        var jsonCount = 0
        if let rawJsonCount = instrumentJson?["levels"].count {
            jsonCount = rawJsonCount
        }
        retNumToShow = jsonCount
        
        if gDoLimitLevels {
            retNumToShow = kNumberOfLevelsToShow
        }
        
        // Don't show tryout level
        retNumToShow -= 1
        
        if !currInstrumentIsBrass() && !currInstIsAClarinet() {
            // Don't show Lip Slurs or CrossBreaks level
            retNumToShow -= 1
        }
        
        if retNumToShow < 0 {
            retNumToShow = 0
        }
        
        if retNumToShow == 0 {
            itsBad()
        }
        
        return retNumToShow
    }
    
    func jsonIndexForRow(_ row: Int) -> Int {
        let retJsonIdx = row
        
//        if showingTryoutLevel {
//            if section == kSectionToDisplayTryoutAt {
//                if let rawJsonCount = instrumentJson?["levels"].count {
//                    retJsonIdx = rawJsonCount-1
//                }
//            }
//            if section > kSectionToDisplayTryoutAt {
//                retJsonIdx = section - 1
//            }
//        }
        
        return retJsonIdx
    }
    
//    var checkImage: UIImage? = nil
//    var nocheckImage: UIImage? = nil
//    var checkImageView: UIImageView? = nil
    
    var instrumentJson: JSON?
    var levelsJson: JSON?
    
    var thresholdsID         = kThershIDsStr_Begin_1
    var singleEventThreshold = kSingleEventThreshDefaultStr
    
    let kNoSectionSelected = -1
    var currLevel:Int = 0
    var currDay = 0
    
    var allowAllLevelAccess = false
    
    var timer = Timer()
    
    // User tried to scroll to higher level without purchasing
    var shouldDisplayAlertAfterScroll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // JUNE15
        // For the time being - until June 15, 2020,  no longer checking subs, etc.
        // So this is set to always allow all access.
        if gTrialPeriodExpired {
//            subscriptionGood = PlayTunesIAPProducts.store.subscriptionGood()  // IAPSUBS
//            if subscriptionGood ||
//               gDoOverrideSubsPresent ||
//               gMKDebugOpt_ShowDebugSettingsBtn  {
//                allowAllLevelAccess = true
//            } else {
//                allowAllLevelAccess = false
//            }
            allowAllLevelAccess = false
       } else {
            allowAllLevelAccess = true
        }
        
        // Restore for subs check:
//        subscriptionGood = PlayTunesIAPProducts.store.subscriptionGood()  // IAPSUBS
//        if subscriptionGood ||
//           gDoOverrideSubsPresent ||
//           gMKDebugOpt_ShowDebugSettingsBtn  {
//            allowAllLevelAccess = true
//        }
        
        if let file = Bundle.main.path(forResource: "TrumpetLessons", ofType: "json") {
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: file))
            if jsonData != nil {
                instrumentJson = try? JSON(data: jsonData!)
            } else {
                print ("unable to acquire jsonData or instrumentJson")
            }
            
            if instrumentJson != nil {
                levelsJson = instrumentJson?["levels"]
            } else {
                print ("unable to acquire levelsJson")
            }
        } else {
            print("Invalid TrumpetLessons filename/path.")
        }

        levelsTableView.delegate = self
        levelsTableView.dataSource = self
        levelsTableView.separatorStyle = .none
        levelsTableViewFooter.frame.size.height = view.frame.size.height
        levelsTableView.decelerationRate = UIScrollView.DecelerationRate.fast
        
        daysTableView.delegate = self
        daysTableView.dataSource = self
        // daysTableView.separatorStyle = .none
        
        daysBackgroundView.layer.cornerRadius = daysBackgroundView.frame.height * 0.1
        if #available(iOS 11.0, *) {
            daysBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // for testing:   JUNE15
//        gTestExpirationCount += 1
        
        // JUNE15
        var numDays = daysUntilFreePeriodEndDate()
        if numDays > 0 && !gTrialPeriodExpired {
            displayFreeTrialExpiryWarningIfNeeded(parentVC: self)
        } else if !gTrialPeriodExpired {
            setTrialExpiredVars()
            showEndDateExpiredAlert(parentVC: self)
        }
        
        assessPurchaseStatus()
        
        let currLDE = LessonScheduler.instance.getCurrentLDE()
        activeLevel = currLDE.level //  LessonScheduler.instance.getCurrLevel()
        setupNewlySelectedLevel()
        levelsTableView.reloadData()
        daysTableView.reloadData()
        
        testBPM()
        let yPosActiveRow = levelsTableView.rectForRow(at: IndexPath(row:activeLevel, section: 0)).origin.y
        print("In viewWillAppear, yPosActiveRow == \(yPosActiveRow)")
        
        scrollToActiveLevel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Ask for permission to use the microphone, if not already granted
        var permissionGranted = false
        if alwaysFalseToSuppressWarn() { print("\(permissionGranted)") }
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            permissionGranted = true
        case AVAudioSessionRecordPermission.denied:
            permissionGranted = false
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                if granted {
                    permissionGranted = true
                }
            }
        default:
            permissionGranted = false
            break
        }
        
        if shouldCheckForAppUpdate() {
            //presentWannaCheckForNewVersionAlert()
            presentCheckForNewVersionAlert()
        }
        
        //        timer = Timer.scheduledTimer(
        //            timeInterval: 1.5,
        //            target: self,
        //            selector: #selector(LevelSeriesViewController.changeTryputHeaderColor),
        //            userInfo: nil,
        //            repeats: true)
        
        
        // For some reason, the call to levelsTableView.rectForRow() within
        // scrollToActiveLevel() returns a garbage value if called here on the
        // initial load of this VC.
        // It works fine in the initial viewDidLoad().
        // But if coming back from Day view, it work fine. So:
        //  - Call scrollToActiveLevel() in viewDidLoad().
        //  - Don't call scrollToActiveLevel() here if initial load and it's
        //    been called in viewDidLoad().
        //  - Do call scrollToActiveLevel() here if coming back from Day screen.
        if !loadedFromHomeScreen // if coming back from Day view, do it
        {
            let yPosActiveRow = levelsTableView.rectForRow(at: IndexPath(row:activeLevel, section: 0)).origin.y
            print("In viewDidAppear, yPosActiveRow == \(yPosActiveRow)")
            scrollToActiveLevel(doAnimate: true)
        } else {
            print("(In viewDidAppear, skipping scrollToActiveLevel)")
        }
        
        
        if classKitPath.count == 0 {
            print("YooHoo")
        } else {
            if classKitPath.count == 3 {
                let level = classKitPath[1]
                switch level {
                    case kCK_Level1_ID:
                        CK_Level = 0;   break
                    case kCK_Level2_ID:
                        CK_Level = 1;   break
                    case kCK_Level12_ID:
                        CK_Level = 11;   break
                    case kCK_Level22_ID:
                        CK_Level = 21;   break
                    default:
                        CK_Level = 0;
                }
                
                let day   = classKitPath[2]
                switch day {
                    case kCK_Day1_ID:
                        CK_Day = 0;   break
                    case kCK_Day2_ID:
                        CK_Day = 1;   break
                    case kCK_Day3_ID:
                        CK_Day = 2;   break
                    case kCK_Day4_ID:
                        CK_Day = 3;   break
                    case kCK_Day5_ID:
                        CK_Day = 4;   break
                    default:
                        CK_Day = 0;   break
                }

                print("HooYoo")
                activeLevel = Int(CK_Level)
                scrollToActiveLevel()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        createParticles()
        
        let yPosActiveRow = levelsTableView.rectForRow(at: IndexPath(row:activeLevel, section: 0)).origin.y
        print("In viewDidLayoutSubviews, yPosActiveRow == \(yPosActiveRow)")
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //    @objc func changeTryputHeaderColor() {
    //        if tryoutBackgroundColor == kSeaFoamBlue {
    //            tryoutBackgroundColor = kLightSkyBlue
    //        } else {
    //            tryoutBackgroundColor = kSeaFoamBlue
    //        }
    //
    //        delay( 0.25) {
    //            let indexSet = IndexSet(integer:kTryoutUpperExercisesLevel)
    ////        self.tableView.beginUpdates()
    //            self.tableView.reloadSections(indexSet, with: .automatic)
    ////        self.tableView.endUpdates()
    //        }
    //    }
    
    
    //    IAPSUBS
    func assessPurchaseStatus() {

        if !gTrialPeriodExpired {
            // JUNE15
            // For the time being - until June 15, 2020,  no longer checking subs, etc.
            // So this is set to always allow all access.
            allowAllLevelAccess = true
            subscriptionGood = true
            return
        } else {
            allowAllLevelAccess = false
            subscriptionGood = false
        }
        
        if gDoOverrideSubsPresent || gMKDebugOpt_ShowDebugSettingsBtn {
            allowAllLevelAccess = true
            subscriptionGood = true
            return
        }
        
        subscriptionGood = PlayTunesIAPProducts.store.subscriptionGood()
        allowAllLevelAccess = subscriptionGood
        if !allowAllLevelAccess &&
            !PlayTunesIAPProducts.store.userDefsStoredSubscStatusIsKnown() {
            // see if just waiting for update
            while PlayTunesIAPProducts.store.confirmedAttempts < 10 {
                if PlayTunesIAPProducts.store.userDefsStoredSubscStatusIsKnown() {
                    //                print("\n\n        Receipt Data repsonse acquired!   \n\n")
                    // if PlayTunesIAPProducts.store.purchaseStatus.state == .purchaseGood {
                    //               if PlayTunesIAPProducts.store.purchaseStatus.subscriptionGood() {
                    if PlayTunesIAPProducts.store.subscriptionGood() {
                        subscriptionGood = true
                        allowAllLevelAccess = true
                    } else {
                        subscriptionGood = false
                        allowAllLevelAccess = false
                    }
                    break
                }
                PlayTunesIAPProducts.store.confirmedAttempts += 1
                print("\n\n        Waiting on Receipt Data repsonse . . . \n\n")
                delay(0.5) {}
            }
        }
        
        PlayTunesIAPProducts.store.confirmedAttempts = 0
        //    IAPSUBS
        //        if PlayTunesIAPProducts.store.purchaseStatus.confirmed {
        //            if PlayTunesIAPProducts.store.purchaseStatus.state == .purchaseGood {
        //                allowAllLevelAccess = true
        //            }
        //        } else {
        //            accessPurchaseStatusRetry()
        //        }
    }
    
    //    IAPSUBS
    //    func accessPurchaseStatusRetry() {
    //        if PlayTunesIAPProducts.store.purchaseStatus.confirmedAttempts < 10 {
    //            delay(0.5) {
    //                PlayTunesIAPProducts.store.purchaseStatus.confirmedAttempts += 1
    //                self.assessPurchaseStatus()
    //            }
    //        }
    //    }
    
    //    IAPSUBS
    func displayMustPurchaseAlert() {
        //    let titleStr = "For access to all levels, you must purchase a PlayTunes Subscription"
        //    var msgStr = "\nLevels 1 & 2 are always free!\n\n"
        //    msgStr += "To explore PlayTunes' upper Levels, go to 'Purchase Options' "
        //    msgStr += "on the Home screen\n\n"
        //    msgStr += "(If you have a valid Subscription from another device, use the Restore button)\n\n"
        //    msgStr += "(If you have just completed a purchase, verification can take a while. Try again in a bit.)"
        
        
        // let titleStr = "To access all Days, you must purchase (or Restore) a PlayTunes Subscription"
        // let titleStr = "Purchase (or Restore) a Playtunes Subscription to access all of PlayTunes"
/*
        let titleStr = "To access all of PlayTunes, Purchase (or Restore) a Subscription"
        //let titleStr = "For total access PlayTunes, you you must purchase (or Restore) a  Subscription"
        var msgStr = "\nLevels 1 & 2 are completely free, as are Day 1 of other Pink Levels!\n\n"
        msgStr += "Go to 'Purchase Options' on the Home screen.\n\n"
        //        msgStr += "(If you have a valid Subscription from another device, use the Restore button)\n\n"
        msgStr += "(If you have just completed a purchase or restore, verification can take a while. Try again in a bit.)"
*/
        
        
        
        // JUNE15 - Remove this:
//        let titleStr = "Try Out Days In Pink Levels For Free!"
//        var msgStr = "- All Days of Levels 1 & 2: Free!\n- Day 1 of other Pink Levels - Free!\n\n"
//        msgStr += "Now that the Spring 2020 Free Trial period is over, "
//        msgStr += "you must download the latest version of PlayTunes to view the current purchase options (including possible free trial extensions).\n\n"
//        msgStr += "Please go to the App Store to get info on purchase options and download the latest version of PlayTunes."

        // JUNE15 - and restore this:
        
        let titleStr = "Try Out Days In Pink Levels For Free!"
        // All Pink Levels To access all of PlayTunes, Purchase (or Restore) a Subscription"
        var msgStr = "- All Days of Levels 1 & 2: Free!\n- Day 1 of other Pink Levels - Free!\n\n"
        msgStr += "Now that the Spring 2020 Free Trial period is over, for total access PlayTunes, you must purchase (or Restore) a Subscription. "
        msgStr += "Go to Settings > Purchase Options.\n\n"
        msgStr += "(You should first make sure you have the latest version of PlayTunes.)\n\n"
        
        //        msgStr += "(If you have a valid Subscription from another device, use the Restore button)\n\n"
        msgStr += "(If you just completed a purchase or restore, verification can take a while. Try again in a bit.)"
        
        
        let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(ac, animated: true, completion: nil)
    }
    
    //    IAPSUBS
    func displaySubsExpiredAlert() {
        let titleStr = "Something is wrong with your Subscription"
        var msgStr = "\nYour subscription to PlayTunes has expired or was cancelled.\n\n"
        msgStr += "To continue using PlayTunes, go to 'Purchase Options' "
        msgStr += "on the Home screen to extend your subscription\n\n"
        let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(ac, animated: true, completion: nil)
    }
    
    //    IAPSUBS
    func displayTryoutAlert() {
        let titleStr = "Are you a more advanced student?"
        var msgStr = "\n\nWant to see what the upper \nlevels are like?\n\n"
        msgStr += "These are examples of what you'll be able to enjoy if you subscribe to PlayTunes.\n\n"
        msgStr += "More levels coming on a regular basis!\n"
        let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK",
                                   style: .default,
                                   handler: nil))
        ac.show(animated: true, completion: nil)
    }
    
    func testBPM() {
        let currBPM = UserDefaults.standard.double(forKey: Constants.Settings.BPM)
        
        let wholeLen  = 4.0 * PerfTrkMgr.instance.qtrNoteTimeInterval
        let halfLen   = 2.0 * PerfTrkMgr.instance.qtrNoteTimeInterval
        let eighthLen = 0.5 * PerfTrkMgr.instance.qtrNoteTimeInterval
        
        print("\n============================================================")
        print("   BPM Tests, at \(currBPM) BPM:")
        print("         WholeLen:   \(wholeLen)")
        print("         HalfLen:    \(halfLen)")
        print("         QtrLen:     \(PerfTrkMgr.instance.qtrNoteTimeInterval)")
        print("         EighthLen:  \(eighthLen)")
        print("============================================================\n")
    }
    
    func numDaysInLevel(level: Int) -> Int {
        var count = 0
        
        var daysJson:JSON?
        daysJson = levelsJson![level]["days"]
        if ( daysJson != nil ) {
            count = daysJson!.count
        }
        
        return count
    }
    
    func isSelectedCell(row: Int) -> Bool {
        //        print ("  in isSelectedCell;  section = \(indexPath.section),  row = \(indexPath.row)")
        if activeLevel == currLevel && row == currDay {
            //           print ("     currLevel = \(currLevel),  currDay = \(currDay); returning->  TRUE")
            return true
        } else {
            //           print ("     currLevel = \(currLevel),  currDay = \(currDay); returning->  FALSE")
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // PPPproblem!!!!!
        
        if let levels = instrumentJson?["levels"] {
            if let destination = segue.destination as? DayOverviewViewController {
                if let indexPath = sender as? IndexPath {
                    loadedFromHomeScreen = false // will be coming back from Day screen
                    _ = LessonScheduler.instance.setCurrentLevel(activeLevel)
                    destination.thisViewsLevel = activeLevel
                    destination.exerLevelIndex = indexPath.row
                    destination.lessonsJson = levels[activeLevel]["exercises"]

                    if let levelTitle = levels[activeLevel]["title"].string {
                        destination.levelTitle = levelTitle
                    }
                    if activeLevelIsLipSlur && currInstIsAClarinet() {
                        destination.levelTitle  = "The Break"
                    }

                    let daysJson:JSON? = levels[activeLevel]["days"]
                    
                    let day = indexPath.row
                    _ = LessonScheduler.instance.setCurrentDay(day)
                    
                    let lde: tLDE_code = (level: activeLevel, day: day, exer: 0)
                    _ = LessonScheduler.instance.setCurrentLDE(toLDE: lde)

                    destination.thisViewsLevelDay = day
                    let oneDayExerListStr = daysJson![indexPath.row]["exercises"].string
                    let oneDayExerTitle   = daysJson![indexPath.row]["title"].string
                    destination.dayTitle = (oneDayExerTitle != nil) ? oneDayExerTitle! : ""
                    if activeLevelIsLipSlur && currInstIsAClarinet() {
                        destination.dayTitle  = "Break Exercises \(indexPath.row+1)"
                    }
                    
                    destination.exercisesListStr = (oneDayExerListStr != nil) ? oneDayExerListStr! : ""
                    
                    destination.thresholdsID         = thresholdsID
                    destination.singleEventThreshold = singleEventThreshold
                    if let threshIDStr = levels[activeLevel]["thresholdsID"].string {
                        destination.thresholdsID = threshIDStr
                    }
                    if let singEvtThersh = levels[activeLevel]["singleEventThreshold"].string {
                        destination.singleEventThreshold = singEvtThersh
                    }
                    if let scanForPitchChange = levels[activeLevel]["scanForPitchLegatoChange"].string {
                        if scanForPitchChange == "Y" {
                            gScanForPitchDuringLegatoPlaying = true
                        } else {
                            gScanForPitchDuringLegatoPlaying = false
                        }
                    } else {
                        //   ?????
                    }
                }
            }
        }
    }
    
//    func canDoSlursAtThisTempo() -> Bool {
//        if !isSlursLevel {
//            return true
//        }
//
//        let currBpm = Int(getCurrBPM())
//            return currBpm > kSlursTempoCutoff ? false : true
//    }
    
}


let kIdxForLipSlurs    = "990"
let kIdxForCrossBreaks = "991"
let kIdxForLongTones6  = "992"
let kIdxForLongTones10 = "993"
let kIdxForLongTones20 = "994"
let kIdxForLongTones30 = "995"
func isSpecialLevel( levelIdx: String ) -> Bool {
    if levelIdx == kIdxForLipSlurs     ||
        levelIdx == kIdxForCrossBreaks  ||
        levelIdx == kIdxForLongTones6   ||
        levelIdx == kIdxForLongTones10  ||
        levelIdx == kIdxForLongTones20  ||
        levelIdx == kIdxForLongTones30     {
        return true
    } else {
        return false
    }
}

extension LevelsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.levelsTableView {
            return numLevelsToShow()
        } else if tableView == self.daysTableView {
            
            guard levelsJson != nil else { return 0 }
            if gDoLimitLevels && activeLevel > kNumberOfLevelsToShow {
                itsBad()
                return 0
            }
            
            return numDaysInLevel(level: activeLevel)
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.levelsTableView {
            
            let cell: LevelTableViewCell = tableView.dequeueReusableCell(withIdentifier: "levelsCell", for: indexPath) as! LevelTableViewCell
            
//            if gDoLimitLevels && indexPath.row > kNumberOfLevelsToShow {
//                itsBad()
//            }
            
            // IAPSUBS
            subscriptionGood = PlayTunesIAPProducts.store.subscriptionGood()
            var levelIsEnabled = subscriptionGood
            
            
            // The text for the level is not simply index + 1. It's in the json
            var levelTitle = String(indexPath.row + 1) // default
            var titleStr = levelsJson?[indexPath.row]["title"].string
            
            if titleStr != nil {
                levelTitle = titleStr!
                if !levelIsEnabled { // See if it's a free Tryout Level
                    levelIsEnabled =
                        TryOutLevelsManager.sharedInstance.isLevelEnabled(levelTitle: levelTitle)
                }
            } else {
                itsBad()
            }
            
            cell.levelNumberLabel.text = levelTitle
            cell.setLevelLabelToDefaultSettings()
            cell.isEnabled = levelIsEnabled

            // Check for the special levels. If it is one, then use the json title
            // for the Level Text (not the number text, like above)
            if let levelIdx = levelsJson?[indexPath.row]["levelIdx"].string {
                if isSpecialLevel( levelIdx: levelIdx ) {
                    cell.setLevelLabelForSpecificLabel()
                    cell.levelNumberLabel.text = ""
                    
                    if levelIdx == kIdxForLipSlurs && currInstIsAClarinet() {
                        titleStr = "The Break"
                    }
                    if titleStr != nil { // NOTE: setting levelLabel, not NumberLabel
                        cell.levelLabel.text = titleStr! // e.g., "Lip Slurs"
                    }
//                    if levelIdx == kIdxForLipSlurs {
//                        isSlursLevel = true
//                    }
                }
            }

            cell.isActive = activeLevel == indexPath.row
            
            let levelState = LessonScheduler.instance.getLevelState(level: indexPath.row)
            
            if levelState == kLDEState_Completed  {  // kLDEState_InProgress
                cell.stateImageView.alpha = 1
            } else {
                cell.stateImageView.alpha = 0
            }
            
            return cell
            
        } else {
            
            let cell: DayTableViewCell = tableView.dequeueReusableCell(withIdentifier: "daysCell", for: indexPath) as! DayTableViewCell
            
            var cellTitleText = "Day " + String(indexPath.row + 1)
//            cell.dayLabel.text = "Day " + String(indexPath.row + 1)

 //           let titleStr = levelsJson?[indexPath.row]["title"].string

            if let levelIdx = levelsJson![activeLevel]["levelIdx"].string {
                if isSpecialLevel( levelIdx: levelIdx ) {
                    let daysJson:JSON? = levelsJson![activeLevel]["days"]
                    if daysJson != nil {
                        var oneDayExerTitle = daysJson![indexPath.row]["title"].string
                        if activeLevelIsLipSlur && currInstIsAClarinet() {
                            oneDayExerTitle = "Break Exercises \(indexPath.row+1)"
                        }
                        if oneDayExerTitle != nil {
                            cellTitleText = oneDayExerTitle!
                        }
                    }
                }
            }
            
            cell.dayLabel.text = cellTitleText
            
            var dayIsEnabled = false
            if selectedLevelIsEnabled {
                //let selectedCell: DayTableViewCell? = tableView.cellForRow(at: indexPath) as? DayTableViewCell
                //let selCellTitle = selectedCell?.dayLabel.text
                dayIsEnabled = subscriptionGood
                if !dayIsEnabled { // then sub not good. See if in free tryput list
                    dayIsEnabled =
                        TryOutLevelsManager.sharedInstance.isDayEnabled(
                            levelTitle: selectedLevelTitleStr,
                            dayTitle: cellTitleText )
                }
            }
            
            if dayIsEnabled {
                cell.dayIsEnabled = true
            } else {
                cell.dayIsEnabled = false
            }
            
            //selectedCell?.isSelectedDay = true

            let currLDE = LessonScheduler.instance.getCurrentLDE()
            let currDay = currLDE.day
            if currDay == indexPath.row  {
                cell.isSelectedDay = true
            } else {
                cell.isSelectedDay = false
            }
            
            if gDoLimitLevels && activeLevel > kNumberOfLevelsToShow {
                itsBad()
                return cell
            }
            
            let jsonIdx = jsonIndexForRow(activeLevel)
            
//            var daysJson: JSON?
//            daysJson = levelsJson![jsonIdx]["days"]
//            if ( daysJson != nil ) {
//                var titleStr = ""
//                if let rowTitle = daysJson![indexPath.row]["title"].string {
//                    titleStr += rowTitle
//                }
//                cell.dayLabel.text = titleStr
//            }
            
            let thisLD: tLD_code = ( jsonIdx, indexPath.row )
            let dayState = LessonScheduler.instance.getDayState(forLD: thisLD)
            
            if dayState == kLDEState_Completed {
                cell.checkImageView.isHidden = false
            } else {
                cell.checkImageView.isHidden = true
            }
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == self.levelsTableView {
            return view.frame.height * 0.4
        } else if tableView == self.daysTableView {
            return view.frame.height * 0.18
        }
        
        return 100
        
    }
    
    //- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
    //func tableView(_ tableView: UITableView,
    //                       willSelectRowAtIndexPath indexPath: IndexPath) {
    {
        if tableView == self.daysTableView {
            print ("yo")
        }
        return indexPath
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /*
         // This is for quickly testing the Video view, which is not normally
         // part of this view at all. You should completely ignore this for the
         // purposes of Level Series Overview work.
         if gMKDebugOpt_TestVideoViewInLessonOverview { // For Video Testing.
         if indexPath.row == 1 {
         if vhView == nil {
         createVideoHelpView()
         }
         
         vhView?.videoID = vidIDs.kVid_Pitch_VeryLow_SpeedUpAir
         vhView?.showVideoVC()
         
         /*  Modal attempt
         if self.popVC == nil {
         self.createVideoHelpView()
         }
         if self.popVC != nil && self.popVC?.vhView != nil {
         self.popVC?.vhView?.videoID = vidIDs.kVid_Pitch_VeryLow_SpeedUpAir // vidIDs.kVid_Pitch_VeryLow_SpeedUpAir // videoID
         self.popVC?.vhView?.showVideoVC()
         self.popVC?.modalPresentationStyle = .popover
         self.present((self.popVC!), animated: true, completion: nil)
         //                    self.popVC!.popoverPresentationController?.sourceView = view
         //                    self.popVC!.popoverPresentationController?.sourceRect = sender.frame
         }
         */
         return
         }
         }
         */
        
        //Here we are going to seguae to the lesson that the user selected
        
        if tableView == self.levelsTableView {
            
            // IAPSUBS ?
            
            // Scroll to tapped level
            let yPos = levelsTableView.rectForRow(at: IndexPath(row: indexPath.row, section: 0)).origin.y
            tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: yPos), animated: true)
            
//            var levelIsEnabled = true
//
//            // The text for the level is not simply index + 1. It's in the json
//            var levelTitle = String(indexPath.row + 1) // default
//            let titleStr = levelsJson?[indexPath.row]["title"].string
//            if titleStr != nil {
//                levelTitle = titleStr!
//                levelIsEnabled =
//                    TryOutLevelsManager.sharedInstance.isLevelEnabled(levelTitle: titleStr!)
//            } else {
//                itsBad()
//            }
//            if !levelIsEnabled {
//                selectedLevelIsEnabled = false
//                //return
//            } else {
//                 selectedLevelIsEnabled = true
//            }
//            selectedLevelTitleStr = levelTitle
 
            if activeLevel != indexPath.row {
                activeLevel = indexPath.row
                setupNewlySelectedLevel()
                //                _ = LessonScheduler.instance.setCurrentLevel(activeLevel)
                //                _ = LessonScheduler.instance.setCurrentDay(0)
                let lde: tLDE_code = (level: activeLevel, day: 0, exer: 0)
                _ = LessonScheduler.instance.setCurrentLDE(toLDE: lde)
                self.daysTableView.reloadData()
                
                if let levelIdx = levelsJson?[indexPath.row]["levelIdx"].string {
                    isSlursLevel =  levelIdx == kIdxForLipSlurs ? true : false
                }
                
//                let canDo = canDoSlursAtThisTempo()
//                if !canDo {
//                    DispatchQueue.main.async {
//                        presentCantDoSlursAtThisTempAlert(presentingVC: self, forLevelVC: true)
//                    }
//                }
           }

//            activeLevel = indexPath.row
//            setupNewlySelectedLevel()
            
//            _ = LessonScheduler.instance.setCurrentLevel(activeLevel)

//            self.daysTableView.reloadData()
            
        } else if tableView == self.daysTableView {
            
//            let canDo = canDoSlursAtThisTempo()
//            if !canDo {
//                presentCantDoSlursAtThisTempAlert()
//                return
//            }
            
//            if !selectedLevelIsEnabled {
//                // IAPSUBS ?
//                return
//            }
            
            let selectedCell: DayTableViewCell? = tableView.cellForRow(at: indexPath) as? DayTableViewCell
            guard selectedCell != nil else {
                itsBad();   return
            }

            // already in here below!!!!
            if !selectedCell!.dayIsEnabled {

                if PlayTunesIAPProducts.store.userDefsStoredSubscStatusIsKnown() &&
                    PlayTunesIAPProducts.store.userDefsStoredSubscHasBeenPurchased() {
                    //    IAPSUBS
                    DispatchQueue.main.async {
                        self.displaySubsExpiredAlert()
                    }
                } else {
                    //    IAPSUBS
                    DispatchQueue.main.async {
                        self.displayMustPurchaseAlert()
                    }
                    
                }
                return
            }
        
            
            let selCellTitle = selectedCell?.dayLabel.text
//            var dayIsEnabled =
//                TryOutLevelsManager.sharedInstance.isDayEnabled(levelTitle: selectedLevelTitleStr,
//                                                                dayTitle: selCellTitle ?? "" )
            
//            selectedLevelTitleStr  cell.dayLabel.text
//            if titleStr != nil {
//                levelTitle = titleStr!
//                dayIsEnabled =
//                    TryOutLevelsManager.sharedInstance.isLevelEnabled(levelTitle: titleStr!)
//            } else {
//                itsBad()
//            }
//            if !levelIsEnabled {
//                selectedLevelIsEnabled = false
//                //return
//            } else {
//                selectedLevelIsEnabled = true
//            }

//            selectedCell?.dayIsEnabled = dayIsEnabled
             if selectedCell!.dayIsEnabled {
 //               selectedCell?.dayLabel.textColor = .black
 //               selectedCell?.dayIsEnabled  = true
                selectedCell?.isSelectedDay = true
                currLevel = activeLevel
                currDay = indexPath.row
                
                let lde: tLDE_code = (level: activeLevel, day: currDay, exer: 0)
                _ = LessonScheduler.instance.setCurrentLDE(toLDE: lde)

                daysTableView.reloadData()
                
                let jsonIdx = jsonIndexForRow(activeLevel)
                let convertedIndexPath = IndexPath(row: indexPath.row, section: jsonIdx)
                performSegue(withIdentifier: "LessonSegue", sender: convertedIndexPath)  // PPPproblem!!!!!
            } else {
                if PlayTunesIAPProducts.store.userDefsStoredSubscStatusIsKnown() &&
                   PlayTunesIAPProducts.store.userDefsStoredSubscHasBeenPurchased() {
                    //    IAPSUBS
                    DispatchQueue.main.async {
                        self.displaySubsExpiredAlert()
                    }
                } else {
                    //    IAPSUBS
                    DispatchQueue.main.async {
                       self.displayMustPurchaseAlert()
                    }
                    
                }




                 selectedCell?.isSelectedDay = false
            }
        }
        
    }
    
    func setupNewlySelectedLevel() {
        var levelIsEnabled = true
        
        if levelsJson == nil {
            print("In setupNewlySelectedLevel(), levelsJson == nil !!!!!")
        } else {
            print("In setupNewlySelectedLevel(), levelsJson != nil")
        }
        
        var levelTitle = String(activeLevel + 1) // default
        let titleStr = levelsJson?[activeLevel]["title"].string
        if titleStr != nil {
            print("In setupNewlySelectedLevel(), title str not nil, and == \(titleStr!)")
            levelTitle = titleStr!
            levelIsEnabled = subscriptionGood
            if !levelIsEnabled {
                levelIsEnabled = TryOutLevelsManager.sharedInstance.isLevelEnabled(levelTitle: titleStr!)
            }
        } else {
            print("In setupNewlySelectedLevel(), title == nil !!!")
            itsBad()
        }
        if !levelIsEnabled {
            selectedLevelIsEnabled = false
            //return
        } else {
            selectedLevelIsEnabled = true
        }
        selectedLevelTitleStr = levelTitle
//        activeLevel = indexPath.row

    }
    
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if tableView == self.daysTableView {
            
            guard activeLevel >= 0 && activeLevel < (levelsJson?.count)! else {
                print ("Unable to get levelsJson in LevelSeriesViewController::didDeselectRowAt")
                return
            }
            
            // var daysJson:JSON?
            let daysJson:JSON? = levelsJson![activeLevel]["days"]
            guard daysJson != nil  else {
                print ("Unable to get daysJson in LevelSeriesViewController::didDeselectRowAt")
                return
            }
            guard indexPath.row >= 0 && indexPath.row < (daysJson?.count)! else {
                print ("row >= num days in LevelSeriesViewController::didDeselectRowAt")
                return
            }
            
            let myIndexPath = IndexPath(row: currDay, section: currLevel)
            let cellToDeSelectQ: DayTableViewCell? = tableView.cellForRow(at: myIndexPath) as? DayTableViewCell
            if cellToDeSelectQ != nil {
                cellToDeSelectQ!.dayLabel.textColor = .greyTextColor
                print ("-->>>  Completed Deselect option 1 in LevelSeriesViewController::didDeselectRowAt")
            } else {
                print ("unable to get cellToDeSelect option 1 in LevelSeriesViewController::didDeselectRowAt")
            }
            
            let cellToDeSelectImp: DayTableViewCell? = tableView.cellForRow(at: indexPath) as? DayTableViewCell
            if cellToDeSelectImp != nil {
                cellToDeSelectImp!.dayLabel.textColor = .greyTextColor
                print ("-->>>  Completed Deselect option 2 in LevelSeriesViewController::didDeselectRowAt")
            } else {
                print ("unable to gdt cellToDeSelect  option 2 in LevelSeriesViewController::didDeselectRowAt")
            }
            
        }   
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView == self.levelsTableView {
            
            let yPosLastRow = levelsTableView.rectForRow(at: IndexPath(row: levelsTableView.numberOfRows(inSection: 0) - 1, section: 0)).origin.y
            
            if targetContentOffset.pointee.y > yPosLastRow {
                
                targetContentOffset.pointee.y = yPosLastRow
                
                if activeLevel == levelsTableView.numberOfRows(inSection: 0) - 1 {
                    // Prevent weird flashing if user keeps attempting to scroll down
                    return
                }
                
            }
            
            guard var scrollingToIP = levelsTableView.indexPathForRow(at: CGPoint(x: 0, y: targetContentOffset.pointee.y)) else {
                // No index path
                return
            }
            
            var scrollingToRect = levelsTableView.rectForRow(at: scrollingToIP)
            let roundingRow = Int(((targetContentOffset.pointee.y - scrollingToRect.origin.y) / scrollingToRect.size.height).rounded())
            scrollingToIP.row += roundingRow // + 0/1
            
//            if !allowAllLevelAccess && (showingTryoutLevel && scrollingToIP.row >= kSectionToDisplayTryoutAt) {
//                //            if PlayTunesIAPProducts.store.purchaseStatus.confirmed &&
//                //               PlayTunesIAPProducts.store.purchaseStatus.state == .expired {
//
//                scrollingToIP.row = kSectionToDisplayTryoutAt - 1
//
//                shouldDisplayAlertAfterScroll = true
//
//            }
            
            scrollingToRect = levelsTableView.rectForRow(at: scrollingToIP)
            targetContentOffset.pointee.y = scrollingToRect.origin.y
            
            if activeLevel != scrollingToIP.row {
                activeLevel = scrollingToIP.row
                setupNewlySelectedLevel()
//                _ = LessonScheduler.instance.setCurrentLevel(activeLevel)
//                _ = LessonScheduler.instance.setCurrentDay(0)
                let lde: tLDE_code = (level: activeLevel, day: 0, exer: 0)
                _ = LessonScheduler.instance.setCurrentLDE(toLDE: lde)
                self.daysTableView.reloadData()
                if let levelIdx = levelsJson?[scrollingToIP.row]["levelIdx"].string {
                    isSlursLevel =  levelIdx == kIdxForLipSlurs ? true : false
                }
                
//                let canDo = canDoSlursAtThisTempo()
//                if !canDo {
//                    DispatchQueue.main.async {
//                        presentCantDoSlursAtThisTempAlert(presentingVC: self, forLevelVC: true)
//                    }
//                }
           }
            
//            //let indexPath = NSIndexPath(row: activeLevel, section: 0)
//            let indexPath = IndexPath(row: activeLevel, section: 0)
//            //tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
//
//            self.levelsTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
//            //self.levelsTableView.curr
//            self.daysTableView.reloadData()
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.levelsTableView {
            
            let yPosLastRow = levelsTableView.rectForRow(at: IndexPath(row: levelsTableView.numberOfRows(inSection: 0) - 1, section: 0)).origin.y
            
            if scrollView.contentOffset.y > yPosLastRow {
                scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: yPosLastRow), animated: false)
            }
            
            if CK_Day >= 0 {
                delay( 0.25) {
                    self.scrollToClassKitDay()
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
//        if scrollView == self.levelsTableView {
//
//            if shouldDisplayAlertAfterScroll {
//
//                if PlayTunesIAPProducts.store.userDefsStoredSubscStatusIsKnown() &&
//                    PlayTunesIAPProducts.store.userDefsStoredSubscHasBeenPurchased() {
//                    //    IAPSUBS
//                    displaySubsExpiredAlert()
//                } else {
//                    //    IAPSUBS
//                    displayMustPurchaseAlert()
//                }
//
//                shouldDisplayAlertAfterScroll = false
//
//            }
//
//        }
        
    }
    
    func scrollToActiveLevel(doAnimate: Bool = false) {
        //        let yPosActiveRow =
        //            levelsTableView.rectForRow(at: IndexPath(row: levelsTableView.numberOfRows(inSection: 0) - 1,
        //                                                     section: 0)).origin.y
        
        let yPosActiveRow =
            levelsTableView.rectForRow(
                at: IndexPath(row:activeLevel, section: 0)).origin.y
        self.levelsTableView.setContentOffset(CGPoint(
            x: self.levelsTableView.contentOffset.x,
            y: yPosActiveRow),
                                              animated: doAnimate)
        
        //if scrollView.contentOffset.y > yPosLastRow {
        //            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: yPosActiveRow), animated: false)
        //}
    }
    
    func scrollToClassKitDay(doAnimate: Bool = false) {
        //        let yPosActiveRow =
        //            levelsTableView.rectForRow(at: IndexPath(row: levelsTableView.numberOfRows(inSection: 0) - 1,
        //                                                     section: 0)).origin.y
        
        let yPosActiveRow =
            daysTableView.rectForRow(
                at: IndexPath(row:Int(CK_Day), section: 0)).origin.y
        self.daysTableView.setContentOffset(CGPoint(
            x: self.daysTableView.contentOffset.x,
            y: yPosActiveRow),
                                              animated: doAnimate)
        
        let IndPath = IndexPath(row:Int(CK_Day), section: 0)
        self.daysTableView.selectRow(at: IndPath, animated: true, scrollPosition: .top)
        
        
        currDay = Int(CK_Day)
        
        let lde: tLDE_code = (level: activeLevel, day: currDay, exer: 0)
        _ = LessonScheduler.instance.setCurrentLDE(toLDE: lde)
        
        daysTableView.reloadData()
        
        
        let jsonIdx = jsonIndexForRow(activeLevel)
        let convertedIndexPath = IndexPath(row: Int(CK_Day), section: jsonIdx)
        CK_Day = -1
        performSegue(withIdentifier: "LessonSegue", sender: convertedIndexPath)  // PPPproblem!!!!!
        
        //if scrollView.contentOffset.y > yPosLastRow {
        //            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: yPosActiveRow), animated: false)
        //}
    }
    

    
    private func createParticles() {
        
        particleEmitter.emitterPosition = CGPoint(x: daysBackgroundView.frame.minX + 50, y: view.center.y)
        particleEmitter.zPosition = -1.0
        particleEmitter.emitterShape = CAEmitterLayerEmitterShape(rawValue: "rectangle")
        particleEmitter.emitterSize = CGSize(width: 1, height: view.frame.height)
        
        let wholeNote = makeEmitterCell(imageName: "wholeNote")
        let halfNote = makeEmitterCell(imageName: "halfNote")
        let eigthNote = makeEmitterCell(imageName: "eigthNote")
        let trebleClef = makeEmitterCell(imageName: "trebleClef")
        let bassClef = makeEmitterCell(imageName: "bassClef")

        particleEmitter.emitterCells = [wholeNote, halfNote, eigthNote, trebleClef, bassClef]
        
        view.layer.addSublayer(particleEmitter)
        
    }
    
    private func makeEmitterCell(imageName: String) -> CAEmitterCell {
        
        let cell = CAEmitterCell()
        
        let randomNum = Double.random(in: 0...3)
        cell.beginTime = randomNum
        
        cell.birthRate = 0.33
        cell.lifetime = 35
        cell.lifetimeRange = 10
        
        cell.velocity = 50
        cell.velocityRange = 20
        
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 2
        
        if DeviceType.IS_IPHONE_5orSE {
            cell.scale = 0.2
        } else {
            cell.scale = 0.4
        }
        
        cell.scaleRange = 0.05
        cell.scaleSpeed = -0.005
        
        cell.spin = 0.2
        cell.spinRange = 0.1
        
        cell.contents = UIImage(named: imageName)?.cgImage
        
        return cell
        
    }
}       // extension LevelsViewController:

let kSlursTempoCutoff =  90

var gShowSlursAtFastBPMWarning = true
var gHaveShownSlursAtFastBPMWarningCount = 0
var gSkipShowingFastBPMWarnCount = 0
let kHaveShownSlursFastBPMWarnThreshold = 3
let kReShowSlursFastBPMWarnThresh = 3

func presentSlursAreAProblemAtThisTempAlert(presentingVC: UIViewController?,
                                            forLevelVC: Bool ) {
    let currBPM = Int(getCurrBPM())
    guard currBPM > 0 else { return }
    
    if !gShowSlursAtFastBPMWarning {
        gSkipShowingFastBPMWarnCount += 1
        if gSkipShowingFastBPMWarnCount > kReShowSlursFastBPMWarnThresh {
            gShowSlursAtFastBPMWarning = true
            gSkipShowingFastBPMWarnCount = 0
        }
    }
    guard gShowSlursAtFastBPMWarning else { return }
    
    gHaveShownSlursAtFastBPMWarningCount += 1
    
    let titleStr = "You are too awesome!"
    
    var msgStr = ""
    //        if !DeviceType.IS_IPHONE_5orSE {
    //            msgStr += "\n"
    //        }
    if forLevelVC {
        msgStr += "\nPlayTunes grades slurs very well at \(kSlursTempoCutoff) BPM or below, "
        msgStr += "so you may want to select a slower tempo (currently \(currBPM))."
        msgStr += "\n\nYou can go ahead and play at this faster tempo if you wish, but you "
        msgStr += "may not get an accurate star rating (may ignore partials).\n\nWe’re working on this. Thanks!"
    } else { // For Day
        msgStr += "\nThis Day contains a Lip Slur exercise.\n\nPlayTunes grades slurs very "
        msgStr += "well at \(kSlursTempoCutoff) BPM or below (you are currently at \(currBPM)). "
        msgStr += "You can go ahead and play at this faster tempo, but you may not get "
        msgStr += "an accurate star rating (may ignore partials). So you may want to select a slower tempo. "
        msgStr += "(We’re working on this. Thanks!)"
    }
    
    let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Okay", style: .default,
                               handler: nil))
    
    // See if should add "Got It!" button
    if gHaveShownSlursAtFastBPMWarningCount > kHaveShownSlursFastBPMWarnThreshold {
        ac.addAction(UIAlertAction(title: "Got It!", style: .default,
                                   handler: slursAtHiTempoGotItHandler))
    }
    
    presentingVC?.present(ac, animated: true, completion: nil)
}

func slursAtHiTempoGotItHandler(_ act: UIAlertAction) {
    gShowSlursAtFastBPMWarning = false
    gSkipShowingFastBPMWarnCount = 0
}
