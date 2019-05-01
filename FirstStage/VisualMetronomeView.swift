//
//  VisualMetronomeView.swift
//  FirstStage
//
//  Created by David S Reich on 25/05/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//

import UIKit

class VisualMetronomeView: UIView {

    let numDots  = 6 // 6
    var numBeats = 4
    var dots = [DotView]()
    let beatColor = UIColor.black
    var beatClearColor = UIColor.black
    var regularColor = UIColor.lightGray

    override func awakeFromNib() {
        regularColor = regularColor.withAlphaComponent(0.3)
        beatClearColor = beatColor.withAlphaComponent(0.3)
        rebuildMetronome ()
        super.awakeFromNib()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        rebuildMetronome()
    }
    
    func rebuildMetronome(inClose: Bool = false) {
        //dots.removeAll()

        // the height of this view should be set to the desired dotCenters
        var dotCenters = CGFloat(ceil(frame.height))
        let dotSize = CGFloat(ceil(dotCenters * 0.6))
        //var dotSpacing =  dotSize
        if isiPhoneSE() ||
           DeviceType.IS_IPHONE_5orSE ||
           DeviceType.IS_IPHONE_4_OR_LESS {
            dotCenters *= 0.7
        }
         
        //let firstDotCenterXOffset = ceil(((CGFloat(numBeats) - 1.0) / 2.0) * dotCenters)
        let firstDotCenterXOffset = ceil(((CGFloat(numDots) - 1.0) / 2.0) * dotCenters)
        useThisToSuppressWarnings(str: "\(firstDotCenterXOffset)")
        let firstDotCenterX = CGFloat(10.0) // CGFloat(ceil((frame.width / 2) - firstDotCenterXOffset))
        let dotCenterY = CGFloat(ceil(frame.height / 2))

        //for i in 0 ..< numBeats {
        for i in 0 ..< numDots {
            let frame = CGRect(x: 0, y: 0, width: dotSize, height: dotSize)
            let dot = DotView(frame: frame, backColor: regularColor)
            dots.append(dot)
            let center = CGPoint(x: firstDotCenterX + CGFloat(i) * dotCenters, y: dotCenterY)
            dot.center = center
            addSubview(dot)
        }
        
        self.clipsToBounds = false
    }

    func setNumBeats(numberBeats: Int) {
        self.numBeats = numberBeats
        if numberBeats > numDots {
            self.numBeats = numDots
        }
        for i in 0 ..< numDots {
            dots[i].isHidden = i < numBeats ? false : true
        }
    }
    
    func setBeat(_ dotIndex: Int) {
        if dots.count <= 0 { return }
        
        for i in 0 ..< numBeats {
            dots[i].layer.backgroundColor = (i == dotIndex) ? beatColor.cgColor : regularColor.cgColor
        }
        if !(0...numBeats).contains(dotIndex) { // a -1 is sent to indicate "reset"
            return                              // only do the animation if running . . .
        }
        UIView.animate(withDuration: 0.25, delay: 0.25, options: .curveLinear, animations: {
             self.dots[dotIndex].layer.backgroundColor = self.beatClearColor.cgColor
        } )
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
