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
        
        //for testing
        if let fnames = getBundleFilesList("xml") {
            print("files:\(fnames)")
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
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = "Practice"
    }
    
    let tuneSegueIdentifier = "ShowTuneSegue"
    let longToneSegueIdentifier = "ShowLongToneSegue"
    let rhythmSegueIdentifier = "ShowRhythmSegue"
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.title = ""
        
        if segue.identifier == tuneSegueIdentifier {
            if let destination = segue.destinationViewController as? TuneExerciseViewController {
                destination.exerciseName = selectedTuneId
                destination.isTune = true
            }
        } else if segue.identifier == rhythmSegueIdentifier {
            if let destination = segue.destinationViewController as? TuneExerciseViewController {
                destination.exerciseName = selectedRhythmId
                destination.isTune = false
            }
        }
        else if segue.identifier == longToneSegueIdentifier {
            if let destination = segue.destinationViewController as? LongToneViewController {
                if let sn = selectedNote
                {
//TO DO -- is -2 correct??
//                    let an = NoteService.getNote(sn.orderId-2)
                    let an = NoteService.getNote(sn.orderId)
                    print("sn: \(sn.orderId) - 2?? ==>")
                    print("an == \(an?.orderId)")
                    destination.targetNote = an
                    destination.targetNoteID = sn.orderId
                }
                else
                {
                    destination.targetNote = NoteService.getNote(destination.kC4)
                    destination.targetNoteID = destination.kC4
                }
                
            }
        }
    }
    
    @IBAction func changeLongToneNoteTap(sender: AnyObject) {
        optionIndex = 1
        
        let ac = UIAlertController(title: "Choose a note for Long Tone", message: "\n\n\n\n\n\n\n\n", preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        let picker = UIPickerView(frame: CGRectMake(0, 0, 300, 160))
        picker.delegate = self
        picker.dataSource = self
        
        func handler(act: UIAlertAction) {
            if let sn = selectedNote {
                playLongNoteBtn.setTitle("Play \(sn.fullName)", forState: .Normal)
            }
        }
        
        ac.addAction(UIAlertAction(title: "Save", style: .Default, handler: handler))
        ac.view.addSubview(picker)
        
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    @IBAction func changeRhythmTuneTap(sender: AnyObject) {
        optionIndex = 2
        
        let ac = UIAlertController(title: "Choose a tune for Rhythm", message: "\n\n\n\n\n\n\n\n", preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        let picker = UIPickerView(frame: CGRectMake(0, 0, 300, 160))
        picker.delegate = self
        picker.dataSource = self
        
        func handler(act: UIAlertAction) {
            playRhythmBtn.setTitle("Play \(selectedRhythmName)", forState: .Normal)
        }
        
        ac.addAction(UIAlertAction(title: "Save", style: .Default, handler: handler))
        ac.view.addSubview(picker)
        
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    @IBAction func changeTuneTap(sender: AnyObject) {
        optionIndex = 3
        
        let ac = UIAlertController(title: "Choose a Tune", message: "\n\n\n\n\n\n\n\n", preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        let picker = UIPickerView(frame: CGRectMake(0, 0, 300, 160))
        picker.delegate = self
        picker.dataSource = self
        
        func handler(act: UIAlertAction) {
            playTuneBtn.setTitle("Play \(selectedTuneName)", forState: .Normal)
        }
        
        ac.addAction(UIAlertAction(title: "Save", style: .Default, handler: handler))
        ac.view.addSubview(picker)
        
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    //*****************************************************************
    //MARK: - Picker Delegate and Data Source
    //*****************************************************************
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if optionIndex == 1 {
            return actionNotes.count
        } else {
            return tuneIds.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
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
        lbl.backgroundColor = UIColor.clearColor()
        lbl.sizeToFit()
        
        return lbl
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
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
    func getBundleFilesList(ofType: String) -> [String]? {
        let docsPath = NSBundle.mainBundle().resourcePath! + "/XML Tunes"
        let fileManager = NSFileManager.defaultManager()
        
        do {
            let docsArray = try fileManager.contentsOfDirectoryAtPath(docsPath).filter{$0.hasSuffix(ofType)}.sort({ $0 < $1 })
            return docsArray
        } catch {
            print(error)
        }

        return nil
    }

}