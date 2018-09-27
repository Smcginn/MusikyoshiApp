//
//  AudioKitManager
//  FirstStage
//
//  Created by David S Reich on 12/04/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//

import AudioKit

class AudioKitManager: NSObject {
    static let minTrackingFrequency = Double(50)
    static let maxTrackingFrequency = Double(2000)
    static var minimumFrequency = AudioKitManager.minTrackingFrequency
    static var maximumFrequency = AudioKitManager.maxTrackingFrequency

    var frequencyTracker: AKFrequencyTracker!
	var microphone: AKMicrophone!

    static let sharedInstance = AudioKitManager()

    var isRunning = false
    var isSetup = false

    private override init () {
        if UIDevice.current.modelName == "Simulator" {
            print("AK:init() - In Simulator")
            kAmplitudeThresholdForIsSound = kAmpThresholdForIsSound_Sim
            kPlaybackVolume = kPlaybackVolume_Sim
            kAmpDropForNewSound = kAmpDropForNewSound_Sim

        } else {
            print("AK:init() - In Real Device")
            kAmplitudeThresholdForIsSound = kAmpThresholdForIsSound_HW
            kPlaybackVolume = kPlaybackVolume_HW
            kAmpDropForNewSound = kAmpDropForNewSound_HW
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
        AudioKit.stop()
        print("\n\n          In AudioKitManager.setup, rebuilding everything, recreating Mic, Tracker, etc.\n\n")

        microphone = AKMicrophone()
        frequencyTracker = AKFrequencyTracker(microphone, hopSize: 200, peakCount: 300)
         print("frequencyTracker == \(frequencyTracker)")
        
        let ampedFTrack = AKBooster(frequencyTracker, gain: 0.0 )
        AudioKit.output = ampedFTrack  // so there is no putput while using the mic

        AudioKit.start()
        frequencyTracker?.start()
        microphone.start()

        isRunning = true
        isSetup = true
    }
    
    func shutDownMicWorkMode() {
        
    }

    func start(forRecordToo: Bool) {
        
        return;
        
        
        guard !isRunning
            else { return }
        print("\n@@@@@     About to call AudioKit.start, then mic, then freqT")
 //       AudioKit.start()
        print("\n\n@@@@@     AudioKit started (in start method)\n")
        isRunning = true
    }

    func stop() {
        print("\n@@@@@       In AudioKit.stop() ! \n")
        
        if frequencyTracker != nil {
            frequencyTracker.stop()
        }
        if microphone != nil {
            microphone.stop()
        }
        
        AudioKit.stop()
        frequencyTracker = nil
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
