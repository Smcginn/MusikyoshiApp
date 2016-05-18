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
    
    var amplitudeTracker: AKAmplitudeTracker!
    var frequencyTracker: AKFrequencyTracker!
    var trackerBooster: AKBooster!
    var microphone: AKMicrophone!
    var microphoneBooster: AKBooster!
    var isSetup = false
    var justAmplitude = false
    var isStarted = false

    static let sharedInstance = AudioKitManager()

    private override init () {        
        AKSettings.audioInputEnabled = true
        AKSettings.defaultToSpeaker = true
    }

//    func setup(justAmplitude: Bool) {
//        self.justAmplitude = justAmplitude
//
//        AudioKit.stop()
//
//        //monitor
//        microphone = AKMicrophone()
//        if justAmplitude {
//            amplitudeTracker = AKAmplitudeTracker(microphone)
////            AudioKit.output = amplitudeTracker
//            trackerBooster = AKBooster(amplitudeTracker, gain: 0.0)
//        } else {
//            frequencyTracker = AKFrequencyTracker(microphone, minimumFrequency: 100, maximumFrequency: 2000)
////            AudioKit.output = frequencyTracker
//            trackerBooster = AKBooster(frequencyTracker, gain: 0.0)
//        }
//
//        AudioKit.output = trackerBooster
//        AudioKit.start()
//    }
    
    func setup(justAmplitude: Bool) {
        //don't setup twice
        guard !isSetup else { return }
        isSetup = true

        self.justAmplitude = justAmplitude
        
        AudioKit.stop()
        
        //monitor
        microphone = AKMicrophone()
        if justAmplitude {
//            amplitudeTracker = AKAmplitudeTracker(microphone)
            microphoneBooster = AKBooster(microphone, gain: 5.0)
            amplitudeTracker = AKAmplitudeTracker(microphoneBooster)
            //            AudioKit.output = amplitudeTracker
            trackerBooster = AKBooster(amplitudeTracker, gain: 0.0)
        } else {
//            frequencyTracker = AKFrequencyTracker(microphone, minimumFrequency: 100, maximumFrequency: 2000)
//            microphoneBooster = AKBooster(microphone, gain: 2.0)
            frequencyTracker = AKFrequencyTracker(microphone, minimumFrequency: 100, maximumFrequency: 2000)
            //            AudioKit.output = frequencyTracker
            trackerBooster = AKBooster(frequencyTracker, gain: 0.0)
        }
        
        AudioKit.output = trackerBooster
        AudioKit.start()
    }

    func start() {
        //don't start twice
        guard !isStarted else { return }
        isStarted = true

        if justAmplitude {
            amplitudeTracker.start()
        } else {
            frequencyTracker.start()
        }

//        trackerBooster.start()
        microphone.start()
    }

    func stop() {
        //don't stop twice
        guard isStarted else { return }
        isStarted = false
        
//        trackerBooster.stop()
        microphone.stop()

        if justAmplitude {
            amplitudeTracker.stop()
        } else {
            frequencyTracker.stop()
        }
    }
    
    func amplitude() -> Double {
        //don't stop twice
        guard isStarted else { return 0 }
        
        if justAmplitude {
            return amplitudeTracker.amplitude
        } else {
            return frequencyTracker.amplitude
        }
    }
}
