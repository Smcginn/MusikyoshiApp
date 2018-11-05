//
//  HomeViewController.swift
//  FirstStage
//
//  Created by John Cook on 10/5/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
        
    @IBOutlet weak var startLessonBtn: UIButton!
    
    // action for this is embedded in Mian SB as an invoke segue action
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBAction func shareButtonTapped(sender: UIButton) {
        let textToShare = "Check out the Musikyoshi app!"
        
        if let appListing = NSURL(string: "https://itunes.apple.com/us/app/monkey-tones/id1132920269?mt=8") {
            let objectsToShare = [textToShare, appListing] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            // excluded activities code
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var progressPanelView: UIView!
    
    @IBOutlet weak var LessonsBtn: UIButton!
    @IBOutlet weak var ResumePracticeSessionBtn: UIButton!
    @IBOutlet weak var OverviewBtn: UIButton!
    @IBOutlet weak var MyProfileBtn: UIButton!
    @IBOutlet weak var ChallengeBtn: UIButton!
    
    @IBAction func LessonsBtnPressed(_ sender: Any) {
    }
    
    @IBAction func ResumePracticeSessionBtnPressed(_ sender: Any) {
    }
    
    @IBAction func OverviewBtnPressed(_ sender: Any) {
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
    
    @IBOutlet weak var settingEnabledBtn: UIButton!
    var numTimesSettingsEnabledTapped = 0
    @IBAction func settingEnabledBtnPressed(_ sender: Any) {
        numTimesSettingsEnabledTapped += 1
        if numTimesSettingsEnabledTapped >= 5 {
            settingEnabledBtn.isOpaque = true
            settingEnabledBtn.titleLabel?.textColor = UIColor.green
            settingEnabledBtn.backgroundColor =
                (UIColor.lightGray).withAlphaComponent(1.0)
            settingEnabledBtn.setTitleColor(UIColor.blue, for: .normal)
            gMKDebugOpt_IsSoundAndLatencySettingsEnabled = true
        }
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
        
        if gMKDebugOpt_IsSoundAndLatencySettingsEnabled {
            settingEnabledBtn.isHidden = false
            settingEnabledBtn.isEnabled = true
            settingEnabledBtn.isOpaque = true
            settingEnabledBtn.titleLabel?.textColor = UIColor.green
            settingEnabledBtn.titleLabel?.isHidden = false
            settingEnabledBtn.setTitleColor(UIColor.blue, for: .normal)
            settingEnabledBtn.backgroundColor =
                (UIColor.lightGray).withAlphaComponent(1.0)
        } else {
            settingEnabledBtn.isHidden = false
            settingEnabledBtn.isEnabled = true
            settingEnabledBtn.isOpaque = false
            settingEnabledBtn.titleLabel?.isHidden = true
            settingEnabledBtn.titleLabel?.textColor = UIColor.clear
            settingEnabledBtn.setTitleColor(UIColor.clear, for: .normal)
            settingEnabledBtn.backgroundColor =
                (UIColor.lightGray).withAlphaComponent(0.0)
       }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        numTimesDebugStuffOnTapped = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let appJsonDataVersion =
            LsnSchdlr.instance.scoreMgr.getInstrumentJsonVersion()
        let versionsEqual =
            LsnSchdlr.instance.scoreMgr.isJsonVersionEqual(versionTuple: appJsonDataVersion)
        if (!versionsEqual) {
            displayDBCompatibilityAlert()
        }
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
        
        self.view.backgroundColor = kDefaultViewBackgroundColor
        progressPanelView.isHidden = true
        
        // Lessons Button
        LessonsBtn.roundedButton()
        LessonsBtn.backgroundColor = kDefault_ButtonBckgrndColor
        let lessonsTxt = createAttributedText(str: "Lessons",
                                              fontSize: 18)
        LessonsBtn.titleLabel?.attributedText = lessonsTxt
        LessonsBtn.setTitleColor(kDefault_ButtonTextColor, for: .normal)
        
        // Resume Practice Session Button
        ResumePracticeSessionBtn.isEnabled = false
        ResumePracticeSessionBtn.roundedButton()
        ResumePracticeSessionBtn.backgroundColor = kDefault_ButtonBckgrndColor
        let resumeTxt = createAttributedText(str: "Resume Practice Session",
                                              fontSize: 16)
        ResumePracticeSessionBtn.titleLabel?.attributedText = resumeTxt
        ResumePracticeSessionBtn.setTitleColor(UIColor.lightText, for: .disabled)
        
        // Overview Button
        OverviewBtn.isEnabled = false
        OverviewBtn.roundedButton()
        OverviewBtn.backgroundColor = kDefault_ButtonBckgrndColor
        let overviewTxt = createAttributedText(str: "Overview",
                                               fontSize: 16)
        OverviewBtn.titleLabel?.attributedText = overviewTxt
        OverviewBtn.setTitleColor(UIColor.lightText, for: .disabled)
        
        // My Profile Button
        MyProfileBtn.isEnabled = false
        MyProfileBtn.roundedButton()
        MyProfileBtn.backgroundColor = kDefault_ButtonBckgrndColor
        let profileTxt = createAttributedText(str: "My Profile",
                                               fontSize: 16)
        MyProfileBtn.titleLabel?.attributedText = profileTxt
        MyProfileBtn.setTitleColor(UIColor.lightText, for: .disabled)
        
        // Challenge Button
        ChallengeBtn.isEnabled = false
        ChallengeBtn.roundedButton()
        ChallengeBtn.backgroundColor = kDefault_ButtonBckgrndColor
        let challengeTxt = createAttributedText(str: "Challenge Another Player!",
                                              fontSize: 16)
        ChallengeBtn.titleLabel?.attributedText = challengeTxt
        ChallengeBtn.setTitleColor(UIColor.lightText, for: .disabled)
    }
}
