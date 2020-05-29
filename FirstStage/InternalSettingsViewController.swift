//
//  InternalSettingsViewController.swift
//  FirstStage
//
//  Created by Scott Freshour on 10/1/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

class InternalSettingsTableViewController : UITableViewController {

    let kDontSet = "DontSet"

    // Slider 1
    @IBOutlet weak var Slider1_Label: UILabel!
    @IBOutlet weak var Slider1_ValueLabel: UILabel!
    @IBOutlet weak var Slider1_Slider: UISlider!
    
    /*
     kNumTolAmpSamples      Int
     Rhythm threshold       Double
     
     kNumSamplesForStillSound
     IsSoundThreshold

     */
    // Slider 2 - kNumTolAmpSamples
    @IBOutlet weak var Slider2_Label: UILabel!
    @IBOutlet weak var Slider2_ValueLabel: UILabel!
    @IBOutlet weak var Slider2_Slider: UISlider!
    
    
    // Slider 3
    @IBOutlet weak var Slider3_Label: UILabel!
    @IBOutlet weak var Slider3_ValueLabel: UILabel!
    @IBOutlet weak var Slider3_Slider: UISlider!
    
    
    // Slider 4
    @IBOutlet weak var Slider4_Label: UILabel!
    @IBOutlet weak var Slider4_ValueLabel: UILabel!
    @IBOutlet weak var Slider4_Slider: UISlider!
   
    // Use Tol for all Levels switch
    @IBOutlet weak var UseTolForAllLevelsSwitch: UISwitch!
    @IBAction func UseTolForAllLevelsSwitch_Changed(_ sender: Any) {
        gAdjustAttackVar_VeryOff_DoOverride = UseTolForAllLevelsSwitch.isOn
    }
 
    // Correct Rhythm Sens Setting Slider
    @IBOutlet weak var correctRhythmSensSetting_Slider: UISlider!
    @IBOutlet weak var correctRhythmSensSetting_ValueLabel: UILabel!
    
    // Legato Pitch Slider
    @IBOutlet weak var numSampsForLegatoPtichSplit_Slider: UISlider!
    @IBOutlet weak var numSampsForLegatoPtichSplit_ValueLabel: UILabel!
    
    // Ejector Seat switch - NOTE:  This is now controlling Legato detection on/off
    @IBOutlet weak var EjectorSeatSwitch: UISwitch!
    @IBAction func EjectorSeatSwitch_Changed(_ sender: Any) {
        gScanForPitchDuringLegatoPlayingAbsolute = EjectorSeatSwitch.isOn
        
//        presentAmpRiseStatusAlert()
    }

    //////////////////////////////////////////////////
    // Amp Rise Sloew, Fast Sliders
    
    @IBOutlet weak var ampRiseSlow_ValueLabel: UILabel!
    @IBOutlet weak var ampRiseSlow_Slider: UISlider!
    
    @IBAction func ampRiseSlow_SliderChanged(_ sender: Any) {
        gAmpRiseChangeValue_Slow = Double(ampRiseSlow_Slider.value)
        let valStr = getTextForFloat(val: ampRiseSlow_Slider.value)
        ampRiseSlow_ValueLabel.text = valStr
        RealTimeSettingsManager.instance.resetRTSMAmpRise()
        ampRiseSlidersChanged = true
    }
    
    @IBOutlet weak var ampRiseFast_ValueLabel: UILabel!
    @IBOutlet weak var ampRiseFast_Slider: UISlider!
    
    @IBAction func ampRiseFast_SliderChanged(_ sender: Any) {
        gAmpRiseChangeValue_Slow = Double(ampRiseFast_Slider.value)
        let valStr = getTextForFloat(val: ampRiseFast_Slider.value)
        ampRiseFast_ValueLabel.text = valStr
        RealTimeSettingsManager.instance.resetRTSMAmpRise()
        ampRiseSlidersChanged = true
    }
    
    var ampRiseSlidersChanged = false
    
    
    @IBOutlet weak var ampRiseAutoCalcSwitch: UISwitch!
    
