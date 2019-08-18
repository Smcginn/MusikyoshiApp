 //
//  IsASoundViewController.swift
//  FirstStage
//
//  Created by Scott Freshour on 10/22/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import AudioKit


// green = .725

 var gDontShowIsASoundOrientationAlert = false
 
class IsASoundViewController: UIViewController {
    
    var userChangedIsSoundThreshold = false
    var userChangedStartTimeOffset  = false
    var userChangedHopSize   = false
    var userChangedPeakCount = false
    
    let kMinIsSoundThreshold: Double = 0.01
    let kMaxIsSoundThreshold: Double = 0.3 // 0.15 // 0.4
    let kMaxVolumeForDisplay: Double = 1.25

    var storedIsASoundThreshold: Double = 0.123
    var currIsASoundThreshold:   Double = 0.1
    
    var storedLatencyOffset: Double = 0.0
    var currLatencyOffset:   Double = 0.1
    
    var lastBelowThresholdMaxVal: Double = 0.0
    var lastAboveThresholdMaxVal: Double = 0.0
    var range: Double = 1.0
    
    var timer = Timer()
    var amplitudeSampleRate = 0.01

    let kTrackTintDarkGreen = UIColor(red:   0.3,  green:  0.645,
                                      blue:  0.19,  alpha:  1.0)
    let kTrackTintRedish    = UIColor(red:   1.0,  green:  0.21,
                                      blue:  0.44,  alpha:  1.0)
    
    var storedHopSize:    Int = 200
    var currHopSize:      Int = 200
    
    var storedPeakCount:  Int = 1000
    var currPeakCount:    Int = 1000
    
    @IBOutlet weak var IsSoundSlider: UISlider!
    @IBOutlet weak var sliderValueLabel: UILabel!
    @IBOutlet weak var belowThreshooldProgressBar: UIProgressView!
    @IBOutlet weak var belowThresholdPeakProgressBar: UIProgressView!
    
    @IBOutlet weak var aboveThreshooldProgressBar: UIProgressView!
    @IBOutlet weak var aboveThresholdPeakProgressBar: UIProgressView!
    
    @IBOutlet weak var maxNotASoundValueLabel: UILabel!
    @IBOutlet weak var maxIsASoundValueLabel: UILabel!

    
    @IBOutlet weak var avgAttackDiffValueLabel: UILabel!
    @IBOutlet weak var currLatencyOffsetValueLabel: UILabel!
    @IBOutlet weak var currLatencyOffsetSlider: UISlider!
    @IBOutlet weak var currLatencyOffsetStepper: UIStepper!
    
    @IBOutlet weak var suggestedLatencyOffsetValueLabel: UILabel!
    
    // hop size and peak couunt
    //      Default_HopSize:   4_096.0
    //      Default_PeakCount:    20.0
    
    //      David's hopSize:     200.0
    //      David's peakCount:  1000.0
    
    // Hop Size:   David: 200,   Default: 4_096.0
    let hopSizeArray = [64, 128, 200, 256, 512, 1024, 2048, 4096]

    // Peak Count: David: 1000,  Default: 20
    let peakCountArray = [10, 20, 50, 75, 100, 150, 200, 300, 400,
                          500, 600, 700, 800, 900, 1000, 1100, 1200]

    @IBOutlet weak var hopSize_Slider: UISlider!
    @IBOutlet weak var peakCount_Slider: UISlider!
    
    @IBAction func hopSize_Slider_Changed(_ sender: Any) {
        let pos = Int(hopSize_Slider.value)
        _ = ASSUME( pos >= 0 && pos < hopSizeArray.count)
        let currHopSizeInt = hopSizeArray[pos]
        currHopSize = currHopSizeInt
        hopSize_Label.text = "\(currHopSize)"
        userChangedHopSize   = true
    }
    
