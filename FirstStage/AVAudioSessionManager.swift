
//
//  AVAudioSessionManager.swift
//  FirstStage
//
//  Created by David S Reich on 22/05/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//

import UIKit
import AudioKit

class AVAudioSessionManager: NSObject {

    var isSetup = false
    var isStarted = false

    static let sharedInstance = AVAudioSessionManager()
    
    func setupAudioSessionCat() -> Bool {
        // Configure the audio session
        let sessionInstance = AVAudioSession.sharedInstance()
        var catStr = sessionInstance.category
        do {
            try sessionInstance.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
            catStr = sessionInstance.category
            
            
        } catch let error as NSError {
            print(error.localizedDescription)
            guard error.code == 0 else { return false }
        } catch let error {
            print(error)
            return false
        }
        
        return true
    }
    
    func setupAudioSession() -> Bool {
        //don't setup twice
        guard !isSetup else { return true }
        isSetup = true

        
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
        do {
            try sessionInstance.setActive(false)
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch let error {
            print(error)
        }
 //       catStr = sessionInstance.category
        
        if !AudioKitManager.sharedInstance.isRunning {
            print("\n@@@@@     ABout to call AudioKit.setup (in setupAudioSession method)\n")
           AudioKitManager.sharedInstance.setup()   // SFAUDIO
        }
 //       catStr = sessionInstance.category
        

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
 //       catStr = sessionInstance.category
        

        do {
            try sessionInstance.setMode(AVAudioSessionModeMeasurement)
        } catch let error as NSError {
            print(error.localizedDescription)
            guard error.code == 0 else { return false }
        } catch let error {
            print(error)
            return false
        }
 //       catStr = sessionInstance.category
        

        let bufferDuration = TimeInterval.init(floatLiteral: 0.005)
        do {
            try sessionInstance.setPreferredIOBufferDuration(bufferDuration)
        } catch let error as NSError {
            print(error.localizedDescription)
            guard error.code == 0 else { return false }
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
            guard error.code == 0 else { return false }
        } catch let error {
            print(error)
            return false
        }
 //       catStr = sessionInstance.category
        

        // add interruption handler
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: NSNotification.Name.AVAudioSessionInterruption, object: sessionInstance)
        
        // we don't do anything special in the route change notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: NSNotification.Name.AVAudioSessionRouteChange, object: sessionInstance)
        
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
    
    @objc func handleRouteChange(_ notification: Notification) {
        let reasonValue = (notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as AnyObject).uintValue
        //AVAudioSessionRouteDescription *routeDescription = [notification.userInfo valueForKey:AVAudioSessionRouteChangePreviousRouteKey];
        
        if reasonValue == AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue {
            //do we need to do something here?
        }
        
        if reasonValue == AVAudioSessionRouteChangeReason.categoryChange.rawValue {
            let sessionInstance = AVAudioSession.sharedInstance()
            let catStr = sessionInstance.category
            print("\n\n . . . Yep, Cat Change   new cat:\(catStr) !!!!!!!!!!!!!!!!!!!!!!! \n\n")
            //AVAudioSessionManager.sharedInstance.stop
//            _ = AVAudioSessionManager.sharedInstance.setupAudioSession()
// hyarhyar SFAUDIO
        }
        
        print("Audio route change: \(String(describing: reasonValue))")
    }
    
    @objc func handleInterruption(_ n: Notification) {
        print("Audio interruption")
        guard let why = n.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        guard let type = AVAudioSessionInterruptionType(rawValue: why) else { return }

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
                guard error.code == 0 else { return }
            } catch let error {
                print(error)
                return
            }

            print("\n@@@@@     ABout to call AudioKit.start (in handleInterruption method)\n")
            AudioKitManager.sharedInstance.start()   // SFAUDIO
        }
    }
    
    
    func clearAudioSession() {
        print("\n@@@@@     ABout to call AudioKit.stop (in clearAudioSession method)\n")

        AudioKitManager.sharedInstance.stop()   // SFAUDIO

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