    @IBAction func ampRiseAutoCalcSwitch_Changed(_ sender: Any) {
        ampRiseSlidersChanged = true
        gUseAmpRiseChangeSlowFastValues = ampRiseAutoCalcSwitch.isOn
        ampRiseSlow_Slider.isEnabled = gUseAmpRiseChangeSlowFastValues
        ampRiseFast_Slider.isEnabled = gUseAmpRiseChangeSlowFastValues
    }
    
    //        var gUseAmpRiseChangeSlowFastValues = true
    //        var gAmpRiseChangeValue_Slow = Double(0.4)
    //        var gAmpRiseChangeValue_Fast = Double(0.6)
    func setupAmpRiseControls() {

        ampRiseAutoCalcSwitch.isOn = gUseAmpRiseChangeSlowFastValues
        
        setupSliderRow( slider: ampRiseSlow_Slider,
                        sliderMinVal: Float(kAmpRiseChangeSliderMinValue),
                        sliderMaxVal: Float(kAmpRiseChangeSliderMaxValue),
                        sliderCurrentVal: Float(gAmpRiseChangeValue_Slow),
                        label: Slider1_Label,
                        labelText: kDontSet,
                        valueLabel: ampRiseSlow_ValueLabel)
        ampRiseSlow_Slider.isEnabled = gUseAmpRiseChangeSlowFastValues
        
        setupSliderRow( slider: ampRiseFast_Slider,
                        sliderMinVal: Float(kAmpRiseChangeSliderMinValue),
                        sliderMaxVal: Float(kAmpRiseChangeSliderMaxValue),
                        sliderCurrentVal: Float(gAmpRiseChangeValue_Fast),
                        label: Slider1_Label,
                        labelText: kDontSet,
                        valueLabel: ampRiseFast_ValueLabel)
        ampRiseFast_Slider.isEnabled = gUseAmpRiseChangeSlowFastValues
//        let valStr = "\(gSamplesNeededToDeterminePitch)"
//        Slider1_ValueLabel.text = valStr
    }
    
    
    /*
    func presentAmpRiseStatusAlert() {
        let titleStr = "Amplitude Rise Checking"
        var msgStr = "\nYou have turned \nAmplitude Rise Checking "
        if gDoAmplitudeRiseChecking {
            msgStr += "ON"
        } else {
            msgStr += "OFF"
        }
        msgStr += "\n\n(Not Ejector Seat)"
        
        //msgStr += "\n\nYou Are Good To Go!\n\n"
        let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
//        var currFrame = ac.view.frame
//        currFrame.size.width += 150
//        ac.view.frame = currFrame
        ac.addAction(UIAlertAction(title: "OK", style: .default,
                                   handler: nil))
        //if parentVC != nil {
            self.present(ac, animated: true, completion: nil)
        //}
    }
    */
    
    
    
    
    // No Sound switch
    @IBOutlet weak var NoSoundSwitch: UISwitch!
    @IBAction func NoSoundSwitch_Changed(_ sender: Any) {
        PerfTrkMgr.instance.doDetectedDuringPerformance = NoSoundSwitch.isOn
    }
    
    
    
    ////////////////////////////////////////////////////////////
    // Slider 1 - gAmpDropForNewSound
    @IBAction func Slider1_SliderChanged(_ sender: Any) {
 
        gSamplesNeededToDeterminePitch = Int(Slider1_Slider.value)
        let valStr = "\(gSamplesNeededToDeterminePitch)"
        Slider1_ValueLabel.text = valStr

//        let labelText = "Samples Needed To Determine Pitch"
//        Slider1_Label.text = labelText


        //        let valStr = getTextForFloat(val: Float(gAmpDropForNewSound))
        //        Slider1_ValueLabel.text = valStr

        
//        gAmpDropForNewSound = tSoundAmpVal(Slider1_Slider.value)
//        let valStr = getTextForFloat(val: Float(gAmpDropForNewSound))
//        Slider1_ValueLabel.text = valStr
//        print ("\(valStr)")
    }
    
    ////////////////////////////////////////////////////////////
    // Slider 2 - gNumTolAmpSamples
    @IBAction func Slider2_SliderChanged(_ sender: Any) {
        let newVal = tSoundAmpVal(Slider2_Slider.value)
        let newValInt = Int(newVal)
//        gNumTolAmpSamples = newValInt
        let valStr = String(newValInt)
        Slider2_ValueLabel.text = valStr
        print ("\(valStr)")
    }
    
