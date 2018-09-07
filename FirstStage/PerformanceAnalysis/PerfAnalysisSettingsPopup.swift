//
//  PerfAnalysisSettingsPopup.swift
//  FirstStage
//
//  Created by Scott Freshour on 1/12/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

protocol PerfAnalysisSettingsChanged : class {
    func perfAnalysisSettingsChange(_ whatChanged : Int)
}

class PerfAnalysisSettingsPopupView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    let issueCatText = [ "By Attack Rating",
                         "By Duration Rating",
                         "By Attack And DurationRating",
                         "By Pitch Rating",
                         "By Individual Rating" ]
                         // map-to-video/alert doesn't support Overall mode yet,
                         // so don't include as an option
                         // "By Overall Rating" ]
    
    var pickCriteriaLabel: UILabel?
    var issueCriteriaPickerView: UIPickerView?
    
    var ignoreMissedNotesLabel: UILabel?
    var ignoreMissedNotesSwitch: UISwitch?
    
    var showSoundsOnOverlayLabel: UILabel?
    var showSoundsOnOverlaySwitch: UISwitch?
    
    var showNotesOnOverlayLabel: UILabel?
    var showNotesOnOverlaySwitch: UISwitch?
    
    var doneBtn: UIButton?
    
    var somethingChanged = false

    weak var settingsChangedDelegate: PerfAnalysisSettingsChanged?
    
    static func getSize() -> CGSize {
        return CGSize(width: 320, height: 280)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported for VideoHelpView")
    }
    
    func createPickerAndLabel() {
        let sz = PerfAnalysisSettingsPopupView.getSize()
        
        pickCriteriaLabel = UILabel()
        pickCriteriaLabel?.frame = CGRect(x: 10, y: 10,
                                          width: sz.width-20, height: 25)
        pickCriteriaLabel?.text = "Issue Sorting Criteria:"
        self.addSubview(pickCriteriaLabel!)
        
        /////////////////////////////////////////////////////////////////
        
        self.issueCriteriaPickerView = UIPickerView()
        self.issueCriteriaPickerView?.dataSource = self as UIPickerViewDataSource
        self.issueCriteriaPickerView?.delegate = self
        self.issueCriteriaPickerView?.frame = CGRect(x: 50, y: 40,
                                                     width: 260, height: 45)
        self.issueCriteriaPickerView?.layer.borderColor = UIColor.darkGray.cgColor
        self.issueCriteriaPickerView?.layer.borderWidth = 1
        self.issueCriteriaPickerView?.isUserInteractionEnabled = true
        let currRow: Int = {
            switch gPerfIssueSortCriteria {
            case .byAttackRating:               return 0
            case .byDurationRating:             return 1
            case .byAttackAndDurationRating:    return 2
            case .byPitchRating:                return 3
            case .byIndividualRating:           return 4
            case .byOverallRating:              return 5
            }
        }()
        self.issueCriteriaPickerView?.selectRow(currRow,
                                                inComponent: 0,
                                                animated: true )
        self.addSubview(issueCriteriaPickerView!)
    }
    
    func createSwitchesAndLabel() {
        
        let sz = PerfAnalysisSettingsPopupView.getSize()
        let labelWd: CGFloat  = sz.width-100.0
        let switchX: CGFloat  = sz.width-90.0
        let switchWd:CGFloat  = 100.0
        var labelRect  = CGRect(x: 10, y: 105, width: labelWd, height: 25)
        var switchRect = CGRect(x: switchX, y: 105.0, width: switchWd, height: 25.0)
        
        ////////////////////////////////////////////////////////////////////////
        // Ignore Missed Notes Label and Switch
        
        ignoreMissedNotesLabel = UILabel()
        ignoreMissedNotesLabel?.frame = labelRect
        ignoreMissedNotesLabel?.text = "Ignore Missed Notes:"
        self.addSubview(ignoreMissedNotesLabel!)
        
        ignoreMissedNotesSwitch = UISwitch()
        ignoreMissedNotesSwitch?.frame = switchRect
        ignoreMissedNotesSwitch?.addTarget(self,
                                           action: #selector(ignoreMsdNtsSwitchChange(_:)),
                                           for: .valueChanged)
        ignoreMissedNotesSwitch?.isOn = kIgnoreMissedNotes
        self.addSubview(ignoreMissedNotesSwitch!)
        
        ////////////////////////////////////////////////////////////////////////
        // Show Sounds On Overlay Label and Switch
        
        showSoundsOnOverlayLabel = UILabel()
        labelRect.origin.y = 150
        showSoundsOnOverlayLabel?.frame = labelRect
        showSoundsOnOverlayLabel?.text = "Show Sounds On Overlay:"
        self.addSubview(showSoundsOnOverlayLabel!)
        
        showSoundsOnOverlaySwitch = UISwitch()
        switchRect.origin.y = 150
        showSoundsOnOverlaySwitch?.frame = switchRect
        showSoundsOnOverlaySwitch?.addTarget(self,
                                             action: #selector(showSoundsSwitchChange(_:)),
                                             for: .valueChanged)
        showSoundsOnOverlaySwitch?.isOn = FSAnalysisOverlayView.getShowSoundsAnalysis()
        self.addSubview(showSoundsOnOverlaySwitch!)
        
        ////////////////////////////////////////////////////////////////////////
        // Show Notes On Overlay Label and Switch
        
        showNotesOnOverlayLabel = UILabel()
        labelRect.origin.y = 195
        showNotesOnOverlayLabel?.frame = labelRect
        showNotesOnOverlayLabel?.text = "Show Notes On Overlay:"
        self.addSubview(showNotesOnOverlayLabel!)
        
        showNotesOnOverlaySwitch = UISwitch()
        switchRect.origin.y = 195
        showNotesOnOverlaySwitch?.frame = switchRect
        showNotesOnOverlaySwitch?.addTarget(self,
                                            action: #selector(ShowNotesSwitchChange(_:)),
                                            for: .valueChanged)
        showNotesOnOverlaySwitch?.isOn = FSAnalysisOverlayView.getShowNotesAnalysis()
        self.addSubview(showNotesOnOverlaySwitch!)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let sz = PerfAnalysisSettingsPopupView.getSize()

        createPickerAndLabel()
        createSwitchesAndLabel()
        
        ///////////////////////////////////////////////////////////////
        // Done Button
        
        let btnFrame = CGRect( x: 10 , y: sz.height-40, width: 100, height: 30 )
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
                                       attributes: [NSAttributedStringKey.font:UIFont(
                                        name: "Marker Felt",
                                        size: 18.0)!])
        doneBtn?.titleLabel?.attributedText = doneMutableString
        doneBtn?.titleLabel?.textColor = UIColor.yellow
        doneBtn?.setTitle("OK", for: .normal)
        self.addSubview(doneBtn!)

        self.backgroundColor = UIColor.lightGray
    }
    
    @objc func ignoreMsdNtsSwitchChange(_ sender: UISwitch) {
        somethingChanged = true
        kIgnoreMissedNotes = sender.isOn
    }
    
    @objc func showSoundsSwitchChange(_ sender: UISwitch) {
        somethingChanged = true
        if sender.isOn {
            FSAnalysisOverlayView.setShowSoundsAnalysis( true );
        } else {
            FSAnalysisOverlayView.setShowSoundsAnalysis( false );
        }
    }
    
    @objc func ShowNotesSwitchChange(_ sender: UISwitch) {
        somethingChanged = true
        if sender.isOn {
            FSAnalysisOverlayView.setShowNotesAnalysis( true );
        } else {
            FSAnalysisOverlayView.setShowNotesAnalysis( false );
        }
    }
    
    /////////////////////////////////////////////////////////////////////////
    // Picker Delegate and Data Source methods
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // map-to-video/alert doesn't support Overall mode yet, so don't include it.
    // When it does, delete this and use PerformanceIssueMgr.kNumSortCriteria
    let numSupportedSortCriteria = PerformanceIssueMgr.kNumSortCriteria-1
    
    public func pickerView(_ pickerView: UIPickerView,
                           numberOfRowsInComponent component: Int) -> Int {
        return numSupportedSortCriteria // PerformanceIssueMgr.kNumSortCriteria
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return issueCatText[row]
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    widthForComponent component: Int) -> CGFloat {
        return 280.0
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    rowHeightForComponent component: Int) -> CGFloat {
        return 25.0
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        somethingChanged = true
        switch row {
        case 0:  setPerfIssueSortCriteria( sortCrit: .byAttackRating )
        case 1:  setPerfIssueSortCriteria( sortCrit: .byDurationRating )
        case 2:  setPerfIssueSortCriteria( sortCrit: .byAttackAndDurationRating )
        case 3:  setPerfIssueSortCriteria( sortCrit: .byPitchRating )
        case 4:  setPerfIssueSortCriteria( sortCrit: .byIndividualRating )
            
        default: setPerfIssueSortCriteria( sortCrit: .byIndividualRating )
        // map-to-video/alert doesn't support Overall mode yet;
        // include when available
        // default: kPerfIssueSortCriteria = .byOverallRating
        }
    }
    
    func showPopup() {
        somethingChanged = false
        isHidden = false
    }
    
    @objc func allDone(sender: UIButton) {
        if somethingChanged {
            settingsChangedDelegate?.perfAnalysisSettingsChange(0)
        }
        self.isHidden = true
    }
}
