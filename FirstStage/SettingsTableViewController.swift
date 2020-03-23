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
    
    var savedCurrInstrument: Int = 0
    
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
    @IBOutlet weak var videoModeSegControl: UISegmentedControl!
    
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
                            "Flute",
                            "Oboe",
                            "Clarinet",
                            "Bass Clarinet",
                            "Bassoon",
                            "Alto Saxophone",
                            "Tenor Saxophone",
                            "Baritone Saxophone" ] // ,
//                           "Bells"  ]

    func getPickerIndexFromInstID(InstID: Int) -> Int {
        var retVal = 0
        switch InstID {
        case kInst_Flute:           retVal =  0
        case kInst_Oboe:            retVal =  1
        case kInst_Clarinet:        retVal =  2
        case kInst_BassClarinet:    retVal =  3
        case kInst_Bassoon:         retVal =  4
        case kInst_AltoSax:         retVal =  5
        case kInst_TenorSax:        retVal =  6
        case kInst_BaritoneSax:     retVal =  7
        case kInst_FrenchHorn:      retVal =  8
        case kInst_Trumpet:         retVal =  9
        case kInst_Trombone:        retVal = 10
        case kInst_Euphonium:       retVal = 11
        case kInst_Tuba:            retVal = 12
        case kInst_Mallet:          retVal = 13
            
        default:   retVal = 0
        }
        return retVal
    }
    
    func getInstIDFromTableIndex(pickerIndex: Int) -> Int {
        var retVal = 0
        switch pickerIndex {
            case  0:   retVal = kInst_Flute
            case  1:   retVal = kInst_Oboe
            case  2:   retVal = kInst_Clarinet
            case  3:   retVal = kInst_BassClarinet
            case  4:   retVal = kInst_Bassoon
            case  5:   retVal = kInst_AltoSax
            case  6:   retVal = kInst_TenorSax
            case  7:   retVal = kInst_BaritoneSax
            case  8:   retVal = kInst_FrenchHorn
            case  9:   retVal = kInst_Trumpet
            case 10:   retVal = kInst_Trombone
            case 11:   retVal = kInst_Euphonium
            case 12:   retVal = kInst_Tuba
            case 13:   retVal = kInst_Mallet

            default:   retVal = kInst_Trumpet
        }
        return retVal
    }
    
    func printInstSelection() {
        
    }
    
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
        setCurrentAmpRiseValsForInstrument(forInstr: currSelInst)
        
        let lde: tLDE_code = (level: 0, day: 0, exer: 0)
        _ = LessonScheduler.instance.setCurrentLDE(toLDE: lde)

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
        let newVal = Double(ampRiseChangeSlider.value)
        let ampRiseChangeValueStr = String(format: "%.2f", newVal)
        ampRiseChangeValueLabel.text = ampRiseChangeValueStr

