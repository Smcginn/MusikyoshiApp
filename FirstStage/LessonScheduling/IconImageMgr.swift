//
//  IconImageMgr.swift
//  FirstStage
//
//  Created by Scott Freshour on 8/27/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

let kIconImageID_NoStars_NotSelected        =  0
let kIconImageID_OneStars_NotSelected       =  1
let kIconImageID_TwoStars_NotSelected       =  2
let kIconImageID_ThreeStars_NotSelected     =  3
let kIconImageID_FourStars_NotSelected      =  4
let kIconImageID_NoStars_Selected           =  5
let kIconImageID_OneStars_Selected          =  6
let kIconImageID_TwoStars_Selected          =  7
let kIconImageID_ThreeStars_Selected        =  8
let kIconImageID_FourStars_Selected         =  9

class IconImageMgr {
    
    static let instance = IconImageMgr()
    
    let noStarImg:     UIImage? = UIImage(named:"Stars-0 64x16")
    let oneStarImg:    UIImage? = UIImage(named:"Stars-1 64x16")
    let twoStarImg:    UIImage? = UIImage(named:"Stars-2 64x16")
    let threeStarImg:  UIImage? = UIImage(named:"Stars-3 64x16")
    let fourStarImg:   UIImage? = UIImage(named:"Stars-4 64x16")
    
    let isCurrentImg:  UIImage? = UIImage(named:"Current Arrow 22x16")
    
    var iconImages: [UIImage?] = []
    
    init() {
        createExerciseIcons()
    }
    
    func getExerciseIcon(numStars: Int, isCurrent: Bool )  -> UIImage? {
        var retImg = iconImages[kIconImageID_NoStars_NotSelected]
        if isCurrent {
            switch numStars {
            case 4:  retImg = iconImages[kIconImageID_FourStars_Selected]
            case 3:  retImg = iconImages[kIconImageID_ThreeStars_Selected]
            case 2:  retImg = iconImages[kIconImageID_TwoStars_Selected]
            case 1:  retImg = iconImages[kIconImageID_OneStars_Selected]
            default: retImg = iconImages[kIconImageID_NoStars_Selected]
            }
        } else { // not Current
            switch numStars {
            case 4:  retImg = iconImages[kIconImageID_FourStars_NotSelected]
            case 3:  retImg = iconImages[kIconImageID_ThreeStars_NotSelected]
            case 2:  retImg = iconImages[kIconImageID_TwoStars_NotSelected]
            case 1:  retImg = iconImages[kIconImageID_OneStars_NotSelected]
            default: retImg = iconImages[kIconImageID_NoStars_NotSelected]
            }
        }
        return retImg
    }
    
    func getExerciseIcon( whichIcon: Int ) -> UIImage? {
        guard whichIcon > 0,
            whichIcon < iconImages.count else {
            itsBad()
            return nil
        }
        
        return iconImages[whichIcon]
    }
    
    func createExerciseIcon( sz: CGSize, numStars: Int, isCurrent: Bool ) -> UIImage? {
        var img: UIImage? = nil
        
        UIGraphicsBeginImageContextWithOptions(sz, false, 0.0);
 
        var starImg: UIImage? = nil
        switch numStars {
        case 4:  starImg = fourStarImg
        case 3:  starImg = threeStarImg
        case 2:  starImg = twoStarImg
        case 1:  starImg = oneStarImg
        default: starImg = noStarImg
        }
        starImg?.draw(at: CGPoint(x:0, y:0))
        
        let arrowPt = CGPoint(x:74, y:0)
        if isCurrent {
            isCurrentImg?.draw(at: arrowPt)
        }
        
        img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return img
    }
    
