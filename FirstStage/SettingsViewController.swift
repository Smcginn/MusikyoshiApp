//
//  SettingsViewController.swift
//  FirstStage
//
//  Created by turtle on 6/23/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        if DeviceType.IS_IPHONE_5orSE {
            titleLabel.font = UIFont(name: "Futura-Bold", size: 27.0)
        }
        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}
