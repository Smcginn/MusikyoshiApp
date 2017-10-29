//
//  SettingsViewController.swift
//  longtones
//
//  Created by Adam Kinney on 6/8/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController,InstrumentControllerDelegate {
    
    @IBOutlet weak var instrumentLabel: UILabel!
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var gameCenterhBtn: UIButton!
    @IBOutlet weak var tutorialBtn: UIButton!
    @IBOutlet weak var navBar: UINavigationBar!

    var delegate:InstrumentControllerDelegate!

    override func viewWillAppear(_ animated: Bool) {
        refreshInstrument()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navItem = UINavigationItem(title: Constants.Title.settings)
        navItem.rightBarButtonItem = UIBarButtonItem(title: Constants.Title.cancel, style: .plain, target: self, action:#selector(cancelBtnTapped))
        navBar.items = [navItem]
        
        UIService.styleButton(refreshBtn)
        UIService.styleButton(gameCenterhBtn)
        UIService.styleButton(tutorialBtn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func cancelBtnTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func refreshInstrument() {
        let ins = InstrumentService.getInstrument(DataService.sharedInstance.currentInstrumentId)
        instrumentLabel.text = ins!.name.rawValue
    }
    
    @IBAction func instrumentBtnTapped(_ sender: UIButton) {
        let vc = InstrumentViewController()
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func gamecenterBtnTapped(_ sender: UIButton) {
        GCHelper.sharedInstance.showGameCenter(self, viewState: .leaderboards)
    }
    
    @IBAction func tutorialBtnTapped(_ sender: UIButton) {
    
        
        let tutorial = TutorialScreen()
        tutorial.modalPresentationStyle = .overCurrentContext
        self.present(tutorial, animated: true)

        
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
                //navController.dismiss(animated: true, completion: nil)
            }
            
            
            
            //self.dismiss(animated: true, completion: {
                self.present(usernameController, animated: true)
            //})
            
            
            //navigationController.present(usernameController, animated: true, completion: nil)
            
        }

    
    }
    
    @IBAction func resetBtnTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Clear fruit screens?", message: "Your points will stay.", preferredStyle: UIAlertControllerStyle.alert)
        let DestructiveAction = UIAlertAction(title: "Clear", style: UIAlertActionStyle.destructive) { (result : UIAlertAction) -> Void in
            DataService.sharedInstance.resetAllKeys()
            self.refreshInstrument()
        }
        let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - InstrumentControllerDelegate
    
    func instrumentWasSelect(controller: InstrumentViewController) {
        //self.dismiss(animated: true, completion:)
        //self.dismiss(animated: true)
        //{
            self.delegate.instrumentWasSelect(controller: controller)
        //}
        
    }

}
