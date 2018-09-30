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
            debugStuffOnBtn.isHidden = false
            debugStuffOnBtn.isOpaque = true
            debugStuffOnBtn.titleLabel?.isHidden = false
            debugStuffOnBtn.titleLabel?.textColor = UIColor.green
            debugStuffOnBtn.backgroundColor =
                (UIColor.lightGray).withAlphaComponent(1.0)
            debugStuffOnBtn.setTitleColor(UIColor.blue, for: .normal)
            gMKDebugOpt_ShowDebugSettingsBtn = true
            gMKDebugOpt_ShowFakeScoreInLTAlert = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if numTimesDebugStuffOnTapped >= 5 { return }

        debugStuffOnBtn.isEnabled = true
        debugStuffOnBtn.isOpaque = false
        debugStuffOnBtn.titleLabel?.textColor = UIColor.clear
        debugStuffOnBtn.titleLabel?.textColor = UIColor.green
        debugStuffOnBtn.titleLabel?.isHidden = true
        debugStuffOnBtn.setTitleColor(UIColor.clear, for: .normal)
        debugStuffOnBtn.backgroundColor =
            (UIColor.lightGray).withAlphaComponent(0.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        numTimesDebugStuffOnTapped = 0
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
