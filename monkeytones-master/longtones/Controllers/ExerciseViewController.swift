//
//  ExerciseViewController.swift
//  longtones
//
//  Created by Adam Kinney on 6/7/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//
import AudioKit
import UIKit
import MessageUI
import SpriteKit


protocol ExerciseControllerDelegate
{
    func exerciseWasFinished(controller:ExerciseViewController, screenshot:UIImage)
}


class ExerciseViewController: UIViewController {
    
    var delegate:ExerciseControllerDelegate!
    
    var shouldAutoAdvance:Bool = false
    
    var transitionFromImage:UIImage?
    var targetNote : Note?
    var starsTimes : [Float]!
    var targetDifficulty : Difficulty?
    var targetLength : Float = 0.0
    var noteIndex : Int = 0
    var numberOfTries:Int = 1
    
    var exerciseState = ExerciseState.notStarted
    var timerStartTime = Date()
    var timer = Timer()
    var currentTime:Float = 0.0
    var freqRanges:[Float] = []
    
    var emailTitle = ""
    var emailBody = ""
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    
    var hasNoteBeenHit = false
    var isExerciseSuccess = false
    
    var isDisapeared = false
    
    @IBOutlet weak var musicLine: MusicLine!
    @IBOutlet weak var infoLbl: UIOutlinedLabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var targetTimeLbl: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressIndicatorView: UIView!
    @IBOutlet weak var countdownLbl: UIOutlinedLabel!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var sendReportBtn: UIButton!
    @IBOutlet weak var nextExerciseBtn: UIButton?
    @IBOutlet weak var hintLabel: UIOutlinedLabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var perfectView: UIView!
    @IBOutlet var stars: [UIImageView]!
    
    @IBOutlet weak var levelNumberView: UIView!
    @IBOutlet weak var levelNumberLabel: UIOutlinedLabel?
    var levelNumber:Int?
    
    @IBOutlet weak var hostView: SKView!
    var scene: BasicScene!
    
    var hintDelayCount : Double = 0.0
    let hintMaxDelay : Double = 15
    var freqRangeHit : Int = -1
    
    static let hintColors = [UIColor.black,UIColor.white,UIColor.black,UIColor.orange,UIColor.white,UIColor.black,UIColor.white,UIColor.orange]
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = targetNote!.friendlyName + " " + targetDifficulty!.name.rawValue
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tryStopAudioTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIService.styleButton(nextExerciseBtn!)
        UIService.styleButton(tryAgainBtn)

        //init audio
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker.init(mic, hopSize: 200, peakCount: 2000)
        silence = AKBooster(tracker, gain: 0)
        
        basicUIInit()
        
