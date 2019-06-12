//
//  HomeViewController.swift
//  FirstStage
//
//  Created by John Cook on 10/5/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController, UITextFieldDelegate {
    
    // action for this is embedded in Mian SB as an invoke segue action
//    @IBOutlet weak var shareButton: UIBarButtonItem!
    
//    @IBAction func shareButtonTapped(sender: UIButton) {
//        let textToShare = "Check out the Musikyoshi app!"
//
//        if let appListing = NSURL(string: "https://itunes.apple.com/us/app/monkey-tones/id1132920269?mt=8") {
//            let objectsToShare = [textToShare, appListing] as [Any]
//            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//
//            // excluded activities code
//            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
//
//            activityVC.popoverPresentationController?.sourceView = sender
//            self.present(activityVC, animated: true, completion: nil)
//        }
//    }
    
    @IBOutlet weak var LessonsBtn: UIButton!
    @IBOutlet weak var OverviewBtn: UIButton!
    @IBOutlet weak var purchaseOptionsBtn: UIButton!
    
    @IBOutlet weak var hiddenPswdTextField: UITextField!
    
    var didDisplayOverview = false
    
    @IBAction func LessonsBtnPressed(_ sender: Any) {
    }
    
    @IBAction func OverviewBtnPressed(_ sender: Any) {
        displayWellcomeVC()
    }
    
    @IBOutlet weak var debugStuffOnBtn: UIButton!
    var numTimesDebugStuffOnTapped = 0
    @IBAction func debugStuffOnPressed(_ sender: Any) {
        numTimesDebugStuffOnTapped += 1
        if numTimesDebugStuffOnTapped >= 5 {
            gMKDebugOpt_HomeScreenDebugOptionsEnabled = true
            debugStuffOnBtn.isHidden = false
            debugStuffOnBtn.isOpaque = true
            debugStuffOnBtn.titleLabel?.isHidden = false
            debugStuffOnBtn.titleLabel?.textColor = UIColor.green
            debugStuffOnBtn.backgroundColor =
                (UIColor.lightGray).withAlphaComponent(1.0)
            debugStuffOnBtn.setTitleColor(UIColor.blue, for: .normal)
            gMKDebugOpt_ShowDebugSettingsBtn = true
            gMKDebugOpt_ShowFakeScoreInLTAlert = true
            gMKDebugOpt_ShowSlidersBtn = true
            gMKDebugOpt_ShowResetBtnInMicCalibScene = true
            gMKDebugOpt_IsSoundAndLatencySettingsEnabled = true
        }
    }
    
    var numTimesSettingsEnabledTapped = 0
    var settingsEnblBtnBckgrndColor = UIColor.clear
    @IBOutlet weak var settingEnabledBtn: UIButton!
    @IBAction func settingEnabledBtnPressed(_ sender: Any) {
        numTimesSettingsEnabledTapped += 1
        if numTimesSettingsEnabledTapped >= 10 {
            settingEnabledBtn.isOpaque = true
            settingEnabledBtn.titleLabel?.textColor = UIColor.green
            settingsEnblBtnBckgrndColor = .lightGray
            settingEnabledBtn.backgroundColor = settingsEnblBtnBckgrndColor
            settingEnabledBtn.setTitleColor(UIColor.blue, for: .normal)
            gMKDebugOpt_IsSoundAndLatencySettingsEnabled = true
        }
        if numTimesSettingsEnabledTapped >= 15 {
            hiddenPswdTextField.isHidden = false
            hiddenPswdTextField.isEnabled = true
            hiddenPswdTextField.keyboardType = .default
            hiddenPswdTextField.becomeFirstResponder()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print ("yo")
        let response = hiddenPswdTextField.text
        
        // must match the dev password
        if response == "EULA" {
            settingEnabledBtn.isOpaque = true
            settingEnabledBtn.titleLabel?.textColor = UIColor.green
            settingsEnblBtnBckgrndColor = .magenta
            settingEnabledBtn.backgroundColor = settingsEnblBtnBckgrndColor
            settingEnabledBtn.setTitleColor(UIColor.blue, for: .normal)
            gDoOverrideSubsPresent = true
            gDoLimitLevels = false
        }
        
        hiddenPswdTextField.isHidden = true
        hiddenPswdTextField.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if gMKDebugOpt_HomeScreenDebugOptionsEnabled {
            debugStuffOnBtn.isHidden = false
            debugStuffOnBtn.isEnabled = true
            debugStuffOnBtn.isOpaque = true
            debugStuffOnBtn.titleLabel?.textColor = UIColor.green
            debugStuffOnBtn.titleLabel?.isHidden = false
            debugStuffOnBtn.setTitleColor(UIColor.blue, for: .normal)
            debugStuffOnBtn.backgroundColor =
                (UIColor.lightGray).withAlphaComponent(1.0)
        } else {
            debugStuffOnBtn.isHidden = false
            debugStuffOnBtn.isEnabled = true
            debugStuffOnBtn.isOpaque = false
            debugStuffOnBtn.titleLabel?.isHidden = true
            debugStuffOnBtn.titleLabel?.textColor = UIColor.clear
            debugStuffOnBtn.setTitleColor(UIColor.clear, for: .normal)
            debugStuffOnBtn.backgroundColor =
                (UIColor.lightGray).withAlphaComponent(0.0)
        }
        
        settingEnabledBtn.backgroundColor = settingsEnblBtnBckgrndColor
        if gMKDebugOpt_IsSoundAndLatencySettingsEnabled {
            settingEnabledBtn.isHidden = false
            settingEnabledBtn.isEnabled = true
            settingEnabledBtn.isOpaque = true
            settingEnabledBtn.titleLabel?.textColor = UIColor.green
            settingEnabledBtn.titleLabel?.isHidden = false
            settingEnabledBtn.setTitleColor(UIColor.blue, for: .normal)
//            settingEnabledBtn.backgroundColor =
//                (UIColor.lightGray).withAlphaComponent(1.0)
        } else {
            settingEnabledBtn.isHidden = false
            settingEnabledBtn.isEnabled = true
            settingEnabledBtn.isOpaque = false
            settingEnabledBtn.titleLabel?.isHidden = true
            settingEnabledBtn.titleLabel?.textColor = UIColor.clear
            settingEnabledBtn.setTitleColor(UIColor.clear, for: .normal)
//            settingEnabledBtn.backgroundColor =
//                (UIColor.lightGray).withAlphaComponent(0.0)
       }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
        numTimesDebugStuffOnTapped = 0
        numTimesSettingsEnabledTapped = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let _ = LsnSchdlr.instance.scoreMgr.getAvailableDiscSpace()
        let _ = LsnSchdlr.instance.scoreMgr.getScoreFileSize()
        
        let appJsonDataVersion =
            LsnSchdlr.instance.scoreMgr.getInstrumentJsonVersion()
        let versionsEqual =
            LsnSchdlr.instance.scoreMgr.isJsonVersionEqual(versionTuple: appJsonDataVersion)
        if (!versionsEqual) {
// HEY !!!!            displayDBCompatibilityAlert()
        }
        
        if !didDisplayOverview {
            displayWellcomeVC()
            didDisplayOverview = true
        }
        
        settingEnabledBtn.backgroundColor = settingsEnblBtnBckgrndColor
        hiddenPswdTextField.isHidden = true
    }
    
    let showWellcomeVCSegueID = "showWellcomeVCSegue"
    func displayWellcomeVC() {
        performSegue(withIdentifier: showWellcomeVCSegueID, sender: nil)
    }
    
    func deleteCurrentDBAndRebuild(_ act: UIAlertAction) {
        let fileIsGone = LsnSchdlr.instance.scoreMgr.deleteCurrentScoreFile()
        
        if fileIsGone {
            // This will create an empty file using the levels/exercises JSON  as the template.
            _ = LessonScheduler.instance.loadScoreFile()
        }
    }

    func displayDBCompatibilityAlert() {
        let titleStr = "Sorry, but your current Score File must be overwritten"
        let msgStr = "\nYou are upgrading from an older (Beta) version of PlayTunes, and your current Score File is incompatible with this version. \n\nUnfortunately, your previous scores will be lost."
        let ac = MyUIAlertController(title: titleStr,
                                     message: msgStr,
                                     preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK",
                                   style: .default,
                                   handler: deleteCurrentDBAndRebuild))
        ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor
        
        self.present(ac, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hiddenPswdTextField.delegate = self
        
    }
    
    @IBAction func unwindToHomeVC(unwindSegue: UIStoryboardSegue) {
        print("here in unwindToHomeVC")
    }
    
}
