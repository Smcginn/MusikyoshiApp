//
//  SettingsViewController.swift
//  FirstStage
//
//  Created by Adam Kinney on 12/2/15.
//  Changed by David S Reich - 2016.
//  Changed by John Cook - 2017.
//  Changed by Scott Freshour - 2017, 2018, 2019.
//  Copyright © 2015 Musikyoshi. All rights reserved.
//

let kSettingsPresentMicCalibSegueID = "SettingsPresentMicCalibVCSegue"

import UIKit

class SettingsTableViewController: UITableViewController, PresentingMicCalibVC, UIPickerViewDataSource, UIPickerViewDelegate {
    
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
    
//    @IBOutlet weak var selectStudentInstrumentSegControl: MySegmentedControl!
    
//    @IBAction func selectStudentInstrumentSegControl_Changed(_ sender: Any) {
//        let instrument = selectStudentInstrumentSegControl.selectedSegmentIndex
//        UserDefaults.standard.set(instrument,
//                                  forKey: Constants.Settings.StudentInstrument)
//        setCurrentStudentInstrument(instrument: instrument)
//
//        loadAmpRiseValuesForCurrentInst()
//    }
    
    var currSelInst = getCurrentStudentInstrument()
    var newSelInst  = getCurrentStudentInstrument()
    
    var showInstrumentPicker = false
    
    let instrumentsText = [ "Trumpet",
                            "Trombone",
                            "Euphonium",
                            "French Horn",
                            "Tuba",
        /*
        "Flute",
        "Oboe",
        "Clarinet",
        "Bass Clarinet",
        "Bassoon",
        "Alto Saxophone",
        "Tenor Saxophone",
        "Baritone Saxophone" */ ]
    
    @IBOutlet weak var selectedInstrumentLabel: UILabel!
    @IBOutlet weak var instrumentPicker: UIPickerView!
    @IBOutlet weak var changeSelectedInstrumentButton: UIButton!
    @IBOutlet weak var doneSelectingInstrumentButton: UIButton!
    
    @IBAction func changeSelectedInstrumentButtonPressed(_ sender: Any) {
        
        changeSelectedInstrumentButton.isEnabled = false
        changeSelectedInstrumentButton.isHidden = true
        doneSelectingInstrumentButton.isHidden = false
        instrumentPicker.isHidden = false
        showInstrumentPicker = true
        
        self.instrumentPicker?.selectRow(currSelInst,
                                         inComponent: 0,
                                         animated: true )
        tableView.beginUpdates()
        tableView.endUpdates()
        
        // CHANGEHERE
        // Set current instrument
        
    }
    
    @IBAction func doneSelectingInstrumentButtonPressed(_ sender: Any) {
        
        changeSelectedInstrumentButton.isEnabled = true
        changeSelectedInstrumentButton.isHidden = false
        doneSelectingInstrumentButton.isHidden = true
        instrumentPicker.isHidden = true
        showInstrumentPicker = false
        
        currSelInst = newSelInst
        selectedInstrumentLabel.text = "Current instrument: " + instrumentsText[currSelInst]
        
        setCurrentStudentInstrument(instrument: currSelInst)
        loadAmpRiseValuesForCurrentInst()
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
    }
    
    func setupInstrumentSelection() {
        currSelInst = getCurrentStudentInstrument()
        selectedInstrumentLabel.text = "Current instrument: " + instrumentsText[currSelInst]
        
    }
    
    ////////////////////////////////////////////////////////////
    //
    //   Picker Delegate and Data Source methods
    //
    
    public func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        newSelInst = row
    }
    
