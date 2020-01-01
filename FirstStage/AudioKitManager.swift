//
//  AudioKitManager
//  FirstStage
//
//  Created by David S Reich on 12/04/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//

import UIKit
import AudioKit

let kUseSplitChaining = true

let kGainMultiplier = 10.0


class AudioKitManager: NSObject {
    static let minTrackingFrequency = Double(50)
    static let maxTrackingFrequency = Double(2000)
    static var minimumFrequency = AudioKitManager.minTrackingFrequency
    static var maximumFrequency = AudioKitManager.maxTrackingFrequency

    var amplitudeTracker: AKAmplitudeTracker!  ///   AMPLEAMPLE
    var frequencyTracker: AKFrequencyTracker!
	var microphone: AKMicrophone!
    var mixer: AKMixer!
    
    static let sharedInstance = AudioKitManager()

    var isRunning = false
    var isSetup = false

    private override init () {
        if UIDevice.current.modelName == "Simulator" {
            print("AK:init() - In Simulator")
            // kAmplitudeThresholdForIsSound now set elsewhere
            // kAmplitudeThresholdForIsSound = kAmpThresholdForIsSound_Sim
            kPlaybackVolume = kPlaybackVolume_Sim
            // FIXME: Need to make this work for per-instrument basis
            // gAmpDropForNewSound = kAmpDropForNewSound_Sim

        } else {
            print("AK:init() - In Real Device")
            // kAmplitudeThresholdForIsSound now set elsewhere
            // kAmplitudeThresholdForIsSound = kAmpThresholdForIsSound_HW
            kPlaybackVolume = kPlaybackVolume_HW
            // FIXME: Need to make this work for per-instrument basis
            //gAmpDropForNewSound = kAmpDropForNewSound_HW
        }
    }

    func enabledForcedReSetup() {
        print("\nAudioKitManager.enabledForcedReSetup() called \n")
        isSetup = false
//        AudioKit.stop()         // NEW Since Toehold
//        microphone = nil        // NEW Since Toehold
 //       frequencyTracker = nil  // NEW Since Toehold
    }
    

