//
//  LevelTableViewCell.swift
//  PlayTunes-debug
//
//  Created by turtle on 7/1/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//

import UIKit

class LevelTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var levelNumberLabel: UILabel!
    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    
    var isActive: Bool = false {
        didSet {
            if self.isEnabled {
                UIView.animate(withDuration: 0.5) {
                    self.containerView.backgroundColor = self.isActive ? .pinkColor : .fadedPinkColor
                }
            } else {
                UIView.animate(withDuration: 0.0) {
                    self.containerView.backgroundColor = self.isActive ? .gray : .lightGray
                }
            }
        }
    }
    
    var isEnabled: Bool = true {
        didSet {
            UIView.animate(withDuration: 0.5) {
                self.containerView.backgroundColor = self.isActive ? .pinkColor : .fadedPinkColor
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
//        if DeviceType.IS_IPHONE_5orSE {
            levelLabel.font = UIFont(name: "Futura-Medium", size: 16)
            levelNumberLabel.font = UIFont(name: "Futura-Bold", size: 27)
//        }
        
        self.containerView.layer.cornerRadius = 15
        
    }
    
    func setLevelLabelToDefaultSettings() {
        if DeviceType.IS_IPHONE_5orSE {
            levelLabel.font = UIFont(name: "Futura-Medium", size: 16)
        } else {
            levelLabel.font = UIFont(name: "Futura-Medium", size: 21)
        }
        levelLabel.text = "Level"
    }
    
    func setLevelLabelForSpecificLabel() {
        levelLabel.font = UIFont(name: "Futura-Bold", size: 22)
    }
    
    func setLevelEnabled() {
        levelLabel.font = UIFont(name: "Futura-Bold", size: 22)
    }
    
}
