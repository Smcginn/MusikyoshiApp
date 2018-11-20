//
//  AutoRenewNotificationViewController.swift
//  FirstStage
//
//  Created by Scott Freshour on 11/15/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

class AutoRenewNotificationViewController: UIViewController {
    
    var userPressedPurchase = false
    
    var productID = ""
    
    var purchaseTitleText = ""
    var descriptionText = ""
    var subsPriceText = ""
    var durationText = ""

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func privacyPolicyBtnPressed(_ sender: Any) {
        
        if let url = URL(string: "https:www.musikyoshi.com/privacy-policy") {
            UIApplication.shared.open(url, options:[:])
        }
    }
    
    // Labels with text that will be altered:
    @IBOutlet weak var purchaseTitleValueLabel: UILabel!
    @IBOutlet weak var descriptionValueLabel: UILabel!
    @IBOutlet weak var subsPriceValueLabel: UILabel!
    @IBOutlet weak var durationValueLabel: UILabel!
    @IBOutlet weak var termsListStaticLabel: UILabel!
    
    @IBAction func purchaseButtonPressed(_ sender: Any) {
        userPressedPurchase = true
        performSegue(withIdentifier: "unwindToInAppPurchSegueID", sender: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "unwindToInAppPurchSegueID", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLayoutSubviews()
        
        let superFrame = super.view.frame
        let scrollFrame = scrollView.frame
        
        // 320x830 for SE
        let contentSz = CGSize(width: scrollFrame.size.width, height: scrollFrame.size.height)
        scrollView.contentSize = contentSz

        scrollView.frame.size = superFrame.size
        let scrollFrame2 = scrollView.frame
        
        getAndSetTextForThisProduct()
        
        print("yo")
    }
    
    func getAndSetTextForThisProduct() {
        purchaseTitleValueLabel.text = purchaseTitleText
        descriptionValueLabel.text = descriptionText
        subsPriceValueLabel.text = subsPriceText
        durationValueLabel.text = durationText

        var msgStr = "\u{2022} Payment will be charged to iTunes Account at confirmation of purchase\n\n"
        msgStr += "\u{2022} Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period\n\n"
        msgStr += "\u{2022} Your account will be charged for renewal within 24-hours prior to the end of the current period, and identify the cost of the renewal\n\n"
        msgStr += "\u{2022} Subscriptions may be managed by the user and auto-renewal may be turned off by going to the users’ Account Settings after purchase"
        
        termsListStaticLabel.text = msgStr
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let superFrame = super.view.frame
        let scrollFrame = scrollView.frame
        scrollView.frame.size.height = super.view.frame.size.height
        
        let contentSz = CGSize(width: scrollFrame.size.width, height: superFrame.size.height)
        scrollView.contentSize = CGSize(width:320, height:840)
        
        let scrollFrame2 = scrollView.frame

        let contentSz2 = scrollView.contentSize

        print("yo")
    }

}
