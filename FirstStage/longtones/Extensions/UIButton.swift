//
//  UIButton.swift
//  longtones
//
//  Created by Adam Kinney on 6/26/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    fileprivate func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func setBackgroundColor(_ color: UIColor, forUIControlState state: UIControlState) {
        self.setBackgroundImage(imageWithColor(color), for: state)
    }
}
