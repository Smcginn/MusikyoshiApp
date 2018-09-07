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

    var isRunning = false
    var isSetup = false

    private override init () {
        if UIDevice.current.modelName == "Simulator" {
            print("AK:init() - In Simulator")
            kAmplitudeThresholdForIsSound = kAmpThresholdForIsSound_Sim
            kPlaybackVolume = kPlaybackVolume_Sim
        } else {
            print("AK:init() - In Real Device")
            kAmplitudeThresholdForIsSound = kAmpThresholdForIsSound_HW
            kPlaybackVolume = kPlaybackVolume_HW
        }
        
        AKSettings.audioInputEnabled = true
        
 //       AKSettings.numberOfChannels = 1
        
//        let playbackVolume = kPlaybackVolume
//        let cat = AKSettings.computedSessionCategory()
//        
//        let opts = AKSettings.computedSessionOptions()
//        
//        let loc_notificationsEnabled = AKSettings.notificationsEnabled ? true : false
//        let loc_disableAVAudioSessionCategoryManagement = AKSettings.disableAVAudioSessionCategoryManagement ? true : false
//        let loc_enableRouteChangeHandling = AKSettings.enableRouteChangeHandling ? true : false
//        let loc_enableCategoryChangeHandling = AKSettings.enableCategoryChangeHandling ? true : false
//        let loc_appSupportsBackgroundAudio = AKSettings.appSupportsBackgroundAudio ? true : false
      
        print("yo")
    }

    func enabledForcedReSetup() {
        print("\n AudioKitManager.enabledForcedReSetup() called \n")
        isSetup = false
        AudioKit.stop()         // NEW Since Toehold
        microphone = nil        // NEW Since Toehold
        frequencyTracker = nil  // NEW Since Toehold
    }
    
    func setup() {
        guard !isSetup else { return }
        isSetup = true
        
//        if frequencyTracker != nil {
//            frequencyTracker.stop()
//        }
//        if microphone != nil {
//            microphone.stop()
//        }
        AudioKit.stop()
        //monitor
        
        print("\n\n          In AudioKitManager.setup, rebuilding everything, recreating Mic, Tracker, etc.\n\n")
        microphone = AKMicrophone()
        frequencyTracker = AKFrequencyTracker(microphone, hopSize: 200, peakCount: 300)
        print("frequencyTracker == \(frequencyTracker)")
        
        // was:
        // let ampedFTrack = AKBooster(frequencyTracker, gain: 0.0 )
        let ampedFTrack = AKBooster(frequencyTracker, gain: 1.0 ) // kPlaybackVolume) // was 0.0

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
        
       //  try AKSettings.sharedInstance().setCategory( category: AVAudioSessionCategoryPlayAndRecord,
        //                                             with: AVAudioSessionCategoryOptions.mixWithOthers )
        
//        try AKSettings.setSession(category: .playAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        
        AudioKit.start()
        print("\n\n@@@@@     AudioKit started (in setup method)\n")

        // I switched the order of these two:       SCF
        microphone.start()
        frequencyTracker.start()
        //can do:
        //        aTracker.start()
        //        aTracker.stop()
        //        tSampler.playNote(70)

        isRunning = true
 
        AKSettings.defaultToSpeaker = true
        do {
            
            //  try AKSettings.setSession(category: .playAndRecord, with:  AVAudioSessionCategoryOptions.defaultToSpeaker)
            
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
            if !AKSettings.headPhonesPlugged {
                try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            }
        } catch {
            print("Errored setting category.")
        }

    
    
    }

    func start() {
        guard !isRunning
            else { return }
        AudioKit.start()
        print("\n\n@@@@@     AudioKit started (in start method)\n")
        isRunning = true
    }

    func stop() {
        AudioKit.stop()
        print("\n@@@@@     AudioKit stopped (in stop method)\n\n")
        isRunning = false
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