    ////////////////////////////////////////////////////////////
    // Slider 3 -
    @IBAction func Slider3_SliderChanged(_ sender: Any) {
        gSoundStartAdjustment = TimeInterval(Slider3_Slider.value)
        let valStr = getTextForFloat(val: Float(gSoundStartAdjustment))
        Slider3_ValueLabel.text = valStr
        print ("\(valStr)")
        clearGlobalRunningAttackDiffs()
    }
    
    ////////////////////////////////////////////////////////////
    // Slider 4 -
    @IBAction func Slider4_SliderChanged(_ sender: Any) {
        PerformanceAnalysisMgr.instance.currTolerances.rhythmTolerance = TimeInterval(Slider4_Slider.value)
        let valStr = getTextForFloat(val: Float(PerformanceAnalysisMgr.instance.currTolerances.rhythmTolerance))
        Slider4_ValueLabel.text = valStr
        print ("\(valStr)")

        
        
        
        
//        gAdjustAttackVar_VeryOff = TimeInterval(Slider4_Slider.value)
//        gAdjustAttackVar_VeryOffOverride = gAdjustAttackVar_VeryOff
//        let valStr = getTextForFloat(val: Float(gAdjustAttackVar_VeryOff))
//        Slider4_ValueLabel.text = valStr
//        print ("\(valStr)")
    }
    
    ////////////////////////////////////////////////////////////
    // Correct Rhythm Sens Setting Slider
    @IBAction func correctRhythmSensSetting_Changed(_ sender: Any) {
        gCalcedRhthymTolSetting = Int(correctRhythmSensSetting_Slider.value)
        correctRhythmSensSetting_ValueLabel.text = "\(gCalcedRhthymTolSetting)"
        print("\(gCalcedRhthymTolSetting)")
    }

    func setupCorrectRhythmSensSettingSlider() {
        correctRhythmSensSetting_Slider.minimumValue = Float(kMinCalcedRhthymTolSetting)
        correctRhythmSensSetting_Slider.maximumValue = Float(kMaxCalcedRhthymTolSetting)
        correctRhythmSensSetting_Slider.value = Float(gCalcedRhthymTolSetting)

        correctRhythmSensSetting_ValueLabel.text = "\(gCalcedRhthymTolSetting)"
        correctRhythmSensSetting_Slider.isEnabled = false
    }
    
    // doAutoCalcOfRealTimeSettingsSwitch: UISwitch!
    
    
    @IBOutlet weak var doAutoCalcOfRealTimeSettingsSwitch: UISwitch!

    @IBAction func doAutoCalcOfRealTimeSettingsSwitchChanged(_ sender: Any) {
        gUseOldRealtimeSettings = !doAutoCalcOfRealTimeSettingsSwitch.isOn
    }

    func setupAutoCalcOfRealTimeSettingsSwitch() {
        doAutoCalcOfRealTimeSettingsSwitch.isOn = !gUseOldRealtimeSettings
    }
    
    
    ////////////////////////////////////////////////////////////
    // Legato Pitch Split slider
    @IBAction func numSampsForLegatoPtichSplit_SliderChanged(_ sender: Any) {
        gDifferentPitchSampleThreshold =
            Int(numSampsForLegatoPtichSplit_Slider.value)
        let valStr = "\(gDifferentPitchSampleThreshold)"
        numSampsForLegatoPtichSplit_ValueLabel.text = valStr
        print ("\(valStr)")
    }
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        setupSlider1()
        setupSlider2()
        setupSlider3()
        setupSlider4()
        setupCorrectRhythmSensSettingSlider()
        setupLegatoSplitControls()
        setupAmpRiseControls()
        setupAutoCalcOfRealTimeSettingsSwitch()
        
        //Slider4_Label.text = "(This one does nothing for now)"
        
        UseTolForAllLevelsSwitch.isOn = gAdjustAttackVar_VeryOff_DoOverride
        UseTolForAllLevelsSwitch.isEnabled = false
        
        // EjectorSeatSwitch ia now used for ScanForPitchDuringLegatoPlayingAbsolute
        EjectorSeatSwitch.isOn = gScanForPitchDuringLegatoPlayingAbsolute
        
