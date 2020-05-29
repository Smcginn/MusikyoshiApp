//
//  LaunchingNextView.swift
//  FirstStage
//
//  Created by Scott Freshour on 8/16/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

let kViewFinished_Proceed = 0
let kViewFinished_Pause   = 1
let kViewFinished_UnPause = 2

let kViewFinishedMode_Ready   = 0
let kViewFinishedMode_First   = 1
let kViewFinishedMode_Loading = 2
let kViewFinishedMode_AllDone = 3


let kViewExerMode_Auto   = 0
let kViewExerMode_Paused = 0



let kAnimDuration = 2.15 // 0.6

protocol ViewFinished {
    func viewFinished(result: Int)
}

class LaunchingNextView: UIView {
    
    static let kDlgWd:         CGFloat = 350.0 //300.0
    static let kDlgHt:         CGFloat = 275.0
    
    let kBackgroundColor = kDefault_LaunchingViewBackgroundColor
    //let bkcolr = [UIColor colorWithRed:1.0 green:0.675 blue:0.156 alpha:0.4]
    
    let kHugeTextFontSz         : CGFloat = 36.0 // 48.0
    let kLargeTextFontSz        : CGFloat = 24.0 // 36.0
    let kMediumTextFontSz       : CGFloat = 18.0 // 24.0
    let kBtnTextFontSz          : CGFloat = 18.0 // 18.0
    
    
    let kGoodJob_Y:     CGFloat =  10.0
    let kGoodJobX:      CGFloat =  10.0
    let kGoodJobHt:     CGFloat =  70.0
    
    
    let kLoadingNext_Y: CGFloat =  70.0
    var kMonkey_Y:      CGFloat = 130.0
    
    let kProgBar_Y:     CGFloat = 150.0
    let kProgBar_Ht:    CGFloat =  25.0
    
    
    let kPauseBtn_Y:    CGFloat = 220.0
    let kPauseBtn_Ht:   CGFloat =  40.0
    let kPauseBtn_Wd:   CGFloat = 130.0
    
    
    let kBeginMonkeyAnimCenterX:        CGFloat =  -50.0
    let kAddForEndMonkeyAnimCenterX:    CGFloat =  300.0 // 400.0
    
    var waitingToBegin = true
    var exercisesDone = false

    var isPaused = false
    
    var viewFinishedDelegate: ViewFinished? = nil
    func setViewFinishedDelegate(del: ViewFinished) {
        viewFinishedDelegate = del
    }
    
    var mode = kViewFinishedMode_First {
        didSet {
            switch mode {
            case kViewFinishedMode_Ready:   setupForModeReady()
            case kViewFinishedMode_First:   setupForModeFirst()
            case kViewFinishedMode_AllDone: setupForModeAllDone()
            case kViewFinishedMode_Loading: fallthrough
            default:  setupForModeLoading()
            }
        }
    }
    
    func setupForModeReady() {
        progBar?.isHidden = false
        
        var topText : NSMutableAttributedString? // = nil
        var midText : NSMutableAttributedString? // = nil

        if isPaused {
            topText = createAttrString(forString: "Paused",
                                       fontSize: kLargeTextFontSz)
            midText = createAttrString(forString: "Press Go to resume",
                                       fontSize: kMediumTextFontSz)
        } else {
            topText = createAttrString(forString: "Ready To Begin?",
                                              fontSize: kLargeTextFontSz)
            midText = createAttrString(forString: "Press Go . . .",
                                            fontSize: kMediumTextFontSz)
        }
        goodJobLbl?.attributedText = topText
        loadingNextLbl?.attributedText  = midText
        
        let btnTxt = createAttrString(forString: "Go",
                                      fontSize: kBtnTextFontSz)
        pauseBtn?.titleLabel?.attributedText = btnTxt
        pauseBtn?.setTitle("Go", for: .normal)
        progBar?.isHidden = true
    }

    func setupForModeFirst() {
        if waitingToBegin {
            waitingToBegin = false
        }
        
        progBar?.isHidden = false
        let allDoneTxt = createAttrString(forString: "Lets Get Started",
                                          fontSize: kLargeTextFontSz)
        goodJobLbl?.attributedText = allDoneTxt
        
        let readyTxt = createAttrString(forString: "Loading First Exercise . . .",
                                        fontSize: kMediumTextFontSz)
        loadingNextLbl?.attributedText  = readyTxt
        
        let btnTxt = createAttrString(forString: "Pause",
                                      fontSize: kBtnTextFontSz)
        pauseBtn?.titleLabel?.attributedText = btnTxt
        pauseBtn?.setTitle("Pause", for: .normal)
    }
    
