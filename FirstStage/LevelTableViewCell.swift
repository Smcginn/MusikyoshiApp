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
    
    var isActive: Bool = false {
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
        
        self.containerView.layer.cornerRadius = 15
        
    }

}
