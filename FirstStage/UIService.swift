//
//  UIService.swift
//  longtones
//
//  Created by Adam Kinney on 6/26/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
import UIKit

struct UIService {
    
    static func cgColorForRed(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> AnyObject {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0).cgColor as AnyObject
    }
    
    static func getPageGradLayer(_ bounds: CGRect) -> CAGradientLayer{
        let l = CAGradientLayer()
        l.frame = bounds
        l.colors = [cgColorForRed(177.0, green: 207.0, blue: 113.0),
                            cgColorForRed(255.0, green: 255.0, blue: 255.0)]
        l.locations = [0.0, 0.38]
        return l;
    }
    
    static func styleButton(_ btn: UIButton)
    {
        //btn.layer.cornerRadius = 12
        //btn.clipsToBounds = true
        btn.tintColor = UIColor.white
        btn.setBackgroundColor(UIColor.init(rgba: "#5d0c96"), forUIControlState: UIControlState())
    }
}
