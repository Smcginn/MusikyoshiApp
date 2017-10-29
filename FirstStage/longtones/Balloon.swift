//
//  Balloon.swift
//  longtones
//
//  Created by Adam Kinney on 6/7/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
import UIKit

class Balloon: UIView {
    
    fileprivate var circle : CAShapeLayer?
    fileprivate let length : CGFloat = 128
    
    var fillColor = UIColor.blue.cgColor {
        didSet{
            if circle != nil
            {
                circle?.fillColor = fillColor
            }
        }
    }
    
    var radius : CGFloat = 6.0 {
        didSet{
            if circle != nil
            {
                circle?.path = UIBezierPath(roundedRect: CGRect(x: length-radius, y: length-radius, width: 2.0 * radius, height: 2.0 * radius)  , cornerRadius: radius).cgPath
            }
        }
    }
    
    override func awakeFromNib() {
        circle = CAShapeLayer()
        let c = circle!
        c.fillColor = fillColor
        c.path = UIBezierPath(roundedRect: CGRect(x: length-radius, y: length-radius, width: 2.0 * radius, height: 2.0 * radius)  , cornerRadius: radius).cgPath
        
        layer.addSublayer(c)
    }
    
    func viewDidLayoutSubviews() {
        
    }
}
