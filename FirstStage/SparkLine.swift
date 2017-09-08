//
//  SparkLine.swift
//  FirstStage
//
//  Created by Adam Kinney on 12/17/15.
//  Changed by David S Reich - 2016.
//  Copyright © 2015 Musikyoshi. All rights reserved.
//
import UIKit

class SparkLine: UIView {

    var lineWidth:CGFloat?
    
    var values: [CGPoint] {
        didSet {
            setNeedsDisplay(self.frame)
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
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        // Check for at least two values
        if (self.values.count < 2) {
            return
        }
        
        // Create sparkline path
        let sparkline = UIBezierPath()
        sparkline.lineWidth = self.lineWidth!
        
        // Add data points to path
        for i in 0 ..< self.values.count {
            if i == 0 { // starting point
                sparkline.move(to: values[i])
            } else {
                sparkline.addLine(to: values[i])
            }
        }
        
        // Draw sparkline
        UIColor.blue.setStroke()
        sparkline.stroke()
    }
    
    func addValue(_ goodPoint: Bool, newValue:CGPoint) {
        self.values.append(newValue)
    }
    
    func addValues(_ goodPoints: Bool, values:[CGPoint]) {
        for value in values {
            self.addValue(goodPoints, newValue: value)
        }
    }
    
    func addValues(_ goodPoints: Bool, values:CGPoint...) {
        self.addValues(goodPoints, values: values)
    }
}
