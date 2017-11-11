//
//  HomeViewController.swift
//  FirstStage
//
//  Created by John Cook on 10/5/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
        
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBAction func shareButtonTapped(sender: UIButton) {
        let textToShare = "Check out the Musikyoshi app!"
        
        if let appListing = NSURL(string: "https://itunes.apple.com/us/app/monkey-tones/id1132920269?mt=8") {
            let objectsToShare = [textToShare, appListing] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            // excluded activities code
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }
}
