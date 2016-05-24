//
//  Balloon.swift
//  FirstStage
//
//  Created by Adam Kinney on 12/13/15.
//  Copyright © 2015 ADKINN, LLC. All rights reserved.
//

import UIKit

class Balloon: UIView {
    
    private var circle : CAShapeLayer?
    private let length : CGFloat = 128
    
    var fillColor = UIColor.blueColor().CGColor {
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
                circle?.path = UIBezierPath(roundedRect: CGRect(x: length-radius, y: length-radius, width: 2.0 * radius, height: 2.0 * radius)  , cornerRadius: radius).CGPath
            }
        }
    }
    
    override func awakeFromNib() {
        circle = CAShapeLayer()
        let c = circle!
        c.fillColor = fillColor
        c.path = UIBezierPath(roundedRect: CGRect(x: length-radius, y: length-radius, width: 2.0 * radius, height: 2.0 * radius)  , cornerRadius: radius).CGPath
        
        layer.addSublayer(c)
    }
}