//        let currInst = getCurrentStudentInstrument()
//        changeAmpRiseForNewSound(forInstr: currInst, rise: newVal)
        
        gAmpRiseForNewSound =  newVal // getAmpRiseForNewSound(forInstr: forInstr)
    }
    
    @IBAction func ampRiseWindowSizeSlider_Changed(_ sender: Any) {
        let newVal = Int(ampRiseWindowSizeSlider.value)
        let ampRiseWindowSizeStr = String(newVal)
        ampRiseWindowSizeLabel.text = ampRiseWindowSizeStr

//        let currInst = getCurrentStudentInstrument()
//        changeNumSamplesInAnalysisWindow(forInstr: currInst, numSamples: UInt(newVal))
        
        gSamplesInAnalysisWindow = UInt(newVal) // getNumSamplesInAnalysisWindow(forInstr: forInstr)
    }
    
    @IBAction func ampRiseNumToSkipSlider_Changed(_ sender: Any) {
        let newVal = Int(ampRiseNumToSkipSlider.value)
        let ampRiseNumToSkipStr = String(newVal)
        ampRiseNumToSkipLabel.text = ampRiseNumToSkipStr
        
//        let currInst = getCurrentStudentInstrument()
//        changeAmpRiseSamplesToSkip(forInstr: currInst, numSamples: UInt(newVal))

        gSkipBeginningSamples    = UInt(newVal) // getAmpRiseSamplesToSkip(forInstr: forInstr)
    }
    
    @IBAction func ResetAllBtnPressed(_ sender: Any) {
 //       let currInst = getCurrentStudentInstrument()
 //       resetAmpRiseValesToDefaults(forInstr: currInst)
        loadAmpRiseValuesForCurrentInst() // set the sliders to restored values
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
        case kInst_Trombone:        instStr += "Trombone"
        case kInst_Euphonium:       instStr += "Euphonium"
        case kInst_FrenchHorn:      instStr += "Horn"
        case kInst_Tuba:            instStr += "Tuba"
            
        case kInst_Flute:           instStr += "Flute"
        case kInst_Oboe:            instStr += "Oboe"
        case kInst_Clarinet:        instStr += "Clarinet"
        case kInst_BassClarinet:    instStr += "BassClarinet"
        case kInst_Bassoon:         instStr += "Bassoon"
        case kInst_AltoSax:         instStr += "AltoSax"
        case kInst_TenorSax:        instStr += "TenorSax"
        case kInst_BaritoneSax:     instStr += "BaritoneSax"
            
        case kInst_Mallet:          instStr += "Mallet Percussion"
            
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
        
        let ampRiseChangeValue     = getAmpRiseForNewSound(forInstr: currInst,
                                                           forSettings: true)
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
        
        bpmStepper.minimumValue = kTempoRangeMin
        bpmStepper.maximumValue = kTempoRangeMax

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
        savedCurrInstrument = studentInstrument
        
        if studentInstrument < kInst_Trumpet || studentInstrument > kInst_Tuba {
            studentInstrument = kInst_Trumpet
        }
    
        loadAmpRiseValuesForCurrentInst()
        
        let vidHelpMode = getVideoHelpMode()
        videoModeSegControl.selectedSegmentIndex = vidHelpMode
        
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
        
        // InstrumentSettingsManager.sharedInstance.resetAdjustedAmpRise()
        
        // We wait to do this test here, in case they make a mistake in selecting an
        // instrument. We only commit and create the score file when leaving Settings screen.
        let currInstrument = getCurrentStudentInstrument()
        if currInstrument != savedCurrInstrument {
            _ = LessonScheduler.instance.loadScoreFile()
            RealTimeSettingsManager.instance.resetFor_CurrInst()
        }
        RealTimeSettingsManager.instance.resetFor_CurrBPM_AndLevel()
        
        let newVidHelpMode = videoModeSegControl.selectedSegmentIndex
        setVideoHelpMode(newMode: newVidHelpMode)
        
        super.viewWillDisappear(animated)
    }
    
    func returningFromMicCalibVC(didCalibrate: Bool) {
        print("in Setup::returningFromMicCalibVC()")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 &&
           indexPath.row == kTCIndex_PurchOptions {
            
            // JUNE15_2 was:
            //  showPurchOptionsAlert()
            
            if let parent = self.parent as? SettingsViewController {
                parent.performSegue(withIdentifier: "toPurchaseOptions", sender: nil)
            }
        }
    }

/* For original JUNE15 work:
    func showPurchOptionsAlert() {   // JUNE15
        let titleStr = "We are re-evaluating our purchase options"
        let msgStr = "\nUse PlayTunes for Free until June 15, 2020!\n\nAfter June 15, please go to the App Store for more information and to download the latest version of PlayTunes.\n\nNote: If you have purchased a subscription, please email us at Shawn@musikyoshi.com."
        
        let ac = MyUIAlertController(title: titleStr,
                                     message: msgStr,
                                     preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK",
                                   style: .default,
                                   handler: nil))
        ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor
        
        self.present(ac, animated: true, completion: nil)
    }
*/
    
    // Table View Cell indices
    let kTCIndex_InstPicker         = 0
    let kTCIndex_BPM                = 1
    let kTCIndex_CorrectionSettings = 2
    let kTCIndex_PurchOptions       = 3
    let kTCIndex_AmpRise            = 4
    let kTCIndex_IsASound           = 5
    let kTCIndex_MicCalibrate       = 6
    let kTCIndex_SmallestNoteWd     = 7
    let kTCIndex_SigWd              = 8

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == kTCIndex_InstPicker && showInstrumentPicker {
            return 200
        } else if indexPath.row <= kTCIndex_PurchOptions {
            return 64
        } else if indexPath.row == kTCIndex_AmpRise { // Amp rise sliders - only show if debug mode
            if gMKDebugOpt_ShowDebugSettingsBtn {
                return 300
            } else {
                return 0
            }
        } else if indexPath.row == kTCIndex_IsASound  ||    // only show these
                  indexPath.row == kTCIndex_MicCalibrate  { //      if in debug mode
            if gMKDebugOpt_ShowDebugSettingsBtn {
                return 64
            } else {
                return 0
            }
        }
        
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
