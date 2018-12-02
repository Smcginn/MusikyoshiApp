//
//  WelcomeViewController.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/1/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

class WelcomeViewController: UIViewController, UIScrollViewDelegate {
    
    // Ultimately want to calc this synamically, at runtime . . .
    let kScrollContentHt = CGFloat(790.0)
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var WelcomeTitleLabel: UILabel!
    
    @IBOutlet weak var howToUsePTLabel: UILabel!
    @IBOutlet weak var howToUseDetailsLabel: UILabel!
    
    @IBOutlet weak var tryOutPTForFreeLabel: UILabel!
    @IBOutlet weak var tryOutPTForFreeDetailsLabel: UILabel!
    
    @IBOutlet weak var accessUpperLevelsLabel: UILabel!
    @IBOutlet weak var accessUpperLevelsDetailLabel: UILabel!
    
    
    @IBOutlet weak var privacyPolicyBtn: UIButton!
    @IBAction func privacyPolicyBtnPressed(_ sender: Any) {
    }
    
    @IBAction func termsOfUseBtnPressed(_ sender: Any) {
    }
    
    @IBAction func okayBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        accessUpperLevelsLabel.text =
                "To Access PlayTunes' Upper \nLevels"
        
        var howToUseDetText = "\u{2022} Select “Levels” to see the\n   available Practice Levels\n"
        howToUseDetText += "\u{2022} Select a Level to see the Days\n   within that Level\n"
        howToUseDetText += "\u{2022} Select a Day to display the exercises\n   within that Day, then:\n"
        howToUseDetText += "   > Select 'Go' to automatically step \n"
        howToUseDetText += "       through a guided practice\n"
        howToUseDetText += "       session,            or\n"
        howToUseDetText += "   > Select 'Choose' to pick\n"
        howToUseDetText += "       individual exercises"

        howToUseDetailsLabel.text = howToUseDetText
        
        var tryOutDetText = "You may access Levels 1 & 2 for free, forever. That’s almost 200 exercises!\n\n"
        tryOutDetText += "For this free trial, you don't need to do anything else; you are good to go!"
        
        tryOutPTForFreeDetailsLabel.text = tryOutDetText

        var subDetailText = "When you see how amazing PlayTunes is, if you want to use the upper levels, you will need to purchase a PlayTunes All-Level Access Subscription.\n\n"
        subDetailText += "(Select 'Purchase Options' to see the available Subscriptions. PlayTunes offers 1-month and 6-month auto-renewing subscriptions. Before purchasing you be presented with all of the details of how these Subscriptions work.)"

        accessUpperLevelsDetailLabel.text = subDetailText
        
        scrollView.showsVerticalScrollIndicator = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Setup so scrollbar flashes evrery 3 secs so user realizes it's a scrollview
        timer = Timer.scheduledTimer(
                    timeInterval: 3.0,
                    target: self,
                    selector: #selector(WelcomeViewController.flashScrollBar),
                    userInfo: nil,
                    repeats: true)
        scrollView.flashScrollIndicators()
   }
    
    @objc func flashScrollBar() {
        scrollView.flashScrollIndicators()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // OK, they know it's a scrollview. Stop flashing the scrollbar
        timer.invalidate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Had some issues trying to set ScrollView dims unless doing it here
        let bottomOfScrollView = privacyPolicyBtn.frame.origin.y - 10
        let topOfScrollView = scrollView.frame.origin.y
        let scrollViewHt = bottomOfScrollView - topOfScrollView
        scrollView.frame.size.height = scrollViewHt
        
        var scrollViewContentSize = scrollView.frame.size
        scrollViewContentSize.height = kScrollContentHt
        scrollView.contentSize = scrollViewContentSize
    }
}
