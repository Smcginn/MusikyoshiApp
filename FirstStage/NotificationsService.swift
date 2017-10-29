//
//  NotificationsService.swift
//  monkeytones
//
//  Created by 1 1 on 15.12.16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

class NotificationsService:NSObject, UNUserNotificationCenterDelegate
{
    
    static let shared = NotificationsService()
    
    static func configurate()
    {
        _ = shared
        shared.registerLocal()
    }
    
    func registerLocal() {
        /*
         if #available(iOS 10.0, *) {
         let center = UNUserNotificationCenter.current()
         center.requestAuthorization(options: [.badge, .alert , .sound]) { (granted, error) in
         if granted {
         center.delegate = self
         center.removeAllPendingNotificationRequests()
         self.scheduleLocal()
         //UIApplication.shared.registerForRemoteNotifications();
         }
         }
         }
         else{
         */
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        UIApplication.shared.cancelAllLocalNotifications()
        scheduleLocal()
        //}
    }
    
    func scheduleLocal() {
        /*if #available(iOS 10.0, *) {
         let center = UNUserNotificationCenter.current()
         
         let content = UNMutableNotificationContent()
         content.title = "Monkey Tones"
         content.body = "Let's earn some exercise points! Get more points for practicing today!"
         content.categoryIdentifier = "alarm"
         //content.userInfo = ["customData": "fizzbuzz"]
         content.sound = UNNotificationSound.default()
         
         var dateComponents = DateComponents()
         dateComponents.hour = 18
         dateComponents.minute = 0
         let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
         
         let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
         center.add(request)
         
         
         } else {
         */
        let tomorrow = Date().tomorrow
        
        var components = tomorrow.components
        components.hour = 18
        components.minute = 00
        
        var tomorrow6pm = Calendar.current.date(from: components)
        
        if tomorrow6pm == nil
        {
            return
        }
        
        for _ in 0..<7
        {
            let weekday = Calendar.current.component(.weekday, from: tomorrow6pm!)
            
            if weekday != 1 && weekday != 7
            {
                let localNotification = UILocalNotification()
                localNotification.fireDate = tomorrow6pm
                localNotification.alertTitle = "Monkey Tones"
                localNotification.alertBody = "Let's earn some exercise points! Get more points for practicing today!"
                localNotification.repeatInterval = .weekOfYear
                localNotification.soundName = UILocalNotificationDefaultSoundName
                localNotification.repeatCalendar = Calendar.current
                UIApplication.shared.scheduleLocalNotification(localNotification)
            }
            tomorrow6pm = Calendar.current.date(byAdding: .day, value: 1, to: tomorrow6pm!)
            
        }
        //}
        
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //Handle the notification
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //Handle the notification
    }
    
}
