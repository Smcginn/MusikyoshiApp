//
//  LevelOverviewViewController.swift
//  FirstStage
//
//  Created by Caitlyn Chen on 1/22/18.
//  Modified by Scott Freshour
//
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

// Second Level VC, suboridinate to LessonSeriesViewController

import UIKit
import Foundation
import SwiftyJSON

protocol ExerciseResults {
    func setExerciseResults( exerNumber: Int, exerStatus: Int, exerScore: Int)
}

class LevelOverviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ViewFinished, ExerciseResults, PresentingMicCalibVC {
    
    var needToCalibrateMic = true

    var allDoneAlert: MyUIAlertController? = nil
    var launchingNextView: LaunchingNextView?
    var firstExer = true
    var exercisesDone = false
    var paused = false

    // as of 8/29, even tho it's set by presenting VC, this doesn't seem to be used by this file.
    //   It's used in a call to a lsnsched call, but that method doesn't use it . . .
    var exercisesListStr:String = ""    // from the json file; the exers for the day
    
    var exercisesTitle:String = ""      // from the json file; the title for the day
    var exerStrs:[String] = []
    var exerType:ExerciseType = .unknownExer
    var currStarScore: Int = 0
    var dayTitle: String = ""
    
    var thisViewsLevel:    Int = 0
    var thisViewsLevelDay: Int = 0
    func makeLDEForViewsLevelDay( andThisExer: Int ) -> tLDE_code {
        let lde: tLDE_code = (level: thisViewsLevel, day: thisViewsLevelDay, exer: andThisExer)
        return lde
    }
    var thisViewsLD:tLD_code = kLD_NotSet
    func verifyThisViewsLDSet() -> Bool {
        if thisViewsLD.level == kLDE_FldNotSet || thisViewsLD.day == kLDE_FldNotSet  {
            itsBad()
            return false
        }
        return true
    }
	var origDayState = kLDEState_NotStarted
    
    var selectedTuneId: String?
    var selectedTuneName: String?
    var selectedRhythmId: String?
    var selectedRhythmName: String?
    var selectedTitle: String?
    var selectedNoteWidth:Int = 0
    var selectedFrameWidth:Int = 0
    var selectedMagnification:Float = 0.0

    var lessonsJson: JSON?
    var exerLevelIndex: Int = 0
    var exerExerciseIndex: Int = 0
    var exerExerciseTag: String = ""
    
    var thresholdsID: String = ""
    var singleEventThreshold: String = ""
    
    // temp: get rid of when solidified . . .
    var ltNoteID: String = "C4"
    var ltDuration: Double = 2.0

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    
    let noteIds = [55,57,58,60,62,63,65,67,69,70,72]
    var actionNotes = [Note]()
    var selectedNote : Note?
    
    // MARK: - View load, show, hide, etc.
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        // Orientation BS - LevelOverviewVC --> viewWillDisappear
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.orientationLock = .landscapeRight
        AppDelegate.AppUtility.lockOrientationToLandscape()
        //        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight,
        //                                               andRotateTo: UIInterfaceOrientation.landscapeRight)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Orientation BS - LevelOverviewVC --> viewDidLoad
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.orientationLock = .landscapeRight
        AppDelegate.AppUtility.lockOrientationToLandscape()
//        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight,
//                                               andRotateTo: UIInterfaceOrientation.landscapeRight)

        thisViewsLD = (level: thisViewsLevel, day: thisViewsLevelDay)
        _ = verifyThisViewsLDSet()
        
        _ = LessonScheduler.instance.setCurrentLevel(thisViewsLevel)
        _ = LessonScheduler.instance.setCurrentDay(thisViewsLevelDay)

        origDayState = LessonScheduler.instance.calcAllExersInDayState(dayLD: thisViewsLD)
        
        // REDUX
        let exersLoaded = LessonScheduler.instance.loadLevelDay(ld: thisViewsLD)
        if !exersLoaded {
            print("Unable to load exercises in LevelOverviewViewController::viewDidLoad()")
        }
        
        let possCurrLDE = makeLDEForViewsLevelDay(andThisExer: 0)
        var itWorked = true
        if LsnSchdlr.instance.verifyLDE(possCurrLDE) {
            itWorked = LsnSchdlr.instance.setCurrentLDE(toLDE: possCurrLDE)
        } else {
            itsBad()
        }
        useThisToSuppressWarnings(str: "\(itWorked)")

