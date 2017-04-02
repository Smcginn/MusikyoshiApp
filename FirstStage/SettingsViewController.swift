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
    @IBOutlet weak var showNoteMarkersLabel: UILabel!
    @IBOutlet weak var showNoteMarkersSwitch: UISwitch!
    @IBOutlet weak var showAnalysisSwitch: UISwitch!
    @IBOutlet weak var showAnalysisLabel: UILabel!

    @IBAction func bpmStepperChanged(_ sender: UIStepper) {
        bpmLabel.text = String(Int(bpmStepper.value))
    }
    
    @IBAction func showNoteMarkerSwitchChanged(_ sender: UISwitch) {
        if showNoteMarkersSwitch.isOn {
            showNoteMarkersLabel.text = "Markers - No Input"
        } else {
            showNoteMarkersLabel.text = "Input - No Markers"
        }
    }

    @IBAction func showAnalysisSwitchChanged(_ sender: UISwitch) {
        updateAnalysisSwitch()
    }

    func updateAnalysisSwitch() {
        if showAnalysisSwitch.isOn {
            showAnalysisLabel.text = "Show"
        } else {
            showAnalysisLabel.text = "Don't show"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bpmStepper.value = UserDefaults.standard.double(forKey: Constants.Settings.BPM)
        bpmLabel.text = String(Int(bpmStepper.value))

        showAnalysisSwitch.isOn = UserDefaults.standard.bool(forKey: Constants.Settings.ShowAnalysis)
        updateAnalysisSwitch()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(bpmStepper.value, forKey: Constants.Settings.BPM)
//        UserDefaults.standard.set(showNoteMarkersSwitch.isOn, forKey: Constants.Settings.ShowNoteMarkers)
        UserDefaults.standard.set(false, forKey: Constants.Settings.ShowNoteMarkers)

        UserDefaults.standard.set(showAnalysisSwitch.isOn, forKey: Constants.Settings.ShowAnalysis)

        super.viewWillDisappear(animated)
    }
}
