//
//  FrequencySampleAnalysisView.swift
//  AEXML iOS
//
//  Created by Scott Freshour on 8/29/19.
//  Copyright © 2019 AE. All rights reserved.
//

import Foundation
import UIKit


class FreqDataScrollView: UIScrollView {
    
    let textView = UITextView()
    var isShowing = false

    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = UIColor.orange
        self.addSubview(textView)

        let myFrame = frame
        var textViewFr = myFrame
        textViewFr.origin.x = 0
        textViewFr.origin.y = 0
        textView.frame = textViewFr
        self.contentSize = textViewFr.size
        
        textView.text = "Hey!"
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported for LaunchingNextView")
    }

    func setScollingText(newText: String) {
        var textViewFrameSz = textView.frame.size
        textView.text = newText
        textViewFrameSz = textView.frame.size
        self.contentSize = textViewFrameSz
    }
    
    func clearScollingText() {
        textView.text = ""
        let textViewFrameSz = textView.frame.size
        self.contentSize = textViewFrameSz
    }
}




class FrequencySampleAnalysisView: UIView, UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.lightGray
        
        setupNotePickerView()
        createFreqDataScrollView()
        addDoneBtn()
        createStatusTextField()
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported for LaunchingNextView")
    }
    
    var freqDataScrollView: FreqDataScrollView? =  nil
    var notePickerView: UIPickerView? = nil
    weak var parentVC: UIViewController? = nil
    var doneBtn: UIButton? = nil
    var helpBtn: UIButton? = nil
    var statusText: UILabel? = nil
    
    var isShowing = false
    func setIsShowing(showing: Bool) {
        isShowing = showing
        if freqDataScrollView != nil {
            freqDataScrollView?.isShowing = isShowing
            freqDataScrollView?.clearScollingText()
            if isShowing {
                notePickerView?.reloadAllComponents()
                delay(0.5) {
                    self.loadFirstNoteIfThere()
                }
            }
        }
    }
    
    func setupNotePickerView() {
    
        self.notePickerView = UIPickerView()
        self.notePickerView?.dataSource = self as UIPickerViewDataSource
        self.notePickerView?.delegate = self
        self.notePickerView?.frame = CGRect(x: 50, y: 140,
                                            width: 260, height: 80)
        self.notePickerView?.layer.borderColor = UIColor.darkGray.cgColor
        self.notePickerView?.layer.borderWidth = 1
        self.notePickerView?.isUserInteractionEnabled = true
        self.addSubview(notePickerView!)
    }
    
    ////////////////////////////////////////////////////////////////////////
    //
    //   UIPickerViewDataSource, UIPickerViewDelegate protocol methods
    //
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let numNotes = PerformanceTrackingMgr.instance.numPerfNotes()
        
        if numNotes == 0 {
            statusText?.text = "No Notes Found"
        } else {
             statusText?.text = ""
        }
        return numNotes
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let retStr = "Note #\(row+1)"
        return retStr
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let perfNote = PerformanceTrackingMgr.instance.getPerfNote(withID: row+1)
        if perfNote == nil {
            itsBad()
        } else {
            setupScrollTextForNote(withID: row+1)
        }
    }    
    
    
    func loadFirstNoteIfThere() {
        let numNotes = PerformanceTrackingMgr.instance.numPerfNotes()
        if numNotes != 0 {
            self.notePickerView?.selectRow(0,
                                           inComponent: 0,
                                           animated: true )
            setupScrollTextForNote(withID: 1)
        }
    }
    
    func setupScrollTextForNote(withID: Int) {
        let perfNote = PerformanceTrackingMgr.instance.getPerfNote(withID: withID)
        if perfNote == nil {
            itsBad()
        } else {
            var scrollText = "If Note Linked to Sound, samples for that Sound displayed below.\n"
            scrollText += "   (If no Sound linked to Note, nothing will show below)\n\n"
            
            let expFreqStr = String(format: "%.2f", perfNote!.expectedFrequency)

            var expectedNoteName = ""
            let expNote = NoteService.getNote(Int(perfNote!.transExpectedNoteID))
            if expNote != nil {
                expectedNoteName = expNote!.fullName
            }

            scrollText += "   Expected Note: " + expectedNoteName + "\n"
            scrollText += "   Expected Freq: " + expFreqStr + "\n\n"
            
            
            if gUseWeightedPitchScore {
                let actualNoteIDTransposed =
                    concertNoteIdToInstrumentNoteID( noteID: perfNote!.actualMidiNote)
                var actualNoteName = ""
                let actNote = NoteService.getNote(Int(actualNoteIDTransposed))
                if actNote != nil {
                    actualNoteName = actNote!.fullName
                }

                scrollText += "  - - - - -\n\n"
                var actFreqStr = ""
//                var pitchRatingStr = ""
                let mostCommonFreq = NoteService.getFreqForNoteID( noteID: perfNote!.mostCommonPlayedNote )
                actFreqStr = String(format: "%.2f", mostCommonFreq)
                actFreqStr += ", "
                let convPC = perfNote!.mostCommonPlayedNotePercentage * 100.0
                let convPCInt = Int(convPC)
                let percStr = String(convPCInt) // mostCommonPlayedNotePercentage)
                actFreqStr += percStr + "%"

                scrollText += "Actual Frequency:    " + actFreqStr + "\n"
                scrollText += "       Note (Guess): " + actualNoteName + "\n"
                scrollText += "\n  - - - - -\n\n"            }
                        
            
            let soundTxt = perfNote!.getSamplesForDisplay()
            scrollText += soundTxt
            freqDataScrollView?.setScollingText(newText: scrollText)
        }
    }
    
    func createStatusTextField() {
        self.statusText = UILabel()
        self.statusText?.frame = CGRect(x: 100, y: 80,
                                        width: 300, height: 20)
        if statusText != nil {
            self.addSubview(statusText!)
        }
    }
    
    @objc func doneButtonPressed(sender: UIButton) {
        self.isHidden = true
        setIsShowing(showing: false)
    }
    
    func addDoneBtn() {
        
        //let selfWd = self.frame.size.width
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
    
    func createFreqDataScrollView() {
        let parsz = self.frame.size
        let viewWd = parsz.width  / 2
        let viewHt = parsz.height - 20.0
        let viewX  = (parsz.width  / 2) - 20.0
        let viewY  = CGFloat(10.0)
        let frm =  CGRect(x: viewX, y: viewY, width: viewWd, height: viewHt)
        freqDataScrollView = FreqDataScrollView(frame: frm)
        freqDataScrollView?.delegate = self
        if freqDataScrollView != nil {
            self.addSubview(freqDataScrollView!)
        }
        freqDataScrollView?.isScrollEnabled = true
        freqDataScrollView?.isHidden = false
        var str = "=====   First  =====\n"
        
        for i in 0...800 {
            str += "\(i):\t\t260.0\n"
        }
        str += "=====   Last  =====\n"

        freqDataScrollView?.setScollingText(newText: str)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("hey")
        freqDataScrollView!.textView.setNeedsDisplay()
    }
}
