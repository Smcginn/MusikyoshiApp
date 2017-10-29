//
//  WelcomeViewController.swift
//  longtones
//
//  Created by Adam Kinney on 6/7/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import UIKit
import SpriteKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var hostView: SKView!
    
    var scene: TreeScene!
    
    override func viewDidAppear(_ animated: Bool) {
        loadScene()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadScene(){
        scene = TreeScene(size:hostView.bounds.size)
        // Configure the view.
        //hostView.showsFPS = true
        //hostView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        hostView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFit
        
        hostView.presentScene(scene)
    }

    @IBAction func btnStartTap(_ sender: AnyObject) {
        //puff
        //scene.puff(2, xMod: 0)
    }
    
    @IBAction func btnIncStrTap(_ sender: AnyObject) {
        scene.startStream()
    }
    
    @IBAction func btnFailTap(_ sender: AnyObject) {
        scene.showFail()
    }
    
    @IBAction func btnSucceedTap(_ sender: AnyObject) {
        scene.showSuccess {
            
        }
    }
}
