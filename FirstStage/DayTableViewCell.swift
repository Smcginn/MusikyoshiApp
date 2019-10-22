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
    
    var dayIsEnabled: Bool = false {
        didSet {
            adjustIfSelectedOrEnabledChanged()
        }
    }
    
    var isSelectedDay: Bool = false {
        didSet {
            adjustIfSelectedOrEnabledChanged()
        }
    }
    
    func adjustIfSelectedOrEnabledChanged() {
        if !self.dayIsEnabled { // doens't matter if selected
            self.dayLabel.textColor = .lightGray
            if DeviceType.IS_IPHONE_5orSE {
                self.dayLabel.font = UIFont(name: "Futura", size: 14.0)
            } else {
                self.dayLabel.font = UIFont(name: "Futura", size: 18.0)
            }
        }
        
        else {
            if self.isSelectedDay {
                UIView.animate(withDuration: 0.5) {
                    self.dayLabel.textColor = .black
                    if DeviceType.IS_IPHONE_5orSE {
                        self.dayLabel.font = UIFont(name: "Futura-Bold", size: 16.0)
                    } else {
                        self.dayLabel.font = UIFont(name: "Futura-Bold", size: 22.0)
                    }
                }
            } else { // day not selected
                UIView.animate(withDuration: 0.5) {
                    UIView.animate(withDuration: 0.5) {
                        self.dayLabel.textColor = .gray
                        if DeviceType.IS_IPHONE_5orSE {
                            self.dayLabel.font = UIFont(name: "Futura-Bold", size: 15.0)
                        } else {
                            self.dayLabel.font = UIFont(name: "Futura-Bold", size: 18.0)
                        }
                    }
                }
            }
        }
    }
    
    
}
