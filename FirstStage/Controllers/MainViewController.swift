//
//  MainViewController.swift
//  longtones
//
//  Created by Adam Kinney on 6/7/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, GCHelperDelegate, InstrumentControllerDelegate, ExerciseControllerDelegate, TreeControllerProtocol {
    
    var firstLaunch:Bool = false
    
    var selectedNote : Note?
    var selectedDifficulty : Difficulty?
    var selectedStarsTimes : [Float]!
    
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var treePane: UIView!
    @IBOutlet weak var menuPane: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var completedImg: UIImageView!
    @IBOutlet weak var exercisePoints: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        let instrumentId = DataService.sharedInstance.currentInstrumentId
        let instrument = InstrumentService.getInstrument(instrumentId)
        let notes = InstrumentService.getInstrumentNotes(instrumentId)
        
        //selectedNote = NoteService.getNote(DataService.sharedInstance.currentNoteId)
        
        var index = notes.index(where: {$0.orderId == DataService.sharedInstance.currentNoteId})
        index = index ?? 0
        selectedNote = notes[index!]
        
        noteLabel.text = "Note: \(selectedNote!.friendlyName)"
        
        selectedDifficulty = DifficultyService.getDifficulty(DataService.sharedInstance.currentDifficultyId)
        difficultyLabel.text = "Difficulty: " + selectedDifficulty!.name.rawValue
        
        // Completion info
        
        let noteId = DataService.sharedInstance.currentNoteId
        let difId = DataService.sharedInstance.currentDifficultyId
        
        let instrumentIdStr = "\(instrumentId.rawValue)"
        let noteIdStr = "\(noteId)"
        let difIdStr = "\(difId)"
        
        let difInd = DifficultyService.getAllDifficulties().index { $0.orderId == DataService.sharedInstance.currentDifficultyId } ?? 0
        
        let value = DataService.sharedInstance.exerciseValueFor(instrumentId: instrumentIdStr, noteId: noteIdStr, difficultyId: difIdStr)
        selectedStarsTimes = DifficultyService.getTargetStarsTimes(difId, instrument: instrument!)

        let imgName = value >= selectedStarsTimes[0] ? Constants.FruitsImagesNames.imagesNames[difInd] + "C-v2.png" : Constants.FruitsImagesNames.imagesNames[difInd] + "G-v2.png"
        
        completedImg.image = UIImage(named: imgName)
        completedLabel.text = "\(DataService.sharedInstance.numbersOfCompletedTask(for: instrumentId)) / \(Constants.Exercises.exersicesCount)"
        
        // Points 
        
        exercisePoints.text = "\(DataService.sharedInstance.exersicePoints)"

    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Check if pick an instrument view need to be shown
        
        if firstLaunch
        {
            firstLaunch = false
            let vc = InstrumentViewController()
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
            
        }

    }

    override func viewDidLayoutSubviews() {
        
        exercisePoints.font = UIFont.init(name: Constants.GlobalFontName.fontName, size: 20)
        completedLabel.font = UIFont.init(name: Constants.GlobalFontName.fontName, size: 20)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "nav_icon.png"))
        
        let leftBtn: UIButton = UIButton()
        leftBtn.setImage(UIImage(named: "settings_icon.png"), for: UIControlState())
        leftBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        leftBtn.addTarget(self, action: #selector(settingsBtnTap), for: .touchUpInside)
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: leftBtn), animated: true)
        
        UIService.styleButton(startBtn)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(treePaneTapped))
        treePane.addGestureRecognizer(gesture)
        
        GCHelper.sharedInstance.delegate = self
        
        
    }
    
    
    func treePaneTapped(_ sender:UITapGestureRecognizer) {
        
        let instrument = DataService.sharedInstance.currentInstrumentId
        let notes = InstrumentService.getInstrumentNotes(instrument)
        let difs = DifficultyService.getAllDifficulties()
        
        let vc = TreeViewController()
        vc.delegate = self
        vc.difficulties = difs
        vc.notes = notes
        self.navigationItem.title = ""
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func difficultyBtnTapped(_ sender: UIButton) {
        let vc = DifficultyViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func startExerciseTapped(_ sender: UIButton) {
        
        var personalRecord = false
        if selectedDifficulty?.name == DifficultyName.personalRecord
        {
            personalRecord = true
        }
        
        let vc = exerciseController(personalRecord: personalRecord)
        
        vc.shouldAutoAdvance = !personalRecord
        vc.levelNumber = (selectedDifficulty?.orderId)! + 1
        
        self.navigationItem.title = ""
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func noteBtnTapped(_ sender: UIButton) {

        let vc = NoteViewController()
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func settingsBtnTap()
    {
        let vc = SettingsViewController()
        vc.delegate = self
        //self.navigationItem.title = ""
        self.present(vc, animated: true, completion: nil)
    }
    
    func shareBtnTap()
    {
        let textToShare = "Monkey Tones is awesome!  Check out this website about it!"
        
        if let myWebsite = URL(string: "http://www.musikyoshi.com/")
        {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            
            
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    //MARK: - GCHelperDelegate 
    
    func authentificationChanged() {
        // If GameCenter not available

    }
    
    //MARK: - TreeControllerProtocol
    
    func treeController(controller: TreeViewController, didSelect note: Note, difficulty: Difficulty) {
        DataService.sharedInstance.currentDifficultyId = difficulty.orderId
        DataService.sharedInstance.currentNoteId = note.orderId
        selectedNote = note
        selectedDifficulty = difficulty
        
        var personalRecord = false
        if selectedDifficulty?.name == DifficultyName.personalRecord
        {
            personalRecord = true
        }
        
        let vc = exerciseController(personalRecord: personalRecord)
        
        vc.shouldAutoAdvance = !personalRecord
        vc.levelNumber = (selectedDifficulty?.orderId)! + 1
        
        self.navigationItem.title = ""
        self.navigationController!.pushViewController(vc, animated: true)

        
    }
    
    //MARK: - InstrumentControllerDelegate
    
    func instrumentWasSelect(controller: InstrumentViewController) {
        
        self.dismiss(animated: true, completion: nil)
        
        let instrument = DataService.sharedInstance.currentInstrumentId
        let notes = InstrumentService.getInstrumentNotes(instrument)
        selectedNote = notes[0]
        
        DataService.sharedInstance.currentNoteId = (selectedNote?.orderId)!
        
        var personalRecord = false
        if selectedDifficulty?.name == DifficultyName.personalRecord
        {
            personalRecord = true
        }
        
        let vc = exerciseController(personalRecord: personalRecord)
        
        self.navigationItem.title = ""
        self.navigationController!.pushViewController(vc, animated: true)

    }
    
    // MARK: - ExerciseControllerDelegate
    
    func exerciseWasFinished(controller: ExerciseViewController, screenshot:UIImage) {
        
        var noteIndex = controller.noteIndex
        var levelNumber:Int?
        
        
        if controller.isKind(of: PRExerciseViewController.self) // New Level
        {
            noteIndex = -1
            selectedDifficulty = DifficultyService.getDifficulty((selectedDifficulty?.orderId)! + 1)
            levelNumber = (selectedDifficulty?.orderId)! + 1
        }
        
        _ = self.navigationController?.popViewController(animated: false)
        
        let instrument = DataService.sharedInstance.currentInstrumentId
        let notes = InstrumentService.getInstrumentNotes(instrument)
        let newIndex = noteIndex + 1
        
        var personalRecord = false
        
        if newIndex < notes.count
        {
            selectedNote = notes[newIndex]
        }
        else
        {
            personalRecord = true
        }
        
        let vc = exerciseController(personalRecord: personalRecord)
        vc.transitionFromImage = screenshot
        vc.levelNumber = levelNumber
        
        if personalRecord
        {
            (vc as! PRExerciseViewController).isPartOfTheDifficultyLevel = true
            if self.selectedDifficulty?.name == DifficultyName.master
            {
                vc.shouldAutoAdvance = false
            }
        }
        
        
        DataService.sharedInstance.currentDifficultyId = (selectedDifficulty?.orderId)!
        DataService.sharedInstance.currentNoteId = (selectedNote?.orderId)!
        
        self.navigationController?.pushViewController(vc, animated: false)
        
    }
    
    // MARK: - Helpers
    
    func exerciseController(personalRecord:Bool) -> ExerciseViewController
    {
        
        var vc:ExerciseViewController
        
        if personalRecord
        {
            vc = PRExerciseViewController()
        }
        else
        {
            vc = ExerciseViewController()
        }
        
        vc.delegate = self

        let instrument = DataService.sharedInstance.currentInstrumentId
        let notes = InstrumentService.getInstrumentNotes(instrument)

        var index = notes.index(where: {$0.orderId == selectedNote?.orderId})
        index = index ?? 0
        
        vc.targetDifficulty = selectedDifficulty
        vc.targetNote = selectedNote
        vc.noteIndex = index!
        vc.shouldAutoAdvance = true
        vc.starsTimes = selectedStarsTimes
        
        return vc
        
    }
    
}
