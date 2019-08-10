//
//  LevelsViewController.swift
//  PlayTunes-debug
//
//  Created by turtle on 7/1/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//

import UIKit
import SwiftyJSON
import AudioKit

//var gDoOverrideSubsPresent = false      // CHECK_THIS_FOR_SUBMIT
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

    @IBOutlet weak var levelsTableView: UITableView!
    @IBOutlet weak var daysTableView: UITableView!
    @IBOutlet weak var levelsTableViewFooter: UIView!
    
    @IBOutlet weak var daysBackgroundView: UIView!
    
    let particleEmitter = CAEmitterLayer()
    
    // is there a subscription?
    //   - this affects Tryout AND showing upper levels
    var subscriptionGood   = false

    var showingTryoutLevel = true
    
    var activeLevel = 0 {
        didSet {
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
        
        // if !showingTryoutLevel {
            retNumToShow -= 1
        // }
        
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
        
        subscriptionGood = PlayTunesIAPProducts.store.subscriptionGood()
        if subscriptionGood || gDoOverrideSubsPresent || !gDoLimitLevels {
            showingTryoutLevel = false
        }
        
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
        levelsTableView.decelerationRate = UIScrollViewDecelerationRateFast
        
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
        
        assessPurchaseStatus()
        
        levelsTableView.reloadData()
        daysTableView.reloadData()
        
        testBPM()
    }
    
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        createParticles()
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
        var msgStr = "\nYour subscription to PlayTunes has expired or was cancelled.\n\n"
        msgStr += "To continue using PlayTunes, go to 'Purchase Options' "
        msgStr += "on the Home screen to extend your subscription\n\n"
        let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(ac, animated: true, completion: nil)
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
                    _ = LessonScheduler.instance.setCurrentLevel(activeLevel)
                    destination.thisViewsLevel = activeLevel
                    destination.exerLevelIndex = indexPath.row
                    destination.lessonsJson = levels[activeLevel]["exercises"]
                    let daysJson:JSON? = levels[activeLevel]["days"]
                    
                    let day = indexPath.row
                    _ = LessonScheduler.instance.setCurrentDay(day)
                    destination.thisViewsLevelDay = day
                    let oneDayExerListStr = daysJson![indexPath.row]["exercises"].string
                    let oneDayExerTitle   = daysJson![indexPath.row]["title"].string
                    destination.dayTitle = (oneDayExerTitle != nil) ? oneDayExerTitle! : ""
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
            
            if gDoLimitLevels && indexPath.row > kNumberOfLevelsToShow {
                itsBad()
            }
            
            cell.levelNumberLabel.text = String(indexPath.row + 1)
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
            
            cell.dayLabel.text = "Day " + String(indexPath.row + 1)
            
            if isSelectedCell(row: indexPath.row) {
                cell.dayLabel.textColor = .black
            } else {
                cell.dayLabel.textColor = .darkGray
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
            
            // Scroll to tapped level
            
            let yPos = levelsTableView.rectForRow(at: IndexPath(row: indexPath.row, section: 0)).origin.y
            tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: yPos), animated: true)
            activeLevel = indexPath.row
            
        } else if tableView == self.daysTableView {
            
            let selectedCell: DayTableViewCell? = tableView.cellForRow(at: indexPath) as? DayTableViewCell
            selectedCell?.dayLabel.textColor = .black
            currLevel = activeLevel
            currDay = indexPath.row
            
            let jsonIdx = jsonIndexForRow(activeLevel)
            let convertedIndexPath = IndexPath(row: indexPath.row, section: jsonIdx)
            performSegue(withIdentifier: "LessonSegue", sender: convertedIndexPath)  // PPPproblem!!!!!
            
        }
        
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
            
            if !allowAllLevelAccess && (showingTryoutLevel && scrollingToIP.row >= kSectionToDisplayTryoutAt) {
                //            if PlayTunesIAPProducts.store.purchaseStatus.confirmed &&
                //               PlayTunesIAPProducts.store.purchaseStatus.state == .expired {
                
                scrollingToIP.row = kSectionToDisplayTryoutAt - 1
                
                shouldDisplayAlertAfterScroll = true
                
            }
            
            scrollingToRect = levelsTableView.rectForRow(at: scrollingToIP)
            targetContentOffset.pointee.y = scrollingToRect.origin.y
            activeLevel = scrollingToIP.row
            
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.levelsTableView {
            
            let yPosLastRow = levelsTableView.rectForRow(at: IndexPath(row: levelsTableView.numberOfRows(inSection: 0) - 1, section: 0)).origin.y
            
            if scrollView.contentOffset.y > yPosLastRow {
                scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: yPosLastRow), animated: false)
            }
            
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == self.levelsTableView {
            
            if shouldDisplayAlertAfterScroll {
                
                if PlayTunesIAPProducts.store.userDefsStoredSubscStatusIsKnown() &&
                    PlayTunesIAPProducts.store.userDefsStoredSubscHasBeenPurchased() {
                    displaySubsExpiredAlert()
                } else {
                    displayMustPurchaseAlert()
                }
                
                shouldDisplayAlertAfterScroll = false
                
            }
            
        }
        
    }
    
    private func createParticles() {
        
        particleEmitter.emitterPosition = CGPoint(x: daysBackgroundView.frame.minX + 50, y: view.center.y)
        particleEmitter.zPosition = -1.0
        particleEmitter.emitterShape = "rectangle"
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
    
}
