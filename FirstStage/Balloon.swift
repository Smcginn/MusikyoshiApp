//
//  Balloon.swift
//  FirstStage
//
//  Created by Adam Kinney on 12/13/15.
//  Changed by David S Reich - 2016.
//  Copyright © 2015 Musikyoshi. All rights reserved.
//

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
}
