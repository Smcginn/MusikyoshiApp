//
//  DayTableViewCell.swift
//  PlayTunes-debug
//
//  Created by turtle on 7/1/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//

import UIKit

class DayTableViewCell: UITableViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        if DeviceType.IS_IPHONE_5orSE {
            dayLabel.font = UIFont(name: "Futura-Bold", size: 16.0)
        }
        
    }

}
