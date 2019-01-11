//
//  SettingsViewController.swift
//  FirstStage
//
//  Created by Adam Kinney on 12/2/15.
//  Changed by David S Reich - 2016.
//  Changed by John Cook - 2017.
//  Copyright © 2015 Musikyoshi. All rights reserved.
//

let kSettingsPresentMicCalibSegueID = "SettingsPresentMicCalibVCSegue"

import UIKit

class SettingsTableViewController: UITableViewController, PresentingMicCalibVC {
    
    var currInstrumentSetting: Int = 0
    
    @IBOutlet weak var showMarkersControl: UISwitch!
    @IBOutlet weak var showAnalysisControl: UISwitch!
    @IBOutlet weak var synthInstrumentControl: UISegmentedControl!
    @IBOutlet weak var magnificationLabel: UILabel!
    @IBOutlet weak var magnificationStepper: UIStepper!
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var bpmStepper: UIStepper!
    @IBOutlet weak var noteWidthLabel: UILabel!
    @IBOutlet weak var noteWidthStepper: UIStepper!
    @IBOutlet weak var signatureWidthLabel: UILabel!
    @IBOutlet weak var signatureWidthStepper: UIStepper!
    
    
    @IBOutlet weak var selectStudentInstrumentSegControl: MySegmentedControl!
    
    @IBOutlet weak var IsASound_Label: UILabel!
    @IBOutlet weak var IsASound_Btn: UIButton!
    
    @IBOutlet weak var calibrateBtn: UIButton!
    @IBAction func calibrateMicBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: kSettingsPresentMicCalibSegueID,
                          sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.title = ""
        if segue.identifier == kSettingsPresentMicCalibSegueID {
            if let destination = segue.destination as? MicCalibrationViewController {
                destination.presentingVC = self
                destination.forceCalibration = true
            }
        }
    }
    
    @IBAction func showAnalysisControlChanged(_ sender: UISwitch) {
    }
    
    @IBAction func synthInstrumentControlChanged(_ sender: UISegmentedControl) {
    }
    
    @IBAction func showMarkersControlChanged(_ sender: UISwitch) {
    }
    
    @IBAction func bpmStepperValueChanged(_ sender: Any) {
        bpmLabel.text = String(Int(bpmStepper.value))
    }
    
    @IBAction func magnificationStepperChanged(_ sender: UIStepper) {
        magnificationLabel.text = String(magnificationStepper.value / 10)
    }
    
    @IBAction func noteWidthStepperChanged(_ sender: UIStepper) {
        noteWidthLabel.text = String(Int(noteWidthStepper.value))
    }
    
    @IBAction func signatureWidthStepperChanged(_ sender: UIStepper) {
        signatureWidthLabel.text = String(Int(signatureWidthStepper.value))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectStudentInstrumentSegControl.multilinesMode = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calibrateBtn.frame.origin.x   -= 8
        calibrateBtn.frame.size.width += 8
    }
    
    //    @IBAction func showNoteMarkerSwitchChanged(_ sender: UISwitch) {
    //        if showNoteMarkersSwitch.isOn {
    //            showNoteMarkersLabel.text = "Markers"
    //        } else {
    //            showNoteMarkersLabel.text = "No Markers"
    //        }
    //    }
    //
    //    @IBAction func showAnalysisSwitchChanged(_ sender: UISwitch) {
    //        updateAnalysisSwitch()
    //    }
    //
    //    @IBAction func pianoTrumpetSwitchChanged(_ sender: UISwitch) {
    //    }
    //    func updateAnalysisSwitch() {
    //        if showAnalysisSwitch.isOn {
    //            showAnalysisLabel.text = "Show"
    //        } else {
    //            showAnalysisLabel.text = "Don't show"
    //        }
    //    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // SFUserDefs
        showAnalysisControl.isSelected = UserDefaults.standard.bool(forKey: Constants.Settings.ShowAnalysis) ? true : false
        showMarkersControl.isSelected = UserDefaults.standard.bool(forKey: Constants.Settings.ShowNoteMarkers) ? true : false
        synthInstrumentControl.selectedSegmentIndex = UserDefaults.standard.bool(forKey: Constants.Settings.PlayTrumpet) ? 0 : 1
        
        bpmStepper.value = UserDefaults.standard.double(forKey: Constants.Settings.BPM)
        bpmLabel.text = String(Int(bpmStepper.value))
        
        magnificationStepper.value = Double(UserDefaults.standard.integer(forKey: Constants.Settings.ScoreMagnification))
        magnificationLabel.text = String(magnificationStepper.value / 10)
        
        noteWidthStepper.value = UserDefaults.standard.double(forKey: Constants.Settings.SmallestNoteWidth)
        noteWidthLabel.text = String(Int(noteWidthStepper.value))
        
        signatureWidthStepper.value = UserDefaults.standard.double(forKey: Constants.Settings.SignatureWidth)
        signatureWidthLabel.text = String(Int(signatureWidthStepper.value))
        
        if gMKDebugOpt_IsSoundAndLatencySettingsEnabled {
            IsASound_Label.isHidden  = false
            IsASound_Btn.isHidden    = false
            IsASound_Label.isEnabled = true
            IsASound_Btn.isEnabled   = true
         } else {
            IsASound_Label.isHidden  = true
            IsASound_Btn.isHidden    = true
            IsASound_Label.isEnabled = false
            IsASound_Btn.isEnabled   = false
        }
        