    func createExerciseIconV2( sz: CGSize, numStars: Int, isCurrent: Bool ) -> UIImage? {
        var img: UIImage? = nil
        
        UIGraphicsBeginImageContextWithOptions(sz, false, 0.0);
        
        let arrowPt = CGPoint(x:0, y:0)
        if isCurrent {
            isCurrentImg?.draw(at: arrowPt)
        }
        
        let starX: CGFloat = (isCurrentImg?.size.width)! + 9.0
        let starPt = CGPoint(x:starX, y:0)
        var starImg: UIImage? = nil
        switch numStars {
        case 4:  starImg = fourStarImg
        case 3:  starImg = threeStarImg
        case 2:  starImg = twoStarImg
        case 1:  starImg = oneStarImg
        default: starImg = noStarImg
        }
        starImg?.draw(at: starPt)
        
        img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
    }
    
    func createExerciseIcons() {
        let wd = 64 + 10 + 22
        let sz = CGSize(width: wd, height:16)
        var img: UIImage? = nil
            
        /////  Not Current /////////////
        img = createExerciseIconV2( sz: sz, numStars: 0, isCurrent: false )
        iconImages.append(img)
        
        img = createExerciseIconV2( sz: sz, numStars: 1, isCurrent: false )
        iconImages.append(img)
        
        img = createExerciseIconV2( sz: sz, numStars: 2, isCurrent: false )
        iconImages.append(img)
        
        img = createExerciseIconV2( sz: sz, numStars: 3, isCurrent: false )
        iconImages.append(img)
        
        img = createExerciseIconV2( sz: sz, numStars: 4, isCurrent: false )
        iconImages.append(img)
        
        /////  Is Current /////////////
        img = createExerciseIconV2( sz: sz, numStars: 0, isCurrent: true )
        iconImages.append(img)
        
        img = createExerciseIconV2( sz: sz, numStars: 1, isCurrent: true )
        iconImages.append(img)
        
        img = createExerciseIconV2( sz: sz, numStars: 2, isCurrent: true )
        iconImages.append(img)
        
        img = createExerciseIconV2( sz: sz, numStars: 3, isCurrent: true )
        iconImages.append(img)
        
        img = createExerciseIconV2( sz: sz, numStars: 4, isCurrent: true )
        iconImages.append(img)
    }
    
    var checkImage: UIImage? = nil
    var blankImage: UIImage? = nil
    
    static func makeCheckboxIconImagesIfNeeded() {
        guard LvlSeriesTVwHdrFtrVw.checkImage == nil &&
            LvlSeriesTVwHdrFtrVw.blankImage == nil &&
            LvlSeriesTVwHdrFtrVw.currentImage == nil
            else { return }
        
        LvlSeriesTVwHdrFtrVw.currentImage = UIImage(named: "Current Arrow 30x16")
        
        let imgSz = CGSize(width: 30.0, height: 16.0)
        
        // Create blank image
        UIGraphicsBeginImageContextWithOptions(imgSz, false, 0.0);
        LvlSeriesTVwHdrFtrVw.blankImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let xAdj:CGFloat = -1.0
        // Create "checked" image
        UIGraphicsBeginImageContextWithOptions(imgSz, false, 0.0);
        let checkPathGray = UIBezierPath()
        checkPathGray.move(to: CGPoint(x: 2+xAdj, y: 8))
        checkPathGray.addLine(to:CGPoint(x: 7+xAdj, y: 13))
        checkPathGray.addLine(to:CGPoint(x: 19+xAdj, y: 2))
        
        checkPathGray.lineWidth = 4
        UIColor.darkGray.setStroke()
        checkPathGray.stroke()
        
        let checkPathGreen = UIBezierPath()
         checkPathGreen.move(to: CGPoint(x: 3+xAdj, y: 9))
        checkPathGreen.addLine(to:CGPoint(x: 7+xAdj, y: 13))
        checkPathGreen.addLine(to:CGPoint(x: 18+xAdj, y: 3))
        
        checkPathGreen.lineWidth = 2
        UIColor.green.setStroke()
        checkPathGreen.stroke()
        
        LvlSeriesTVwHdrFtrVw.checkImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
