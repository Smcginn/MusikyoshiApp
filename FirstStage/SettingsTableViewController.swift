//
//  SettingsViewController.swift
//  FirstStage
//
//  Created by Adam Kinney on 12/2/15.
//  Changed by David S Reich - 2016.
//  Changed by John Cook - 2017.
//  Copyright © 2015 Musikyoshi. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(showMarkersControl.isSelected == true, forKey: Constants.Settings.ShowNoteMarkers)
        UserDefaults.standard.set(showAnalysisControl.isSelected == true, forKey: Constants.Settings.ShowAnalysis)
        UserDefaults.standard.set(synthInstrumentControl.selectedSegmentIndex != 1, forKey: Constants.Settings.PlayTrumpet)
        UserDefaults.standard.set(bpmStepper.value, forKey: Constants.Settings.BPM)
        UserDefaults.standard.set(magnificationStepper.value, forKey: Constants.Settings.ScoreMagnification)
        UserDefaults.standard.set(noteWidthStepper.value, forKey: Constants.Settings.SmallestNoteWidth)
        UserDefaults.standard.set(signatureWidthStepper.value, forKey: Constants.Settings.SignatureWidth)
        
        super.viewWillDisappear(animated)
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