        // now the data is setup, load the tables. . .
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        if actionNotes.count == 0 {
            for nId in noteIds {
                actionNotes.append(NoteService.getNote(nId)!)
            }
        } else {
            print("did load test")
        }
        
        self.view.backgroundColor = kDayOverVw_BackgroundColor
        self.tableView.backgroundColor = kDayOverVw_BackgroundColor

        ThresholdsMgr.instance.setThresholds(thresholdsID: thresholdsID,
                                             ejectorSeatThreshold: singleEventThreshold)
        
        let currBPM: Double = UserDefaults.standard.double(forKey: Constants.Settings.BPM)
        calcAndSetAdjustedRhythmTolerances(bpm: currBPM)
        
        needToCalibrateMic = true
    }
    
    var firstTimeInView = true
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBar.topItem?.title = dayTitle
  //      delay(0.2) {
            self.setupForViewWillAppear()
  //      }
        /*
        if needToCalibrateMic {
            
        }
        
        if firstTimeInView {
            firstTimeInView = false
            self.launchingNextView?.isHidden =  true
            var titleStr = "Press 'GO' to go through a guided practice session"
            titleStr +=    "\n\nPress 'Choose' to pick individual exercises"
            let ac = MyUIAlertController(title: titleStr,
                                       message: "",
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "GO",
                                       style: .default,
                                       handler: startAutoSchedHandler))
            ac.addAction(UIAlertAction(title: "Choose",
                                       style: .default,
                                       handler: nil))
            //ac.view.backgroundColor =  kLightGold
//            ac.view.tintColor = UIColor.green
            ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor

            self.present(ac, animated: true, completion: nil)
       }
        */
       PerformanceAnalysisMgr.instance.printThresholdsInUse()
    }
    
    // DELME
    /*
    func thisorthat()
    {
        if firstTimeInView {
            firstTimeInView = false
            self.launchingNextView?.isHidden =  true
            var titleStr = "Press 'Go' to automatically go through exercises in order"
            titleStr +=    "\n\nPress 'Choose' to select exercises"
            // if !firstTimeInView
            titleStr +=    "(or Exit)"
            let ac = MyUIAlertController(title: "Press 'Go' to automatically go through exercises in order\n\nPress 'Choose' to select exercises",
                                       message: "",
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Go",
                                       style: .default,
                                       handler: startAutoSchedHandler))
            ac.addAction(UIAlertAction(title: "Choose",
                                       style: .default,
                                       handler: nil))
            self.present(ac, animated: true, completion: nil)
        }
    }
    */
    
    func startAutoSchedHandler(_ act: UIAlertAction) {
        print("startAutoSchedHandler  called")
        self.launchingNextView?.isHidden =  false
        self.launchingNextView?.animateMonkeyImageView()
        self.launchingNextView?.mode = kViewFinishedMode_First
    }
    
    func resumeAutoSchedHandler(_ act: UIAlertAction) {
        print("resumeAutoSchedHandler  called")
        self.paused = false
        self.launchingNextView?.isHidden =  false
        self.launchingNextView?.animateMonkeyImageView()
        self.launchingNextView?.mode = kViewFinishedMode_Loading
    }
    
    // may be called in a closure
    func setupForViewWillAppear() {
        if self.launchingNextView == nil {
            let lnvSz = LaunchingNextView.getSize()
            let selfWd = self.view.frame.size.width
            let selfHt = self.view.frame.size.height
            let wdToUse = max(selfHt, selfWd)
            let htToUse = min(selfHt, selfWd)
            //let lnvX   = valToUse - (lnvSz.width + 10.0)
            let lnvX   = wdToUse/2.0 - lnvSz.width/2.0
            var y = CGFloat(41.0)
            if htToUse <= 320 {
                y = 41.0
            } else {
                y = 35.0 + ((htToUse-40.0)/2.0 - lnvSz.height/2.0)
            }
            let lnFrame = CGRect( x: lnvX, y: y, // 47,
                                  width: lnvSz.width, height: lnvSz.height )
            self.launchingNextView = LaunchingNextView.init(frame: lnFrame)
            self.view.addSubview(self.launchingNextView!)
            self.launchingNextView?.setViewFinishedDelegate(del: self)
            self.self.launchingNextView?.isHidden =  true
        }
        
        self.tableView.reloadData()
        if !(self.launchingNextView?.waitingToBegin)! {
            self.launchingNextView?.animateMonkeyImageView()
        }
        
        self.title = "Lesson 1"
        
        // because this is called from a delayed closure
        if firstTimeInView {
            self.launchingNextView?.isHidden =  true
        }

        if (self.launchingNextView?.waitingToBegin)! {
            self.launchingNextView?.mode = kViewFinishedMode_Ready
        } else if self.firstExer {
            self.launchingNextView?.mode = kViewFinishedMode_First
//        } else if self.exercisesDone {
//            delay(2.0) {
//                self.showAllDoneAlerts()
//            }
//            // self.launchingNextView?.mode = kViewFinishedMode_AllDone
        } else {
            self.launchingNextView?.mode = kViewFinishedMode_Loading
        }
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(item: self.currExerNumber,
                                      section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
//        if needToCalibrateMic {
//            goToCalibrateMicVCIfAppropriate()
//        }
        
//        else {
            if firstTimeInView {
                firstTimeInView = false
                self.launchingNextView?.isHidden =  true
                var titleStr = "Press 'GO' to go through a guided practice session"
                titleStr +=    "\n\nPress 'Choose' to pick individual exercises"
                let ac = MyUIAlertController(title: titleStr,
                                             message: "",
                                             preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "GO",
                                           style: .default,
                                           handler: startAutoSchedHandler))
                ac.addAction(UIAlertAction(title: "Choose",
                                           style: .default,
                                           handler: nil))
                //ac.view.backgroundColor =  kLightGold
                //            ac.view.tintColor = UIColor.green
                ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor
                
                self.present(ac, animated: true, completion: nil)
            }
            
            if self.exercisesDone {
     //           delay(2.0) {
                    self.showAllDoneAlert()
    //            }
            }
 //       }  //  else,  of if needToCalibrateMic
    }
    
    /*
    func showAllDoneAlert() {
        guard allDoneFirstTime else { return }
        
        let titleStr = "! Way to Go !"
        let msgStr = "You have finished all the exercises for the day. Next time, you'll do the next day"
        let ac = MyUIAlertController(title: titleStr,
                                     message: msgStr,
                                     preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK!",
                                   style: .default,
                                   handler: doneWithDayHandler))
        ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor
        self.present(ac, animated: true, completion: nil)
    }
    */
    
    func showAllDoneAlert() {
        guard allDoneFirstTime else { return }
        allDoneFirstTime = false
        
        let titleStr = "! Way to Go !"
        
        if !allDoneWithLevelAlso {
            var msgStr = "\nYou have finished all the exercises for this Day!"
            msgStr +=    "\n\nPress 'Done' to go back to Level Overview"
            msgStr +=    "\n\nPress 'Choose' if you want to redo selected exercises (for a better score)"
            let ac = MyUIAlertController(title: titleStr,
                                         message: msgStr,
                                         preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Done",
                                       style: .default,
                                       handler: doneWithDayHandler))
            ac.addAction(UIAlertAction(title: "Choose",
                                       style: .default,
                                       handler: nil))
            ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor
            self.present(ac, animated: true, completion: nil)
            
        } else { // Done with not only this Day, but the entire Level, too
            var msgStr = "\nYou have finished all the exercises for this day, "
            msgStr +=    "and all of the days in this Level, too!"
            msgStr +=    "\n\nPress 'Done' to go back to Level Overview"
            msgStr +=    "\n\nPress 'Choose' if you want to redo selected exercises (for a better score)"
            let ac = MyUIAlertController(title: titleStr,
                                         message: msgStr,
                                         preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Done",
                                       style: .default,
                                       handler: doneWithDayHandler))
            ac.addAction(UIAlertAction(title: "Choose",
                                       style: .default,
                                       handler: nil))
            ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor
            self.present(ac, animated: true, completion: nil)
        }
    }
    
    func showAllDoneAlerts() {
        guard allDoneFirstTime else { return }
        
        let titleStr = "! Way to Go !"
        let msgStr = "You have finished all the exercises for the day. Next time, you'll do the next day"
        let allDoneAlert = MyUIAlertController(title: titleStr,
                                     message: msgStr,
                                     preferredStyle: .alert)
        allDoneAlert.addAction(UIAlertAction(title: "OK!",
                                   style: .default,
                                   handler: doneWithDayHandler))
        allDoneAlert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor
        self.present(allDoneAlert, animated: true, completion: nil)
//        if let rootVC = UIApplication.shared.delegate?.window??.rootViewController {
//            rootVC.present(allDoneAlert, animated: true, completion: nil)
//        } else {
//            print("Root view controller is not set.")
//        }
        return;
/*
        allDoneFirstTime = false
        
        //////////////////
        
        if allDoneWithLevelAlso {
            let titleStr = "! Way to Go !"
            var msgStr = "You can redo exercises you've completed (for a better score)"
            msgStr +=    "\n\nOr Exit to the Levels Screen"
            let ac = MyUIAlertController(title: titleStr,
                                         message: msgStr,
                                         preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Redo Selected Exercises",
                                       style: .default,
                                       handler: doneWithLevelHandler))
            ac.addAction(UIAlertAction(title: "Exit to Levels",
                                       style: .default,
                                       handler: doneWithLevelHandler))
            ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor
            self.present(ac, animated: true, completion: nil)

        }
*/
    }
    
    func doneWithLevelHandler(_ act: UIAlertAction) {
        print("Done With Level!")
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneWithDayHandler(_ act: UIAlertAction) {
        self.dismiss(animated: true, completion: nil)

//        if allDoneWithLevelAlso {
//            let titleStr = "! Way to Go !"
//            var msgStr = "You can redo exercises you've completed (for a btter score)"
//            msgStr +=    "\n\nOr Exit to the Levels Screen"
//            let ac = MyUIAlertController(title: titleStr,
//                                         message: msgStr,
//                                         preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "Redo Selected Exercises",
//                                       style: .default,
//                                       handler: doneWithLevelHandler))
//            ac.addAction(UIAlertAction(title: "Exit to Levels",
//                                       style: .default,
//                                       handler: doneWithLevelHandler))
//            ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor
//            self.present(ac, animated: true, completion: nil)
//            
//        } else {
//            self.dismiss(animated: true, completion: nil)
//        }
    }
    
    // MARK: - Navigation

    let tuneSegueIdentifier = "ShowTuneSegue"
    let longToneSegueIdentifier = "ShowLongToneSegue"
    let rhythmSegueIdentifier = "ShowRhythmSegue"
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier != longToneSegueIdentifier else { return false }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.title = ""
        
        if segue.identifier == tuneSegueIdentifier {
            if let destination = segue.destination as? TuneExerciseViewController {
                destination.exerNumber = currExerNumber
                destination.exerciseName = selectedTuneId!
                destination.navBarTitle = selectedTitle!
                destination.specifiedMag = selectedMagnification
                destination.specifiedNoteWidth = selectedNoteWidth
                destination.specifiedFrameWidth = selectedFrameWidth
                destination.bestStarScore = currStarScore
                destination.exerciseType = exerType
                destination.isTune = true
                destination.callingVCDelegate = self
            }
        } else if segue.identifier == rhythmSegueIdentifier {
            if let destination = segue.destination as? TuneExerciseViewController {
                destination.exerNumber = currExerNumber
                destination.exerciseName = selectedRhythmId!
                destination.navBarTitle = selectedTitle!
                destination.bestStarScore = currStarScore
                destination.isTune = false
                destination.exerciseType = exerType
            }
        }
        else if segue.identifier == longToneSegueIdentifier {
            if let destination = segue.destination as? LongToneViewController {
                destination.exerNumber = currExerNumber
                destination.noteName = self.ltNoteID
                destination.targetTime = self.ltDuration
                destination.targetNoteID = destination.kDb4
                destination.exerLevelIndex = self.exerLevelIndex
                destination.exerExerciseIndex = self.exerExerciseIndex
                destination.exerExerciseTag = self.exerExerciseTag
                destination.callingVCDelegate = self
                destination.exerciseType = exerType
                destination.bestStarScore = currStarScore
           }
        } else if segue.identifier == presentMicCalibVCSegueID {
            if let destination = segue.destination as? MicCalibrationViewController {
                destination.presentingVC = self
            }
        }
    }
    
    @IBAction func unwindToLevelOverviewVC(unwindSegue: UIStoryboardSegue) {
        print("here in unwindToLevelOverviewVC")
    }
    
    func goToCalibrateMicVCIfAppropriate() {
        let mustCalibrate = MicCalibrationViewController.mustCalibrate()
        let calibProblyGood = MicCalibrationViewController.currCalibrationProbablyGood()
        
        if mustCalibrate || !calibProblyGood {
            delay(0.5) {
                self.performSegue(withIdentifier: presentMicCalibVCSegueID,
                                  sender: self)
            }
        }
    }
    
    func returningFromMicCalibVC(didCalibrate: Bool) {
        needToCalibrateMic = false
        print("yoo hoo")
    }

    
    // MARK: - Orientation
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // return .landscapeRight
        
        // override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientationMask.landscapeRight // .rawValue
    }
    
    //    override var shouldAutorotate: Bool {
    //        return true
    //    }
    //
    //    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    //       // return .landscapeRight // | .landscapeLeft
    //
    //       // override func supportedInterfaceOrientations() -> Int {
    //        return UIInterfaceOrientationMask.landscapeRight // .rawValue
    //
    ////        supported
    ////            return Int(supported)
    //        //}
    //
    //    }
    
    // MARK: - Table View Delegate, DataSource Calls

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        _ = verifyThisViewsLDSet()
        let numExers = LessonScheduler.instance.numExercises(ld: thisViewsLD)
        
        return numExers
      }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonItemCell", for: indexPath)
        
         _ = verifyThisViewsLDSet()
        let numExers = LessonScheduler.instance.numExercises(ld: thisViewsLD)
        guard indexPath.row < numExers else { return cell }

        let thisLDE = makeLDEForViewsLevelDay( andThisExer: indexPath.row )
        let cellText = LessonScheduler.instance.getPrettyNameForExercise( forLDE: thisLDE )

        
        
        
        let currLDE = LsnSchdlr.instance.getCurrentLDE()
        let currExerNum = currLDE.exer
        
        let thisExerStarScore = LessonScheduler.instance.getExerStarScore( lde: thisLDE )

        var image : UIImage? = nil
        if indexPath.row == currExerNum {
            image = IconImageMgr.instance.getExerciseIcon(numStars: thisExerStarScore,
                                                          isCurrent: true )
        } else {
            image = IconImageMgr.instance.getExerciseIcon(numStars: thisExerStarScore,
                                                          isCurrent: false )
        }
        
        cell.imageView?.image = image
        cell.textLabel?.text = cellText
        
        if kDayOverVw_DoSetCellBkgrndColor {
            cell.backgroundColor = kDayOverVw_CellBkgrndColor
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  
        var itWorked = true
        let possCurrLDE = makeLDEForViewsLevelDay(andThisExer: indexPath.row)
        if LsnSchdlr.instance.verifyLDE(possCurrLDE) {
            itWorked = LsnSchdlr.instance.setCurrentLDE(toLDE: possCurrLDE)
        } else {
            itsBad()
            // return // now what?
        }
        useThisToSuppressWarnings(str: "\(itWorked)")

        exerType = LsnSchdlr.instance.getCurrExerType()
        loadAndRunCurrentExer()
    }
    
    // MARK: - Misc funcs
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if verifyThisViewsLDSet() {
            let dayState = LessonScheduler.instance.calcAllExersInDayState(dayLD: thisViewsLD)
            LessonScheduler.instance.setDayState(forLD: thisViewsLD, newState: dayState)
            _ = LessonScheduler.instance.saveScoreFile()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func loadAndRunCurrentExer() {
        
        let currExerLDE = LsnSchdlr.instance.getCurrentLDE()
        guard currExerLDE != kLDE_NotSet,
              LsnSchdlr.instance.verifyLDE(currExerLDE)  else {
            itsBad()
            return // now what?
        }
        
        resetExerResults()
        currExerNumber = currExerLDE.exer
        
        let exerCodeStr: String = LsnSchdlr.instance.getExerIDStr(lde: currExerLDE)
        guard exerCodeStr.isNotEmpty else {
            print ("Can't get exerCode for current Exer in loadAndRunCurrentExer()")
            return
        }
        let exerType = getExerciseType( exerCode: exerCodeStr )
        guard exerType != .unknownExer else {
            print ("Can't get ExerType for current Exer in loadAndRunCurrentExer()")
            return
        }
        self.exerType = exerType
        
        currStarScore = 0
        let currExerStatus = LessonScheduler.instance.getExerState(lde: currExerLDE)
        if currExerStatus == kLDEState_Completed {
            currStarScore = LessonScheduler.instance.getExerStarScore(lde: currExerLDE)
        }
        
        if exerType == .longtoneExer || exerType == .longtoneRecordExer {
            var ltInfo:longtoneExerciseInfo
            if exerType == .longtoneExer {
                ltInfo = getLongtoneInfo(forLTCode: exerCodeStr)
            } else { // .longtoneRecordExer
                ltInfo = getLongtoneRecordInfo(forLTCode: exerCodeStr)
            }
            
            ltNoteID = ltInfo.note
            ltDuration = Double(ltInfo.durationSecs)
            performSegue(withIdentifier: longToneSegueIdentifier, sender: self)
        } else {
            // tune of some sort
            let tuneInfo = LsnSchdlr.instance.getTuneFileInfo(forFileCode: exerCodeStr)
            selectedTuneId = String(tuneInfo.xmlFile.dropLast(4))
            selectedRhythmId = String(tuneInfo.xmlFile.dropLast(4))
            selectedTitle = tuneInfo.title
            
            // SCORESIZE
            // These are for debugging; easily see vals coming from json file.
            let noteWidthStr: String = tuneInfo.noteWidth
            selectedNoteWidth = Int(noteWidthStr)!
            let frameWidthStr: String = tuneInfo.frameWidth
            selectedFrameWidth = Int(frameWidthStr)!
            let magStr: String = tuneInfo.magnification
            let magInt:Int = Int(magStr)!
            selectedMagnification = Float(magInt)/10.0
            
            if selectedTuneId != kFieldDataNotDefined {
                performSegue(withIdentifier: tuneSegueIdentifier, sender: self)
            } else {
                itsBad()
            }
        }
    }

    var currExerNumber:Int = 0 // for sanity check - compare against reported results
    
    // This data is set by presented VC (either LongtoneVC or TuneExerciseVC)
    var exerResultsSet = false
    var exerResultsNumber:Int = -1     // sanity check - is this the score for the exer we think?
    var exerResultsStatus:Int = 0      // not started, started, completed, etc.
    var exerResultsScore:Int  = 0      // student's Performance
    func resetExerResults() {
        exerResultsSet    = false
        exerResultsNumber = -1
        exerResultsStatus = 0
        exerResultsScore  = 0
    }
    
    var allDoneFirstTime        = false
    var allDoneWithLevelAlso    = false

    // Longtones or TuneExercise VC calls this with results
    func setExerciseResults( exerNumber: Int,
                             exerStatus: Int,
                             exerScore: Int) {
        let thisLDE = makeLDEForViewsLevelDay(andThisExer: exerNumber)
        
        // compare existing score status, etc., before overwriting
        var doSave = false
        let currExerStatus = LessonScheduler.instance.getExerState( lde: thisLDE )
        if currExerStatus != kLDEState_Completed {
            doSave = true
        } else { // student already did this. Compare scores before overwriting
            let currExerScore = LessonScheduler.instance.getExerStarScore( lde: thisLDE )
            if exerScore > currExerScore {
                doSave = true
            }
        }
        
        if doSave {
            self.exerResultsSet = true
            self.exerResultsNumber = exerNumber
            self.exerResultsStatus = exerStatus
            self.exerResultsScore  = exerScore
            _ = LessonScheduler.instance.updateScoreFields( forLDE: thisLDE,
                                                            rawScore: Float(exerScore),
                                                            starScore:
                                                            exerScore, state: exerStatus  )
            _ = LessonScheduler.instance.saveScoreFile()
        }
    
        // In any case, move on to next exer . . .
        if !LessonScheduler.instance.incrementCurrentLDE() {
            launchingNextView?.isHidden = true
            
            // Student has gone through all exercises.  See if they completed all,
            // or skipped some
            let dayState = LsnSchdlr.instance.calcAllExersInDayState(dayLD: thisViewsLD)
            if dayState != origDayState { // update }
                if dayState == kLDEState_Completed { // just transistioned to this
                    LessonScheduler.instance.setDayState(forLD: thisViewsLD,
                                                         newState: dayState)
                    allDoneFirstTime        = true
 
                    // it's possible they just finished a level, too
                    let lvl = thisViewsLD.level
                    let currLevelState = LsnSchdlr.instance.getLevelState(level: lvl)
                    let nowLevelState =
                        LsnSchdlr.instance.calcAllDaysInLevelState(level: lvl)
                    if currLevelState != nowLevelState &&
                        nowLevelState == kLDEState_Completed  {
                        allDoneWithLevelAlso = true
                        LsnSchdlr.instance.setLevelState(level: lvl,
                                                         newState: nowLevelState)
                    }
                    _ = LessonScheduler.instance.saveScoreFile()
                    
//                    let titleStr = "! Way to Go !"
//                    let msgStr = "You have finished all the exercises for the day. Next time, you'll do the next day"
//                    let ac = MyUIAlertController(title: titleStr,
//                                               message: msgStr,
//                                               preferredStyle: .alert)
//                    ac.addAction(UIAlertAction(title: "OK!",
//                                               style: .default,
//                                               handler: nil))
//                    ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor
//                    self.present(ac, animated: true, completion: nil)
                }
            }
            exercisesDone = true
            
//            let titleStr = "! Way to Go !"
//            let msgStr = "You can redo exercises you've completed (for a btter score)\n\nOr Exit to the Levels Screen"
//            let ac = MyUIAlertController(title: titleStr,
//                                         message: msgStr,
//                                         preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "Redo Exercises",
//                                       style: .default,
//                                       handler: nil))
//            ac.addAction(UIAlertAction(title: "Exit to Levels",
//                                       style: .default,
//                                       handler: nil))
//            ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor
//            self.present(ac, animated: true, completion: nil)
            

            
 //           launchingNextView?.mode = kViewFinishedMode_AllDone
        }
    }
    
    // "Launching View" calls this when done, or if user presses "pause"
    func viewFinished(result: Int) {
        if result == kViewFinished_Proceed {
            if (self.launchingNextView?.waitingToBegin)! {
                self.launchingNextView?.animateMonkeyImageView()
                self.launchingNextView?.mode = kViewFinishedMode_First
            } else if exercisesDone {
                // NOTE update superview of status?
  //              self.dismiss(animated: true, completion: nil)
            } else if paused {
                print ("Yo! Pausededed!")
            } else {
                print ("Yo! Proceed!")
                goToNextExercise()
            }
        } else if result == kViewFinished_Pause  {
            
            self.launchingNextView?.isHidden =  true
            launchPausedDlg()
            
            // ----> Pause button lands here
            
            paused = true
            //self.launchingNextView?.isPaused = true
            //self.launchingNextView?.mode = kViewFinishedMode_Ready
            print ("Yo! Pausededed!")
        } else if result == kViewFinished_UnPause  {
            paused = false
            self.launchingNextView?.isPaused = false
            self.launchingNextView?.mode = kViewFinishedMode_Loading
            print ("Yo! Unpaused!")
            goToNextExercise()

  
        } else {
            print ("Yo! I don't know what to do!")
        }
    }
    
    func launchPausedDlg() {
        var titleStr = "Press 'Resume' to continue guided practice session"
        titleStr +=    "\n\nPress 'Choose' to exit guided practice session\n(and pick individual exercises)"
        let ac = MyUIAlertController(title: titleStr,
                                     message: "",
                                     preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Resume",
                                   style: .default,
                                   handler: resumeAutoSchedHandler))
        ac.addAction(UIAlertAction(title: "Choose",
                                   style: .default,
                                   handler: nil))
        //ac.view.backgroundColor =  kLightGold
        //            ac.view.tintColor = UIColor.green
        ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor
        
        self.present(ac, animated: true, completion: nil)
    }
    
    func goToNextExercise() {
        if firstExer { // first one hasn't been executed yet
            firstExer = false
        }
        if !exercisesDone {
            loadAndRunCurrentExer()
        }
    }
}
