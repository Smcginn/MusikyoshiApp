//
//  DotView.swift
//  FirstStage
//
//  Created by David S Reich on 25/05/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//

import UIKit

class DotView: UIImageView {
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported for DotView")
    }
    
    init(frame:CGRect, backColor: UIColor) {
        super.init(frame: frame)
        
        
        layer.cornerRadius = frame.height / 2   //h and w should be ==
        layer.backgroundColor = backColor.cgColor
        
        isUserInteractionEnabled = false
    }
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
}
