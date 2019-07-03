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
//// This is the artificial level number to display the tryput section at (it is not
//// the order in the json file). We show this if they don't have a subscription.
//let kSectionToDisplayTryoutAt: Int = 2
//
//// In the JSON file, this is the number of Tryout Level
//let kTryoutUpperValInJson: Int = 1000

class LevelsViewController: UIViewController {

    @IBOutlet weak var levelsTableView: UITableView!
    @IBOutlet weak var daysTableView: UITableView!
    @IBOutlet weak var levelsTableViewFooter: UIView!
    
    @IBOutlet weak var daysBackgroundView: UIView!
    
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
    
    var checkImage: UIImage? = nil
    var nocheckImage: UIImage? = nil
    var checkImageView: UIImageView? = nil
    
    var instrumentJson: JSON?
    var levelsJson: JSON?
    
    var thresholdsID         = kThershIDsStr_Begin_1
    var singleEventThreshold = kSingleEventThreshDefaultStr
    
    let kNoSectionSelected = -1
    var currLevel:Int = 0
    var currDay = 0
    
    var allowAllLevelAccess = false
    
    var timer = Timer()
    
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
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        assessPurchaseStatus()
        
        //tableView.reloadData()
        
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
        var msgStr = "\nYour subscription to PlayTunes has Expired or was Cancelled.\n\n"
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
    
}

extension LevelsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.levelsTableView {
            return numLevelsToShow()
        } else if tableView == self.daysTableView {
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
            
            return cell
            
        } else {
            
            let cell: DayTableViewCell = tableView.dequeueReusableCell(withIdentifier: "daysCell", for: indexPath) as! DayTableViewCell
            
            cell.dayLabel.text = "Day " + String(indexPath.row + 1)
            
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
            scrollingToRect = levelsTableView.rectForRow(at: scrollingToIP)
            targetContentOffset.pointee.y = scrollingToRect.origin.y
            
            activeLevel = scrollingToIP.row
            
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.levelsTableView {
            
            let yPosLastRow = levelsTableView.rectForRow(at: IndexPath(row: levelsTableView.numberOfRows(inSection: 0) - 1, section: 0)).origin.y
            
            if scrollView.contentOffset.y > yPosLastRow {
                scrollView.contentOffset.y = yPosLastRow
            }
            
        }
        
    }
    
}