    func setupForModeLoading() {
        progBar?.isHidden = false
        let goodJobText = randomEncouragingText()
        let goodJobAttrText = createAttrString(forString: goodJobText,
                                               fontSize: kHugeTextFontSz)
        // -> NSMutableAttributedString
        goodJobLbl?.attributedText = goodJobAttrText // "All Done!"
        
        let readyTxt = createAttrString(forString: "Loading Next Exercise . . .",
                                        fontSize: kMediumTextFontSz)
        loadingNextLbl?.attributedText  = readyTxt
        
        
        let btnTxt = createAttrString(forString: "Pause",
                                      fontSize: kBtnTextFontSz)
        pauseBtn?.titleLabel?.attributedText = btnTxt
        pauseBtn?.setTitle("Pause", for: .normal)
    }
    
    func setupForModeAllDone() {
        exercisesDone = true
        progBar?.isHidden = true
        let allDoneTxt = createAttrString(forString: "All Done!",
                                          fontSize: kHugeTextFontSz)
        // -> NSMutableAttributedString
        goodJobLbl?.attributedText = allDoneTxt // "All Done!"
        
        let readyTxt = createAttrString(forString: "Next Day?",
                                        fontSize: kMediumTextFontSz)
        loadingNextLbl?.attributedText  = readyTxt
        
        
        let btnTxt = createAttrString(forString: "Return",
                                      fontSize: kBtnTextFontSz)
        pauseBtn?.titleLabel?.attributedText = btnTxt
        pauseBtn?.setTitle("Return", for: .normal)
    }
    
    let encouringTextEntries = [ "Awesome!", "Way To Go!", "Great Job!", "Keep It Up!"]
    var currRandomTextNum = 0
    func randomEncouragingText() -> String {
        currRandomTextNum += 1
        if currRandomTextNum >= encouringTextEntries.count {
            currRandomTextNum = 0
        }
        return encouringTextEntries[currRandomTextNum]
    }
    
    var monkeyImageView:  UIImageView? = nil
    var monkeyImageView2: UIImageView? = nil
    var monkeyImageView3: UIImageView? = nil
    var whichImgView: UIImageView? = nil
    var goodJobLbl: UILabel? = nil
    var loadingNextLbl: UILabel? = nil
    var progBar: UIView? = nil
    var pauseBtn: UIButton? = nil


    var pauseButton: UIButton?
 
