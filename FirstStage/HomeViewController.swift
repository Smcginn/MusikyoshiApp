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
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var hiddenPswdTextField: UITextField!
    
//    var didDisplayOverview = false
    
    let particleEmitter = CAEmitterLayer()
    
    @IBAction func LessonsBtnPressed(_ sender: Any) {
    }
    
    @IBAction func OverviewBtnPressed(_ sender: Any) {
        displayWelcomeVC()
    }
    
    var handlingDebugModePassword = true
    
    @IBOutlet weak var debugStuffOnBtn: UIButton!
    var numTimesDebugStuffOnTapped = 0
    @IBAction func debugStuffOnPressed(_ sender: Any) {
        numTimesDebugStuffOnTapped += 1
        if numTimesDebugStuffOnTapped >= 15 {
            handlingDebugModePassword = true
            hiddenPswdTextField.backgroundColor = .lightGray
            hiddenPswdTextField.isHidden = false
            hiddenPswdTextField.isEnabled = true
            hiddenPswdTextField.keyboardType = .default
            hiddenPswdTextField.becomeFirstResponder()
        }
     }
    
    var numTimesSettingsEnabledTapped = 0
    var settingsEnblBtnBckgrndColor = UIColor.clear
    @IBOutlet weak var settingEnabledBtn: UIButton!
    @IBAction func settingEnabledBtnPressed(_ sender: Any) {
        if gDoOverrideSubsPresent {
            showLevelsAlreadyEnabledAlert()
        }

        numTimesSettingsEnabledTapped += 1
        if numTimesSettingsEnabledTapped >= 5 {
            handlingDebugModePassword = false
            hiddenPswdTextField.backgroundColor = .lightGray
            hiddenPswdTextField.isHidden = false
            hiddenPswdTextField.isEnabled = true
            hiddenPswdTextField.keyboardType = .default
            hiddenPswdTextField.becomeFirstResponder()
            showEnterPasswordAlert()
        }
    }
    
    
    let kDebugModeBtn   = 0
    let kLevelAccessBtn = 1
    
    let kEULAPswd       = "EULA"
    let kDebugPswd      = "DDDDD"
    let kAllLevelsPswd1 = "PAUSD"
    let kAllLevelsPswd2 = "FORSCHOOL"
    let kAllLevelsPswd3 = "FREE-PASS"

    func isValidPassword(forButton: Int, response: String) -> Bool {
        let upResp = response.uppercased()
        if forButton == kDebugModeBtn &&
           (upResp == kDebugPswd || upResp == kEULAPswd) {
            return true
        } else if forButton == kLevelAccessBtn &&
                  (upResp == kAllLevelsPswd1 ||
                   upResp == kAllLevelsPswd2 ||
                   upResp == kAllLevelsPswd3 ||
                   upResp == kEULAPswd)  {
            return true
        }
        return false
    }
    
    func showWrongPasswordAlert() {
            let titleStr = "That is not the correct Password"
            let msgStr = "\n\nPlease try again."
            showAlert(title: titleStr, message: msgStr)
    }
    
    func showLevelsAlreadyEnabledAlert() {
        let titleStr = "You Already Have\nAll Level Access"
        let msgStr = "\n\nYou either have entered the correct password, or you have a valid subscription.\n\nYou're good to go!"
        showAlert(title: titleStr, message: msgStr)
    }
    
    func showLevelsGoodToGoAlert() {
        let titleStr = "You Now Have\nAll Level Access!"
        var msgStr = "\n\nYou're good to go!\n\n"
        msgStr += "You may now enjoy all \naspects of PlayTunes!\n\n"
        showAlert(title: titleStr, message: msgStr)
    }
    
    func showEnterPasswordAlert() {
        let titleStr = "Enter Password For\nAll Level Access!"
        var msgStr = "\n\nIf you have been given a password for PlayTunes "
        msgStr += "Unlimited All Levels access, enter it in the gray text field, "
        msgStr += "then press the Return button.\n\n"
        msgStr += "You will see a confirmation dialog if successful.\n\n"

        showAlert(title: titleStr, message: msgStr)
    }
    
    func showAlert(title: String, message: String) {
        let ac = MyUIAlertController(title: title,
                                     message: message,
                                     preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK",
                                   style: .default,
                                   handler: nil))
        ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor =
                kDefault_AlertBackgroundColor
        
        self.present(ac, animated: true, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print ("yo")
        let response = hiddenPswdTextField.text
        if response == nil || response == "" {
            return
        }
        
        // must match the dev password
        if handlingDebugModePassword {
            if !isValidPassword(forButton: kDebugModeBtn,
                                response: response!) {
                showWrongPasswordAlert()
                return
            }
            
            gMKDebugOpt_ShowDebugSettingsBtn = true

            gMKDebugOpt_HomeScreenDebugOptionsEnabled = true
            debugStuffOnBtn.isHidden = false
            debugStuffOnBtn.isOpaque = true
            debugStuffOnBtn.titleLabel?.isHidden = false
            debugStuffOnBtn.titleLabel?.textColor = UIColor.green
            debugStuffOnBtn.backgroundColor =
                (UIColor.lightGray).withAlphaComponent(1.0)
            debugStuffOnBtn.setTitleColor(UIColor.blue, for: .normal)
            gMKDebugOpt_ShowFakeScoreInLTAlert = true
            gMKDebugOpt_ShowSlidersBtn = true
            gMKDebugOpt_ShowResetBtnInMicCalibScene = true
            gMKDebugOpt_IsSoundAndLatencySettingsEnabled = true
        } else {
            if !isValidPassword(forButton: kLevelAccessBtn,
                                response: response!) {
                showWrongPasswordAlert()
                return
            }
            
            // If still here, then password was good.
            saveSubsriptionOverridePswdSet()
            
            settingEnabledBtn.titleLabel?.textColor = .clear
            settingsEnblBtnBckgrndColor = .clear
            settingEnabledBtn.setTitleColor(.clear, for: .normal)
            settingEnabledBtn.titleLabel?.isHidden = false
            gDoOverrideSubsPresent = true
            gDoLimitLevels = false
            showLevelsGoodToGoAlert()
        }
        
        
        hiddenPswdTextField.isHidden = true
        hiddenPswdTextField.isEnabled = false
    }
    
    func saveSubsriptionOverridePswdSet() {
        UserDefaults.standard.set(
            true,
            forKey: Constants.Settings.SubsriptionOverridePswdSet)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        LessonsBtn.layer.cornerRadius = LessonsBtn.frame.width / 2
        
        createParticles()
        
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
        if gDoOverrideSubsPresent {
            settingEnabledBtn.setTitle("Levels Enabled ", for: .normal)
            settingEnabledBtn.isHidden = false
            settingEnabledBtn.isEnabled = true
            settingEnabledBtn.isOpaque = true
            settingEnabledBtn.titleLabel?.textColor = UIColor.green
            settingEnabledBtn.setTitleColor(UIColor.black, for: .normal)
        } else {
            settingEnabledBtn.setTitle("", for: .normal)
            settingEnabledBtn.isHidden = false
            settingEnabledBtn.isEnabled = true
            settingEnabledBtn.isOpaque = false
            settingEnabledBtn.setTitleColor(UIColor.clear, for: .normal)
       }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideViews()
        
        navigationController?.navigationBar.isHidden = true
        
        numTimesDebugStuffOnTapped = 0
        numTimesSettingsEnabledTapped = 0
        settingEnabledBtn.titleLabel?.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
        
        hiddenPswdTextField.text = "" // otherwise could invoke "wrong pswd" dlg
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
            if !LsnSchdlr.instance.scoreMgr.scoreFileCanBeUpdatedToVersion_0_3_x() {
                displayDBCompatibilityAlert()
            }
        }
        
        let shouldDisplayOverview = !UserDefaults.standard.bool(forKey: "displayedOverviewPopup")
        
        if shouldDisplayOverview {
            displayWelcomeVC()
            UserDefaults.standard.set(true, forKey: "displayedOverviewPopup")
        }
        
