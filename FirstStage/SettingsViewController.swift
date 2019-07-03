//
//  SettingsViewController.swift
//  FirstStage
//
//  Created by turtle on 6/23/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}
