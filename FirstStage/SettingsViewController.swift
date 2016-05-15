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
    
    @IBAction func bpmStepperChanged(sender: UIStepper) {
        bpmLabel.text = String(Int(bpmStepper.value))
    }
    
    @IBAction func showNoteMarkerSwitchChanged(sender: UISwitch) {
        if showNoteMarkersSwitch.on {
            showNoteMarkersLabel.text = "Markers - No Input"
        } else {
            showNoteMarkersLabel.text = "Input - No Markers"
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        bpmStepper.value = NSUserDefaults.standardUserDefaults().doubleForKey(Constants.Settings.BPS)
        bpmLabel.text = String(Int(bpmStepper.value))
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSUserDefaults.standardUserDefaults().setDouble(bpmStepper.value, forKey: Constants.Settings.BPS)
        NSUserDefaults.standardUserDefaults().setBool(showNoteMarkersSwitch.on, forKey: Constants.Settings.ShowNoteMarkers)
        
        super.viewWillDisappear(animated)
    }
}