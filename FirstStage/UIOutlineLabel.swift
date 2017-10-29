//
//  UIOutlineLabel.swift
//  monkeytones
//
//  Created by 1 1 on 23.11.16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
import UIKit

class UIOutlinedLabel: UILabel {
    
    var outlineWidth: CGFloat = 1
    var outlineColor: UIColor = UIColor.white
    
    override func drawText(in rect: CGRect) {
        
        let strokeTextAttributes = [
            NSFontAttributeName : self.font,
            NSStrokeColorAttributeName : outlineColor,
            NSStrokeWidthAttributeName : -1 * outlineWidth,
            ] as [String : Any]
        
        self.attributedText = NSAttributedString(string: self.text ?? "", attributes: strokeTextAttributes)
        super.drawText(in: rect)
    }
}
