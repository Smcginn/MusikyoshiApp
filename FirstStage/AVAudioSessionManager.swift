
//
//  AVAudioSessionManager.swift
//  FirstStage
//
//  Created by David S Reich on 22/05/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//

import UIKit
import AudioKit

enum AudioSessMode {
    case playbackMode
    case usingMicMode
}


class AVAudioSessionManager: NSObject {

    var isSetup = false
    var isStarted = false
    var currentMode: AudioSessMode = .playbackMode
    
    static let sharedInstance = AVAudioSessionManager()
    
    
    // forImmediateUse: if sessionMode == usingMicMode, forImmediateUse specifies
    //                  whether to set the Mode for Measurement immediatley, or
    //                  to set the mode to the default, and a latter call will
    //                  set the mode to Measurement
    func setupAudioSession(sessionMode: AudioSessMode,
                           forImmediateUse: Bool = true) -> Bool {
        
        AudioKitManager.sharedInstance.stop()
        
        print ("\n\n@@@@@@    In AVAudioSessionManager.setupAudioSession(), continuing with setup\n\n")
        
        // Configure the audio session
        let sessionInstance = AVAudioSession.sharedInstance()
//        var catStr = sessionInstance.category
        
        
//        do {
//            try sessionInstance.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
//            catStr = sessionInstance.category
//
//
//        } catch let error as NSError {
//            print(error.localizedDescription)
//            guard error.code == 0 else { return false }
//        } catch let error {
//            print(error)
//            return false
//        }

        //set inactive before making changes
        print ("  Calling sessionInstance.setActive(false)")
        do {
            try sessionInstance.setActive(false)
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch let error {
            print(error)
        }
 //       catStr = sessionInstance.category

        // Was here (and didn't work . . )
//        if sessionMode == .usingMicMode {
//            AudioKitManager.sharedInstance.setupForUsingMic()   // SFAUDIO
//        } else {
//            AudioKitManager.sharedInstance.setupForJustPlayback()
//        }
        
//
//        if !AudioKitManager.sharedInstance.isRunning {
//            print("  About to call AudioKit.setup")
//            AudioKitManager.sharedInstance.setup()   // SFAUDIO
//        } else {
//            print("  Didn't call AudioKit.setup; bc AVAKMgr.isRunning laready tru")
//
//        }
 //       catStr = sessionInstance.category
        
/*
    open func setCategory(_ category: String,
                          with options: AVAudioSessionCategoryOptions = []) throws

         open func setCategory(_ category: String,
                                 mode: String,
                                 options: AVAudioSessionCategoryOptions = []) throws

         open func setCategory(_ category: String,
                                 mode: String,
                                 routeSharingPolicy policy: AVAudioSessionRouteSharingPolicy,
                                 options: AVAudioSessionCategoryOptions = []) throws
 
         /* Returns an enum indicating whether the user has granted or denied permission to record, or has not been asked */
         @available(iOS 8.0, *)
         open func recordPermission() -> AVAudioSessionRecordPermission
         
         open func requestRecordPermission(_ response: @escaping AVFoundation.PermissionBlock)
         
         /* A description of the current route, consisting of zero or more input ports and zero or more output ports */
         @available(iOS 6.0, *)
         open var currentRoute: AVAudioSessionRouteDescription { get }

         */

        /* keep, for reference
        let availCats     = sessionInstance.availableCategories
        let availModes    = sessionInstance.availableModes
        let availOptions  = sessionInstance.categoryOptions
        */
        
        do {
            if sessionMode == .usingMicMode {
                print("  About to call MULTI  AudioSess.setCat(AVAudioSessionCategoryPlayAndRecord)")
                let sessMode = AVAudioSession.Mode.measurement      // AVAudioSessionModeDefault
//                if !forImmediateUse {
//                    // AVAudioSessionModeDefault is used here so Metronome can be heard.
//                    // Will be set to AVAudioSessionModeMeasurement in a subsequent
//                    // call to setSessionMode() (below) just before mic analysis begins
//                    sessMode = AVAudioSessionModeDefault
//                }
                try sessionInstance.setCategory(
                    AVAudioSession.Category.playAndRecord,
                            mode: sessMode,
                            options: AVAudioSession.CategoryOptions.defaultToSpeaker)
                print("  About to call AudioSess.overrideOutputAudioPort)")
                if !AKSettings.headPhonesPlugged {
                    try sessionInstance.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                }
                
            } else { // Playback
                print("  About to call MULTI AudioSess.setCat(AVAudioSessionCategoryPlayback)")
                // try sessionInstance.setCategory(AVAudioSessionCategoryPlayback,
                //                                 with:AVAudioSessionCategoryOptions.defaultToSpeaker)
                // MixWithOthers, duckOthers, InterruptSpokenAudioAndMixWithOthers
                
                try sessionInstance.setCategory(
                    AVAudioSession.Category.playback,
                    mode: AVAudioSession.Mode.moviePlayback, //AVAudioSessionModeDefault
                    options: AVAudioSession.CategoryOptions.duckOthers)
                
//                print("  About to call AudioSess.overrideOutputAudioPort)")
//                if !AKSettings.headPhonesPlugged {
//                    try sessionInstance.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
//                }
            }
        } catch let error as NSError {
            print("  ERROR in call to AudioSess.setCat() or OverrideAudioPort")
            print(error.localizedDescription)
            let ec = error.code
            print("  ErrorCode == \(ec)")
            guard error.code == 0 else {
                return false }
        } catch let error {
            print("  ERROR in call to AudioSess.setCat()")
            print(error)
            return false
        }
 
        delay(0.5) {}

        if sessionMode == .usingMicMode  {

            let bufferDuration = TimeInterval.init(floatLiteral: 0.005)
            do {
                try sessionInstance.setPreferredIOBufferDuration(bufferDuration)
            } catch let error as NSError {
                print(error.localizedDescription)
                guard error.code == 0 else {
                    return false }
            } catch let error {
                print(error)
                return false
            }

            let hwSampleRate = 44100.0;
            do {
                try sessionInstance.setPreferredSampleRate(hwSampleRate)
            } catch let error as NSError {
                print(error.localizedDescription)
                guard error.code == 0 else {
                    return false }
            } catch let error {
                print(error)
                return false
            }

        } // if sessionMode == .usingMicMode
        
        /*
        else {
            do {
                print("  About to call AudioSess.setMode(AVAudioSessionModeMoviePlayback)")
                try sessionInstance.setMode(AVAudioSessionModeMoviePlayback)
                // try sessionInstance.setMode(AVAudioSessionModeMeasurement)
            } catch let error as NSError {
                print("  ERROR in call to AudioSess.setMode()")
                print(error.localizedDescription)
                guard error.code == 0 else {
                    return false }
            } catch let error {
                print("  ERROR in call to AudioSess.setMode()")
                print(error)
                return false
            }
        }
        */

        // add interruption handler
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: sessionInstance)
        
        // we don't do anything special in the route change notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: sessionInstance)
        
        // we don't do anything special in the media server reset notification
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleMediaServerReset), name: AVAudioSessionMediaServicesWereResetNotification, object: sessionInstance)
        
        // activate the audio session
        do {
            try sessionInstance.setActive(true)
        } catch let error as NSError {
            print(error.localizedDescription)
            guard error.code == 0 else {
                return false }
        } catch let error {
            print(error)
            return false
        }
        
        if sessionMode == .usingMicMode {
            AudioKitManager.sharedInstance.setupForUsingMic()
        }
        
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        
        for output in currentRoute.outputs {
            
            switch output.portType {
                
            case AVAudioSession.Port.headphones:
                print("Headphones are on.")
            case AVAudioSession.Port.builtInSpeaker:
                print("Speaker is on.")
            default:
                break
            }
        }
        
        print ("@@@@@@    Exiting AVAudioSessionManager.setupAudioSession()\n\n")
        return true
    }

    /*    Keep, just in case
    // NOT CALLED
    func extraSetupForCountdown(turnSpeakerOn: Bool) -> Bool {
        let sessionInstance = AVAudioSession.sharedInstance()
        
        if turnSpeakerOn { // in countdown, need to hear metronome
            do {
                try sessionInstance.setMode(AVAudioSessionModeDefault) //AVAudioSessionModeMoviePlayback)
            } catch let error as NSError {
                print("  ERROR in call to AudioSess.setMode()")
                print(error.localizedDescription)
                guard error.code == 0 else {
                    return false }
            } catch let error {
                print("  ERROR in call to AudioSess.setMode()")
                print(error)
                return false
            }

        } else {  // done with countdown, shift to analysis
            
 //           let hwSampleRate = 44100.0;
            do {
                print("  About to call AudioSess.setMode(AVAudioSessionModeMeasurement)")
                try sessionInstance.setMode(AVAudioSessionModeMoviePlayback)
                //try sessionInstance.setMode(AVAudioSessionModeMeasurement)
             } catch let error as NSError {
                print("  ERROR in call to AudioSess.setMode()")
                print(error.localizedDescription)
                guard error.code == 0 else {
                    return false }
            } catch let error {
                print("  ERROR in call to AudioSess.setMode()")
                print(error)
                return false
            }

            
            
            
            / *
            let bufferDuration = TimeInterval.init(floatLiteral: 0.005)
            let hwSampleRate = 44100.0;
            do {
                print("  About to call AudioSess.setMode(AVAudioSessionModeMeasurement)")
                //try sessionInstance.setMode(AVAudioSessionModeMoviePlayback)
                try sessionInstance.setMode(AVAudioSessionModeMeasurement)
                try sessionInstance.setPreferredIOBufferDuration(bufferDuration)
                try sessionInstance.setPreferredSampleRate(hwSampleRate)
            } catch let error as NSError {
                print("  ERROR in call to AudioSess.setMode()")
                print(error.localizedDescription)
                guard error.code == 0 else {
                    return false }
            } catch let error {
                print("  ERROR in call to AudioSess.setMode()")
                print(error)
                return false
            }
 * /
        }
        return true
        
            / *
         
             do {
                try sessionInstance.setPreferredIOBufferDuration(bufferDuration)
            } catch let error as NSError {
                print(error.localizedDescription)
                guard error.code == 0 else {
                    return false }
            } catch let error {
                print(error)
                return false
            }
            //       catStr = sessionInstance.category
         
         
            let hwSampleRate = 44100.0;
            do {
                try sessionInstance.setPreferredSampleRate(hwSampleRate)
            } catch let error as NSError {
                print(error.localizedDescription)
                guard error.code == 0 else {
                    return false }
            } catch let error {
                print(error)
                return false
            }
         
} // if sessionMode == .usingMicMode
 
 * /
    }
    */
    
    /* Keep, just in case
    // No longer called
    func setSessionMode(forVideoPlayback: Bool) -> Bool {
        return true
     
        print("In call to AudioSess.setSessionMode(forVideoPlayback:\(forVideoPlayback))")
        do {
            let sessionInstance = AVAudioSession.sharedInstance()
 //           try sessionInstance.setActive(false)
            if forVideoPlayback {
                try sessionInstance.setMode(AVAudioSessionModeDefault) //AVAudioSessionModeMoviePlayback)
            } else {
                try sessionInstance.setMode(AVAudioSessionModeMeasurement)
            }
            
            AudioKitManager.sharedInstance.setupForUsingMic()
            
 //           try sessionInstance.setActive(true)
        } catch let error as NSError {
            let ec = error.code
            print("  ERROR == \(ec) in call to AudioSess.setSessionMode(forVideoPlayback:\(forVideoPlayback)")
            print(error.localizedDescription)
            guard error.code == 0 else {
                return false }
        } catch let error {
            print("  ERROR in call to AudioSess.setSessionMode(forVideoPlayback:\(forVideoPlayback)")
            print(error)
            return false
        }
        return true
    }
    */
    
    //MARK: Audio Session Route Change Notification
    
    @objc func handleRouteChange(_ notification: Notification) {
        
        print("\n\n@@@@@@ handleRouteChange called")
        let reasonValue = (notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as AnyObject).uintValue
        //AVAudioSessionRouteDescription *routeDescription = [notification.userInfo valueForKey:AVAudioSessionRouteChangePreviousRouteKey];
        
        if reasonValue == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue {
            //do we need to do something here?
        }
        
        if reasonValue == AVAudioSession.RouteChangeReason.categoryChange.rawValue {
            let sessionInstance = AVAudioSession.sharedInstance()
            let catStr = sessionInstance.category
            print("\n\n . . . Yep, Cat Change   new cat:\(catStr) !!!!!!!!!!!!!!!!!!!!!!! \n\n")
            //AVAudioSessionManager.sharedInstance.stop
//            _ = AVAudioSessionManager.sharedInstance.setupAudioSession()
// hyarhyar SFAUDIO

            /*
            // YOYOYOY
            if !AKSettings.headPhonesPlugged {
                do {
                    //let sessionInstance = AVAudioSession.sharedInstance()
                    try sessionInstance.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker) // handleRouteChange
                } catch let error as NSError {
                    print(error.localizedDescription)
                    guard error.code == 0 else { return }
                } catch let error {
                    print(error)
                    return
                }

            
            }
 */
         }
        
        print("Audio route change: \(String(describing: reasonValue))")
    }
    
    @objc func handleInterruption(_ n: Notification) {
        //print("Audio interruption")
        print("\n\n@@@@@@ handleInterruption called\n")
        guard let why = n.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        guard let type = AVAudioSession.InterruptionType(rawValue: why) else { return }

        if type == .began {
            print("interruption began:\n\(n.userInfo!)")
            print("\n@@@@@     ABout to call AudioKit.stop (in handleInterruption method)\n")
           AudioKitManager.sharedInstance.stop()  // SFAUDIO
        } else if type == .ended {
            print("interruption ended:\n\(n.userInfo!)")

            // NEW Since Toehold   // SFAUDIO
            AudioKitManager.sharedInstance.enabledForcedReSetup()
            
            // activate the audio session (again)
            do {
                let sessionInstance = AVAudioSession.sharedInstance()
                try sessionInstance.setActive(true)
            } catch let error as NSError {
                print(error.localizedDescription)
                guard error.code == 0 else {
                    return }
            } catch let error {
                print(error)
                return
            }

            print("\n@@@@@     ABout to call AudioKit.start (in handleInterruption method)\n")
            AudioKitManager.sharedInstance.start(forRecordToo:false)   // SFAUDIO
        }
    }
    
    func clearAudioSession() {
        print("\n\n@@@@@@    In clearAudioSession method - calling AVAudioSession.setActive(false)\n")

        AudioKitManager.sharedInstance.stop()

        let sessionInstance = AVAudioSession.sharedInstance()
        NotificationCenter.default.removeObserver(self)
        do {
            try sessionInstance.setActive(false)
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch let error {
            print(error)
        }
    }

    deinit {
        clearAudioSession()
    }
}
