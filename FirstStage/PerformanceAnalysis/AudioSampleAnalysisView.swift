//
//  AudioSampleAnalysisView.swift
//  AEXML iOS
//
//  Created by Scott Freshour on 8/29/19.
//  Copyright © 2019 AE. All rights reserved.
//

import Foundation
import UIKit

class AudioSampleAnalysisView: UIView, UIScrollViewDelegate {
    
    weak var parentVC: UIViewController? = nil
    var doneBtn: UIButton? = nil
    var helpBtn: UIButton? = nil

    var isShowing = false
    func setIsShowing(showing: Bool) {
        isShowing = showing
        if waveformView != nil {
            waveformView?.isShowing = isShowing
        }
    }
    
    var waveformView: WaveformView? = nil
 
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let stepper = UIStepper(frame: CGRect(x: 100, y: 200, width: 0, height: 0))
//    }
    
    
    @objc func stepperValueChanged(_ stepper: UIStepper) {
//        print("Chnaged Value: \(stepper.value)")
//        stepper.value += 2
//        print("Chnaged Value: \(stepper.value)")
        if waveformView != nil {
            waveformView?.changeZoom(zoom:stepper.value)
        }
    }
    
    var zoomStepper: UIStepper? = nil
        
    func createZoomStepper() {
        
        let parsz = self.frame.size
        let stepWd = CGFloat(120)
        let stepHt = CGFloat(60)
        let stepX  = CGFloat(30.0)
        let stepY  = CGFloat(70.0) //parsz.height - CGFloat(60)
        let frm =  CGRect(x: stepX, y: stepY, width: stepWd, height: stepHt)

        zoomStepper = UIStepper(frame: frm)
        if zoomStepper != nil {
            zoomStepper!.wraps = false
            zoomStepper!.autorepeat = true
            zoomStepper!.minimumValue =  1
            zoomStepper!.maximumValue = 20
            zoomStepper!.value = 5
            zoomStepper!.addTarget(self,
                                   action: #selector(stepperValueChanged(_:)),
                                   for: .valueChanged)
            self.addSubview(zoomStepper!)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
 
        self.backgroundColor = UIColor.lightGray
        
        createWaveformView()
        addDoneBtn()
        createZoomStepper()
        addHelpBtn()
        
//        self.roundedView()
//        self.center.x = super.center.x
    }

//    public required init?(coder aDecoder: NSCoder)
//    {
////        showPartNames = false
////        showBarNumbers = false
////        synthVoice = .Sampled
////        temperament = .Equal
////        symmetry = 0.5
////        risefall = 0.5
//        super.init(coder: aDecoder)
//    }
    

    required init(coder: NSCoder) {
        fatalError("NSCoding not supported for LaunchingNextView")
    }

    @objc func doneButtonPressed(sender: UIButton) {
        self.isHidden = true
        setIsShowing(showing: false)
        
        print("Done!")
        //        if waitingToBegin || exercisesDone {
        //            viewFinishedDelegate?.viewFinished(result: kViewFinished_Proceed)
        //        } else if isPaused {
        //            isPaused = false
        //            viewFinishedDelegate?.viewFinished(result: kViewFinished_UnPause)
        //        } else {
        //            monkeyImageView?.isHidden = true
        //            monkeyImageView2?.isHidden = true
        //            progBar?.isHidden = true
        //
        //            self.layer.removeAllAnimations()
        //            viewFinishedDelegate?.viewFinished(result: kViewFinished_Pause)
        //        }
    }
    
    @objc func helpButtonPressed(sender: UIButton) {
        print("Help!")
        presentHelpAlert()
        
        //        if waitingToBegin || exercisesDone {
        //            viewFinishedDelegate?.viewFinished(result: kViewFinished_Proceed)
        //        } else if isPaused {
        //            isPaused = false
        //            viewFinishedDelegate?.viewFinished(result: kViewFinished_UnPause)
        //        } else {
        //            monkeyImageView?.isHidden = true
        //            monkeyImageView2?.isHidden = true
        //            progBar?.isHidden = true
        //
        //            self.layer.removeAllAnimations()
        //            viewFinishedDelegate?.viewFinished(result: kViewFinished_Pause)
        //        }
    }
    
    func addDoneBtn() {
        
        let selfWd = self.frame.size.width
        let selfHt = self.frame.size.height
        let btnFrame = CGRect( x: 20, y: selfHt - 50,
                               width: 100, height: 30 )
        doneBtn = UIButton(frame: btnFrame)
        
        doneBtn?.roundedButton()
        doneBtn?.backgroundColor = UIColor.blue
        doneBtn?.addTarget(self,
                           action: #selector(doneButtonPressed(sender:)),
                           for: .touchUpInside )
        doneBtn?.isEnabled = true
        doneBtn?.isHidden = false
        doneBtn?.titleLabel?.textColor = UIColor.blue
        doneBtn?.setTitle("Done", for: .normal)
        self.addSubview(doneBtn!)
    }
    
    func addHelpBtn() {
        let selfWd = self.frame.size.width
        let selfHt = self.frame.size.height
        let btnFrame = CGRect( x: 140, y: selfHt - 50,
                               width: 100, height: 30 )
        helpBtn = UIButton(frame: btnFrame)
        
        helpBtn?.roundedButton()
        helpBtn?.backgroundColor = UIColor.blue
        helpBtn?.addTarget(self,
                           action: #selector(helpButtonPressed(sender:)),
                           for: .touchUpInside )
        helpBtn?.isEnabled = true
        helpBtn?.isHidden = false
        helpBtn?.titleLabel?.textColor = UIColor.blue
        helpBtn?.setTitle("Help", for: .normal)
        self.addSubview(helpBtn!)
    }
    
    func createWaveformView() {
        let parsz = self.frame.size
        let viewWd = parsz.width  - 30.0
        let viewHt = parsz.height - 80.0
        let viewX  = CGFloat(15.0)
        let viewY  = CGFloat(15.0)
        let frm =  CGRect(x: viewX, y: viewY, width: viewWd, height: viewHt)
        waveformView = WaveformView(frame: frm)
        waveformView?.delegate = self
        if waveformView != nil {
            self.addSubview(waveformView!)
        }
        waveformView?.isScrollEnabled = true
        waveformView?.isHidden = false
    }
    
     
    
    func displayAmplitude() {
        if waveformView != nil {
            waveformView!.displayAmplitude()
        }

    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("hey")
        waveformView!.setNeedsDisplay()
    }

    func presentHelpAlert() {
        let titleStr = "Help"
        let msgStr = getHelpText()
        //msgStr += "\n\nYou Are Good To Go!\n\n"
        let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
        var currFrame = ac.view.frame
        currFrame.size.width += 150
        ac.view.frame = currFrame
        ac.addAction(UIAlertAction(title: "OK", style: .default,
                                   handler: nil))
        if parentVC != nil {
            parentVC!.present(ac, animated: true, completion: nil)
        }
//        let when = DispatchTime.now() + 2
//        DispatchQueue.main.asyncAfter(deadline: when){
//            // your code with delay
//            ac.dismiss(animated: true, completion: nil)
//        }
//        //        close(alert: ac, after: 2.0)
    }

    func getHelpText() -> String {
        var helpString = ""
        
        helpString += "Each Sound is represented by a retangle with either a cyan or "
        helpString += "yellow background. (There is nothing special about these colors; "
        helpString += "they just alternate to be able to denote different sounds.)\n\n"
        
        helpString += "In addition, each Sound has Beginning Green and Ending Red "
        helpString += "veritical lines, to clearly show its boundaries.\n\n"
        
        helpString += "There are three (possible) cross-hatched areas:\n"
        helpString += "- BLUE: At the beginning of a sound: Indicates the "
        helpString += "'skip samples' area. Samples in "
        helpString += "this zone won't trigger a new Sound due to an Amplitude Rise.\n"
        helpString += "- RED: At the end of a sound: Indicates the current Sound "
        helpString += "was terminated because of an Amplitude Rise.\n"
        helpString += "- ORANGE: At the end of a sound: Indicates the current Sound was "
        helpString += "terminated because of a change in pitch while playing legato.\n\n"

        helpString += "The Stepper control at the top left controls the Zoom Level "
        helpString += "(from 1 to 20): The # of pixels used "
        helpString += "per 1 sample (samples are at 1/100 of a second).\n\n"
        
        helpString += "The waveform is drawn to match the levels of each performance. "
        helpString += "Loud and soft performances may appear to have the same height. "

        return helpString
    }

    
    
}
