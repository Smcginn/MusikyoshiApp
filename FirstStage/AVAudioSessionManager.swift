//
//  AVAudioSessionManager.swift
//  FirstStage
//
//  Created by David S Reich on 22/05/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//

import UIKit

class AVAudioSessionManager: NSObject {

    var isSetup = false
    var isStarted = false
    
    static let sharedInstance = AVAudioSessionManager()
    
    func setupAudioSession() -> Bool {
        //don't setup twice
        guard !isSetup else { return true }
        isSetup = true

        // Configure the audio session
        let sessionInstance = AVAudioSession.sharedInstance()
        
        //set inactive before making changes
        do {
            try sessionInstance.setActive(false)
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch let error {
            print(error)
        }

        AudioKitManager.sharedInstance.setup()
        
        do {
            try sessionInstance.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions:AVAudioSessionCategoryOptions.DefaultToSpeaker)
        } catch let error as NSError {
            print(error.localizedDescription)
            guard error.code == 0 else { return false }
        } catch let error {
            print(error)
            return false
        }
        
        do {
            try sessionInstance.setMode(AVAudioSessionModeMeasurement)
        } catch let error as NSError {
            print(error.localizedDescription)
            guard error.code == 0 else { return false }
        } catch let error {
            print(error)
            return false
        }
        
        let bufferDuration = NSTimeInterval.init(floatLiteral: 0.005)
        do {
            try sessionInstance.setPreferredIOBufferDuration(bufferDuration)
        } catch let error as NSError {
            print(error.localizedDescription)
            guard error.code == 0 else { return false }
        } catch let error {
            print(error)
            return false
        }
        
        let hwSampleRate = 44100.0;
        do {
            try sessionInstance.setPreferredSampleRate(hwSampleRate)
        } catch let error as NSError {
            print(error.localizedDescription)
            guard error.code == 0 else { return false }
        } catch let error {
            print(error)
            return false
        }
        
        // add interruption handler
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleInterruption), name: AVAudioSessionInterruptionNotification, object: sessionInstance)
        
        // we don't do anything special in the route change notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSessionRouteChangeNotification, object: sessionInstance)
        
        // we don't do anything special in the media server reset notification
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleMediaServerReset), name: AVAudioSessionMediaServicesWereResetNotification, object: sessionInstance)
        
        // activate the audio session
        do {
            try sessionInstance.setActive(true)
        } catch let error as NSError {
            print(error.localizedDescription)
            guard error.code == 0 else { return false }
        } catch let error {
            print(error)
            return false
        }
        
        return true
    }

    //MARK: Audio Session Route Change Notification
    
    func handleRouteChange(notification: NSNotification) {
        let reasonValue = notification.userInfo?[AVAudioSessionRouteChangeReasonKey]?.unsignedIntegerValue
        //AVAudioSessionRouteDescription *routeDescription = [notification.userInfo valueForKey:AVAudioSessionRouteChangePreviousRouteKey];
        
        if reasonValue == AVAudioSessionRouteChangeReason.OldDeviceUnavailable.rawValue {
            //do we need to do something here?
        }
        print("Audio route change: \(reasonValue)")
    }
    
    func handleInterruption(n: NSNotification) {
        print("Audio interruption")
        guard let why = n.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        guard let type = AVAudioSessionInterruptionType(rawValue: why) else { return }

        if type == .Began {
            print("interruption began:\n\(n.userInfo!)")
            AudioKitManager.sharedInstance.stop()
        } else if type == .Ended {
            print("interruption ended:\n\(n.userInfo!)")

            // activate the audio session (again)
            do {
                let sessionInstance = AVAudioSession.sharedInstance()
                try sessionInstance.setActive(true)
            } catch let error as NSError {
                print(error.localizedDescription)
                guard error.code == 0 else { return }
            } catch let error {
                print(error)
                return
            }

            AudioKitManager.sharedInstance.start()
        }
    }
    
    
    func clearAudioSession() {
        AudioKitManager.sharedInstance.stop()

        let sessionInstance = AVAudioSession.sharedInstance()
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
