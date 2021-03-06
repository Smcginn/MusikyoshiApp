//
//  VideoHelpView.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/19/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

////////////////////////////////////////////////////////////////////////////
// This file is responsible for building the PopUp that displays a help video.
//
// It uses the AVPlayerItem, AVPlayer, and AVPlayerViewController classes.
//
// Given a MusiKyoshi VideoID, it locates the correct embedded video, creates
// the URL, and uses it to creates a AVPlayerItem, which is loaded into the
// AVPlayer.
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
// Initial implementation. More or less just a of a proof of concept. Can 
// certainly be improved, as currently it is:
// - Entirely programatic. Should probably be Designed in IB, Storyboarded, etc.
// - Designed to work in Landscape mode - no provision for Portrait mode.
// - Not doing autolayout, etc. hard-coded to work with an iPhone 7; may have 
//   issues with other devices.
// - Only working with the TuneExerciseViewController.

import Foundation
import AVFoundation
import AVKit

// As noted above - programmatic, for quick proof of concept. Size consts:
let avcHt = 250.0  // 285.0 for iPhone 7.  320.0 works for iPhone 7 Plus
let avcWd = avcHt * 1.777
let bottomButtonSpacing = 40.0

class VideoHelpView: UIView {

    var doneBtn: UIButton?
    var againBtn: UIButton?
    
    var avPlayer: AVPlayer?
    var avpVC: AVPlayerViewController?
    
    var comingSoonLabel: UILabel?
    var issueMsgLabel: UILabel?
    var issueMsgText: String?

    static func getSize() -> CGSize {
        let sz = CGSize(width: avcWd, height: avcHt+bottomButtonSpacing)
        return sz
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported for VideoHelpView")
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.roundedView()
        
        self.backgroundColor = (UIColor.lightGray).withAlphaComponent(0.85)
        addMsgLabels()
        addButtons()
    }
    
    func addMsgLabels() {
        
        // Add the TEMPORARY "Coming Soon" and Video Description Msg Labels.
        // These appear if the Video is not yet available, announcing that the 
        // video is coming . . .
        
        let comingSoonX  = 100.0
        let comingSoonY  =  50.0
        let comingSoonHt =  35.0
        let comingSoonWd = 300.0
        let cmngSoonFrame = CGRect( x: comingSoonX , y: comingSoonY,
                                    width: comingSoonWd, height: comingSoonHt )
        comingSoonLabel = UILabel(frame: cmngSoonFrame)
        let comingSoonStr = "Coming Soon, a Video About:"
        let comingSoonAttrStr =
            NSMutableAttributedString( string: comingSoonStr,
                                       attributes: [NSFontAttributeName:UIFont(
                                       name: "Marker Felt",
                                       size: 24.0)!])
        comingSoonLabel?.attributedText  = comingSoonAttrStr
        comingSoonLabel?.textColor = UIColor.yellow
        self.addSubview(comingSoonLabel!)
        
        /////////////////////////////////////////////////////////////////
        let msgY  =  50.0
        let msgHt = 300.0
        let msgFrame = CGRect( x: comingSoonX , y: msgY,
                               width: comingSoonWd, height: msgHt )
        issueMsgLabel = UILabel(frame: msgFrame)
        issueMsgLabel?.textColor = UIColor.yellow
        issueMsgLabel?.lineBreakMode = .byWordWrapping
        issueMsgLabel?.numberOfLines = 3
        self.addSubview(issueMsgLabel!)
    }
    
    func addButtons() {
        let btnWd: CGFloat     = 80.0
        let btnHt: CGFloat     = 35.0
        let rightBtnX: CGFloat = 50.0
        let leftBtnX: CGFloat  = frame.size.width - (rightBtnX + btnWd)
        let btnY: CGFloat      = frame.size.height - (btnHt + 2)
        
        ////////////////////////////////////////////////////////////////////////
        // Again button
        var btnFrame = CGRect( x: rightBtnX , y: btnY, width: btnWd, height: btnHt )
        againBtn = UIButton(frame: btnFrame)
        againBtn?.roundedButton()
        againBtn?.backgroundColor = UIColor.blue
        againBtn?.addTarget(self,
                            action: #selector(playAgain(sender:)),
                            for: .touchUpInside )
        againBtn?.isEnabled = true
        
        let str = "Again"
        let againMutableString =
            NSMutableAttributedString( string: str,
                                       attributes: [NSFontAttributeName:UIFont(
                                        name: "Marker Felt",
                                        size: 24.0)!])
        againBtn?.titleLabel?.attributedText = againMutableString
        againBtn?.titleLabel?.textColor = UIColor.yellow
        againBtn?.setTitle("Again", for: .normal)
        self.addSubview(againBtn!)
        
        ////////////////////////////////////////////////////////////////////////
        // Done button
        btnFrame.origin.x = leftBtnX
        doneBtn = UIButton(frame: btnFrame)
        doneBtn?.roundedButton()
        doneBtn?.backgroundColor = UIColor.blue
        doneBtn?.addTarget(self,
                           action: #selector(allDone(sender:)),
                           for: .touchUpInside )
        doneBtn?.isEnabled = true
        let okStr = "OK"
        let doneMutableString =
            NSMutableAttributedString( string: okStr,
                                       attributes: [NSFontAttributeName:UIFont(
                                        name: "Marker Felt",
                                        size: 24.0)!])
        doneBtn?.titleLabel?.attributedText = doneMutableString
        doneBtn?.titleLabel?.textColor = UIColor.yellow
        doneBtn?.setTitle("OK", for: .normal)
        self.addSubview(doneBtn!)
    }
    
