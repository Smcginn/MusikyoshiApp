//
//  LevelSeriesTableViewHeaderFooterView.swift
//  FirstStage
//
//  Created by Scott Freshour on 8/22/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

typealias LvlSeriesTVwHdrFtrVw = LevelSeriesTableViewHeaderFooterView

class LevelSeriesTableViewHeaderFooterView: UITableViewHeaderFooterView {
    var section = 0
    var isChecked = false
    
    static var checkImage: UIImage? = nil
    static var blankImage: UIImage? = nil
    static var currentImage: UIImage? = nil
    
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
        //       checkPathGray.lineWidth = 3
        checkPathGray.move(to: CGPoint(x: 2+xAdj, y: 8))
        checkPathGray.addLine(to:CGPoint(x: 7+xAdj, y: 13))
        checkPathGray.addLine(to:CGPoint(x: 19+xAdj, y: 2))
        
        checkPathGray.lineWidth = 4
        UIColor.darkGray.setStroke()
        checkPathGray.stroke()
        
        let checkPathGreen = UIBezierPath()
        //        checkPathGreen.lineWidth = 3
        checkPathGreen.move(to: CGPoint(x: 3+xAdj, y: 9))
        checkPathGreen.addLine(to:CGPoint(x: 7+xAdj, y: 13))
        checkPathGreen.addLine(to:CGPoint(x: 18+xAdj, y: 3))
        
        checkPathGreen.lineWidth = 2
        UIColor.green.setStroke()
        checkPathGreen.stroke()
        
        LvlSeriesTVwHdrFtrVw.checkImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    static func getImageForCheckState(state: CheckState) -> UIImage? {
        LvlSeriesTVwHdrFtrVw.makeCheckboxIconImagesIfNeeded()
        if state == .checked {
            return LvlSeriesTVwHdrFtrVw.checkImage
        } else if state == .current {
            return  LvlSeriesTVwHdrFtrVw.currentImage
        } else {
            return  LvlSeriesTVwHdrFtrVw.blankImage
        }
    }
    
    func makeCheckboxImageViewIfNeeded() {
        guard checkImageView == nil
            else { return }
        
        LvlSeriesTVwHdrFtrVw.makeCheckboxIconImagesIfNeeded()
        checkImageView = UIImageView(image:LvlSeriesTVwHdrFtrVw.checkImage)
    }
    
    var checkImageView: UIImageView? = nil

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        LvlSeriesTVwHdrFtrVw.makeCheckboxIconImagesIfNeeded()
        makeCheckboxImageViewIfNeeded()
        if checkImageView != nil {
            checkImageView!.frame.origin.x = 7
            checkImageView!.frame.origin.y = 6
            self.contentView.addSubview(checkImageView!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum CheckState {
        case unchecked
        case checked
        case current
    }

    var checkedState: CheckState = .unchecked
    func setCheckedState( state: CheckState ) {
        self.checkedState = state
        
        guard LvlSeriesTVwHdrFtrVw.checkImage != nil,
              LvlSeriesTVwHdrFtrVw.blankImage != nil,
              LvlSeriesTVwHdrFtrVw.currentImage != nil,
              checkImageView != nil
            else { return }
        
        if checkedState == .checked {
            checkImageView?.image = LvlSeriesTVwHdrFtrVw.checkImage
        } else if checkedState == .current {
            checkImageView?.image = LvlSeriesTVwHdrFtrVw.currentImage
        } else {
            checkImageView?.image = LvlSeriesTVwHdrFtrVw.blankImage
        }
    }
 }
