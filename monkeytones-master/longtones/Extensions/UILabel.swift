//
//  UILabel.swift
//  longtones
//
//  Created by Adam Kinney on 6/26/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
import UIKit

extension UILabel{
    dynamic var defaultFont: UIFont? {
        get { return self.font }
        set { self.font = newValue }
    }
}

extension Double {
    static var min = DBL_MIN
    static var max = DBL_MAX
}