    func roundedView(){
        let maskPAth1 = UIBezierPath(roundedRect: self.bounds,
                                     byRoundingCorners: .allCorners,
                                     cornerRadii:CGSize(width:18.0, height:12.0))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.bounds
        maskLayer1.path = maskPAth1.cgPath
        self.layer.mask = maskLayer1
    }
    
    var playerItem: AVPlayerItem?
    
    func createPlayerItemForVideoID( _ vidID: Int ) -> Bool {
        playerItem = nil
        guard let url = getURLForVideoID( vidID ) else { return false }
        
        playerItem = AVPlayerItem(url: url)
        if playerItem == nil {
            return false
        } else {
            return true
        }
    }
    
    var videoID: Int = vidIDs.kVid_NoVideoAvailable
    
    func buildVideoVC() {

        if avPlayer == nil {
            guard createPlayerItemForVideoID( videoID ) else { return }
            avPlayer = AVPlayer(playerItem: playerItem)
        }
        if avpVC == nil {
            avpVC = AVPlayerViewController()
        }
        avpVC?.player = avPlayer
        
        avpVC?.view.frame = CGRect(x:0, y:0,  width: avcWd, height: avcHt)
        avpVC?.view.tag = 113
        avpVC?.view.backgroundColor = UIColor.clear
        avpVC?.showsPlaybackControls =  false
        self.addSubview((avpVC?.view)!)
    }
    
    func showTempMsg(tempMsg:String) {
        issueMsgText = tempMsg
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        let issueMsgAttrStr =
            NSMutableAttributedString(
                string: issueMsgText!,
                attributes: [NSFontAttributeName:UIFont(name: "Marker Felt",
                                                        size: 24.0)!,
                             NSParagraphStyleAttributeName: paragraphStyle])
        issueMsgLabel?.attributedText  = issueMsgAttrStr
        
        avpVC?.view.isHidden = true
        isHidden = false
    }
    
    func showVideoVC() {
        if avPlayer == nil || avpVC == nil {
            buildVideoVC()
        }
        guard avPlayer != nil && avpVC != nil else { return }
            
        avPlayer?.pause()
        avPlayer?.seek(to: kCMTimeZero)
        
        guard createPlayerItemForVideoID( videoID ) else { return }
        
        avPlayer?.replaceCurrentItem(with: playerItem)
        let playerStatus = avPlayer?.status
        if playerStatus != .failed {
            self.isHidden = false
            self.avpVC?.view.isHidden = false
            delay(0.5) {  
                self.avPlayer?.play()
            }
        }
    }
    
    func playAgain(sender: UIButton) {
        avPlayer?.pause()
        avPlayer?.seek(to: kCMTimeZero)
        avPlayer?.play()
    }
    
    func allDone(sender: UIButton) {
        hideVideoVC()
    }
    
    func hideVideoVC() {
        avPlayer?.pause()
        avPlayer?.seek(to: kCMTimeZero)
        self.isHidden = true
    } 
    
    func cleanup() {
        avPlayer?.pause()
        avPlayer = nil
        avpVC = nil
        playerItem = nil
    }
    
    deinit {
        print ("deiniting VideoHelpView")
    }
}

extension UIButton {
    func roundedButton(){
        let maskPAth1 = UIBezierPath(roundedRect: self.bounds,
                                     byRoundingCorners: .allCorners,
                                     cornerRadii:CGSize(width:8.0, height:8.0))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.bounds
        maskLayer1.path = maskPAth1.cgPath
        self.layer.mask = maskLayer1
    }
}