    @IBAction func peakCount_Slider_Changed(_ sender: Any) {
        let pos = Int(peakCount_Slider.value)
        _ = ASSUME( pos >= 0 && pos < peakCountArray.count)
        let currPeakCountInt = peakCountArray[pos]
        currPeakCount = currPeakCountInt
        peakCount_Label.text = "\(currPeakCount)"
        userChangedPeakCount = true
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var hopSize_Label: UILabel!
    @IBOutlet weak var peakCount_Label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Orientation BS --> viewDidLoad
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.orientationLock = .landscapeRight
        AppDelegate.AppUtility.lockOrientationToLandscape()
        
        storedIsASoundThreshold = UserDefaults.standard.double(forKey: Constants.Settings.UserNoteThresholdOverride)
        currIsASoundThreshold   = kAmplitudeThresholdForIsSound
        if storedIsASoundThreshold > 0.01 { // it's been set if not == 0.0
            currIsASoundThreshold = storedIsASoundThreshold
        }
        
        IsSoundSlider.minimumValue = Float(kMinIsSoundThreshold)
        IsSoundSlider.maximumValue = Float(kMaxIsSoundThreshold)
        IsSoundSlider.value = Float(currIsASoundThreshold)
        setSliderLabel(val: currIsASoundThreshold)
        resetNotASoundValues()
        resetIsASoundValues()
        
        range = kMaxVolumeForDisplay - currIsASoundThreshold
        print ("Range = \(range)")

        setupProgressBars()
        setupTimingOffsetControls()
        
        // =========================================
 
        let storedHopSizeOverride =
            UserDefaults.standard.integer(forKey: Constants.Settings.UserHopSizeOverride)
        if storedHopSizeOverride >= 0 {
            currHopSize = storedHopSizeOverride
        }
        let numHopSizes = hopSizeArray.count
        let kMinHopSize = 0
        let kMaxHopSize = numHopSizes-1

        hopSize_Slider.minimumValue = Float(kMinHopSize)
        hopSize_Slider.maximumValue = Float(kMaxHopSize)
        let hsPos = getHopSizePosFromValue(value: Float(currHopSize))
        _ = ASSUME( hsPos >= 0 && hsPos < numHopSizes)
        hopSize_Slider.value = Float(hsPos) // hopSizeArray[2])
        hopSize_Label.text = "\(currHopSize)"

        // =========================================
        
        let storedPeakCountOverride =
            UserDefaults.standard.integer(forKey: Constants.Settings.UserPeakCountOverride)
        if storedPeakCountOverride >= 0 {
            currPeakCount = storedPeakCountOverride
        }
        let numPeakCounts = peakCountArray.count
        let kMinPeakCountSize = 0
        let kMaxPeakCountSize = numPeakCounts-1
 
        peakCount_Slider.minimumValue = Float(kMinPeakCountSize)
        peakCount_Slider.maximumValue = Float(kMaxPeakCountSize)
        let pcPos = getPeakCountPosFromValue(value: Float(currPeakCount))
        _ = ASSUME( pcPos >= 0 && pcPos < numPeakCounts)
        peakCount_Slider.value = Float(pcPos)
        peakCount_Label.text = "\(currPeakCount)"
    }
    
    func setupTimingOffsetControls() {
        currLatencyOffset = kSoundStartAdjustment
        storedLatencyOffset =
            UserDefaults.standard.double(forKey: Constants.Settings.UserLatencyOffsetThresholdOverride)
        if storedLatencyOffset > 0.001 { // defaulted to 0; > .01 means it's been set
            currLatencyOffset = storedLatencyOffset
        }
        currLatencyOffsetStepper.value = 0
        
        currLatencyOffsetSlider.minimumValue = kSoundStartAdjustment_MinValue
        currLatencyOffsetSlider.maximumValue = kSoundStartAdjustment_MaxValue
        
        currLatencyOffsetSlider.value = Float(currLatencyOffset)
        let soundStartAdjustmentStr = String(format: "%.3f", currLatencyOffset)
        currLatencyOffsetValueLabel.text = soundStartAdjustmentStr
        
        if gRunningAvgAttackDiffAvailable {
            let avgAttackDiffStr = String(format: "%.3f", gRunningAvgAttackDiff)
            avgAttackDiffValueLabel.text = avgAttackDiffStr
            
            var suggestedVal = kSoundStartAdjustment + gRunningAvgAttackDiff
            if suggestedVal > Double(kSoundStartAdjustment_MaxValue) {
                suggestedVal = Double(kSoundStartAdjustment_MaxValue)
            }
            if suggestedVal < Double(kSoundStartAdjustment_MinValue) {
                suggestedVal = Double(kSoundStartAdjustment_MinValue)
            }
            let suggestedValStr = String(format: "%.3f", suggestedVal)
            suggestedLatencyOffsetValueLabel.text = suggestedValStr
        } else {
            suggestedLatencyOffsetValueLabel.text = "---"
            avgAttackDiffValueLabel.text = "---"
        }
    }
    