    func setupForUsingMic() {
        // AudioKit.stop()
 
        do {
            try AudioKit.stop()
        } catch let error as NSError {
            print(error.localizedDescription)
            guard error.code == 0 else {
                return }
        } catch let error {
            print(error)
            return
        }
        
        print("\n\n          In AudioKitManager.setup, rebuilding everything, recreating Mic, Tracker, etc.\n\n")


        // Attempting to analyze (fix?) the Crash were the output sampe rates don't match
        let ak_sampRate = AKSettings.sampleRate
        let ak_chanCount = AKSettings.channelCount

        let inChannelCount = AudioKit.engine.inputNode.inputFormat(forBus: 0).channelCount
        var inSampRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
        
        let outChannelCount = AudioKit.engine.outputNode.outputFormat(forBus: 0).channelCount
        var outSampRate = AudioKit.engine.outputNode.outputFormat(forBus: 0).sampleRate
        
//        let unusedVar1 = ak_sampRate * 2
//        let unusedVar2 = ak_chanCount * 2

        print("\n==============================================================")
        print("  Setting up AK stuff    - AKAKAK\n\n")
        print("      AKSettings.sampleRate                            = \(ak_sampRate)")
        print("      AKSettings.channelCount                          = \(ak_chanCount)")
        print("      AudioKit.engine.inputNode.inputFormatsampleRate  = \(inSampRate)")
        print("      AudioKit.engine.inputNode.inputFormatChanCount   = \(inChannelCount)")
        print("      AudioKit.engine.inputNode.outputFormatsampleRate = \(outSampRate)")
        print("      AudioKit.engine.inputNode.outputFormatChanCount  = \(outChannelCount)")
 
        /*
        if outSampRate != inSampRate || ak_sampRate != outSampRate {
            // Disabling. Restore commented code to enable bug fix.
            
            // This can cause a crash. Set them so they are equal. The output is often
            // lower than the input.
            if outSampRate != inSampRate {
                print("\n  !!!!!!  AKAKAK  !!!!!!   outSampRate != inSampRate  !!!!!!!\n\n")
            }
            if ak_sampRate != outSampRate {
                print("\n  !!!!!!  AKAKAK  !!!!!!   ak_sampRate != inSampRate  !!!!!!!\n\n")
            }

//            print("    outSampRate != inSampRate -  attempting to change")
//            AKSettings.sampleRate = si_sampleRate // 48000.0 // inSampRate
//            AKSettings.channelCount = outChannelCount
//            let outSampRate2 = AudioKit.engine.outputNode.outputFormat(forBus: 0).sampleRate
//            print("    New outSampRate = \(outSampRate2)\n\n")
        } else {
            print("\n\n")
        }
        
        delay(0.5) {}
*/
        
        // This seems to fix the device HW sample rate dosena't match the
        // requested sample rate
        var inputFormat = AudioKit.engine.inputNode.outputFormat(forBus: 0)
        AKLog("wrong rate---> session rate: \(AVAudioSession.sharedInstance().sampleRate) input rate: \(inputFormat.sampleRate)")
        inputFormat = AudioKit.engine.inputNode.outputFormat(forBus: 0)
        AKSettings.sampleRate = inputFormat.sampleRate
        AKSettings.channelCount = inputFormat.channelCount
        AKLog("correct rate--->  session rate: \(AVAudioSession.sharedInstance().sampleRate) input rate: \(inputFormat.sampleRate) aksettings rate:\(AKSettings.sampleRate)")
        
        microphone = AKMicrophone()

//======================================================
        // defaultd for below:
        //      hopSize: Int = 4_096,
        //      peakCount: Int = 20)
        // original David's
        //      hopSize: 200,
        //      peakCount: 300)
//        frequencyTracker = AKFrequencyTracker(microphone,
//                                              hopSize: 200,
//                                              peakCount: 1000)
//======================================================
        
        amplitudeTracker =
            AKAmplitudeTracker(microphone ) //,
//                               halfPowerPoint: <#T##Double#>,
//                               threshold: <#T##Double#>,
//                               thresholdCallback: nil) //<#T##AKThresholdCallback##AKThresholdCallback##(Bool) -> Void#>)

        print("amplitudeTracker == \(String(describing: amplitudeTracker))")

        //======================================================
        
        let kDefault_HopSize: Int   = 4_096
        let kDefault_PeakCount: Int =    20
        
        let kDavids_HopSize: Int    =   200
        let kDavids_PeakCount: Int  =  1000
        
        var hopSizeToUse:   Int = kDavids_HopSize
        var peakCountToUse: Int = kDavids_PeakCount
        if kUseDefaultHopSizeAndPeakCount {
            hopSizeToUse   = kDefault_HopSize
            peakCountToUse = kDefault_PeakCount
        }
        
        let storedHopSizeOverride =
            UserDefaults.standard.integer(forKey: Constants.Settings.UserHopSizeOverride)
        if storedHopSizeOverride >= 0 {
            hopSizeToUse = Int(storedHopSizeOverride)
        }
        let storedPeakCountOverride =
            UserDefaults.standard.integer(forKey: Constants.Settings.UserPeakCountOverride)
        if storedPeakCountOverride >= 0 {
            peakCountToUse = Int(storedPeakCountOverride)
        }
        
        print("\nFor AKFreqTracker, using  hop size: \(hopSizeToUse),   peak count: \(peakCountToUse)")
        
        if kUseSplitChaining {
            
            // Frequency Tracker Version 2  FTVER
            
            frequencyTracker = AKFrequencyTracker(microphone,
                                                  hopSize: hopSizeToUse, // 200,
                                                  peakCount: peakCountToUse) // 1000)
            let freqTrackerStr = String(describing: frequencyTracker)
            print("frequencyTracker == \(freqTrackerStr)")
            
            mixer = AKMixer(amplitudeTracker, frequencyTracker)
            let ampedFTrack2 = AKBooster(mixer, gain: 0.0 )
            AudioKit.output = ampedFTrack2  // so there is no putput while using the mic
        
        } else {  // not split chaining
            
            // Frequency Tracker Version 1  FTVER
            
            frequencyTracker = AKFrequencyTracker(amplitudeTracker,
                                                  hopSize: hopSizeToUse, // 200,
                                                  peakCount: peakCountToUse) // 1000)
            let freqTrackerStr = String(describing: frequencyTracker)
            print("frequencyTracker == \(freqTrackerStr)")

            let ampedFTrack = AKBooster(frequencyTracker, gain: 0.0 )
            AudioKit.output = ampedFTrack  // so there is no putput while using the mic
        }
        
        // AudioKit.start()
        do {
            try AudioKit.start()
        } catch let error as NSError {
            print(error.localizedDescription)
            guard error.code == 0 else {
                return }
        } catch let error {
            print(error)
            return
        }
        
        if mixer != nil { // Frequency Tracker Version 2  FTVER
            mixer?.start()
        }
        
        amplitudeTracker?.start()   ///   AMPLEAMPLE
        frequencyTracker?.start()
        
        microphone.start()

        var outputVol = microphone.volume
        if alwaysFalseToSuppressWarn() { print("\(outputVol)") }
        let currVal = microphone.volume
        microphone.volume = kGainMultiplier
        outputVol = microphone.volume

        isRunning = true
        isSetup = true
    }
    
