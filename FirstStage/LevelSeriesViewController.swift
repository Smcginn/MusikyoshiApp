//
//  LessonSeriesViewController.swift
//  FirstStage
//
//  Created by Caitlyn Chen on 1/22/18.
//  Modified by Scott Freshour
//
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

// Top Level VC

import UIKit
import Foundation
import SwiftyJSON
import AudioKit

var gDoOverrideSubsPresent = false      // CHECK_THIS_FOR_SUBMIT
var gDoLimitLevels = false              // CHECK_THIS_FOR_SUBMIT
let kNumberOfLevelsToShow: Int = 11

// This is the artificial level number to display the tryput section at (it is not
// the order in the json file). We show this if they don't have a subscription.
let kSectionToDisplayTryoutAt: Int = 2

// In the JSON file, this is the number of Tryout Level
let kTryoutUpperValInJson: Int = 1000

let levelHeaderSpacingStr = "       " // leaves room at front for checkbox icon

class LevelSeriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let sectionTitlesIfNoSubsriptions = ["Level 1",
                                         "Level 2",
                                         "--> Try out some Upper Level Exercises For Free!",
                                         "Level 3",
                                         "Level 4",
                                         "Level 5",
                                         "Level 6",
                                         "Level 7",
                                         "Level 8",
                                         "Level 9",
                                         "Level 10",
                                         ]
    

    // is there a subscription?
    //   - this affects Tryout AND showing upper levels
    var subscriptionGood   = false

    var showingTryoutLevel = true
    
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
        
        if !showingTryoutLevel {
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
    
    func jsonIndexForSection(_ section: Int) -> Int {
        var retJsonIdx = section
        
        if showingTryoutLevel {
            if section == kSectionToDisplayTryoutAt {
                if let rawJsonCount = instrumentJson?["levels"].count {
                    retJsonIdx = rawJsonCount-1
                }
            }
            if section > kSectionToDisplayTryoutAt {
                retJsonIdx = section - 1
            }
        }
        
        return retJsonIdx
    }
    
    var checkImage: UIImage? = nil
    var nocheckImage: UIImage? = nil
    var checkImageView: UIImageView? = nil

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var instrumentJson: JSON?
    var levelsJson: JSON?
    
    var thresholdsID         = kThershIDsStr_Begin_1
    var singleEventThreshold = kSingleEventThreshDefaultStr
    
    let kNoSectionSelected = -1
    var currLevel:Int = 0
    var currDay = 0

    var allowAllLevelAccess = false
    
    var timer = Timer()
    var tryoutBackgroundColor = kSeaFoamBlue
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Ask for permission to use the microphone, if not already granted
        var permissionGranted = false
        if alwaysFalseToSuppressWarn() { print("\(permissionGranted)") }
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            permissionGranted = true
        case AVAudioSessionRecordPermission.denied:
            permissionGranted = false
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission {
                [weak self] granted in
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscriptionGood = PlayTunesIAPProducts.store.subscriptionGood()
        if subscriptionGood || gDoOverrideSubsPresent || !gDoLimitLevels {
            showingTryoutLevel = false
        }
        
        // Orientation BS - LevelSeriesVC --> viewDidLoad
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.orientationLock = .landscapeRight
        AppDelegate.AppUtility.lockOrientationToLandscape()
//        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight,
//                                               andRotateTo: UIInterfaceOrientation.landscapeRight)
        
        // let currOrien =
        AppDelegate.AppUtility.currOrientation()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        if let file = Bundle.main.path(forResource: "TrumpetLessons", ofType: "json"){
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
        
        self.view.backgroundColor = kDefaultViewBackgroundColor
        self.tableView.backgroundColor = kDefaultViewBackgroundColor
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
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
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // return .landscapeRight
        
        // override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientationMask.landscapeRight // .rawValue
    }
    override var shouldAutorotate: Bool {
        return false
    }

    func assessPurchaseStatus() {
        if gDoOverrideSubsPresent {
            allowAllLevelAccess = true
            return
        }
        
        allowAllLevelAccess = PlayTunesIAPProducts.store.subscriptionGood()
        if !allowAllLevelAccess &&
           !PlayTunesIAPProducts.store.userDefsStoredSubscStatusIsKnown() {
            // see if just waiting for update
            while PlayTunesIAPProducts.store.confirmedAttempts < 10 {
                if PlayTunesIAPProducts.store.userDefsStoredSubscStatusIsKnown() {
    //                print("\n\n        Receipt Data repsonse acquired!   \n\n")
                    // if PlayTunesIAPProducts.store.purchaseStatus.state == .purchaseGood {
     //               if PlayTunesIAPProducts.store.purchaseStatus.subscriptionGood() {
                    if PlayTunesIAPProducts.store.subscriptionGood() {
                       allowAllLevelAccess = true
                    } else {
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
//        if PlayTunesIAPProducts.store.purchaseStatus.confirmed {
//            if PlayTunesIAPProducts.store.purchaseStatus.state == .purchaseGood {
//                allowAllLevelAccess = true
//            }
//        } else {
//            accessPurchaseStatusRetry()
//        }
    }
    
//    func accessPurchaseStatusRetry() {
//        if PlayTunesIAPProducts.store.purchaseStatus.confirmedAttempts < 10 {
//            delay(0.5) {
//                PlayTunesIAPProducts.store.purchaseStatus.confirmedAttempts += 1
//                self.assessPurchaseStatus()
//            }
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        assessPurchaseStatus()
        
        tableView.reloadData()
        
        navigationBar.topItem?.title = "Levels"
        
        testBPM()
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        // Orientation BS - LevelSeriesVC --> viewWillDisappear
//        let appDel = UIApplication.shared.delegate as! AppDelegate
//        appDel.orientationLock = .portrait
        //AppDelegate.AppUtility.unlockOrientation()
//        AppDelegate.AppUtility.lockOrientationToPortrait()
        //AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numLevelsToShow()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var retStr = "Level 1"
        
        if gDoLimitLevels && section > kNumberOfLevelsToShow {
            itsBad()
            return retStr
        }
        
        if showingTryoutLevel {
            if section < sectionTitlesIfNoSubsriptions.count {
                retStr = sectionTitlesIfNoSubsriptions[section]
            }
        } else {
            if let titleStr = levelsJson?[section]["title"].string {
                retStr = levelHeaderSpacingStr + titleStr // leave room at front for checkbox icon
            }
        }
        return retStr
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard levelsJson != nil else { return 0 }
        if gDoLimitLevels && section > kNumberOfLevelsToShow {
            itsBad()
            return 0
        }
    
        if section != currLevel { return 0 }

        let jsonIdx = jsonIndexForSection(section)
        return numDaysInLevel(level: jsonIdx)
        
//        var count = 0
//        var daysJson:JSON?
//        daysJson = levelsJson![section]["days"]
//        if ( daysJson != nil ) {
//            count = daysJson!.count
//        }
//
//        return count
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if gDoLimitLevels && section > kNumberOfLevelsToShow {
            itsBad()
            return nil
        }
        
        let header =
            tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
                as? LevelSeriesTableViewHeaderFooterView
                ?? LevelSeriesTableViewHeaderFooterView(reuseIdentifier: "header")
        
//        if !allowAllLevelAccess && section >= 2 {
//            header.contentView.backgroundColor = kDefault_DisabledSectionBkgrndColor
////            header.contentView.tintColor = UIColor.gray
//            header.textLabel?.textColor = .lightGray
//        } else {
//            header.contentView.backgroundColor = kDefault_SectionBkgrndColor
//            header.textLabel?.textColor = .black
//        }
        header.section = section
        if header.gestureRecognizers == nil {
            let tap = UITapGestureRecognizer( target: self, action: #selector(headerTapped))
            tap.numberOfTapsRequired = 1
            header.addGestureRecognizer(tap)
        }
        
        let levelState = LessonScheduler.instance.getLevelState(level: section)
        
        var checkState: LevelSeriesTableViewHeaderFooterView.CheckState = .unchecked
        if levelState == kLDEState_Completed  {  // kLDEState_InProgress
            checkState = .checked
        }
        header.setCheckedState(state: checkState)
        
        return header
    }

    func displayMustPurchaseAlert() {
        let titleStr = "For access to all levels, you must purchase a PlayTunes Subscription"
        var msgStr = "\nLevels 1 & 2 are always free!\n\n"
        msgStr += "To explore PlayTunes' upper Levels, go to 'Purchase Options' "
        msgStr += "on the Home screen\n\n"
        msgStr += "(If you have a valid Subscription from another device, use the Restore button)\n\n"
        msgStr += "(If you have just completed a purchase, verification can take a while. Try again in a bit.)"
        let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(ac, animated: true, completion: nil)
    }
    
    func displaySubsExpiredAlert() {
        let titleStr = "Something is wrong with your Subscription"
        var msgStr = "\nYour subscription to PlayTunes has Expired or was Cancelled.\n\n"
        msgStr += "To continue using PlayTunes, go to 'Purchase Options' "
        msgStr += "on the Home screen to extend your subscription\n\n"
        let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(ac, animated: true, completion: nil)
    }
    
    var handlingSectionTap = false
    
    @objc func headerTapped(_ g: UIGestureRecognizer) {
        if self.handlingSectionTap { return }
        
        self.handlingSectionTap = true
        
        let vw = g.view as! LevelSeriesTableViewHeaderFooterView
        let section = vw.section
        
        if !allowAllLevelAccess && (showingTryoutLevel && section > kSectionToDisplayTryoutAt) {
//            if PlayTunesIAPProducts.store.purchaseStatus.confirmed &&
//               PlayTunesIAPProducts.store.purchaseStatus.state == .expired {
            if PlayTunesIAPProducts.store.userDefsStoredSubscStatusIsKnown() &&
               PlayTunesIAPProducts.store.userDefsStoredSubscHasBeenPurchased() {
                displaySubsExpiredAlert()
            } else {
                displayMustPurchaseAlert()
            }
            self.handlingSectionTap = false
            return
        }
        
        //guard section != self.currLevel else { return }
        
        let oldSection = self.currLevel
        self.currLevel = kNoSectionSelected
        
        // collapse current section
        if oldSection != kNoSectionSelected { // all were already collapsed
            let indexSet = IndexSet(integer:oldSection)
            tableView.reloadSections(indexSet, with: .automatic)
        }
        
        if oldSection == section { // They presumably just want to collapse current section.
            self.handlingSectionTap = false
            return
       }
        
        // Otherwise, expand new section
        self.currLevel = section
        delay( 0.25) {
            let indexSetNew = IndexSet(integer: section)
            self.tableView.reloadSections(indexSetNew, with: .automatic)
            if self.numDaysInLevel(level: section) > 0 {
                delay( 0.25) {
                    let idxPath = IndexPath(row:0, section: section)
                    self.tableView.scrollToRow(at: idxPath, at: .top, animated: true)
                    if kSectionToDisplayTryoutAt == section && self.showingTryoutLevel {
                        self.timer.invalidate()
                        delay( 0.5) {
                          self.displayTryoutAlert()
                        }
                    }
                    self.handlingSectionTap = false
                }
            }
            else {
                self.handlingSectionTap = false
            }
        }
    }
    
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
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! LevelSeriesTableViewHeaderFooterView // UITableViewHeaderFooterView
        //header.textLabel?.font = UIFont.(name: "Futura", size: 13)!
//        if allowAllLevelAccess {
//            header.backgroundView?.backgroundColor = kDefaultViewBackgroundColor
//        } else {
//            header.backgroundView?.backgroundColor = kDefaultViewBackgroundColor
//        }
        
        if showingTryoutLevel && kSectionToDisplayTryoutAt == section {
            header.contentView.backgroundColor = tryoutBackgroundColor
            header.textLabel?.textColor = .darkGray
        } else if !allowAllLevelAccess && section >= 2 {
            header.contentView.backgroundColor = kDefault_DisabledSectionBkgrndColor
            header.textLabel?.textColor = .darkGray
        } else {
            header.contentView.backgroundColor = kDefault_SectionBkgrndColor
            header.textLabel?.textColor = .black
        }
    }
    
    func isSelectedCell(indexPath: IndexPath) -> Bool {
//        print ("  in isSelectedCell;  section = \(indexPath.section),  row = \(indexPath.row)")
        if indexPath.section == currLevel && indexPath.row == currDay {
 //           print ("     currLevel = \(currLevel),  currDay = \(currDay); returning->  TRUE")
            return true
        } else {
 //           print ("     currLevel = \(currLevel),  currDay = \(currDay); returning->  FALSE")
           return false
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         if isSelectedCell(indexPath:indexPath) {
             cell.contentView.backgroundColor = kDefault_SelectCellBkgrndColor
        } else {
            cell.contentView.backgroundColor = kDefault_CellBkgrndColor
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = ""
        
        let section = indexPath.section
//        let row = indexPath.row
        
        if gDoLimitLevels && section > kNumberOfLevelsToShow {
            itsBad()
            return cell
        }

 //       print ("in cellForRowAt;  section = \(section),  row = \(row)")
        if isSelectedCell(indexPath:indexPath) {
        // if cell.isSelected {
            cell.contentView.backgroundColor = kDefault_SelectCellBkgrndColor
        } else {
            cell.contentView.backgroundColor = kDefault_CellBkgrndColor
        }
        
        guard levelsJson != nil  else { return cell }

        let jsonIdx = jsonIndexForSection(indexPath.section)
        
        var daysJson:JSON?
        daysJson = levelsJson![jsonIdx]["days"]
        if ( daysJson != nil ) {
            var titleStr = ""
            if let rowTitle = daysJson![indexPath.row]["title"].string {
                titleStr += rowTitle
            }
            cell.textLabel?.text = titleStr
        }
        
        let thisLD: tLD_code = ( jsonIdx, indexPath.row )
        let dayState = LessonScheduler.instance.getDayState(forLD: thisLD)
        
        makeCheckboxIconImage()
        if dayState == kLDEState_Completed {
            cell.imageView?.image = checkImage
        } else {
            cell.imageView?.image = nocheckImage
        }
        cell.imageView?.frame.origin.x += 5
        cell.imageView?.isHidden = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        //Here we are going to seguae to the lesson that the user selected
        //performSegue(withIdentifier: "LessonSegue", sender: indexPath.row)  // PPPproblem!!!!!
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = kDefault_SelectCellBkgrndColor
        
        return indexPath
    }
    

    // For Viedo Testing.  Invoked if kMKDebugOpt_TestVideoViewInLessonOverview is true
    var vhView: VideoHelpView?
    let vhViewTag = 901 // just something unique
    var popVC: PopoverVC?

    func createVideoHelpView() {
        /*  Modal attempt
        if self.popVC == nil {
            let sz = VideoHelpView.getSize()
            let selfViewFrame = self.view.frame
            var selfVwWd = selfViewFrame.size.width
            var selfVwht = selfViewFrame.size.height
            if selfVwht > selfVwWd {
                let tempHt = selfVwht
                selfVwht = selfVwWd
                selfVwWd = tempHt
            }
            let horzSpacing = (selfVwWd - sz.width) / 2
            let x = horzSpacing * 1.75
            let frm = CGRect( x: x, y:40, width: sz.width, height: sz.height )
            self.popVC = PopoverVC.init(rect: frm)
        }
        */

        if self.vhView == nil {
            let sz = VideoHelpView.getSize()
            let horzSpacing = (self.view.frame.width - sz.width) / 2
            let x = horzSpacing * 1.75
            let frm = CGRect( x: x, y:40, width: sz.width, height: sz.height )
            self.vhView = VideoHelpView.init(frame: frm)
            self.vhView?.tag = vhViewTag
            self.view.addSubview(self.vhView!)
        }
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
        let selectedCell:UITableViewCell? = tableView.cellForRow(at: indexPath)!
        selectedCell?.contentView.backgroundColor = kDefault_SelectCellBkgrndColor
        currLevel = indexPath.section
        currDay = indexPath.row
        
        let jsonIdx = jsonIndexForSection(indexPath.section)
        let convertedIndexPath = IndexPath(row: indexPath.row, section: jsonIdx)
        performSegue(withIdentifier: "LessonSegue", sender: convertedIndexPath)  // PPPproblem!!!!!
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard indexPath.section >= 0 && indexPath.section < (levelsJson?.count)! else {
            print ("Unable to get levelsJson in LevelSeriesViewController::didDeselectRowAt")
            return
        }
        
        // var daysJson:JSON?
        let daysJson:JSON? = levelsJson![indexPath.section]["days"]
        guard daysJson != nil  else {
            print ("Unable to get daysJson in LevelSeriesViewController::didDeselectRowAt")
            return
        }
        guard indexPath.row >= 0 && indexPath.row < (daysJson?.count)! else {
            print ("row >= num days in LevelSeriesViewController::didDeselectRowAt")
            return
        }
        
        let myIndexPath = IndexPath(row: currDay, section: currLevel)
        let cellToDeSelectQ:UITableViewCell? = tableView.cellForRow(at: myIndexPath)
        if cellToDeSelectQ != nil {
            cellToDeSelectQ!.contentView.backgroundColor = kDefault_CellBkgrndColor
            print ("-->>>  Completed Deselect option 1 in LevelSeriesViewController::didDeselectRowAt")
        } else {
            print ("unable to get cellToDeSelect option 1 in LevelSeriesViewController::didDeselectRowAt")
        }

        let cellToDeSelectImp:UITableViewCell? = tableView.cellForRow(at: indexPath)
        if cellToDeSelectImp != nil {
            cellToDeSelectImp!.contentView.backgroundColor = kDefault_CellBkgrndColor
            print ("-->>>  Completed Deselect option 2 in LevelSeriesViewController::didDeselectRowAt")
        } else {
            print ("unable to gdt cellToDeSelect  option 2 in LevelSeriesViewController::didDeselectRowAt")
        }
    }
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // PPPproblem!!!!!
        
        if let levels = instrumentJson?["levels"] {
            if let destination = segue.destination as? LevelOverviewViewController {
                if let indexPath = sender as? IndexPath {
                    let level = indexPath.section
                    _ = LessonScheduler.instance.setCurrentLevel(level)
                    destination.thisViewsLevel = level
                    destination.exerLevelIndex = indexPath.row
                    destination.lessonsJson = levels[indexPath.section]["exercises"]
                    let daysJson:JSON? = levels[indexPath.section]["days"]
                    
                    let day = indexPath.row
                    _ = LessonScheduler.instance.setCurrentDay(day)
                    destination.thisViewsLevelDay = day
                    let oneDayExerListStr = daysJson![indexPath.row]["exercises"].string
                    let oneDayExerTitle   = daysJson![indexPath.row]["title"].string
                    destination.dayTitle = (oneDayExerTitle != nil) ? oneDayExerTitle! : ""
                    destination.exercisesListStr = (oneDayExerListStr != nil) ? oneDayExerListStr! : ""

                    destination.thresholdsID         = thresholdsID
                    destination.singleEventThreshold = singleEventThreshold
                    if let threshIDStr = levels[indexPath.section]["thresholdsID"].string {
                       destination.thresholdsID = threshIDStr
                    }
                    if let singEvtThersh = levels[indexPath.section]["singleEventThreshold"].string {
                        destination.singleEventThreshold = singEvtThersh
                    }
                    if let scanForPitchChange = levels[indexPath.section]["scanForPitchLegatoChange"].string {
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
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Create a checkmark image
    func makeCheckboxIconImage() {
        if  checkImage != nil && nocheckImage != nil
        { return }
        
        let imgSz = CGSize(width: 35.0, height: 16.0) // was 20
        UIGraphicsBeginImageContextWithOptions(imgSz, false, 0.0);

        nocheckImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
      
        UIGraphicsBeginImageContextWithOptions(imgSz, false, 0.0);

        let xAdj = 15.0
        
        let checkPathGray = UIBezierPath()
        checkPathGray.lineWidth = 2
        checkPathGray.move(to: CGPoint(x: 2+xAdj, y: 8))         // 2, 9
        checkPathGray.addLine(to:CGPoint(x: 7+xAdj, y: 13))      // 6, 13
        checkPathGray.addLine(to:CGPoint(x: 19+xAdj, y: 2))      // 18, 2

        checkPathGray.lineWidth = 4
        UIColor.darkGray.setStroke()
        checkPathGray.stroke()
        
        let checkPathGreen = UIBezierPath()
        checkPathGreen.lineWidth = 3
        checkPathGreen.move(to: CGPoint(x: 3+xAdj, y: 9))       // 3, 10
        checkPathGreen.addLine(to:CGPoint(x: 7+xAdj, y: 13))     // 6, 13
        checkPathGreen.addLine(to:CGPoint(x: 18+xAdj, y: 3))     // 17, 3
        
        checkPathGreen.lineWidth = 2
        UIColor.green.setStroke()
        checkPathGreen.stroke()
        
        checkImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if checkImage != nil {
            checkImageView = UIImageView(image:checkImage)
        }
    }
}