    func setupProgressBars() {
        belowThreshooldProgressBar.progress = 0.0
        belowThreshooldProgressBar.transform =
            belowThreshooldProgressBar.transform.scaledBy(x: 1, y: 5)
        belowThreshooldProgressBar.trackTintColor =
            (UIColor.lightGray).withAlphaComponent(0.05)
        belowThreshooldProgressBar.tintColor = kTrackTintRedish

        belowThresholdPeakProgressBar.progress = 0.0
        belowThresholdPeakProgressBar.trackTintColor =
            (UIColor.lightGray).withAlphaComponent(0.05)
        belowThresholdPeakProgressBar.tintColor = kTrackTintRedish.withAlphaComponent(0.4)

        aboveThreshooldProgressBar.progress = 0.0
        aboveThreshooldProgressBar.transform =
            aboveThreshooldProgressBar.transform.scaledBy(x: 1, y: 5)
        aboveThreshooldProgressBar.trackTintColor =
            (UIColor.lightGray).withAlphaComponent(0.05)
        aboveThreshooldProgressBar.tintColor = kTrackTintDarkGreen

        aboveThresholdPeakProgressBar.progress = 0.0
        aboveThresholdPeakProgressBar.trackTintColor =
            (UIColor.lightGray).withAlphaComponent(0.05)
        aboveThresholdPeakProgressBar.tintColor = kTrackTintDarkGreen.withAlphaComponent(0.85)
    }
    
    @IBAction func currLatencyOffsetSlider_Changed(_ sender: Any) {
        currLatencyOffset = Double(currLatencyOffsetSlider.value)
        let soundStartAdjustmentStr = String(format: "%.3f", currLatencyOffset)
        currLatencyOffsetValueLabel.text = soundStartAdjustmentStr
        userChangedStartTimeOffset = true
    }
    
    @IBAction func currLatencyOffsetStepper_Changed(_ sender: Any) {
        if currLatencyOffsetStepper.value > 0 {
            currLatencyOffset += 0.001
        } else if currLatencyOffsetStepper.value < 0 {
            currLatencyOffset -= 0.001
        }
        if currLatencyOffset > Double(kSoundStartAdjustment_MaxValue) {
            currLatencyOffset = Double(kSoundStartAdjustment_MaxValue)
        }
        if currLatencyOffset < Double(kSoundStartAdjustment_MinValue) {
            currLatencyOffset = Double(kSoundStartAdjustment_MinValue)
        }
        currLatencyOffsetSlider.value = Float(currLatencyOffset)
        let soundStartAdjustmentStr = String(format: "%.3f", currLatencyOffset)
        currLatencyOffsetValueLabel.text = soundStartAdjustmentStr
        userChangedStartTimeOffset = true
        currLatencyOffsetStepper.value = 0
    }
    
    func getHopSizePosFromValue(value: Float) -> Int {
        var retVal = 0
        switch value {
        case   64: retVal = 0
        case  128: retVal = 1
        case  200: retVal = 2
        case  256: retVal = 3
        case  512: retVal = 4
        case 1024: retVal = 5
        case 2048: retVal = 6
        case 4096: retVal = 7
        default:  retVal = 2
        }
        return retVal
    }
    
