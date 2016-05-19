//
//  AudioKitManager
//  FirstStage
//
//  Created by David S Reich on 12/04/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//


class AudioKitManager: NSObject {

    let microphone = AKMicrophone()
    var analyzer: AKAudioAnalyzer!

    var isSetup = false
    var isStarted = false

    static let sharedInstance = AudioKitManager()
    
    func setup() {
        //don't setup twice
        guard !isSetup else { return }
        isSetup = true

        AKSettings.shared().audioInputEnabled = true
        
        analyzer = AKAudioAnalyzer(input: microphone.output)
        AKOrchestra.addInstrument(microphone)
        AKOrchestra.addInstrument(analyzer)
        
    }

    func start() {
        //don't start twice
        guard !isStarted else { return }
        isStarted = true

        analyzer.start()
        microphone.start()
    }

    func stop() {
        //don't stop twice
        guard isStarted else { return }
        isStarted = false
        
        analyzer.stop()
        microphone.stop()
    }
    
    func amplitude() -> Float {
        //don't stop twice
        guard isStarted else { return 0 }

        return analyzer.trackedAmplitude.value
    }

    func frequency() -> Float {
        //don't stop twice
        guard isStarted else { return 0 }
        
        return analyzer.trackedFrequency.value
    }
}
