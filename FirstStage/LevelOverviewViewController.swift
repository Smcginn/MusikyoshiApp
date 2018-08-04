//
//  LevelOverviewViewController.swift
//  FirstStage
//
//  Created by Caitlyn Chen on 1/22/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class LevelOverviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var selectedTuneId: String?
    var selectedTuneName: String?
    var selectedRhythmId: String?
    var selectedRhythmName: String?
    var lessonsJson: JSON?
    var exerLevelIndex: Int = 0
    var exerExerciseIndex: Int = 0
    var exerExerciseTag: String = ""

    // temp: get rid of when solidified . . .
    var ltNoteID: String = "C4"
    
    @IBOutlet weak var tableView: UITableView!
    
    let noteIds = [55,57,58,60,62,63,65,67,69,70,72]
    var actionNotes = [Note]()
    var selectedNote : Note?
    
    override func viewDidLoad() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        if actionNotes.count == 0 {
            for nId in noteIds {
                actionNotes.append(NoteService.getNote(nId)!)
            }
        } else {
            print("did load test")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Lesson 1" // + profile.currentLessonNumber
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight)
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    let tuneSegueIdentifier = "ShowTuneSegue"
    let longToneSegueIdentifier = "ShowLongToneSegue"
    let rhythmSegueIdentifier = "ShowRhythmSegue"
//    let informationBoardIdentifier = "InformationBoardSegue"
    
    // MARK: - Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier != longToneSegueIdentifier else { return false }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.title = ""
        
        if segue.identifier == tuneSegueIdentifier {
            if let destination = segue.destination as? TuneExerciseViewController {
                destination.exerciseName = selectedTuneId!
                destination.isTune = true
            }
        } else if segue.identifier == rhythmSegueIdentifier {
            if let destination = segue.destination as? TuneExerciseViewController {
                destination.exerciseName = selectedRhythmId!
                destination.isTune = false
            }
        }
        else if segue.identifier == longToneSegueIdentifier {
            if let destination = segue.destination as? LongToneViewController {
                destination.noteName = self.ltNoteID
                destination.targetNoteID = destination.kDb4
                destination.exerLevelIndex = self.exerLevelIndex
                destination.exerExerciseIndex = self.exerExerciseIndex
                destination.exerExerciseTag = self.exerExerciseTag
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let count = lessonsJson?.count {
            return count
        }
        return 0 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonItemCell", for: indexPath)
        
        // Configure the cell...
        if let lessons = lessonsJson {
            let tagStr = lessons[indexPath.row]["exerciseTag"].string
            let titleStr = lessons[indexPath.row]["title"].string
            let labelStr = tagStr! + " - " + titleStr!
            cell.textLabel?.text = labelStr
            // restore: cell.textLabel?.text = lessons[indexPath.row]["title"].string
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let lesssonType =
            LessonItemType(rawValue: (lessonsJson?[indexPath.row]["type"].string?.lowercased())!) {
            
            if let exerTag = lessonsJson?[indexPath.row]["exerciseTag"].string! {
                exerExerciseTag = exerTag
            }
            self.exerExerciseIndex = indexPath.row

            switch lesssonType {
            case .longTone:
                // NoteID
                if let noteID = lessonsJson?[indexPath.row]["noteID"].string! {
                    ltNoteID = noteID
                }
                performSegue(withIdentifier: longToneSegueIdentifier, sender: self)
            case .rhythm:
                if let musicFile = lessonsJson?[indexPath.row]["resource"].string! {
                    selectedRhythmId = String(musicFile.dropLast(4))
                }
                performSegue(withIdentifier: rhythmSegueIdentifier, sender: self)
            case .tune:
                if let musicFile = lessonsJson?[indexPath.row]["resource"].string! {
                    selectedTuneId = String(musicFile.dropLast(4))
                }
                performSegue(withIdentifier: tuneSegueIdentifier, sender: self)
//            case .informationNode:
//                performSegue(withIdentifier: informationBoardIdentifier, sender: self)
            }
        }    
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }  
}
