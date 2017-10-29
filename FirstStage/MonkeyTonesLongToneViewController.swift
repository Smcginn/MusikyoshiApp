//
//  MonkeyTonesLongToneViewController.swift
//  FirstStage
//
//  Created by John Cook on 10/29/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import UIKit
//import Firebase

class MonkeyTonesLongToneViewController: UIViewController {
    
    var window: UIWindow?
    
    override func viewWillAppear(_ animated: Bool) {
        showInitialViewController()
    }
    
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
