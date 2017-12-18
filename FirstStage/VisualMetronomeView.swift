//
//  VisualMetronomeView.swift
//  FirstStage
//
//  Created by David S Reich on 25/05/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//

import UIKit

class VisualMetronomeView: UIView {

    var numBeats = 4
    var dots = [DotView]()
    let beatColor = UIColor.black
    var regularColor = UIColor.lightGray
    
    override func awakeFromNib() {
        regularColor = regularColor.withAlphaComponent(0.3)
        super.awakeFromNib()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        rebuildMetronome()
    }
    
    func rebuildMetronome () {
        dots.removeAll()

        // the height of this view should be set to the desired dotCenters
        let dotCenters = CGFloat(ceil(frame.height))
        let dotSize = CGFloat(ceil(dotCenters * 0.6))

        let firstDotCenterXOffset = ceil(((CGFloat(numBeats) - 1.0) / 2.0) * dotCenters)
        let firstDotCenterX = CGFloat(ceil((frame.width / 2) - firstDotCenterXOffset))
        let dotCenterY = CGFloat(ceil(frame.height / 2))

        for i in 0 ..< numBeats {
            let frame = CGRect(x: 0, y: 0, width: dotSize, height: dotSize)
            let dot = DotView(frame: frame, backColor: regularColor)
            dots.append(dot)
            let center = CGPoint(x: firstDotCenterX + CGFloat(i) * dotCenters, y: dotCenterY)
            dot.center = center
            addSubview(dot)
        }
    }

    func setBeat(_ dotIndex: Int) {
        for i in 0 ..< numBeats {
            dots[i].layer.backgroundColor = (i == dotIndex) ? beatColor.cgColor : regularColor.cgColor
        }
    }



    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
