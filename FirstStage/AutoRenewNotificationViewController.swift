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
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func privacyPolicyBtnPressed(_ sender: Any) {
        if let url = URL(string: kMKPrivacyPolicyURL) {
            UIApplication.shared.open(url, options:[:])
        }
    }
    
    @IBAction func termsAndConditionsBtnPressed(_ sender: Any) {
        if let url = URL(string: kMKTermsOfUseURL) {
            UIApplication.shared.open(url, options:[:])
        }
        
        // showTermsAndConditionsAlert()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func showApplesEULAHandler(_ act: UIAlertAction) {
        if let url = URL(string: kMKTermsOfUseURL) {
            UIApplication.shared.open(url, options:[:])
        }
    }
    
    func showTermsAndConditionsAlert() {
        let titleStr = "MusiKyoshi's\nTerms of Use"
        let msgStr = "\nPlayTunes is covered by Apple's End User License Agreement (EULA) for Apps sold through the App Store.\n"
        let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "View Apple's EULA",
                                   style: .default,
                                   handler: showApplesEULAHandler))
        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        self.present(ac, animated: true, completion: nil)
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
    
    override func viewDidLoad() {
        super.viewDidLayoutSubviews()
        
        if DeviceType.IS_IPHONE_5orSE {
            titleLabel.font = UIFont(name: "Futura-Bold", size: 27.0)
        }
        
        self.title = "Confirm"

        
//        let superFrame = super.view.frame
//        let scrollFrame = scrollView.frame
        
        // 320x830 for SE
//        let contentSz = CGSize(width: scrollFrame.size.width,
//                               height: scrollFrame.size.height)
//
//        let frameHt = superFrame.size.height - scrollFrame.origin.y
//        let frameSz = CGSize(width: scrollFrame.size.width,
//                             height: frameHt)
        // scrollView.frame.size = frameSz // superFrame.size
        let scrollFrame2 = scrollView.frame
        useThisToSuppressWarnings(str: "\(scrollFrame2.size.width)")

        // scrollView.contentSize = contentSz

        getAndSetTextForThisProduct()
        
        print("yo")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let superFrame = super.view.frame
        let scrollFrame = scrollView.frame
//        scrollView.frame.size.height = super.view.frame.size.height
        
        let contentSz = CGSize(width: scrollFrame.size.width, height: superFrame.size.height)
        useThisToSuppressWarnings(str: "\(contentSz.width)")
        // scrollView.contentSize = CGSize(width:300, height:1000) //320
        
        let scrollFrame2 = scrollView.frame
        
        let contentSz2 = scrollView.contentSize
        useThisToSuppressWarnings(str: "\(scrollFrame2.size.width),  \(contentSz2.width)")

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        print("yo")
    }

    func getAndSetTextForThisProduct() {
        
        purchaseTitleValueLabel.text = purchaseTitleText
        descriptionValueLabel.text = descriptionText
        subsPriceValueLabel.text = subsPriceText
        durationValueLabel.text = durationText

        var msgStr = "\u{2022} Payment will be charged to iTunes Account at confirmation of purchase\n\n"
        msgStr += "\u{2022} Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period\n\n"
        msgStr += "\u{2022} Account will be charged for renewal within 24-hours prior to the end of the current period, and identify the cost of the renewal\n\n"
        msgStr += "\u{2022} Subscriptions may be managed by the user and auto-renewal may be turned off by going to the user's Account Settings after purchase\n\n"
        msgStr += "\u{2022} Current subscription may not be cancelled during the active subscription period\n\n"
        msgStr += "\u{2022} Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable"

        termsListStaticLabel.text = msgStr
    }
}
