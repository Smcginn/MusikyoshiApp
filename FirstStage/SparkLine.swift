//
//  SparkLine.swift
//  FirstStage
//
//  Created by Adam Kinney on 12/17/15.
//  Copyright © 2015 ADKINN, LLC. All rights reserved.
//
import UIKit

class SparkLine: UIView {

    var lineWidth:CGFloat?
    
    var values: [CGPoint] {
        didSet {
            setNeedsDisplayInRect(self.frame)
        }
    }
    
    init(frame: CGRect, values:[CGPoint]) {
        self.values = values
        self.lineWidth = 2.0
        
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        self.values = [CGPoint]()
        self.lineWidth = 2.0
        
        super.init(coder:aDecoder)
    }
    
    override func drawRect(dirtyRect: CGRect) {
        super.drawRect(dirtyRect)
        
        // Check for at least two values
        if (self.values.count < 2) {
            return
        }
        
        // Create sparkline path
        let sparkline = UIBezierPath()
        sparkline.lineWidth = self.lineWidth!
        
        // Add data points to path
        for var i = 0; i < self.values.count; i++ {
            if i == 0 { // starting point
                sparkline.moveToPoint(values[i])
            } else {
                sparkline.addLineToPoint(values[i])
            }
        }
        
        // Draw sparkline
        UIColor.blueColor().setStroke()
        sparkline.stroke()
    }
    
    func addValue(goodPoint: Bool, newValue:CGPoint) {
        self.values.append(newValue)
    }
    
    func addValues(goodPoints: Bool, values:[CGPoint]) {
        for value in values {
            self.addValue(goodPoints, newValue: value)
        }
    }
    
    func addValues(goodPoints: Bool, values:CGPoint...) {
        self.addValues(goodPoints, values: values)
    }
}