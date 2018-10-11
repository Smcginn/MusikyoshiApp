//
//  Balloon.swift
//  FirstStage
//
//  Created by Adam Kinney on 12/13/15.
//  Changed by David S Reich  - 2016.
//  Changed by Scott Freshour - 2018.
//  Copyright © 2015 Musikyoshi. All rights reserved.
//

import UIKit

class Balloon: UIView {
    
    fileprivate var circle : CAShapeLayer?
    fileprivate let length : CGFloat = 128
    
    var imgView: UIImageView!
    var monkeyFaceImgVw: UIImageView!
    
    let balloonImage1 = UIImage(named: "Balloon_1")
    let balloonImage2 = UIImage(named: "Balloon_2")
    let balloonImage3 = UIImage(named: "Balloon_3")
    let balloonImage4 = UIImage(named: "Balloon_4")
    let balloonImage5 = UIImage(named: "Balloon_5")
    let balloonExplodeImg = UIImage(named: "Monkey_Ballon_Explode")

    var superCenter = CGPoint(x: 0.0, y: 0.0)
    
    var expCount = 0
    var currImg  = 1

    var startX:  CGFloat = 0.0
    var startY:  CGFloat = 0.0
    var startWd: CGFloat = 0.0
    var endWd:   CGFloat = 0.0
    var wdRange: CGFloat = 0.0
    
    var fillColor = UIColor.blue.cgColor {
        didSet{
            if circle != nil
            {
                circle?.fillColor = fillColor
            }
        }
    }
    
    var currPercentage: Int = 1
    
    func deflateBallon() {
        UIView.animate(withDuration: 1.5, delay: 0.0, options: .curveLinear, animations: {
            // this will change Y position of your imageView center
            // by 1 every time you press button
            self.imgView.frame.size.width  = self.startWd
            self.imgView.frame.size.height = self.startWd
            self.imgView.frame.origin.x    = self.startX
            self.imgView.frame.origin.y    = self.startY
            self.imgView.alpha = 1.0
        }) { (_) in }
    }
    
    func increaseBalloonSize(toPercentage: CGFloat) {
        let toPercentageInt = Int(toPercentage*100)
        //print("toPercentageInt: \(toPercentageInt),   currPercentage: \(currPercentage)")
       
        guard toPercentageInt > currPercentage, // exclude 0, too
              //toPercentageInt <= 100,
              imgView != nil
            else { return }
        
        currPercentage = toPercentageInt
        
        // change image if necessary, as balloon gets bigger
        if currPercentage > 20 &&  currImg <= 1 {
            imgView.image = balloonImage2
            currImg = 2
        }
        else if currPercentage > 40 && currImg <= 2 {
            imgView.image = balloonImage3
            currImg = 3
        }
        else if currPercentage > 60 && currImg <= 3 {
            imgView.image = balloonImage4
            currImg = 4
        }
        else if currPercentage > 80 && currImg <= 4 {
            imgView.image = balloonImage5
            currImg = 5
        }
        
        let growth = wdRange * toPercentage
        print("  growth == \(growth)")
        let newWd = startWd + growth
        print("  newWd == \(newWd)")
        imgView.frame.size = CGSize(width:newWd, height: newWd)
        
        let x = self.frame.width/2 - newWd/2
        let y = self.frame.height/2 - newWd/2

        imgView.frame.origin.x = x
        imgView.frame.origin.y = y
    }
    
    func explodeBalloon(hideMonkeyFace: Bool = true)
    {
        imgView.image = balloonExplodeImg
        
        // First, animate increasing explosion image by 400 pixels
        UIView.animate(withDuration: 0.75, delay: 0.0, options: .curveLinear, animations: {
            // this will change Y position of your imageView center
            // by 1 every time you press button
            self.imgView.frame.size.width += 400
            self.imgView.frame.size.height += 400
            self.imgView.frame.origin.x -= 200
            self.imgView.frame.origin.y -= 200
            self.imgView.alpha = 0.7
        }) { (_) in

        // Then, fade out the image while having the pieces "fall"
        UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveLinear, animations: {
            // this will change Y position of your imageView center
            // by 1 every time you press button
            self.imgView.center.y += 300
            self.imgView.alpha = 0.0
            if hideMonkeyFace {
                self.monkeyFaceImgVw.alpha = 0.0
            }
        } )
        }
    }
    
    //  uncomment to restore use of non-image balloon.
    var radius : CGFloat = 6.0// {
