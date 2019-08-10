//
//  ExerciseTableViewCell.swift
//  PlayTunes-debug
//
//  Created by turtle on 7/5/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {

    @IBOutlet weak var starStackView: UIStackView!
    @IBOutlet weak var exerciseLabel: UILabel!
    
    var numberOfStars = 0 {
        didSet {
            updateStars()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        backgroundColor = .clear
        
        if DeviceType.IS_IPHONE_5orSE {
            exerciseLabel.font = UIFont(name: "Futura-Bold", size: 14.0)
        }
    }
    
    func updateStars() {
        
        for i in 0..<starStackView.subviews.count {
            
            if let starImageView = starStackView.subviews[i] as? UIImageView {
                
                if i < numberOfStars {
                    starImageView.image = UIImage(named: "star")
                } else {
                    starImageView.image = UIImage(named: "greyStar")
                }
                
            }
            
        }
        
    }

}