//    public func pickerView(_ pickerView: UIPickerView,
//                           titleForRow row: Int,
//                           forComponent component: Int) -> String? {
//        return instrumentsText[row]
//    }
    
    public func pickerView(_ pickerView: UIPickerView,
                           widthForComponent component: Int) -> CGFloat {
        return 250.0
    }
    
    public func pickerView(_ pickerView: UIPickerView,
                           rowHeightForComponent component: Int) -> CGFloat {
        return 25.0
    }
    
    public func pickerView(_ pickerView: UIPickerView,
                           numberOfRowsInComponent component: Int) -> Int {
        // What is this?
        // return kInst_NumInstruments
        
        return instrumentsText.count
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        pickerLabel.text = instrumentsText[row]
        pickerLabel.font = UIFont(name: "Futura-Medium", size: 16)
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    @IBOutlet weak var IsASound_Label: UILabel!
    @IBOutlet weak var IsASound_Btn: UIButton!
    
    @IBOutlet weak var calibrateBtn: UIButton!
//    @IBAction func calibrateMicBtnPressed(_ sender: Any) {
//        self.performSegue(withIdentifier: kSettingsPresentMicCalibSegueID,
//                          sender: self)
//    }
    
    // Amp Rise settings related
    @IBOutlet weak var ampRiseValuesTableViewCell: UITableViewCell!
    @IBOutlet weak var ampRiseSettingsHeaderLabel: UILabel!
    @IBOutlet weak var ampRiseChangeSlider: UISlider!
    @IBOutlet weak var ampRiseChangeValueLabel: UILabel!
    @IBOutlet weak var ampRiseWindowSizeSlider: UISlider!
    @IBOutlet weak var ampRiseWindowSizeLabel: UILabel!
    @IBOutlet weak var ampRiseNumToSkipSlider: UISlider!
    @IBOutlet weak var ampRiseNumToSkipLabel: UILabel!
    @IBOutlet weak var resetAllToDefaultsLabel: UILabel!
    
    @IBAction func ampRiseChangeSlider_Changed(_ sender: Any) {
        let newVal = ampRiseChangeSlider.value
        let ampRiseChangeValueStr = String(format: "%.2f", newVal)
        ampRiseChangeValueLabel.text = ampRiseChangeValueStr

        let currInst = getCurrentStudentInstrument()
        changeAmpRiseForNewSound(forInstr: currInst, rise: Double(newVal))
    }
    
    @IBAction func ampRiseWindowSizeSlider_Changed(_ sender: Any) {
        let newVal = Int(ampRiseWindowSizeSlider.value)
        let ampRiseWindowSizeStr = String(newVal)
        ampRiseWindowSizeLabel.text = ampRiseWindowSizeStr

        let currInst = getCurrentStudentInstrument()
        changeNumSamplesInAnalysisWindow(forInstr: currInst, numSamples: UInt(newVal))
    }
    
    @IBAction func ampRiseNumToSkipSlider_Changed(_ sender: Any) {
        let newVal = Int(ampRiseNumToSkipSlider.value)
        let ampRiseNumToSkipStr = String(newVal)
        ampRiseNumToSkipLabel.text = ampRiseNumToSkipStr
        
        let currInst = getCurrentStudentInstrument()
        changeAmpRiseSamplesToSkip(forInstr: currInst, numSamples: UInt(newVal))
    }
    
    @IBAction func ResetAllBtnPressed(_ sender: Any) {
        let currInst = getCurrentStudentInstrument()
        resetAmpRiseValesToDefaults(forInstr: currInst)
    }
    
    @IBAction func isASoundBtnPressed(_ sender: Any) {
        if let parent = self.parent as? SettingsViewController {
            parent.performSegue(withIdentifier: "toIsASoundVC", sender: nil)
        }
    }
    
    @IBAction func calibrateBtnPressed(_ sender: Any) {
        if let parent = self.parent as? SettingsViewController {
            parent.performSegue(withIdentifier: kSettingsPresentMicCalibSegueID, sender: nil)
        }
    }
    
    func initAmpRiseSliders() {
        ampRiseChangeSlider.minimumValue = Float(kAmpRiseForNewSound_min)
        ampRiseChangeSlider.maximumValue = Float(kAmpRiseForNewSound_max)
        
        ampRiseWindowSizeSlider.minimumValue = Float(kSamplesInAnalysisWindow_min)
        ampRiseWindowSizeSlider.maximumValue = Float(kSamplesInAnalysisWindow_max)
        
        ampRiseNumToSkipSlider.minimumValue = Float(kSkipBeginningSamples_min)
        ampRiseNumToSkipSlider.maximumValue = Float(kSkipBeginningSamples_max)
    }
    
    func loadAmpRiseValuesForCurrentInst() {
        let currInst = getCurrentStudentInstrument()

        var instStr = ""
        switch currInst {
        case kInst_Trombone:    instStr += "Trombone"
        case kInst_Euphonium:   instStr += "Euphonium"
        case kInst_FrenchHorn:  instStr += "Horn"
        case kInst_Tuba:        instStr += "Tuba"
        case kInst_Trumpet:  fallthrough
        default:                instStr += "Trumpet"
        }
        var titleStr = "Amplitude Rise Values for: "
        titleStr += instStr
        ampRiseSettingsHeaderLabel.text = titleStr
        var resetStr = "Reset All Above to "
        resetStr += instStr
        resetStr += "'s Defaults"
        resetAllToDefaultsLabel.text = resetStr
        
        let ampRiseChangeValue     = getAmpRiseForNewSound(forInstr: currInst)
        let ampRiseWindowSizeValue = getNumSamplesInAnalysisWindow(forInstr: currInst)
        let ampRiseNumToSkipValue  = getAmpRiseSamplesToSkip(forInstr: currInst)

        ampRiseChangeSlider.value = Float(ampRiseChangeValue)
        let ampRiseChangeValueStr = String(format: "%.3f", ampRiseChangeValue)
        ampRiseChangeValueLabel.text = ampRiseChangeValueStr

        ampRiseWindowSizeSlider.value = Float(ampRiseWindowSizeValue)
        let ampRiseWindowSizeStr = String(ampRiseWindowSizeValue)
        ampRiseWindowSizeLabel.text = ampRiseWindowSizeStr

        ampRiseNumToSkipSlider.value = Float(ampRiseNumToSkipValue)
        let ampRiseNumToSkipStr = String(ampRiseNumToSkipValue)
        ampRiseNumToSkipLabel.text = ampRiseNumToSkipStr
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
        
        bpmStepper.tintColor = .pinkColor
        
        self.instrumentPicker!.dataSource = self //as UIPickerViewDataSource
        self.instrumentPicker!.delegate = self
        
        setupInstrumentSelection()
        
        initAmpRiseSliders()
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
        
        if gMKDebugOpt_ShowDebugSettingsBtn {
            ampRiseValuesTableViewCell.isHidden  = false
        } else {
            ampRiseValuesTableViewCell.isHidden  = true
        }
        
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
        
        var studentInstrument =
            UserDefaults.standard.integer(forKey: Constants.Settings.StudentInstrument)
        currInstrumentSetting = studentInstrument
        
        if studentInstrument < kInst_Trumpet || studentInstrument > kInst_Tuba {
            studentInstrument = kInst_Trumpet
        }
    
        loadAmpRiseValuesForCurrentInst()
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
        
//        let instrument = selectStudentInstrumentSegControl.selectedSegmentIndex
//        if currInstrumentSetting != instrument {
//            UserDefaults.standard.set(instrument,
//                                      forKey: Constants.Settings.StudentInstrument)
//            setCurrentStudentInstrument(instrument: instrument)
//        }
        
        super.viewWillDisappear(animated)
    }
    
    func returningFromMicCalibVC(didCalibrate: Bool) {
        print("in Setup::returningFromMicCalibVC()")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 && indexPath.row == 2 {
            if let parent = self.parent as? SettingsViewController {
                parent.performSegue(withIdentifier: "toPurchaseOptions", sender: nil)
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 && showInstrumentPicker {
            return 200
        } else if indexPath.row <= 2 {
            return 64
        } else if indexPath.row == 4 { // Amp rise sliders - only show if debug mode
            if gMKDebugOpt_ShowDebugSettingsBtn {
                return 300
            } else {
                return 0
            }
        } else if indexPath.row == 5 { // "Is a Sound" button - only show if debug mode
            if gMKDebugOpt_ShowDebugSettingsBtn {
                return 50
            } else {
                return 0
            }
        }
        
        //        else if indexPath.row == 6 { // "Is a Sound" button - only show if debug mode
        //            if gMKDebugOpt_ShowDebugSettingsBtn {
        //                return 50
        //            } else {
        //                return 0
        //            }
        //        }
        
        // else . . . lots of disabled stuff we're not quite yet commiting to
        //            getting rid of
        return 0
        
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
