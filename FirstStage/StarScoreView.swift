//
//  StarScoreView.swift
//  FirstStage
//
//  Created by Scott Freshour on 8/6/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

class StarScore: UIView {

    let bananaOnImage  = UIImage(named: "bananas")
    let bananaOffImage = UIImage(named: "bananas_incomplete")!.alpha(0.5)

    var imgView: UIImageView!

    var star1ImgView: UIImageView!
    var star2ImgView: UIImageView!
    var star3ImgView: UIImageView!
    var star4ImgView: UIImageView!

    func setStarCount(numStars: Int) {
        switch numStars {
        case 1: star1ImgView.image = bananaOnImage
                star2ImgView.image = bananaOffImage
                star3ImgView.image = bananaOffImage
                star4ImgView.image = bananaOffImage
        case 2: star1ImgView.image = bananaOnImage
                star2ImgView.image = bananaOnImage
                star3ImgView.image = bananaOffImage
                star4ImgView.image = bananaOffImage
        case 3: star1ImgView.image = bananaOnImage
                star2ImgView.image = bananaOnImage
                star3ImgView.image = bananaOnImage
                star4ImgView.image = bananaOffImage
        case 4: star1ImgView.image = bananaOnImage
                star2ImgView.image = bananaOnImage
                star3ImgView.image = bananaOnImage
                star4ImgView.image = bananaOnImage
        case 0: fallthrough
        default: star1ImgView.image = bananaOffImage
                 star2ImgView.image = bananaOffImage
                 star3ImgView.image = bananaOffImage
                 star4ImgView.image = bananaOffImage
       }
    }
    
    func initWithPoint(atPoint: CGPoint) {
        
        let oneStarSize = bananaOnImage!.size
        
        star1ImgView = UIImageView(image: bananaOffImage)
        star1ImgView.frame.origin.x = 1
        self.addSubview(star1ImgView)
        
        star2ImgView = UIImageView(image: bananaOffImage)
        star2ImgView.frame.origin.x = oneStarSize.width + 3
        self.addSubview(star2ImgView)

        star3ImgView = UIImageView(image: bananaOffImage)
        star3ImgView.frame.origin.x = (2*oneStarSize.width) + 5
        self.addSubview(star3ImgView)

        star4ImgView = UIImageView(image: bananaOffImage)
        star4ImgView.frame.origin.x = (3*oneStarSize.width) + 7
        self.addSubview(star4ImgView)

        let viewHt = oneStarSize.height + 2
        let viewWd = (oneStarSize.width * 4) + 10
        self.frame =  CGRect(x: atPoint.x, y: atPoint.y, width: viewWd, height: viewHt)
    }
    
    static func getSize() -> CGSize {
        let bananaOnImage  = UIImage(named: "bananas")
        let oneStarSize = bananaOnImage?.size
        let viewHt = (oneStarSize?.height)! + 2
        let viewWd = ((oneStarSize?.width)! * 4) + 10
        return CGSize(width: viewWd, height: viewHt)
    }
    
    func pulseView() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue =  1.5
        pulseAnimation.autoreverses = true
        pulseAnimation.duration = 0.5
        pulseAnimation.beginTime = 0.0
        pulseAnimation.repeatCount = 4.0
        self.layer.add(pulseAnimation, forKey: nil)
     }
}

extension UIImage {
    
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

