//
//  MicCalibrationViewController.swift
//  FirstStage
//
//  Created by Scott Freshour on 10/19/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import AudioKit

let presentMicCalibVCSegueID = "PresentMicCalibVCSegue2"

protocol PresentingMicCalibVC {
    func returningFromMicCalibVC(didCalibrate: Bool)
}


enum howArrivedInMicCalibVC {
    case viaLevelOverviewVC
}

let kIGuessThatsASound = Double(0.01)

// for checking timeintervals
let minuteIntv: TimeInterval = 60.0
let hourIntv:   TimeInterval = 60.0 * minuteIntv
let dayIntv:    TimeInterval = 24.0 * hourIntv
let weekIntv:   TimeInterval =  7.0 * dayIntv

let kCalibProbablyGoodIntv = minuteIntv     // dayIntv
let kMustCalibIntv         = 3*minuteIntv   // weekIntv

class MicCalibrationViewController: UIViewController {
    
    var currStoredMmaxPlayingVolume: Double = 0.0
    var playingVolumeSoundThreshold: Double = 0.02
    var lastPlayingVolumeCheckDate: TimeInterval = 0.0 // Date.timeIntervalSinceReferenceDate
    
    
    var needToAskAboutRecalibrate = true    // May be okay, but need to ask
    var needToRecalibrate = true            // Need to do it, don't even ask
    var forceCalibration  = false           // set by Settings screen

    var calibrateTime = 6.0        // duration of testing
    var amplitudeSampleRate = 0.01

    var timer = Timer()

    var startTime = Date()
    //    var exerStartTime = Date()
    var actualStartTime = Date()

    var maxAmplitude = 0.0
    
    var presentingVC: PresentingMicCalibVC? = nil
    
    // delme var howIGotHere = howArrivedInMicCalibVC.viaLevelOverviewVC
    
    var listening = false
    var calibrated = false

    @IBOutlet weak var BeginPlayingBtn: UIButton!
    @IBOutlet weak var SkipCalibrationBtn: UIButton!
    
    @IBOutlet weak var PlayAt_Label1: UILabel!
    @IBOutlet weak var PlayAt_Label2: UILabel!
    @IBOutlet weak var redSquareBtn: UIButton!
    @IBOutlet weak var AmplitudePregressBar: UIProgressView!
    
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var maxAmplitudeLabel: UILabel!
    @IBAction func resetBtnPressed(_ sender: Any) {
        maxAmplitude = 0.0
        maxAmplitudeLabel.text = String(format: "%.2f", maxAmplitude)
    }
    
    @IBOutlet weak var getSetupLabel1: UILabel!
    @IBOutlet weak var getSetupLabel2: UILabel!
    
    static func currCalibrationProbablyGood() -> Bool {
        let calProbGood = true
/* need to restore
        let lastPlayingVolCheckDate =
            UserDefaults.standard.double(forKey: Constants.Settings.LastPlayingVolumeCheckDate)
        let nowTIntv = Date.timeIntervalSinceReferenceDate
        let storedPlusOKTime = lastPlayingVolCheckDate + kCalibProbablyGoodIntv
        if nowTIntv > storedPlusOKTime {
            // Then it's been more than the "OK Time" since we did claibration . . .
            calProbGood = false
        }
 */
        return calProbGood
    }