//        for segmentViews in selectStudentInstrumentSegControl.subviews {
//            for segmentLabel in segmentViews.subviews {
//                if segmentLabel is UILabel {
//                    (segmentLabel as! UILabel).numberOfLines = 0
//                }
//            }
//        }
        
        var segTitle = "Trombone"
        selectStudentInstrumentSegControl.setTitle(segTitle,
                                                   forSegmentAt: 1)
        
        segTitle = "Euphonium"
        selectStudentInstrumentSegControl.setTitle(segTitle,
                                                   forSegmentAt: 2)
        
        segTitle = "French\nHorn"
        selectStudentInstrumentSegControl.setTitle(segTitle,
                                                   forSegmentAt: 3)
        
        segTitle = "Tuba"
        selectStudentInstrumentSegControl.setTitle(segTitle,
                                                   forSegmentAt: 4)
        
        var studentInstrument =
            UserDefaults.standard.integer(forKey: Constants.Settings.StudentInstrument)
        currInstrumentSetting = studentInstrument
        
        if studentInstrument < kInst_Trumpet || studentInstrument > kInst_Tuba {
            studentInstrument = kInst_Trumpet
        }
        selectStudentInstrumentSegControl.selectedSegmentIndex = studentInstrument
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // SFUserDefs
        UserDefaults.standard.set(showMarkersControl.isSelected == true, forKey: Constants.Settings.ShowNoteMarkers)
        UserDefaults.standard.set(showAnalysisControl.isSelected == true, forKey: Constants.Settings.ShowAnalysis)
        UserDefaults.standard.set(synthInstrumentControl.selectedSegmentIndex != 1, forKey: Constants.Settings.PlayTrumpet)
        UserDefaults.standard.set(bpmStepper.value, forKey: Constants.Settings.BPM)
        UserDefaults.standard.set(magnificationStepper.value, forKey: Constants.Settings.ScoreMagnification)
        UserDefaults.standard.set(noteWidthStepper.value, forKey: Constants.Settings.SmallestNoteWidth)
        UserDefaults.standard.set(signatureWidthStepper.value, forKey: Constants.Settings.SignatureWidth)
        
        let instrument = selectStudentInstrumentSegControl.selectedSegmentIndex
        if currInstrumentSetting != instrument {
            UserDefaults.standard.set(instrument,
                                      forKey: Constants.Settings.StudentInstrument)
            setCurrentStudentInstrument(instrument: instrument)
        }
        
        super.viewWillDisappear(animated)
    }
    
    func returningFromMicCalibVC(didCalibrate: Bool) {
        print("in Setup::returningFromMicCalibVC()")
    }
}

extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    
    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}


@IBDesignable class MySegmentedControl: UISegmentedControl {
    
    @IBInspectable var height: CGFloat = 29 {
        didSet {
            let centerSave = center
            frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: height)
            center = centerSave
        }
    }
    
    @IBInspectable var multilinesMode: Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for segment in self.subviews {
            for subview in segment.subviews {
                if let segmentLabel = subview as? UILabel {
                    segmentLabel.frame = CGRect(x: 0, y: 0, width: segmentLabel.frame.size.width, height: segmentLabel.frame.size.height * 1.6)
                    if (multilinesMode == true)
                    {
                        segmentLabel.numberOfLines = 0
                    }
                    else
                    {
                        segmentLabel.numberOfLines = 1
                    }
                }
            }
        }
    }
    
}
