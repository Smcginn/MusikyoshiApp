//
//  OnboardingSlideView.swift
//  PlayTunes-debug
//
//  Created by turtle on 7/16/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//

import UIKit

class OnboardingSlideView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    func addTarget(target: AnyObject, action: Selector, forControlEvents: UIControlEvents) {
        startButton.addTarget(target, action: action, for: forControlEvents)
    }

}
