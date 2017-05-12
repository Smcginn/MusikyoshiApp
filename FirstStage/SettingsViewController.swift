//
//  SettingsViewController.swift
//  FirstStage
//
//  Created by Adam Kinney on 12/2/15.
//  Changed by David S Reich - 2016.
//  Copyright © 2015 Musikyoshi. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController
{
    
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var bpmStepper: UIStepper!
    @IBOutlet weak var showMarkersControl: UISegmentedControl!
    @IBOutlet weak var showAnalysisControl: UISegmentedControl!
    @IBOutlet weak var synthInstrumentControl: UISegmentedControl!
    @IBOutlet weak var magnificationLabel: UILabel!
    @IBOutlet weak var magnificationStepper: UIStepper!
    @IBOutlet weak var noteWidthLabel: UILabel!
    @IBOutlet weak var noteWidthStepper: UIStepper!
    @IBOutlet weak var signatureWidthLabel: UILabel!
    @IBOutlet weak var signatureWidthStepper: UIStepper!

    @IBAction func bpmStepperChanged(_ sender: UIStepper) {
        bpmLabel.text = String(Int(bpmStepper.value))
    }

    @IBAction func showAnalysisControlChanged(_ sender: UISegmentedControl) {
    }
    
    @IBAction func synthInstrumentControlChanged(_ sender: UISegmentedControl) {
    }

    @IBAction func showMarkersControlChanged(_ sender: UISegmentedControl) {
    }

    @IBAction func magnificationStepperChanged(_ sender: UIStepper) {
        magnificationLabel.text = String(magnificationStepper.value)
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
        
        bpmStepper.value = UserDefaults.standard.double(forKey: Constants.Settings.BPM)
        bpmLabel.text = String(Int(bpmStepper.value))

        showAnalysisControl.selectedSegmentIndex = UserDefaults.standard.bool(forKey: Constants.Settings.ShowAnalysis) ? 1 : 0
        showMarkersControl.selectedSegmentIndex = UserDefaults.standard.bool(forKey: Constants.Settings.ShowNoteMarkers) ? 1 : 0
        synthInstrumentControl.selectedSegmentIndex = UserDefaults.standard.bool(forKey: Constants.Settings.PlayTrumpet) ? 0 : 1

        magnificationStepper.value = UserDefaults.standard.double(forKey: Constants.Settings.ScoreMagnification)
        magnificationLabel.text = String(magnificationStepper.value)

        noteWidthStepper.value = UserDefaults.standard.double(forKey: Constants.Settings.SmallestNoteWidth)
        noteWidthLabel.text = String(Int(noteWidthStepper.value))

        signatureWidthStepper.value = UserDefaults.standard.double(forKey: Constants.Settings.SignatureWidth)
        signatureWidthLabel.text = String(Int(signatureWidthStepper.value))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(bpmStepper.value, forKey: Constants.Settings.BPM)
        UserDefaults.standard.set(showMarkersControl.selectedSegmentIndex == 1, forKey: Constants.Settings.ShowNoteMarkers)
        UserDefaults.standard.set(showAnalysisControl.selectedSegmentIndex == 1, forKey: Constants.Settings.ShowAnalysis)
        UserDefaults.standard.set(synthInstrumentControl.selectedSegmentIndex != 1, forKey: Constants.Settings.PlayTrumpet)
        UserDefaults.standard.set(magnificationStepper.value, forKey: Constants.Settings.ScoreMagnification)
        UserDefaults.standard.set(noteWidthStepper.value, forKey: Constants.Settings.SmallestNoteWidth)
        UserDefaults.standard.set(signatureWidthStepper.value, forKey: Constants.Settings.SignatureWidth)

        super.viewWillDisappear(animated)
    }
}
