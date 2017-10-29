//
//  AppDelegate.swift
//  longtones
//
//  Created by Adam Kinney on 6/7/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import UIKit
import Firebase

func delay(_ delay:Double, closure:@escaping ()->()){
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GCHelper.sharedInstance.authenticateLocalUser()
        
        NotificationsService.configurate()
        FIRApp.configure()
        
        //style elements
        //UINavigationBar.appearance().translucent = false
        //UINavigationBar.appearance().barTintColor = UIColor(rgba: "#5d0c96")
        UINavigationBar.appearance().tintColor = UIColor(rgba: "#5d0c96")
        //UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        UILabel.appearance().defaultFont = UIFont.init(name: Constants.GlobalFontName.fontName, size: 17)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName:UIFont.init(name: Constants.GlobalFontName.fontName, size: 17)!]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName:UIFont.init(name: Constants.GlobalFontName.fontName, size: 17)!], for: .normal)
        
        UILabel.appearance(whenContainedInInstancesOf: [UITextField.self]).defaultFont = UIFont.systemFont(ofSize: 17)
        
        // initialize data
        InstrumentService.initInstruments()
        DifficultyService.initDifficulties()
        NoteService.initNotes()
        
        //decide screen toshow
        showInitialViewController()
        
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        print(notificationSettings.types.rawValue)
    }
    
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        // Do something serious in a real app.
        print("Received Local Notification:")
    }
    
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        
        
        completionHandler()
    }
    
    
    // MARK: - Helpers
    
    func showInitialViewController()
    {
        let navigationController:UINavigationController = UINavigationController()
        let initialViewController:MainViewController = MainViewController(nibName:"MainViewController", bundle:nil)
        
        //navigationController.viewControllers = [initialViewController]
        
        let frame = UIScreen.main.bounds
        window = UIWindow(frame: frame)
        
        window!.rootViewController = navigationController
        window!.makeKeyAndVisible()
        
        // First Launch
        let firstLaunch = !UserDefaults.standard.bool(forKey: Constants.SettingsKeys.notFirstLaunch)
        if firstLaunch
        {
            navigationController.setNavigationBarHidden(true, animated: false)
            
            initialViewController.firstLaunch = true
            
            let tutorial = TutorialScreen()
            tutorial.modalPresentationStyle = .overCurrentContext
            //navigationController.present(tutorial, animated: false, completion: nil)
            
            navigationController.pushViewController(tutorial, animated: false)
            
            tutorial.completionBlock = {
                
                var username:String? = nil
                
                if GCHelper.sharedInstance.authenticated
                {
                                        
                    if GCHelper.sharedInstance.localPLayer.alias != nil
                    {
                        username = GCHelper.sharedInstance.localPLayer.alias
                    }
                }
                let usernameController = ProfileViewController()
                usernameController.predefinedUsername = username
                usernameController.completionBlock = {
                    UserDefaults.standard.set(true, forKey: "NotFirstLanuch")
                    navigationController.pushViewController(initialViewController, animated: true)
                    navigationController.setNavigationBarHidden(false, animated: false)
                    
                }
                
                navigationController.pushViewController(usernameController, animated: true)
                //navigationController.present(usernameController, animated: true, completion: nil)
                
            }
            
        }
        else
        {
            navigationController.pushViewController(initialViewController, animated: false)
        }
        
    }
    
}

