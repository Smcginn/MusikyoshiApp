//
//  PracticeViewController.swift
//  FirstFive
//
//  Created by Adam Kinney on 11/27/15.
//  Changed by David S Reich - 2016.
//  Copyright © 2015 Musikyoshi. All rights reserved.
//

import UIKit

class PracticeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var optionIndex = 0
    
    var tuneIds = ["Note_test", "ex1", "ex2", "ex3", "ex4", "ex5"]
    var tuneNames = ["Test", "Exercise 1", "Exercise 2", "Exercise 3", "Exercise 4", "Exercise 5"]
//    let tuneIds = ["110 The Entertainer -tpt", "119 Korobeiniki Trumpet", "100 Take Me Out to the Ball Game Trumpet", "109 Trepak - Trumpet", "Test Score", "Trepak", "Test", "Trepak", "Test"]
//    let tuneNames = ["110 The Entertainer -tpt", "119 Korobeiniki Trumpet", "100 Take Me Out to the Ball Game Trumpet", "109 Trepak - Trumpet", "Test Score", "Trepak", "Test", "Trepak", "Test"]
    var selectedTuneId = ""
    var selectedTuneName = ""
    var selectedRhythmId = ""
    var selectedRhythmName = ""
    
//    let noteIds = [53,55,57,58,60,62,63,65,67,69,70]
    // noteIds must be >= LongToneViewController.kFirstLongTone24Note = 54 && <= LongToneViewController.kLastLongTone24Note = 77
    let noteIds = [55,57,58,60,62,63,65,67,69,70,72]
    var actionNotes = [Note]()
    var selectedNote : Note?
    
    @IBOutlet weak var playLongNoteBtn: UIButton!
    @IBOutlet weak var playRhythmBtn: UIButton!
    @IBOutlet weak var playTuneBtn: UIButton!
    
    override func viewDidLoad() {
        if actionNotes.count == 0 {
            for nId in noteIds {
                actionNotes.append(NoteService.getNote(nId)!)
            }
        } else {
            print("did load test")
        }
        
        if let fnames = getBundleFilesList("xml") {
//            print("files:\(fnames)")
            tuneIds.removeAll()
            tuneNames.removeAll()
            for n in fnames {
                let shortN = String(n.characters.dropLast(4))
                tuneIds.append(shortN)
                tuneNames.append(shortN)
            }
        }

        selectedTuneId = tuneIds.first!
        selectedRhythmId = tuneIds.first!

        selectedRhythmName = tuneNames.first!
        selectedTuneName = tuneNames.first!
        playRhythmBtn.setTitle("Play \(selectedRhythmName)", for: UIControlState())
        playTuneBtn.setTitle("Play \(selectedTuneName)", for: UIControlState())
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "Practice"
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight, andRotateTo: UIInterfaceOrientation.landscapeRight)
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    let tuneSegueIdentifier = "ShowTuneSegue"
    let longToneSegueIdentifier = "ShowLongToneSegue"
    let rhythmSegueIdentifier = "ShowRhythmSegue"
    
    // MARK: - Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier != longToneSegueIdentifier else { return false }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.title = ""
        
        if segue.identifier == tuneSegueIdentifier {
            if let destination = segue.destination as? TuneExerciseViewController {
                destination.exerciseName = selectedTuneId
                destination.isTune = true
            }
        } else if segue.identifier == rhythmSegueIdentifier {
            if let destination = segue.destination as? TuneExerciseViewController {
                destination.exerciseName = selectedRhythmId
                destination.isTune = false
            }
        }
        else if segue.identifier == longToneSegueIdentifier {
            if let destination = segue.destination as? LongToneViewController {
                if let sn = selectedNote
                {
//TO DO -- is -2 correct??
//                    let an = NoteService.getNote(sn.orderId-2)
                    let an = NoteService.getNote(sn.orderId)
                    print("sn: \(sn.orderId) - 2?? ==>")
                    print("an == \(String(describing: an?.orderId))")
                    destination.targetNote = an
                    destination.targetNoteID = sn.orderId
                    destination.noteName = (selectedNote?.fullName)!
                }
                else
                {
                    destination.targetNote = NoteService.getNote(destination.kC4)
                    destination.targetNoteID = destination.kC4
                }
                
            }
        }
    }
    
    @IBAction func changeLongToneNoteTap(_ sender: AnyObject) {
        return; //semicolon so next line isn't considered a return value!

        optionIndex = 1
        
        let ac = UIAlertController(title: "Choose a note for Long Tone", message: "\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 300, height: 160))
        picker.delegate = self
        picker.dataSource = self
        
        func handler(_ act: UIAlertAction) {
            if let sn = selectedNote {
                playLongNoteBtn.setTitle("Play \(sn.fullName)", for: UIControlState())
            }
        }
        
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: handler))
        ac.view.addSubview(picker)
        
        self.present(ac, animated: true, completion: nil)
    }
    
    @IBAction func changeRhythmTuneTap(_ sender: AnyObject) {
        optionIndex = 2

        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 300, height: 160)
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 300, height: 160))
        picker.delegate = self
        picker.dataSource = self
        vc.view.addSubview(picker)

        let ac = UIAlertController(title: "Choose a tune for Rhythm", message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        func handler(_ act: UIAlertAction) {
            playRhythmBtn.setTitle("Play \(selectedRhythmName)", for: UIControlState())
        }

        ac.setValue(vc, forKey: "contentViewController")
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: handler))

        self.present(ac, animated: true, completion: nil)

        let defaultRowIndex = tuneNames.index(of: selectedRhythmName) ?? 0
        picker.selectRow(defaultRowIndex, inComponent: 0, animated: true)
    }

    @IBAction func changeTuneTap(_ sender: AnyObject) {
        optionIndex = 3

        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 300, height: 160)
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 300, height: 160))
        picker.delegate = self
        picker.dataSource = self
        vc.view.addSubview(picker)

        let ac = UIAlertController(title: "Choose a Tune", message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        func handler(_ act: UIAlertAction) {
            playTuneBtn.setTitle("Play \(selectedTuneName)", for: UIControlState())
        }
        
        ac.setValue(vc, forKey: "contentViewController")
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: handler))

        self.present(ac, animated: true, completion: nil)

        let defaultRowIndex = tuneNames.index(of: selectedTuneName) ?? 0
        picker.selectRow(defaultRowIndex, inComponent: 0, animated: true)
    }
    
    //*****************************************************************
    //MARK: - Picker Delegate and Data Source
    //*****************************************************************
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if optionIndex == 1 {
            return actionNotes.count
        } else {
            return tuneIds.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let lbl : UILabel
        
        if let label = view as? UILabel {
            lbl = label
        } else {
            lbl = UILabel()
        }
        
        if optionIndex == 1 {
            lbl.text = actionNotes[row].fullName
        } else {
            lbl.text = tuneNames[row]
        }
        lbl.backgroundColor = UIColor.clear
        lbl.sizeToFit()
        
        return lbl
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if optionIndex == 1 {
            selectedNote = actionNotes[row]
        } else if optionIndex == 2 {
            selectedRhythmId = tuneIds[row]
            selectedRhythmName = tuneNames[row]
        } else {
            selectedTuneId = tuneIds[row]
            selectedTuneName = tuneNames[row]
        }
    }

    //for development - list all xml files
    func getBundleFilesList(_ ofType: String) -> [String]? {
        let docsPath = Bundle.main.resourcePath! + "/XML Tunes"
        let fileManager = FileManager.default
        
        do {
            let docsArray = try fileManager.contentsOfDirectory(atPath: docsPath).filter{$0.hasSuffix(ofType)}.sorted(by: { $0 < $1 })
            return docsArray
        } catch {
            print(error)
        }

        return nil
    }

}
