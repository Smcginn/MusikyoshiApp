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

    //    var amplitudeTracker: AKAmplitudeTracker!
    var frequencyTracker: AKFrequencyTracker!
    var microphone: AKMicrophone!
//    var trumpetSampler: AKSampler!
//    var ampedTSampler: AKBooster!

    static let sharedInstance = AudioKitManager()

    private override init () {
        AKSettings.audioInputEnabled = true
    }

    func setup() {
        AudioKit.stop()
        //monitor
        microphone = AKMicrophone()
        frequencyTracker = AKFrequencyTracker(microphone, hopSize: 200, peakCount: 300)
        let ampedFTrack = AKBooster(frequencyTracker, gain: 0.0)
        //        amplitudeTracker = AKAmplitudeTracker(microphone)
        //        let ampedATrack = AKBooster(amplitudeTracker, gain: 0.0)

//        //play
//        trumpetSampler = AKSampler()
//        trumpetSampler.loadWav("trumpetShort2")
//        ampedTSampler = AKBooster(trumpetSampler, gain: 3.0)

        //        let mixed = AKMixer(ampedFTrack, ampedATrack, ampedTSampler)
//        let mixed = AKMixer(ampedFTrack, ampedTSampler)
//        AudioKit.output = mixed
        AudioKit.output = ampedFTrack
        AudioKit.start()

        frequencyTracker.start()
        microphone.start()
        //can do:
        //        aTracker.start()
        //        aTracker.stop()
        //        tSampler.playNote(70)

    }

    func start() {
        AudioKit.start()
    }

    func stop() {
        AudioKit.stop()
    }

//    func playNote(noteID: Int, duration: Double) {
//        print("playNote \(noteID - 2)")
//        ampedTSampler.gain = 3.0
//        trumpetSampler.play(noteNumber: noteID - 2)
//        delay(duration, closure: {
//            self.ampedTSampler.gain = 0.0
//            self.trumpetSampler.stop(noteNumber: noteID - 2)
//        })
//    }

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
