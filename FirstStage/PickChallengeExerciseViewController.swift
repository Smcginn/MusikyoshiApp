//
//  PickChallengeExerciseViewController.swift
//  PlayTunes-debug
//
//  Created by Sidney Hough on 12/21/20.
//  Copyright © 2020 Musikyoshi. All rights reserved.
//

import UIKit
import SwiftyJSON

class PickChallengeExerciseViewController: UIViewController {
    
    @IBOutlet weak var picker: UIPickerView!
    
    var responderUsername: String!
    
    var activeLevel = 0
    var activeDay = 0
    var activeExer = 0

    var instrumentJson: JSON?
    var levelsJson: JSON?
    
    var exerType: ExerciseType = .unknownExer
    
    var currExerNumber:Int = 0 // for sanity check - compare against reported results
    
    var selectedTuneId: String?
    var selectedTuneName: String?
    var selectedRhythmId: String?
    var selectedNoteWidth: Int = 0
    var selectedFrameWidth: Int = 0
    var selectedMagnification: Float = 0.0
    var selectedTitle: String?
    
    var exerLevelIndex: Int = 0
    var exerExerciseIndex: Int = 0
    var exerExerciseTag: String = ""
    
    func numLevelsToShow() -> Int {
    
        var retNumToShow = 1
    
        var jsonCount = 0
        if let rawJsonCount = instrumentJson?["levels"].count {
            jsonCount = rawJsonCount
        }
        retNumToShow = jsonCount
        
        if gDoLimitLevels {
            retNumToShow = kNumberOfLevelsToShow
        }
        
        // Don't show tryout level
        retNumToShow -= 1
        
        if !currInstrumentIsBrass() && !currInstIsAClarinet() {
            // Don't show Lip Slurs or CrossBreaks level
            retNumToShow -= 1
        }
        
        if retNumToShow < 0 {
            retNumToShow = 0
        }
        
        if retNumToShow == 0 {
            itsBad()
        }
        
        return retNumToShow
        
    }
    
    func numDaysInLevel(level: Int) -> Int {
        var count = 0
        
        var daysJson:JSON?
        daysJson = levelsJson![level]["days"]
        if ( daysJson != nil ) {
            count = daysJson!.count
        }
        
        return count
    }
    
    func verifyThisViewsLDSet() -> Bool {
        if activeLevel == kLDE_FldNotSet || activeDay == kLDE_FldNotSet  {
            itsBad()
            return false
        }
        return true
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        picker.dataSource = self
        
        if let file = Bundle.main.path(forResource: "TrumpetLessons", ofType: "json") {
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: file))
            if jsonData != nil {
                instrumentJson = try? JSON(data: jsonData!)
            } else {
                print ("unable to acquire jsonData or instrumentJson")
            }

            if instrumentJson != nil {
                levelsJson = instrumentJson?["levels"]
            } else {
                print ("unable to acquire levelsJson")
            }
        } else {
            print("Invalid TrumpetLessons filename/path.")
        }
        
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        
        let currExerLDE = (level: activeLevel, day: activeDay, exer: activeExer)
        guard currExerLDE != kLDE_NotSet,
            LsnSchdlr.instance.verifyLDE(currExerLDE)  else {
                itsBad()
                return // now what?
        }
        
        currExerNumber = currExerLDE.exer
        
        let exerCodeStr: String = LsnSchdlr.instance.getExerIDStr(lde: currExerLDE)
        guard exerCodeStr.isNotEmpty else {
            print ("Can't get exerCode for current Exer in loadAndRunCurrentExer()")
            return
        }
        
        let exerType = getExerciseType( exerCode: exerCodeStr )
        guard exerType != .unknownExer else {
            print ("Can't get ExerType for current Exer in loadAndRunCurrentExer()")
            return
        }
        self.exerType = exerType
        
        let tuneInfo = LsnSchdlr.instance.getTuneFileInfo(forFileCode: exerCodeStr)
        selectedTuneId = String(tuneInfo.xmlFile.dropLast(4))
        selectedRhythmId = String(tuneInfo.xmlFile.dropLast(4))
        selectedTitle = tuneInfo.title
        
        // SCORESIZE
        // These are for debugging; easily see vals coming from json file.
        let noteWidthStr: String = tuneInfo.noteWidth
        selectedNoteWidth = Int(noteWidthStr)!
        let frameWidthStr: String = tuneInfo.frameWidth
        selectedFrameWidth = Int(frameWidthStr)!
        let magStr: String = tuneInfo.magnification
        let magInt:Int = Int(magStr)!
        selectedMagnification = Float(magInt)/10.0
        
        if selectedTuneId != kFieldDataNotDefined {
            self.performSegue(withIdentifier: "toExerVC", sender: nil)
        } else {
            itsBad()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
//        if let destination = segue.destination as? TuneExerciseViewController {
//                destination.exerNumber = currExerNumber
//                destination.exerciseName = selectedTuneId!
//                destination.navBarTitle = selectedTitle!
//                destination.specifiedMag = selectedMagnification
//                destination.specifiedNoteWidth = selectedNoteWidth
//                destination.specifiedFrameWidth = selectedFrameWidth
//                destination.bestStarScore = currStarScore
//                destination.exerciseType = exerType
//                destination.isTune = true
//                destination.callingVCDelegate = self
//            }
//        } else if segue.identifier == rhythmSegueIdentifier {
//            if let destination = segue.destination as? TuneExerciseViewController {
//                destination.exerNumber = currExerNumber
//                destination.exerciseName = selectedRhythmId!
//                destination.navBarTitle = selectedTitle!
//                destination.bestStarScore = currStarScore
//                destination.isTune = false
//                destination.exerciseType = exerType
//            }
        
        if segue.identifier == "toExerVC", let vc = segue.destination as? TuneExerciseViewController {
            
            vc.inChallengeMode = true
            vc.newChallenge = true
            vc.challengeIssuer = UserDefaults.standard.string(forKey: "username")!
            vc.challengeResponder = responderUsername
            
            vc.exerNumber = currExerNumber
            vc.exerciseName = selectedTuneId!
            vc.navBarTitle = selectedTitle!
            vc.specifiedMag = selectedMagnification
            vc.specifiedNoteWidth = selectedNoteWidth
            vc.specifiedFrameWidth = selectedFrameWidth
            
            vc.exerciseType = exerType
            vc.isTune = true
            
        }
        
    }
    
}

extension PickChallengeExerciseViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch component {
        case 0:
            return numLevelsToShow()
        case 1:
            return numDaysInLevel(level: activeLevel)
        case 2:
            _ = verifyThisViewsLDSet()
            let numExers = LessonScheduler.instance.numExercises(ld: (level: activeLevel, day: activeDay))
            return numExers
        default:
            return 0
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch component {
        case 0:
            return "Level \(row + 1)"
        case 1:
            return "Day \(row + 1)"
        case 2:
            return "Exercise \(row + 1)"
        default:
            return ""
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch component {
        case 0:
            activeLevel = component
        case 1:
            activeDay = component
        case 2:
            activeExer = component
        default:
            break
        }
        
        pickerView.reloadAllComponents()
        
    }
    
}
