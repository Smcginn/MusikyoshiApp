//
//  InternalSettingsViewController.swift
//  FirstStage
//
//  Created by Scott Freshour on 10/1/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

class InternalSettingsTableViewController : UITableViewController {
    
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
    
    // Ejector Seat switch
    @IBOutlet weak var EjectorSeatSwitch: UISwitch!
    @IBAction func EjectorSeatSwitch_Changed(_ sender: Any) {
        doEjectorSeat = NoSoundSwitch.isOn
    }
    
    // No Sound switch
    @IBOutlet weak var NoSoundSwitch: UISwitch!
    @IBAction func NoSoundSwitch_Changed(_ sender: Any) {
        PerfTrkMgr.instance.doDetectedDuringPerformance = NoSoundSwitch.isOn
    }
    
    
    
    ////////////////////////////////////////////////////////////
    // Slider 1 - gAmpDropForNewSound
    @IBAction func Slider1_SliderChanged(_ sender: Any) {
 
        gAmpDropForNewSound = tSoundAmpVal(Slider1_Slider.value)
        let valStr = getTextForFloat(val: Float(gAmpDropForNewSound))
        Slider1_ValueLabel.text = valStr
        print ("\(valStr)")
    }
    
    ////////////////////////////////////////////////////////////
    // Slider 2 - gNumTolAmpSamples
    @IBAction func Slider2_SliderChanged(_ sender: Any) {
        let newVal = tSoundAmpVal(Slider2_Slider.value)
        let newValInt = Int(newVal)
        gNumTolAmpSamples = newValInt
        let valStr = String(newValInt)
        Slider2_ValueLabel.text = valStr
        print ("\(valStr)")
    }
    
    ////////////////////////////////////////////////////////////
    // Slider 3 -
    @IBAction func Slider3_SliderChanged(_ sender: Any) {
        kSoundStartAdjustment = TimeInterval(Slider3_Slider.value)
        let valStr = getTextForFloat(val: Float(kSoundStartAdjustment))
        Slider3_ValueLabel.text = valStr
        print ("\(valStr)")
        clearGlobalRunningAttackDiffs()
    }
    
    ////////////////////////////////////////////////////////////
    // Slider 4 -
    @IBAction func Slider4_SliderChanged(_ sender: Any) {
        gAdjustAttackVar_VeryOff = TimeInterval(Slider4_Slider.value)
        gAdjustAttackVar_VeryOffOverride = gAdjustAttackVar_VeryOff
        let valStr = getTextForFloat(val: Float(gAdjustAttackVar_VeryOff))
        Slider4_ValueLabel.text = valStr
        print ("\(valStr)")
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
        setupLegatoSplitCOntrols()
        //Slider4_Label.text = "(This one does nothing for now)"
        
        UseTolForAllLevelsSwitch.isOn = gAdjustAttackVar_VeryOff_DoOverride
        EjectorSeatSwitch.isOn = doEjectorSeat
        NoSoundSwitch.isOn = PerfTrkMgr.instance.doDetectedDuringPerformance
    }

    func setupSlider1() { // gAmpDropForNewSound
        // assume hardware
        var sliderMinVal: Float = 0.01
        var sliderMaxVal: Float = 0.3
        if kRunningInSim {
            sliderMinVal = 0.01
            sliderMaxVal = 0.3
            
        }
        
        setupSliderRow( slider: Slider1_Slider,
                        sliderMinVal: sliderMinVal,
                        sliderMaxVal: sliderMaxVal,
                        sliderCurrentVal: Float(gAmpDropForNewSound),
                        label: Slider1_Label,
                        labelText: "Amplitude Rise > new Note (0.3)",
                        valueLabel: Slider1_ValueLabel)
    }
    
    func setupSlider2() { // gNumTolAmpSamples
        // assume hardware
        let sliderMinVal: Float = 2.0
        let sliderMaxVal: Float = 8.0
        
        setupSliderRow( slider: Slider2_Slider,
                        sliderMinVal: sliderMinVal,
                        sliderMaxVal: sliderMaxVal,
                        sliderCurrentVal: Float(gNumTolAmpSamples),
                        label: Slider2_Label,
                        labelText: "Num samples Ampl Tol Zone",
                        valueLabel: Slider2_ValueLabel)
        let valInt = Int(gNumTolAmpSamples)
        Slider2_ValueLabel.text = String(valInt)
    }
    
    
    func setupSlider3() { // kSoundStartAdjustment
        // assume hardware
        let sliderMinVal: Float = 0.1
        let sliderMaxVal: Float = 0.275
        
        let currentVal = kSoundStartAdjustment
        let currFloat  = Float(kSoundStartAdjustment)
        
        setupSliderRow( slider: Slider3_Slider,
                        sliderMinVal: sliderMinVal,
                        sliderMaxVal: sliderMaxVal,
                        sliderCurrentVal: currFloat,  // Float(kSoundStartAdjustment),
                        label: Slider3_Label,
                        labelText: "Sound Start Offset (.175)",
                        valueLabel: Slider3_ValueLabel)
        let curVal = Slider3_Slider.value
        print("\(curVal)")
    }
    
    func setupSlider4() { // kSoundStartAdjustment
        // assume hardware
        let sliderMinVal: Float = 0.1
        let sliderMaxVal: Float = 0.7
        
        let valToUse =
            Float( gAdjustAttackVar_VeryOff_DoOverride ? gAdjustAttackVar_VeryOffOverride
                                                       : gAdjustAttackVar_VeryOff)
        
        let currBPM = UserDefaults.standard.double(forKey: Constants.Settings.BPM)
        let currBPMInt = Int(currBPM)

        setupSliderRow( slider: Slider4_Slider,
                        sliderMinVal: sliderMinVal,
                        sliderMaxVal: sliderMaxVal,
                        sliderCurrentVal: valToUse,
                        label: Slider4_Label,
                        labelText: "Rhythm Tolerance, at \(currBPMInt) BPM ",
                        valueLabel: Slider4_ValueLabel)
        let curVal = Slider4_Slider.value
        print("\(curVal)")
    }
    
    func setupLegatoSplitCOntrols() {
        numSampsForLegatoPtichSplit_Slider.minimumValue = Float(3)
        numSampsForLegatoPtichSplit_Slider.maximumValue = Float(12)
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
        if let label = label {
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
