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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
    }

}
