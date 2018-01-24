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

    func setupFeedbackView(_ parent: UIViewController) {
        guard !setupAlready else { return }

        setupAlready = true
        parentViewController = parent
        containingView = parent.view

        feedbackViewTapRecognizer.isEnabled = false
        feedbackViewTapRecognizer.addTarget(self, action: #selector(FeedbackView.feedbackViewTapped(_:)))
        feedbackViewTapRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(feedbackViewTapRecognizer)

        contentMode = .scaleAspectFit
        clipsToBounds = true
        isHidden = true
        isUserInteractionEnabled = true
        backgroundColor = UIColor.clear

        self.frame = containingView.bounds
        containingView.addSubview(self)

        image = UIImage(named: "FeedbackImage")
    }

    func showFeedback(_ containingFrame: CGRect) {
        self.frame = containingFrame
        feedbackViewTapRecognizer.isEnabled = true
        isHidden = false
    }

    @objc func feedbackViewTapped(_ sender: UITapGestureRecognizer) {
        isHidden = true
        feedbackViewTapRecognizer.isEnabled = false
    }
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