        // Level Number Image
        if let levelNumb = levelNumber
        {
            
            levelNumberLabel?.outlineColor = UIColor(red: 0.953, green: 0.863, blue: 0.776, alpha: 1.00)
            levelNumberLabel?.textColor = UIColor(red: 0.412, green: 0.176, blue: 0.373, alpha: 1.00)
            levelNumberLabel?.text = "Level \(levelNumb)"
            self.view.bringSubview(toFront: levelNumberView)
            levelNumberView.alpha = 1
            
            UIView.animate(withDuration: 0.5, delay: 1.4, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.levelNumberView.alpha = 0
            }, completion: nil)
        }
        
        
        
        //hook up events
        let gesture = UITapGestureRecognizer(target: self, action: #selector(infoViewTapped))
        infoView.addGestureRecognizer(gesture)
        

    }
    
    func basicUIInit()
    {
        let instrumentId = DataService.sharedInstance.currentInstrumentId
        let instrument = InstrumentService.getInstrument(instrumentId)

        //Render exercise
        if let tn = targetNote
        {
            let yPosOffset = CGFloat(NoteService.getYPos(tn.orderId))
            perfectView.frame = CGRect(x: 99, y: 74 + yPosOffset, width: 19, height: 14)
            perfectView.isHidden = true
            freqRanges = InstrumentService.getFrequencyRanges(tn.orderId)
            //freqTips = InstrumentService.getFrequencyTips()
                        
            let ex = Exercise()
            let m = Measure()
            
            if let noteRendered = NoteService.getNote(tn.orderId)
            {
                noteRendered.xPos = 100
                m.notes.append(noteRendered)
            }
            
            m.width = 172
            ex.measures.append(m)
            musicLine.exercise = ex
            
            if instrument?.name == InstrumentName.trombone || instrument?.name == InstrumentName.baritoneEuphonium || instrument?.name == InstrumentName.bassoon || instrument?.name == InstrumentName.tuba
            {
                musicLine.bassClef = true
            }
            else
            {
                musicLine.bassClef = false
            }
            
            let hintCorrection = InstrumentService.tipsYCorrection(instrumentId:instrumentId)
            hintLabel.frame = CGRect(x: hintLabel.frame.origin.x + 4, y: hintLabel.frame.origin.y + hintCorrection, width: hintLabel.frame.width, height: hintLabel.frame.height)
        }
        
        if let td = targetDifficulty {
            targetLength = Float(DifficultyService.getTargetLength(td.orderId, instrument: instrument!))
            
            if targetTimeLbl != nil
            {
                targetTimeLbl.text = String(targetLength)
            }
        }

        
        // Transition from image
        
        if let image = transitionFromImage
        {
            let imgView = UIImageView(image: image)
            imgView.frame = (navigationController?.view.bounds)!
            imgView.layer.shadowColor = UIColor.black.cgColor
            imgView.layer.shadowRadius = 10
            imgView.layer.shadowOpacity = 0.7
            
            navigationController?.view.addSubview(imgView)
            
            UIView.animate(withDuration: 0.3, animations: {
                imgView.frame = CGRect.zero
            }, completion: { (completed) in
                imgView.removeFromSuperview()
            })
        }

        pointsLabel.text = "Exercise points: \(DataService.sharedInstance.exersicePoints)"

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AudioKit.output = silence
        
        self.view.layoutIfNeeded()
        
        loadScene()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        isDisapeared = true
    }
    
    override func viewDidLayoutSubviews() {
        
        if levelNumberLabel != nil
        {
            levelNumberLabel?.font = UIFont.init(name: "Carlisle", size: 60)
        }
        
        infoLbl.font = UIFont.init(name: "Carlisle", size: 18)
        infoLbl.outlineWidth = 4
        infoLbl.outlineColor = ExerciseViewController.hintColors[noteIndex]
        
        countdownLbl.font = UIFont.init(name: "Carlisle", size: 94)
        countdownLbl.outlineWidth = 6
        countdownLbl.outlineColor = ExerciseViewController.hintColors[noteIndex]
        
        hintLabel.font = UIFont.init(name: "Carlisle", size: 24)
        hintLabel.outlineWidth = 3
        //hintLabel.outlineColor = UIColor.whi
        
        
        //countdownLbl.attributedText = NSAttributedString(string: "1", attributes: strokeTextAttributes)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - User actions
    @IBAction func completeBtnTapped(_ sender: UIButton) {
        self.navigationController!.isNavigationBarHidden = false
        
        let vc = MainViewController()
        self.navigationController!.pushViewController(vc, animated: true)
    }

    @IBAction func tryAgainBtnTapped(_ sender: UIButton) {
                
        //status variables
        exerciseState = ExerciseState.notStarted
        isExerciseSuccess = false
        hasNoteBeenHit = false
        currentTime = 0
        hintDelayCount = 0.0
        freqRangeHit = -1
        //emailBody = ""
        
        //ui
        tryAgainUIUpdate()
        
        //start fresh
        startCountdown()
        
        numberOfTries += 1
    }
    
    @IBAction func nextExerciseBtnTapped(_ sender: UIButton) {
        self.autoAdvance()
    }

    
    

    func infoViewTapped() {
        
        if exerciseState == ExerciseState.notStarted
        {
            startCountdown()
        }
    }
    
    // MARK: - UI Helpers
    func loadScene(){
        
        switch noteIndex
        {
        case 0:
            scene = TreeScene(fileNamed: "TreeScene.sks")
            scene.size = hostView.bounds.size
        case 1:
            scene = MonkeyScene(size:hostView.bounds.size)
        case 2:
            scene = CarnivalScene(size:hostView.bounds.size)
        case 3:
            scene = LakeScene(size:hostView.bounds.size)
        case 4:
            scene = BuildingsScene(size:hostView.bounds.size)
        case 5:
            scene = SkiingScene(size:hostView.bounds.size)
        case 6:
            scene = CaveScene(size:hostView.bounds.size)
        case 7:
            scene = PlaneScene(size:hostView.bounds.size)
        default:
            scene = BasicScene(size:hostView.bounds.size)
        }
        
        // Configure the view.
        //hostView.showsFPS = true
        //hostView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        hostView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFit
        
        hostView.presentScene(scene)
    }
    
    
    
    func hideNoteIndicators(){
        hintLabel.text = ""
        perfectView.isHidden = true
    }
    
    func updateTimingUI() {
        
        if currentTime >= targetLength
        {
            exerciseCompleted()
            progressIndicatorView.frame = CGRect(x: 0 , y: 0, width: progressView.frame.width, height: progressIndicatorView.frame.height)

        }
        else
        {
            let percentComplete = currentTime / targetLength
            
            timerLbl.text = String(format: "%.1f", currentTime)
            //balloon.radius += 0.3
            
            let pvw = Double(progressView.frame.width)
            progressIndicatorView.frame = CGRect(x: 0 , y: 0, width: CGFloat(pvw * percentComplete), height: progressIndicatorView.frame.height)
            scene.updateProgress(progress: CGFloat(percentComplete))
        }
        
        for i in 0..<stars.count
        {
            if currentTime >= starsTimes[i]
            {
                let star = stars[i]
                
                if star.alpha == 0
                {
                    star.alpha = 1
                    star.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    UIView.animate(withDuration: 0.3, animations: {
                        var transform = star.transform
                        transform = transform.rotated(by: 2*CGFloat.pi/5)
                        transform = transform.scaledBy(x: 2, y: 2)
                        star.transform = transform
                    })
                }
            }
        }
    }
    
    func tryAgainUIUpdate()
    {
        timerLbl.text = "0"
        progressIndicatorView.frame = CGRect(x: 0 , y: 0, width: 1, height: progressIndicatorView.frame.height)
        //sendReportBtn.isHidden = true
        tryAgainBtn.isHidden = true
        nextExerciseBtn?.isHidden = true
        
        for star in stars
        {
            star.alpha = 0
        }
        
        loadScene()
        hideNoteIndicators()
    }
    
    func showHint(targetFreqRange: Int)
    {
        if targetFreqRange == -1
        {
            return
        }
        
        if freqRangeHit != targetFreqRange {
            print("freqNoteChanged: \(targetFreqRange)")
            
            freqRangeHit = targetFreqRange
            
            
            hintDelayCount = 0;
            infoLbl.text = ""
            hideNoteIndicators()
            hintLabel.text = Constants.Hints.titles[targetFreqRange]
            hintLabel.textColor = Constants.Hints.colors[targetFreqRange]
            hintLabel.outlineColor = Constants.Hints.colors[targetFreqRange]
            
            /*
            switch targetFreqRange {
            case 0:
                noteWayTooHighView.isHidden = false
                break
            case 1:
                noteTooHighView.isHidden = false
                break
            case 3:
                noteTooLowView.isHidden = false
                break
            case 4:
                noteWayTooLowView.isHidden = false
                break
            default:
                break
            }
            */
        }
        else
        {
            hintDelayCount += 0.1;
            //print("hintDelayCount: \(hintDelayCount)")
        }
    }
    

    

    // MARK: - Process managment
    
    func startCountdown()
    {
        //infoLbl.text = "Get Ready"
        infoLbl.text = ""
        countdownLbl.text = "3"
        countdownLbl.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        
        
        //tryAgainBtn.isEnabled = false
        exerciseState = ExerciseState.inProgress
        
        UIView.animate(withDuration: 1.0, animations: {
            self.countdownLbl.alpha = 1
            self.countdownLbl.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        
        delay(1.0){
            //self.infoLbl.text = "Set"
            
            self.countdownLbl.alpha = 0
            self.countdownLbl.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.countdownLbl.text = "2"
            
            UIView.animate(withDuration: 1.0, animations: {
                self.countdownLbl.alpha = 1
                self.countdownLbl.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
            
            delay(1.0){
                //self.infoLbl.text = "Go!"
                
                self.countdownLbl.alpha = 0
                self.countdownLbl.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                self.countdownLbl.text = "1"
                
                UIView.animate(withDuration: 1.0, animations: {
                    self.countdownLbl.alpha = 1
                    self.countdownLbl.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
                delay(1.0){
                    self.countdownLbl.alpha = 0
                    //self.tryAgainBtn.isEnabled = true
                    self.startExercise()
                }
                
            }
        }
    }
    
    func startExercise(){
        
        if isDisapeared
        {
            return
        }
        
        AudioKit.start()
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTracking), userInfo: nil, repeats: true)
    }
    
    func stopExercise(){
        tryStopAudioTimer()
        
        hideNoteIndicators()
        
        
        if isExerciseSuccess
        {
            //infoLbl.text = "Congratulations!"
            
            let rpt = "---Exercise SUCCESS---"
            print(rpt)
            
            
        }
        else
        {
            
            let rpt = "---Exercise Fail---"
            print(rpt)
            tryAgainBtn.isHidden = false
            
            if let nextExerciseBtn = nextExerciseBtn
            {
                nextExerciseBtn.isHidden = false
                
                if numberOfTries >= Constants.Exercises.maxNumberOfTries
                {
                    nextExerciseBtn.isEnabled = true
                }
            }
            
        }
        
        // Save score
        
        DataService.sharedInstance.exersicePoints += Int(currentTime)
        pointsLabel.text = "Exercise points: \(DataService.sharedInstance.exersicePoints)"
        
        exerciseState = ExerciseState.completed
        
        reportExerciseCompletion()
    }
    
    func reportExerciseCompletion()
    {
        
        var time:Float = 0.0
        
        if isExerciseSuccess
        {
            time = Float(targetLength)
        }
        else
        {
            time = Float(currentTime)
        }
        
        DataService.sharedInstance.setExerciseCompletion(instrumentId: DataService.sharedInstance.currentInstrumentId,
            noteId: "\(DataService.sharedInstance.currentNoteId)",
            difficultyId: DataService.sharedInstance.currentDifficultyId,
            time: time)
    

    }
    
    func tryStopAudioTimer() {
        AudioKit.stop()
        timer.invalidate()
    }
    
    
    func noteDidHit()
    {
        scene.startStream()
    }
    
    func noteDidFailed()
    {
        scene.showFail()
    }
    
    func exerciseCompleted()
    {
        scene.showSuccess {
            self.autoAdvance()
        }
        
        isExerciseSuccess = true
        stopExercise()
        
    }
    
    func autoAdvance()
    {
        if self.shouldAutoAdvance
        {
            if self.navigationController != nil
            {
                UIGraphicsBeginImageContext((self.navigationController?.view.frame.size)!)
                self.navigationController?.view.layer.render(in: UIGraphicsGetCurrentContext()!)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                self.delegate.exerciseWasFinished(controller: self, screenshot: image!)
            }
        }
    }
    
    
    // MARK: - Note recognition logic
    
    func updateTracking()
    {
        if tracker.amplitude > 0.12 // was 0.8
        {
            let freq = Float(tracker.frequency);
            //let noteHit = NoteService.getNote(freq)
            var noteIsHit = false
            
            var currentRange = freqRanges.count
            for i in 0..<freqRanges.count
            {
                let range = freqRanges[i]
                if freq >= range
                {
                    currentRange = i
                    break
                }
            }
            
            showHint(targetFreqRange: currentRange)
            
            if currentRange == 2
            {
                noteIsHit = true
                perfectView.isHidden = false
            }

            
            if noteIsHit
            {
                //begin tracking if not already
                if !hasNoteBeenHit {
                    timerStartTime = Date()
                    noteDidHit()
                    hasNoteBeenHit = true
                }
                let now = Date()
                currentTime = Float(now.timeIntervalSince(self.timerStartTime))

                updateTimingUI()
            }
            else if hasNoteBeenHit
            {
                //cancel if note started
                noteDidFailed()
                stopExercise()
            }
        }
        else if hasNoteBeenHit
        {
            //note started but fell silent
            let rpt = String(format: "freq: %f vol: %f", tracker.frequency, tracker.amplitude)
            //emailBody += "<li>" + rpt + "</li>"
            print(rpt)
            noteDidFailed()
            stopExercise()
        }
    }
}