//        if !didDisplayOverview {
//            displayWelcomeVC()
//            didDisplayOverview = true
//        }
        
        settingEnabledBtn.backgroundColor = settingsEnblBtnBckgrndColor
        hiddenPswdTextField.isHidden = true
        
        animateViews()
        
    }
    
    func animateViews() {
        
        let delayFactor = 0.2
        let duration = 0.8
        let damping: CGFloat = 0.8
        let initialSpringVel: CGFloat = 0.1
        
        welcomeLabel.transform = CGAffineTransform(translationX: -400, y: 0)
        UIView.animate(withDuration: duration, delay: delayFactor * 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {
            self.welcomeLabel.alpha = 1
            self.welcomeLabel.transform = .identity
        }, completion: nil)
        
        LessonsBtn.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: duration, delay: delayFactor * 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {
            self.LessonsBtn.alpha = 1
            self.LessonsBtn.transform = .identity
        }, completion: nil)
        
        dateLabel.transform = CGAffineTransform(translationX: -400, y: 0)
        UIView.animate(withDuration: duration, delay: delayFactor * 1, usingSpringWithDamping: damping, initialSpringVelocity: initialSpringVel, options: .curveEaseOut, animations: {
            self.dateLabel.alpha = 1
            self.dateLabel.transform = .identity
        }, completion: nil)
        
    }
    
    func hideViews() {
        welcomeLabel.alpha = 0
        dateLabel.alpha = 0
        LessonsBtn.alpha = 0
    }
    
    let showWellcomeVCSegueID = "showWellcomeVCSegue"
    func displayWelcomeVC() {
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
    
    func getFormattedDate() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        
        return formatter.string(from: Date())
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI customization
        
        hiddenPswdTextField.delegate = self
        
        if DeviceType.IS_IPHONE_5orSE {
            welcomeLabel.font = UIFont(name: "Futura-Bold", size: 27.0)
        }
        
        dateLabel.text = getFormattedDate()
        
        hiddenPswdTextField.autocorrectionType = .no
    }
    
    @IBAction func unwindToHomeVC(unwindSegue: UIStoryboardSegue) {
        print("here in unwindToHomeVC")
    }
    
    private func createParticles() {
        
        particleEmitter.emitterPosition = CGPoint(x: LessonsBtn.frame.midX, y: LessonsBtn.frame.midY)
        particleEmitter.zPosition = -1.0
        particleEmitter.emitterShape = "point"
        particleEmitter.emitterSize = CGSize(width: LessonsBtn.frame.width, height: LessonsBtn.frame.height)
        
        let wholeNoteOrange = makeEmitterCell(imageName: "wholeNote", color: .orangeColor)
        let wholeNotePink = makeEmitterCell(imageName: "wholeNote", color: .pinkColor)
        let wholeNotePurple = makeEmitterCell(imageName: "wholeNote", color: .purpleColor)
        
        let halfNoteOrange = makeEmitterCell(imageName: "halfNote", color: .orangeColor)
        let halfNotePink = makeEmitterCell(imageName: "halfNote", color: .pinkColor)
        let halfNotePurple = makeEmitterCell(imageName: "halfNote", color: .purpleColor)
        
        let eigthNoteOrange = makeEmitterCell(imageName: "eigthNote", color: .orangeColor)
        let eigthNotePink = makeEmitterCell(imageName: "eigthNote", color: .pinkColor)
        let eigthNotePurple = makeEmitterCell(imageName: "eigthNote", color: .purpleColor)
        
        let trebleClefOrange = makeEmitterCell(imageName: "trebleClef", color: .orangeColor)
        let trebleClefPink = makeEmitterCell(imageName: "trebleClef", color: .pinkColor)
        let trebleClefPurple = makeEmitterCell(imageName: "trebleClef", color: .purpleColor)
        
        let bassClefOrange = makeEmitterCell(imageName: "bassClef", color: .orangeColor)
        let bassClefPink = makeEmitterCell(imageName: "bassClef", color: .pinkColor)
        let bassClefPurple = makeEmitterCell(imageName: "bassClef", color: .purpleColor)
        
        particleEmitter.emitterCells = [wholeNoteOrange,
                                        wholeNotePink,
                                        wholeNotePurple,
                                        halfNoteOrange,
                                        halfNotePink,
                                        halfNotePurple,
                                        eigthNoteOrange,
                                        eigthNotePink,
                                        eigthNotePurple,
                                        trebleClefOrange,
                                        trebleClefPink,
                                        trebleClefPurple,
                                        bassClefOrange,
                                        bassClefPink,
                                        bassClefPurple
                                       ]
        
        view.layer.addSublayer(particleEmitter)
        
    }
    
    private func makeEmitterCell(imageName: String, color: UIColor?) -> CAEmitterCell {
        
        let cell = CAEmitterCell()
        
        let randomNum = Double.random(in: 0...10)
        cell.beginTime = randomNum
        
        cell.birthRate = 0.1
        cell.lifetime = 35
        cell.lifetimeRange = 10
        
        cell.velocity = 60
        cell.velocityRange = 25
        
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi
        
        if DeviceType.IS_IPHONE_5orSE {
            cell.scale = 0.5
        } else {
            cell.scale = 0.9
        }
        
        cell.scaleRange = 0.4
        cell.scaleSpeed = -0.01
        
        cell.spin = 0.2
        cell.spinRange = 0.1
        
        cell.color = color!.cgColor
        cell.contents = UIImage(named: imageName)?.cgImage
        return cell
        
    }
    
}