//       didSet{
//            expCount += 0
//            if circle != nil
//            {
//                circle?.path = UIBezierPath(roundedRect: CGRect(x: length-radius, y: length-radius, width: 2.0 * radius, height: 2.0 * radius)  , cornerRadius: radius).cgPath
//            }
//            if imgView != nil {
//                var imgWd = imgView.frame.width
//                var imgHt = imgView.frame.height
//                imgWd *= 1.003
//                imgHt *= 1.003
//
//                 if expCount > 100 && currImg < 5 {
//                    if currImg == 1 {
//                        imgView.image = balloonImage2
//                        currImg = 2
//                    }
//                    else if currImg == 2 {
//                        imgView.image = balloonImage3
//                        currImg = 3
//                   }
//                    else if currImg == 3 {
//                        imgView.image = balloonImage4
//                        currImg = 4
//                   }
//                    else if currImg == 4 {
//                        imgView.image = balloonImage5
//                        currImg = 5
//                    }
//                    expCount = 0
//                }
//                expCount += 1
//
//                imgView.frame.size = CGSize(width:imgWd, height: imgHt)
//                let wd = self.frame.width
//                let ht = self.frame.height
//                let x = wd/2 - imgWd/2
//                let y = ht/2 - imgHt/2
//
//                imgView.frame.origin.x = x
//                imgView.frame.origin.y = y
//            }
//        }
//    }
    
    
    func reset() {
        currImg = 1
        currPercentage = 1
        imgView.image = balloonImage1
        imgView.frame.size = balloonImage1!.size
        
        let imgWd = imgView.frame.width
        let imgHt = imgView.frame.height
        let wd = self.frame.width
        let ht = self.frame.height
        
        let x = wd/2 - imgWd/2
        let y = ht/2 - imgHt/2
        
        imgView.frame.origin.x = x
        imgView.frame.origin.y = y
        
        imgView.alpha = 1.0
   }
    
    override func awakeFromNib() {
        
        startWd = balloonImage1!.size.width
        endWd   = self.frame.size.width
        wdRange = endWd - startWd
        
        let selfFrame = self.frame
        let selfWd = selfFrame.size.width
        let selfHt = selfFrame.size.height
        
        let monkeyFaceImg = UIImage(named: "Monkey_Ballon-Face02@2x")
        monkeyFaceImgVw = UIImageView(image:monkeyFaceImg)
        let monkeyWd = monkeyFaceImgVw.bounds.size.width
        let monkeyHt = monkeyFaceImgVw.bounds.size.height
        let monkeyX = selfWd/2.0 - monkeyWd/2.0
        var monkeyY = selfHt/2.0 - monkeyHt/2.0
        monkeyY -= 25.0 // this is the amount that the mouth is not centered
                        //   in Monkey face image
        
        addSubview(monkeyFaceImgVw)
        monkeyFaceImgVw.frame.origin.x = monkeyX
        monkeyFaceImgVw.frame.origin.y = monkeyY

        imgView = UIImageView(image: balloonImage1)
        imgView.frame.size = balloonImage1!.size
        addSubview(imgView)
        
        superCenter = self.center
        
        let imgWd = imgView.frame.width
        let imgHt = imgView.frame.height
        let wd = self.frame.width
        let ht = self.frame.height

        let x = wd/2 - imgWd/2
        let y = ht/2 - imgHt/2
        
        imgView.frame.origin.x = x
        imgView.frame.origin.y = y
        startX  = x
        startY  = y

        circle = CAShapeLayer()
        let c = circle!
        c.fillColor = fillColor
        c.path = UIBezierPath(roundedRect: CGRect(x: length-radius, y: length-radius, width: 2.0 * radius, height: 2.0 * radius)  , cornerRadius: radius).cgPath
        
        //  uncomment to restore use of non-image balloon.
 //       layer.addSublayer(c)
 
    }
}