    func getPeakCountPosFromValue(value: Float) -> Int {
//        10, 20, 50, 75, 100, 150, 200, 300, 400,
//        500, 600, 700, 800, 900, 1000, 1100, 1200
        var retVal = 0
        switch value {
        case    10: retVal = 0
        case    20: retVal = 1
        case    50: retVal = 2
        case    75: retVal = 3
        case   100: retVal = 4
        case   150: retVal = 5
        case   200: retVal = 6
        case   300: retVal = 7
        case   400: retVal = 8
        case   500: retVal = 9
        case   600: retVal = 10
        case   700: retVal = 11
        case   800: retVal = 12
        case   900: retVal = 13
        case  1000: retVal = 14
        case  1100: retVal = 15
        case  1200: retVal = 16
        default:  retVal = 14
        }
        return retVal
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = AVAudioSessionManager.sharedInstance.setupAudioSession(sessionMode: .usingMicMode)
        timer = Timer.scheduledTimer(
            timeInterval: amplitudeSampleRate,
            target: self,
            selector: #selector(IsASoundViewController.updateTracking),
            userInfo: nil,
            repeats: true)
        if !gDontShowIsASoundOrientationAlert {
            displayOrientationAlert()
        }
   }

    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        timer.invalidate()
        AudioKitManager.sharedInstance.stop()
        