    static func mustCalibrate() -> Bool {
        let mustCalib = false
/* need to restore
        let lastPlayingVolCheckDate =
            UserDefaults.standard.double(forKey: Constants.Settings.LastPlayingVolumeCheckDate)
        let nowTIntv = Date.timeIntervalSinceReferenceDate
        let storedPlusOKTime = lastPlayingVolCheckDate + kMustCalibIntv
        if nowTIntv > storedPlusOKTime {
            // Then it's been more than the "OK Time" since we did claibration . . .
            mustCalib = true
        }
 */
        return mustCalib
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Orientation BS - LevelOverviewVC --> viewDidLoad
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.orientationLock = .landscapeRight
        AppDelegate.AppUtility.lockOrientationToLandscape()
        
        resetBtn.isHidden = !gMKDebugOpt_ShowResetBtnInMicCalibScene
        
        self.PlayAt_Label1.alpha = 0.0
        self.PlayAt_Label2.alpha = 0.0
        AmplitudePregressBar.alpha = 0.0
       // PlayAt_Label1.isHidden = true
        //PlayAt_Label2.isHidden = true
       // AmplitudePregressBar.isHidden = true
        AmplitudePregressBar.progress = 0.0
        redSquareBtn.isHidden = true
        redSquareBtn.alpha = 0.0

        // need to restore these
        /*
        currStoredMmaxPlayingVolume =
            UserDefaults.standard.double(forKey: Constants.Settings.MaxPlayingVolume)
        playingVolumeSoundThreshold =
            UserDefaults.standard.double(forKey: Constants.Settings.PlayingVolumeSoundThreshold)
        lastPlayingVolumeCheckDate =
            UserDefaults.standard.double(forKey: Constants.Settings.LastPlayingVolumeCheckDate)
        */
        
        needToRecalibrate = MicCalibrationViewController.mustCalibrate()
        if needToRecalibrate || forceCalibration {
            needToAskAboutRecalibrate = true
        } else {
            needToAskAboutRecalibrate = !MicCalibrationViewController.currCalibrationProbablyGood()
        }
        
       // needToAskAboutRecalibrate = MicCalibrationViewController.currCalibrationProbablyGood()
        /*
        let nowTIntv = Date.timeIntervalSinceReferenceDate
        let storedPlusOKTime = lastPlayingVolumeCheckDate + dayIntv
        if nowTIntv > storedPlusOKTime {
            // Then it's been more than the "OK Time" since we did claibration . . .
            needToAskAboutRecalibrate = true
        } else {
            needToAskAboutRecalibrate = false
        }
         */
    }
    
//    static func currentCalibrationGood() -> Bool {
//        var retVal = true
//        let lastPlayingVolCheckDate =
//            UserDefaults.standard.double(forKey: Constants.Settings.LastPlayingVolumeCheckDate)
//        let nowTIntv = Date.timeIntervalSinceReferenceDate
//        let storedPlusOKTime = lastPlayingVolCheckDate + dayIntv
//        if nowTIntv > storedPlusOKTime {
//            // Then it's been more than the "OK Time" since we did claibration . . .
//            retVal = true
//        }
//        return retVal
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        AmplitudePregressBar.bounds.size.width  += 10.0
        AmplitudePregressBar.bounds.size.height += 10.0
        AmplitudePregressBar.frame.size.width  += 10.0
        AmplitudePregressBar.frame.size.height += 10.0
        AmplitudePregressBar.transform =
                        AmplitudePregressBar.transform.scaledBy(x: 1, y: 5)
        maxAmplitudeLabel.text = String(format: "%.2f", maxAmplitude)
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        // Orientation BS - LevelOverviewVC --> viewWillDisappear
        let appDel = UIApplication.shared.delegate as! AppDelegate
        if forceCalibration {
            appDel.orientationLock = .portrait
            AppDelegate.AppUtility.lockOrientationToPortrait()
        } else {
            appDel.orientationLock = .landscapeRight
            AppDelegate.AppUtility.lockOrientationToLandscape()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !needToRecalibrate && needToAskAboutRecalibrate {
            let titleStr = "Has Anything Changed Since the Last Calibration?"
            var msgStr = "\nIf nothing has changed (the room, instrument, your playing ability, etc.), press 'Skip' to Skip calibration\n\n"
            msgStr += "If you think you should calibrate once more, press 'Calibrate'"
            let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Skip", style: .cancel, handler: allDoneHandler))
            ac.addAction(UIAlertAction(title: "Calibrate", style: .default, handler: nil))
            
            self.present(ac, animated: true, completion: nil)
        }
    }
    
    @IBAction func WhyBtnPressed(_ sender: Any) {
        let titleStr = "Why do we need to calibrate the microphone?"
        var msgStr = "Everyone's phone, instrument, room acoustics, and playing are different.\n\n"
        msgStr += "We need to get a sense of your practice volume so we can accurately decide when you are playing, and when you are not playing (what is just room noise, breaths, etc.)."
        let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        self.present(ac, animated: true, completion: nil)
    }
    
