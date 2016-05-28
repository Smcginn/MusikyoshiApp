//
//  FeedbackView.swift
//  FirstStage
//
//  Created by David S Reich on 28/05/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//

import UIKit

class FeedbackView: UIImageView, UIGestureRecognizerDelegate {

    let feedbackViewTapRecognizer = UITapGestureRecognizer()
    var containingView: UIView!
    var parentViewController: UIViewController?
    var setupAlready = false

    func setupFeedbackView(parent: UIViewController) {
        guard !setupAlready else { return }

        setupAlready = true
        parentViewController = parent
        containingView = parent.view

        feedbackViewTapRecognizer.enabled = false
        feedbackViewTapRecognizer.addTarget(self, action: #selector(FeedbackView.feedbackViewTapped(_:)))
        feedbackViewTapRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(feedbackViewTapRecognizer)

        contentMode = .ScaleAspectFit
        clipsToBounds = true
        hidden = true
        userInteractionEnabled = true
        backgroundColor = UIColor.clearColor()

        self.frame = containingView.bounds
        containingView.addSubview(self)

        image = UIImage(named: "FeedbackImage")
    }

    func showFeedback(containingFrame: CGRect) {
        self.frame = containingFrame
        feedbackViewTapRecognizer.enabled = true
        hidden = false
    }

    func feedbackViewTapped(sender: UITapGestureRecognizer) {
        hidden = true
        feedbackViewTapRecognizer.enabled = false
    }
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