    func shutDownMicWorkMode() {
        
    }

    func start(forRecordToo: Bool) {
        
        return;
        
        
//        guard !isRunning
//            else { return }
//        print("\n@@@@@     About to call AudioKit.start, then mic, then freqT")
// //       AudioKit.start()
//        print("\n\n@@@@@     AudioKit started (in start method)\n")
//        isRunning = true
    }

    func stop() {
        print("\n@@@@@       In AudioKit.stop() ! \n")
        
        if mixer != nil {
            mixer.stop()
        }
        if frequencyTracker != nil {
            frequencyTracker.stop()
        }
        if amplitudeTracker != nil { ///   AMPLEAMPLE
            amplitudeTracker.stop()
        }
        if microphone != nil {
            microphone.stop()
        }
        
        // AudioKit.stop()
        do {
            try AudioKit.stop()
        } catch let error as NSError {
            print(error.localizedDescription)
            guard error.code == 0 else {
                return }
        } catch let error {
            print(error)
            return
        }
        
        frequencyTracker = nil
        amplitudeTracker = nil ///   AMPLEAMPLE
        microphone       = nil
        
        
        return;
        
//        isRunning = false
    }
}

//class AudioKitManager: NSObject {
//
//    let microphone = AKMicrophone()
//    var analyzer: AKAudioAnalyzer!
//
//    var isSetup = false
//    var isStarted = false
//
//    static let sharedInstance = AudioKitManager()
//    
//    func setup() {
//        //don't setup twice
//        guard !isSetup else { return }
//        isSetup = true
//
//        AKSettings.shared().audioInputEnabled = true
//        
//        analyzer = AKAudioAnalyzer(input: microphone.output)
//        AKOrchestra.add(microphone)
//        AKOrchestra.add(analyzer)
//        
//    }
//
//    func start() {
//        //don't start twice
//        guard !isStarted else { return }
//        isStarted = true
//
//        analyzer.start()
//        microphone.start()
//    }
//
//    func stop() {
//        //don't stop twice
//        guard isStarted else { return }
//        isStarted = false
//        
//        analyzer.stop()
//        microphone.stop()
//    }
//    
//    func amplitude() -> Float {
//        //don't stop twice
//        guard isStarted else { return 0 }
//
//        return analyzer.trackedAmplitude.value
//    }
//
//    func frequency() -> Float {
//        //don't stop twice
//        guard isStarted else { return 0 }
//        
//        return analyzer.trackedFrequency.value
//    }
//}