        kAmplitudeThresholdForIsSound = currIsASoundThreshold
        saveData()
    }
    
	override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        belowThreshooldProgressBar.trackTintColor = (UIColor.lightGray).withAlphaComponent(0.05)
        aboveThreshooldProgressBar.trackTintColor = (UIColor.lightGray).withAlphaComponent(0.05)

	}
    
    
    var belowThresholdMaxProgressPercent: Float = 0.0
    var aboveThresholdMaxProgressPercent: Float = 0.0
    @objc func updateTracking()
    {
        var amplitude = 0.0
        if AudioKitManager.sharedInstance.frequencyTracker != nil {
            amplitude = AudioKitManager.sharedInstance.frequencyTracker.amplitude
        }
        printAmplitude(currAmp: amplitude, at: 0.0, atComp: 0.0)

        ////////////////////////////////////////////
        // Below Threshold
        
        if amplitude < currIsASoundThreshold {
            let percent = amplitude/currIsASoundThreshold
            belowThreshooldProgressBar.progress = Float(percent)
            if amplitude > lastBelowThresholdMaxVal {
                lastBelowThresholdMaxVal = amplitude
                belowThresholdMaxProgressPercent = Float(percent)
            }
        } else {
            belowThreshooldProgressBar.progress = 1.0
            belowThresholdMaxProgressPercent = 1.0
            lastBelowThresholdMaxVal = currIsASoundThreshold
        }
        belowThresholdPeakProgressBar.progress = belowThresholdMaxProgressPercent
        maxNotASoundValueLabel.text =
            String(format: "%.3f", lastBelowThresholdMaxVal)

        ////////////////////////////////////////////
        // Above Threshold

        if amplitude > lastAboveThresholdMaxVal {
            lastAboveThresholdMaxVal = amplitude
        }
        if amplitude > currIsASoundThreshold {
            _ = ASSUME( range != 0.0 )
            
            let amountOverThreshold = amplitude - currIsASoundThreshold
            let percent = Float(amountOverThreshold/range)
            aboveThreshooldProgressBar.progress = percent
            maxIsASoundValueLabel.text =
                String(format: "%.3f", lastAboveThresholdMaxVal)
            if percent > aboveThresholdMaxProgressPercent {
                aboveThresholdMaxProgressPercent = percent
            }
        } else {
            aboveThreshooldProgressBar.progress = 0.0
        }
        aboveThresholdPeakProgressBar.progress = aboveThresholdMaxProgressPercent

    }
    
    
    ////////////////////////////////////////////////////////////
    //   Slider and Label
    
    func setSliderLabel(val: Double) {
        let sliderStr = String(format: "%.3f", val)
        sliderValueLabel.text = sliderStr // String(format: "%.3f", val)
    }
    
    @IBAction func ssSoundSliderChanged(_ sender: Any) {
        userChangedIsSoundThreshold = true
        currIsASoundThreshold = Double(IsSoundSlider.value)
        setSliderLabel(val: currIsASoundThreshold)
        range = kMaxVolumeForDisplay - currIsASoundThreshold
        print ("Range = \(range)")
        resetNotASoundValues()
        resetIsASoundValues()
    }
    
    ////////////////////////////////////////////////////////////
    // Below Threshold
    
    func resetNotASoundValues() {
        lastBelowThresholdMaxVal = 0.0
        maxNotASoundValueLabel.text = "-"
            //String(format: "%.2f", lastBelowThresholdMaxVal)
    }
    
    @IBAction func resetNotASoundBtnPressed(_ sender: Any) {
        resetNotASoundValues()
        resetIsASoundValues()
    }
    
    func setBelowThresholdMaxValueAndLabel(currValue: Double) {
        if currValue > lastBelowThresholdMaxVal {
            if currValue >= currIsASoundThreshold {
                lastBelowThresholdMaxVal = currIsASoundThreshold
            } else {
                lastBelowThresholdMaxVal = currValue
            }
            maxNotASoundValueLabel.text =
                String(format: "%.3f", lastBelowThresholdMaxVal)
        }
    }
    
    func setCurrMinValueProgressBar() {
        let percentage = lastBelowThresholdMaxVal/currIsASoundThreshold
        belowThreshooldProgressBar.progress = Float(percentage)
    }
    
    ////////////////////////////////////////////////////////////
    // Above Threshold
    
    func resetIsASoundValues() {
        lastAboveThresholdMaxVal = currIsASoundThreshold
        maxIsASoundValueLabel.text = "-"
           //  String(format: "%.3f", 0.0)
        belowThresholdMaxProgressPercent = 0.0
        aboveThresholdMaxProgressPercent = 0.0
    }
    
    @IBAction func resetIsASoundBtnPressed(_ sender: Any) {
        resetIsASoundValues()
    }
    
    func setAboveThresholdMaxValueAndLabel(currValue: Double) {
        if currValue > lastAboveThresholdMaxVal {
            lastAboveThresholdMaxVal = currValue
            maxIsASoundValueLabel.text = String(format: "%.3f", currValue)
        }
    }
    
    func setCurrMaxValueProgressBar() {
        let aboveThresholdRrange = kMaxVolumeForDisplay - currIsASoundThreshold
        let percentage = lastAboveThresholdMaxVal/aboveThresholdRrange
        aboveThreshooldProgressBar.progress = Float(percentage)
    }
    
    func dontShowThisAlertAgainHandler(_ act: UIAlertAction) {
        gDontShowIsASoundOrientationAlert = true
    }

    func displayOrientationAlert() {
        let ac = MyUIAlertController(title: "If Orientation isn't Landscape",
                                     message: "\nThere can be a slight bug with this screen (which is not part of the release prodcut). If the Orientation isn't Landscape, go back to settings and lauch it again.",
                                     preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK",  style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "OK (and don't show this alert again)",
                                   style: .default,
                                   handler: dontShowThisAlertAgainHandler))
        ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor
        
        self.present(ac, animated: true, completion: nil)
    }
    
    
    func saveData() {

        if userChangedStartTimeOffset {
            clearGlobalRunningAttackDiffs()
            kSoundStartAdjustment = currLatencyOffset
            UserDefaults.standard.set(currLatencyOffset,
                                      forKey: Constants.Settings.UserLatencyOffsetThresholdOverride)
        }
        
        if userChangedIsSoundThreshold {
            UserDefaults.standard.set(currIsASoundThreshold,
                                      forKey: Constants.Settings.UserNoteThresholdOverride)
        }
        
        if userChangedHopSize {
            UserDefaults.standard.set(currHopSize,
                                      forKey: Constants.Settings.UserHopSizeOverride)
        }
        
        if userChangedPeakCount {
            UserDefaults.standard.set(currPeakCount,
                                      forKey: Constants.Settings.UserPeakCountOverride)
        }
    }
}
