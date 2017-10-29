//
//  UIImageButton.swift
//  Swatch
//
//  Created by admin on 08.07.16.
//  Copyright © 2016 1. All rights reserved.
//

import Foundation
import UIKit

class UIImageButton:UIButton
{
    
    var userData:Any?
    
    @IBInspectable override var contentEdgeInsets: UIEdgeInsets
        {
        didSet {
            self.setNeedsDisplay()
        }
    }

    
    @IBInspectable var imageInsetsX: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var imageInsetsY: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var image: UIImage? {
        didSet {
            self.setNeedsDisplay()
        }
    }


    override var isHighlighted: Bool{
        willSet {
            //print("changing from \(selected) to \(newValue)")
        }
        
        didSet {
            //print("changed from \(oldValue) to \(selected)")
            if !isEnabled
            {
                return
            }
            
            if isHighlighted
            {
                self.alpha=0.6
            }
            else
            {
                self.alpha=1.0
            }
            
        }
    }
    
    override var isEnabled:Bool{
        didSet {
            if isEnabled
            {
                self.alpha=1.0
            }
            else
            {
                self.alpha=0.3
            }
            
        }
    }


    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        // hack to call didset
        //let enabled = self.isEnabled
        //self.isEnabled=enabled
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        //let enabled = self.isEnabled
        //self.isEnabled=enabled

    }

    
    override func draw(_ rect: CGRect) {
        
        if let img = image
        {
            var imgRect = rect.insetBy(dx: imageInsetsX, dy: imageInsetsY)
            imgRect.origin.x += self.contentEdgeInsets.left
            imgRect.origin.x -= self.contentEdgeInsets.right

            
            let ctx = UIGraphicsGetCurrentContext();

            ctx!.saveGState();
            
            img.draw(in: imgRect)
            
            ctx!.restoreGState()
        }
    }
    
}