    @IBAction func BackBtnPressed(_ sender: Any) {
        if presentingVC != nil {
            presentingVC!.returningFromMicCalibVC(didCalibrate: false)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func BeginPlayingBtnPressed(_ sender: Any) {
        listening = !listening
        self.BeginPlayingBtn.isHidden = true
        if listening {
            redSquareBtn.isHidden = false
            AmplitudePregressBar.progress = 0.0
            startCalibrating()
            self.BeginPlayingBtn.setTitle(NSLocalizedString("Done Playing",
                                                            comment: ""),
                                                            for: .normal)
            showSoundTrackingControls()
            /*
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
                //self.PlayAt_Label1.isHidden = false
                //self.PlayAt_Label2.isHidden = false
                self.PlayAt_Label1.alpha = 1.0
                self.PlayAt_Label2.alpha = 1.0
                self.AmplitudePregressBar.alpha = 1.0
                self.getSetupLabel1.alpha = 0.0
                self.getSetupLabel2.alpha = 0.0
                //self.AmplitudePregressBar.isHidden = false
//                self.getSetupLabel1.isHidden = true
//                self.getSetupLabel2.isHidden = true
                //BeginPlayingBtn.titleLabel?.text = "Done Playing"
                self.redSquareBtn.alpha = 1.0
             })
             */
       } else {
            stopCalibrating(launchHowWasItAlert: false)
            AmplitudePregressBar.progress = 0.0
            self.BeginPlayingBtn.setTitle(NSLocalizedString("Begin Playing",
                                                            comment: ""),
                                                            for: .normal)
            BeginPlayingBtn.isHidden = true
            hideSoundTrackingControls()
            /*
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
                //self.PlayAt_Label1.isHidden = true
                //self.PlayAt_Label2.isHidden = true
                self.PlayAt_Label1.alpha = 0.0
                self.PlayAt_Label2.alpha = 0.0
                self.AmplitudePregressBar.alpha = 0.0
                self.getSetupLabel1.alpha = 1.0
                self.getSetupLabel2.alpha = 1.0
                self.redSquareBtn.alpha = 0.0
                //self.AmplitudePregressBar.isHidden = true
//                self.getSetupLabel1.isHidden = false
//                self.getSetupLabel2.isHidden = false
                //BeginPlayingBtn.titleLabel?.text = "Begin Playing"
            })
            */
        }
    }
    
    @IBAction func SkipCalibrationBtnPressed(_ sender: Any) {
        let titleStr = "Do You Really Want to \nSkip Calibration?"
        var msgStr = "\nWe didn't determine your playing volume.\n\n"
        msgStr += "(The app can use default values, which may or may not be correct, but it would be better to calibrate)"
        let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Skip", style: .cancel, handler: allDoneHandler))
        ac.addAction(UIAlertAction(title: "Calibrate", style: .default, handler: nil))
        
        self.present(ac, animated: true, completion: nil)

        
//        if presentingVC != nil {
//            presentingVC!.returningFromMicCalibVC(didCalibrate: false)
//        }
//        self.dismiss(animated: true, completion: nil)
        
//        if howIGotHere == .viaLevelOverviewVC {
//            self.performSegue(withIdentifier: "unwindToLevelOverviewVC", sender: self)
//        }
    }
    
    func showSoundTrackingControls() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
            //self.PlayAt_Label1.isHidden = false
            //self.PlayAt_Label2.isHidden = false
            self.PlayAt_Label1.alpha = 1.0
            self.PlayAt_Label2.alpha = 1.0
            self.AmplitudePregressBar.alpha = 1.0
            self.getSetupLabel1.alpha = 0.0
            self.getSetupLabel2.alpha = 0.0
            //self.AmplitudePregressBar.isHidden = false
            //                self.getSetupLabel1.isHidden = true
            //                self.getSetupLabel2.isHidden = true
            //BeginPlayingBtn.titleLabel?.text = "Done Playing"
            self.redSquareBtn.alpha = 1.0
        })
    }

    func hideSoundTrackingControls() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
            //self.PlayAt_Label1.isHidden = true
            //self.PlayAt_Label2.isHidden = true
            self.PlayAt_Label1.alpha = 0.0
            self.PlayAt_Label2.alpha = 0.0
            self.AmplitudePregressBar.alpha = 0.0
            self.getSetupLabel1.alpha = 1.0
            self.getSetupLabel2.alpha = 1.0
            self.redSquareBtn.alpha = 0.0
            //self.AmplitudePregressBar.isHidden = true
            //                self.getSetupLabel1.isHidden = false
            //                self.getSetupLabel2.isHidden = false
            //BeginPlayingBtn.titleLabel?.text = "Begin Playing"
        })
    }
    
    func startCalibrating() {
        startTime = Date()
        _ = AVAudioSessionManager.sharedInstance.setupAudioSession(sessionMode: .usingMicMode)
        timer = Timer.scheduledTimer(
                timeInterval: amplitudeSampleRate,
                target: self,
                selector: #selector(MicCalibrationViewController.updateTracking),
                userInfo: nil,
                repeats: true)
    }
    
    func stopCalibrating(launchHowWasItAlert: Bool) {
        hideSoundTrackingControls()
        UIView.animate(withDuration: 0.5,   delay: 0.0,
                       options: .curveLinear,  animations: {
            self.redSquareBtn.alpha = 0.0
        })
        timer.invalidate()
        delay(0.2) {
            self.AmplitudePregressBar.progress = 0.0
            self.AmplitudePregressBar.setNeedsDisplay()
            if launchHowWasItAlert {
                self.displayHowWasThatAlert()
            }
        }
    }
    
    @objc func updateTracking()
    {
        let timeSinceCalibStart = Date().timeIntervalSince(startTime)
        // if Date().timeIntervalSince(startTime) > calibrateTime {
        if timeSinceCalibStart > calibrateTime {
            // we're done!
            stopCalibrating(launchHowWasItAlert: true)
        }

        var amplitude = 0.0
        if AudioKitManager.sharedInstance.frequencyTracker != nil {
            amplitude = AudioKitManager.sharedInstance.frequencyTracker.amplitude
        }
        if amplitude > maxAmplitude {
            maxAmplitude = amplitude
            maxAmplitudeLabel.text = String(format: "%.2f", maxAmplitude)
        }
        printAmplitude(currAmp: amplitude, at: timeSinceCalibStart, atComp: timeSinceCalibStart)
        
        if maxAmplitude > kIGuessThatsASound {
            calibrated = true
        }
        
        let dispAmp = (0.0...1.0).clamp(amplitude)
        AmplitudePregressBar.progress = Float(dispAmp)

    }
    
    func displayHowWasThatAlert() {
        let titleStr = "How was that?"
        var msgStr = "\nIf you felt like that was the volume you'll be playing at, press 'OK'\n\n"
        msgStr += "If you think you should do it again, press 'Again' when you're ready to play"
        let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: allDoneAndSaveHandler))
        ac.addAction(UIAlertAction(title: "Again", style: .default, handler: againHandler))
        
        self.present(ac, animated: true, completion: nil)
    }
    
    /*
    func displayHasAnythingChangedAlert() {
        let titleStr = "Has Anything Changed Since the Last Calibration?"
        var msgStr = "\nIf nothing has changed (the room, instrument, your playing ability, etc.), press 'OK' to Skip calibration\n\n"
        msgStr += "If you think you should calibrate once more, press 'Again' when you're ready to play"
        let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "No Change", style: .cancel, handler: allDoneHandler))
        ac.addAction(UIAlertAction(title: "Again", style: .default, handler: againHandler))
        
        self.present(ac, animated: true, completion: nil)
    }
    */
    
    func allDoneHandler(_ act: UIAlertAction) {
        print("All done!")
        if presentingVC != nil {
            presentingVC!.returningFromMicCalibVC(didCalibrate: false)
        }
        
        if forceCalibration && self.navigationController != nil {
            //self.navigationController?.popToRootViewController(animated: true)
            self.navigationController?.popToViewController(presentingVC as! UIViewController, //SettingsTableViewController,
                                                           animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func allDoneAndSaveHandler(_ act: UIAlertAction) {
        print("All done!")
        saveData()
        if presentingVC != nil {
            presentingVC!.returningFromMicCalibVC(didCalibrate: false)
        }
        if forceCalibration && self.navigationController != nil {
            //self.navigationController?.popToRootViewController(animated: true)
            self.navigationController?.popToViewController(presentingVC as! UIViewController, //SettingsTableViewController,
                animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func againHandler(_ act: UIAlertAction) {
        print("Again!")
        redSquareBtn.isHidden = false
        AmplitudePregressBar.progress = 0.0
        startCalibrating()
        showSoundTrackingControls()
    }
    
    func okayToExit() -> Bool {
        return calibrated
    }
    
    func saveData() {
/* Need to restore these:
        let nowTIntv = Date.timeIntervalSinceReferenceDate
        UserDefaults.standard.set(nowTIntv, forKey: Constants.Settings.LastPlayingVolumeCheckDate)

        UserDefaults.standard.set(maxAmplitude, forKey: Constants.Settings.MaxPlayingVolume)
 */
    }
    
    
    // start AudioSession
    
    // stop AudioSession

    // start timer
    // stop timer

    // get amplitude
    // track
    
    // save maximum amplitude
    // save date and time max amplitude set.
    
}