    var monkeyImageEntries:[UIImageView?] = []

    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported for LaunchingNextView")
    }
    
    static func getSize() -> CGSize {
        return CGSize(width:  LaunchingNextView.kDlgWd,
                      height: LaunchingNextView.kDlgHt)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.roundedView()
        self.center.x = super.center.x
        addLabelsAndProgBar()
        addPauseBtn()
        self.backgroundColor = kBackgroundColor
        buildMonkeyImageView()
        buildMonkeyImageView2()
        buildMonkeyImageView3()
        monkeyImageEntries = [monkeyImageView, monkeyImageView2, monkeyImageView3]
     }
    
    func addPauseBtn() {
        self.monkeyImageView?.center.x  = -50
        self.monkeyImageView2?.center.x = -50

        let selfWd = self.frame.size.width
        let pauseX = (selfWd/2.0) - (kPauseBtn_Wd/2.0)
        let btnFrame = CGRect( x: pauseX , y: kPauseBtn_Y,
                               width: kPauseBtn_Wd, height: kPauseBtn_Ht )
        pauseBtn = UIButton(frame: btnFrame)
 
        pauseBtn?.roundedButton()
        pauseBtn?.backgroundColor = UIColor.black
        pauseBtn?.addTarget(self,
                           action: #selector(pausedPressed(sender:)),
                           for: .touchUpInside )
        pauseBtn?.isEnabled = true
        pauseBtn?.isHidden = false
        let pauseStr = "Pause"
        let pauseMutableString =
            NSMutableAttributedString( string: pauseStr,
                                       attributes: [NSAttributedString.Key.font:UIFont(
                                        name: "Marker Felt",
                                        size: kBtnTextFontSz)!])
        pauseBtn?.titleLabel?.attributedText = pauseMutableString
        pauseBtn?.titleLabel?.textColor = UIColor.yellow
        pauseBtn?.setTitle("Pause", for: .normal)
        self.addSubview(pauseBtn!)
    }
    
    func createAttrString(forString: String, fontSize: CGFloat) -> NSMutableAttributedString {
        //let retMutableStr =
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        let retMutableStr =
            NSMutableAttributedString(
                string: forString,
                attributes: [
                    NSAttributedString.Key.font:UIFont( name: "Marker Felt",
                                                       size: fontSize)!,
                    NSAttributedString.Key.paragraphStyle: paragraphStyle] )
        return retMutableStr
    }
    
    @objc func pausedPressed(sender: UIButton) {
        if waitingToBegin || exercisesDone {
            viewFinishedDelegate?.viewFinished(result: kViewFinished_Proceed)
        } else if isPaused {
            isPaused = false
            viewFinishedDelegate?.viewFinished(result: kViewFinished_UnPause)
        } else {
            monkeyImageView?.isHidden = true
            monkeyImageView2?.isHidden = true
            progBar?.isHidden = true

            self.layer.removeAllAnimations()
            viewFinishedDelegate?.viewFinished(result: kViewFinished_Pause)
        }
    }

    func addLabelsAndProgBar() {
        
        // Add the TEMPORARY "Coming Soon" and Video Description Msg Labels.
        // These appear if the Video is not yet available, announcing that the
        // video is coming . . .
        
        let superFrm = self.frame
        let goodJobWd:CGFloat = superFrm.size.width - (2*kGoodJobX)
        let goodJobFrame = CGRect( x: kGoodJobX , y: kGoodJob_Y,
                                   width: goodJobWd, height: kGoodJobHt )
        goodJobLbl = UILabel(frame: goodJobFrame)
        
        let goodJobAttrStr = createAttrString(forString: "Good Job!",
                                          fontSize: kHugeTextFontSz)

        goodJobLbl?.attributedText  = goodJobAttrStr
        goodJobLbl?.textColor = UIColor.black
        self.addSubview(goodJobLbl!)
        
        var ldingNextFrame = goodJobFrame
        ldingNextFrame.origin.y = kLoadingNext_Y //100.0
            
        loadingNextLbl = UILabel(frame: ldingNextFrame)
        let ldingNextStr = "Loading Next Exercise . . ."
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        let ldingNextAttrStr =
            NSMutableAttributedString(
                string: ldingNextStr,
                attributes: [ NSAttributedString.Key.font:UIFont(
                    name: "Marker Felt",
                    size: kMediumTextFontSz)!,
                              NSAttributedString.Key.paragraphStyle: paragraphStyle])
        loadingNextLbl?.attributedText  = ldingNextAttrStr
        loadingNextLbl?.textColor = UIColor.black
        self.addSubview(loadingNextLbl!)
        
        
        var progBarFrame = goodJobFrame
        progBarFrame.size.height = kProgBar_Ht
        progBarFrame.origin.y = kProgBar_Y
        progBar = UIView.init(frame: progBarFrame)
        progBar?.backgroundColor = UIColor.purple
        self.addSubview(progBar!)
    }

    func buildMonkeyImageView() {
        let mnkyImg1 = UIImage(named:"Monkey_Jumping Temples_monkey 04@2x")!
        let mnkyImg2 = UIImage(named:"Monkey_Jumping Temples_monkey 03@2x")!
        let mnkyImg3 = UIImage(named:"Monkey_Jumping Temples_monkey 02@2x")!
        UIGraphicsBeginImageContextWithOptions(mnkyImg1.size, false, 0.0);
        let emptyImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Have to see original in Tunes to understand the numbering
        // - I changed the associated images . . .
        // Using images, alternate to create dancing . . .
        let imgArr = [mnkyImg1, mnkyImg2, mnkyImg1, mnkyImg2,
                      mnkyImg1, mnkyImg2, mnkyImg3, mnkyImg2,
                      mnkyImg1, mnkyImg2, mnkyImg1, mnkyImg2,
                      mnkyImg1, mnkyImg2, mnkyImg1, mnkyImg2,
                      mnkyImg3, mnkyImg2, mnkyImg1, mnkyImg2,
                      mnkyImg3, mnkyImg2, mnkyImg1, mnkyImg2,
                      mnkyImg1, mnkyImg2, mnkyImg3, mnkyImg1,
                      mnkyImg2, mnkyImg2, mnkyImg1]
        print("imsz")
        monkeyImageView = UIImageView(image:emptyImg)
        monkeyImageView?.frame.origin = CGPoint(x: 160, y: kMonkey_Y)
        self.addSubview(monkeyImageView!)
        monkeyImageView?.animationImages = imgArr
        monkeyImageView?.animationDuration = kAnimDuration
        monkeyImageView?.animationRepeatCount = 1
    }
    
    func buildMonkeyImageView2() {
        let mnkyImg1 = UIImage(named:"Monkey_Skiing_03@2x")!
        let mnkyImg2 = UIImage(named:"Monkey_Skiing_02@2x")!
//        let mnkyImg3 = UIImage(named:"Monkey_Skiing_01@2x")!
        let mnkyImg4 = UIImage(named:"Monkey_Skiing_06@2x")!
        // iOS 10 or later:
        //  let emptyImg = UIGraphicsImageRenderer(size: mnkyImg1.size).image {_ in}
        UIGraphicsBeginImageContextWithOptions(mnkyImg1.size, false, 0.0);
        let emptyImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imgArr = [mnkyImg4, mnkyImg4, mnkyImg4, mnkyImg4,
                      mnkyImg1, mnkyImg2, mnkyImg1, mnkyImg2,
                      mnkyImg1,
                      mnkyImg4, mnkyImg4, mnkyImg4, mnkyImg4,]
        
        monkeyImageView2 = UIImageView(image:emptyImg)
        monkeyImageView2?.frame.origin = CGPoint(x: 160, y: kMonkey_Y+20)
        self.addSubview(monkeyImageView2!)
        monkeyImageView2?.animationImages = imgArr
        monkeyImageView2?.animationDuration = kAnimDuration
        monkeyImageView2?.animationRepeatCount = 1
    }

    
    func buildMonkeyImageView3() {
        let mnkyImg1 = UIImage(named:"MonkeyPlaneWithProp large")!
        let mnkyImgSmall = UIImage(named:"Monkey_Jumping Temples_monkey 04@2x")!
        // iOS 10 or later:
        //  let emptyImg = UIGraphicsImageRenderer(size: mnkyImg1.size).image {_ in}
        UIGraphicsBeginImageContextWithOptions(mnkyImgSmall.size, false, 0.0);
        let emptyImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let imgArr = [mnkyImg1]
        
        monkeyImageView3 = UIImageView(image:emptyImg)
        monkeyImageView3?.transform = CGAffineTransform(scaleX: -1, y: 1); //Flipped

        monkeyImageView3?.frame.origin = CGPoint(x: 160, y: kMonkey_Y)
        self.addSubview(monkeyImageView3!)
        monkeyImageView3?.animationImages = imgArr
        monkeyImageView3?.animationDuration = kAnimDuration
        monkeyImageView3?.animationRepeatCount = 1
    }
    
    var currRandomMonkeyNum = 0
    func randommonkeyImage() -> UIImageView? {
        currRandomMonkeyNum += 1
        if currRandomMonkeyNum >= monkeyImageEntries.count {
            currRandomMonkeyNum = 0
        }
        
        return monkeyImageEntries[currRandomMonkeyNum]
    }
    
    func animateMonkeyImageView() {
 //       self.whichImgView = randommonkeyImage()
        
 //       self.whichImgView?.center.x = self.kBeginMonkeyAnimCenterX
 //       self.whichImgView?.startAnimating()
        progBar?.backgroundColor = UIColor.clear

        progBar?.isHidden = true
        self.progBar?.frame.size.width = 1
        self.progBar?.setNeedsDisplay()
        self.setNeedsDisplay()

 //       self.whichImgView?.isHidden = false
        
        if !isPaused {
            delay(0.1) {}
            progBar?.backgroundColor = UIColor.purple
            progBar?.isHidden = false
            
            UIView.animate(withDuration: kAnimDuration, delay: 0.0, options: .curveLinear, animations: {
     //           self.whichImgView?.center.x += self.kAddForEndMonkeyAnimCenterX
                let superFrm = self.frame
                self.progBar?.frame.size.width = superFrm.size.width - 20
            }) { (_) in
                if !self.exercisesDone { // don't auto-return to caller if all done
                    self.viewFinishedDelegate?.viewFinished(result: kViewFinished_Proceed)
                }
            }
        }
    }
    
    /*
    func animateMonkeyImageView() {
        self.whichImgView = randommonkeyImage()
        
        self.whichImgView?.center.x = self.kBeginMonkeyAnimCenterX
        self.whichImgView?.startAnimating()
        self.progBar?.frame.size.width = 1
        self.whichImgView?.isHidden = false
        progBar?.isHidden = false
        
        UIView.animate(withDuration: kAnimDuration, delay: 0.0, options: .curveLinear, animations: {
            self.whichImgView?.center.x += self.kAddForEndMonkeyAnimCenterX
            let superFrm = self.frame
            self.progBar?.frame.size.width = superFrm.size.width - 20
        }) { (_) in
            if !self.exercisesDone { // don't auto-return to caller if all done
                self.viewFinishedDelegate?.viewFinished(result: kViewFinished_Proceed)
            }
        }
     }
     */
}