        NoSoundSwitch.isOn = PerfTrkMgr.instance.doDetectedDuringPerformance
        
        if !gUseOldRealtimeSettings {
            showAutoCalcOnAlert()
        }
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        RealTimeSettingsManager.instance.test_getRTSMAmpRiseImpl()
        RealTimeSettingsManager.instance.test_getRTSMIsASoundThrshldImpl()
        
        if ampRiseSlidersChanged {
            // TODO: call reset, etc.
            if self.isMovingFromParent {
                DispatchQueue.main.async {
                    self.showCurrAmpValueAlert()
                    //wrapperClass.BasicAlert("View is Dismissed", message: "", view: self)
                }
            }
        }
    }

    // TODO:  Put me in Misc
//    func getCurrBPM() -> TimeInterval {
//        let currBPM = UserDefaults.standard.double(forKey: Constants.Settings.BPM)
//        guard currBPM > 0 else {
//            itsBad()
//            return currBPM
//        }
//        
//        return currBPM
//    }
    
    func showAutoCalcOnAlert() {
        let titleStr = "Auto Calc of Settings Switch (bleow) is ON.\n This means that most of the settings on this screen will have no affect. (Turn it off to use these values,)"
        let msgStr = "\nThe Auto Calculate RelaTime Settings is "
        let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default,
                                   handler: nil))
        self.present(ac, animated: true, completion: nil)
    }
    

    func showCurrAmpValueAlert() {
        let currBPM = Int(getCurrBPM())
        guard currBPM > 0 else { return }

        let ampRiseStr =
            String(format: "%.2f", gRTSM_AmpRise)
        
        let titleStr = "New Amplitude Rise Value"
        let msgStr = "\nAt this tempo (\(currBPM) BPM) the AmpRise Change Value is: \(ampRiseStr)"
        let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default,
                                   handler: nil))
        self.present(ac, animated: true, completion: nil)
    }

    func setupSlider1() { // gAmpDropForNewSound
        // assume hardware
//        var sliderMinVal: Float = 0.01
//        var sliderMaxVal: Float = 0.3
//        if gRunningInSim {
//            sliderMinVal = 0.01
//            sliderMaxVal = 0.3
//            
//        }
//        
//        setupSliderRow( slider: Slider1_Slider,
//                        sliderMinVal: sliderMinVal,
//                        sliderMaxVal: sliderMaxVal,
//                        sliderCurrentVal: Float(gAmpDropForNewSound),
//                        label: Slider1_Label,
//                        labelText: "Amplitude Rise > new Note (0.3)",
//                        valueLabel: Slider1_ValueLabel)
//        Slider1_Slider.isEnabled = false
        
        
//        gSamplesNeededToDeterminePitch = Int(Slider1_Slider.value)
//        let valStr = "\(gSamplesNeededToDeterminePitch)"
//        Slider1_ValueLabel.text = valStr
        
        //        let labelText = "Samples Needed To Determine Pitch"
        //        Slider1_Label.text = labelText

        
//        gSamplesNeededToDeterminePitch = Int(Slider1_Slider.value)
//        let valStr = "\(gSamplesNeededToDeterminePitch)"
//        Slider1_ValueLabel.text = valStr
        
        let labelText = "Samples To Determine Pitch"
        
        let kMinSamplesNeededToDeterminePitch =  6
        let kMaxSamplesNeededToDeterminePitch = 40
 
        setupSliderRow( slider: Slider1_Slider,
                        sliderMinVal: Float(kMinSamplesNeededToDeterminePitch),
                        sliderMaxVal: Float(kMaxSamplesNeededToDeterminePitch),
                        sliderCurrentVal: Float(gSamplesNeededToDeterminePitch),
                        label: Slider1_Label,
                        labelText: labelText,
                        valueLabel: Slider1_ValueLabel)
        Slider1_Slider.isEnabled = true
        
        let valStr = "\(gSamplesNeededToDeterminePitch)"
        Slider1_ValueLabel.text = valStr
   }
    
    func setupSlider2() { // gNumTolAmpSamples
        // assume hardware
//        let sliderMinVal: Float = 2.0
//        let sliderMaxVal: Float = 8.0
//
//        setupSliderRow( slider: Slider2_Slider,
//                        sliderMinVal: sliderMinVal,
//                        sliderMaxVal: sliderMaxVal,
//                        sliderCurrentVal: Float(gNumTolAmpSamples),
//                        label: Slider2_Label,
//                        labelText: "Num samples Ampl Tol Zone",
//                        valueLabel: Slider2_ValueLabel)
//        let valInt = Int(gNumTolAmpSamples)
//        Slider2_ValueLabel.text = String(valInt)
        
        Slider2_Label.text = "   (Not Used)"
        Slider2_ValueLabel.text = "   ----"
        Slider2_Slider.isEnabled = false    }
    
    
    func setupSlider3() { // kSoundStartAdjustment
        // assume hardware
        let sliderMinVal: Float = 0.02
        let sliderMaxVal: Float = 0.275
        
//        let currentVal = gSoundStartAdjustment
        let currFloat  = Float(gSoundStartAdjustment)
        
        setupSliderRow( slider: Slider3_Slider,
                        sliderMinVal: sliderMinVal,
                        sliderMaxVal: sliderMaxVal,
                        sliderCurrentVal: currFloat,  // Float(gSoundStartAdjustment),
                        label: Slider3_Label,
                        labelText: "Sound Start Offset (.175)",
                        valueLabel: Slider3_ValueLabel)
        let curVal = Slider3_Slider.value
        print("\(curVal)")
    }
    
    func setupSlider4() { // gSoundStartAdjustment
        // assume hardware
        let sliderMinVal: Float = 0.1
        let sliderMaxVal: Float = 0.7
        
        let valToUse =
            Float(PerformanceAnalysisMgr.instance.currTolerances.rhythmTolerance)
        
        
        
        
        
//        let valToUse =
//            Float( gAdjustAttackVar_VeryOff_DoOverride ? gAdjustAttackVar_VeryOffOverride
//                                                       : gAdjustAttackVar_VeryOff)
        
        let currBPM = UserDefaults.standard.double(forKey: Constants.Settings.BPM)
        let currBPMInt = Int(currBPM)

        setupSliderRow( slider: Slider4_Slider,
                        sliderMinVal: sliderMinVal,
                        sliderMaxVal: sliderMaxVal,
                        sliderCurrentVal: valToUse,
                        label: Slider4_Label,
                        // labelText: "Rhythm Tolerance, at \(currBPMInt) BPM ",
                        labelText: "Rhythm Tolerance",
                        valueLabel: Slider4_ValueLabel)
        let curVal = Slider4_Slider.value
        print("\(curVal)")
        
        // Slider4_Slider.isEnabled = false
    }
    
    func setupLegatoSplitControls() {
        numSampsForLegatoPtichSplit_Slider.minimumValue = Float(3)
        numSampsForLegatoPtichSplit_Slider.maximumValue = Float(40)
        numSampsForLegatoPtichSplit_Slider.value =
                    Float(gDifferentPitchSampleThreshold)
        let valStr = "\(gDifferentPitchSampleThreshold)"
        numSampsForLegatoPtichSplit_ValueLabel.text = valStr
    }
    
	func getTextForFloat(val: Float) -> String {
        var retStr = "4.3"
        
        retStr = String(format: "%.3f", val)

        return retStr
    }
    
    func setupSliderRow( slider: UISlider?,
                         sliderMinVal: Float,
                         sliderMaxVal: Float,
                         sliderCurrentVal: Float,
                         label: UILabel?,
                         labelText: String,
                         valueLabel: UILabel?) {
        if labelText != kDontSet,
           let label = label {
            label.text = labelText
        }
        
        if let slider = slider {
            slider.minimumValue = sliderMinVal
            slider.maximumValue = sliderMaxVal
            slider.value = sliderCurrentVal
        }
        
        if let valueLabel = valueLabel {
            valueLabel.text = getTextForFloat(val: sliderCurrentVal)
        }
    }
    
}


/*
 
 To Do:
 
 Set values for each instrument in json
 
 retrieve per-instrumernt global Adjusted values or value ranges
 - In AppDelegate - for current instrument
 - when new instrument is chosen
 
 reset adjustable vales whenever Level is entered.
 
 Find every place previous vals were used in app, and substitute adjusted vals.
 
 
 
 */
