//
//  UITintButton.swift
//  Swatch
//
//  Created by 1 1 on 23.09.16.
//  Copyright © 2016 1. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class UITintButton:UIButton
{
    
    var userData:Any?
    
    @IBInspectable var initialColor: UIColor
        {
        didSet {
            backgroundColor = initialColor
        }
    }


    @IBInspectable var selectedColor: UIColor
        {
        didSet {

        }
    }
    
    
    override var isHighlighted: Bool{
        didSet {
            
            if !isEnabled
            {
                return
            }
            
            if isHighlighted
            {
                self.backgroundColor = selectedColor
            }
            else
            {
                self.backgroundColor = initialColor
            }
            
        }
    }
    required init?(coder: NSCoder)
    {
        initialColor = UIColor.clear
        selectedColor = UIColor.clear
        
        super.init(coder: coder)
        
    }
    
    required override init(frame: CGRect) {
        
        initialColor = UIColor.clear
        selectedColor = UIColor.clear
        
        super.init(frame: frame)
        
    }

    
    
    
}
