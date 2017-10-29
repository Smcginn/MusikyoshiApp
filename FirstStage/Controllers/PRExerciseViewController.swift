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
import Photos
import AVFoundation

class PRExerciseViewController: ExerciseViewController
{
    @IBOutlet weak var nextLevelBtn: UIButton!
    
    var documentController: UIDocumentInteractionController!

    @IBOutlet weak var completionView: UIView!
    @IBOutlet weak var completionImgView: UIImageView!
    @IBOutlet weak var completionLabelShadow: UILabel!
    @IBOutlet weak var completionLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!

    @IBOutlet weak var shareButtonTrailing: NSLayoutConstraint!
    @IBOutlet weak var instagramButtonTrailing: NSLayoutConstraint!
    
    var localPLayerName:String = UserDefaults.standard.string(forKey: "Username") ?? "Player"
    
    var isPartOfTheDifficultyLevel = false
    
    var showCompletionTask:DispatchWorkItem?
    
    override func viewDidLoad() {

        UIService.styleButton(tryAgainBtn)
        UIService.styleButton(nextLevelBtn)
        UIService.styleButton(shareButton)
        
        tryAgainBtn.isEnabled = false
        nextLevelBtn.isEnabled = false
        
        //init audio
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker.init(mic, hopSize: 200, peakCount: 2000)
        silence = AKBooster(tracker, gain: 0)
        
        basicUIInit()
        
        //hook up events
        let gesture = UITapGestureRecognizer(target: self, action: #selector(infoViewTapped))
        infoView.addGestureRecognizer(gesture)
                
        ///self.shareToInstagram(image: #imageLiteral(resourceName: "monkey-branch.png"))
        
        
        completionView.isHidden = true

        GCHelper.sharedInstance.getLeaderboardScore(identifier: Constants.LeaderBoardIds.personalRecord, completion: { (score) in
            
            self.localPLayerName = GCHelper.sharedInstance.localPLayer.alias ?? self.localPLayerName
        })
        
        if !GCHelper.sharedInstance.authenticated
        {
            //timerBtn.isEnabled = false
        }
        
        //self.completionImgView.image = self.completionImage(difficultyNumber: 6,username: self.localPLayerName)

        if isPartOfTheDifficultyLevel
        {
            let difID = DataService.sharedInstance.currentDifficultyId
            let instrumetnID = DataService.sharedInstance.currentInstrumentId
            let instrument = InstrumentService.getInstrument(instrumetnID)
                
            targetLength = Float(DifficultyService.getTargetLength(difID, instrument: instrument!))
            
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        //timerLbl.font = UIFont.systemFont(ofSize: 78)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timerLbl.font = UIFont.init(name: "Helvetica Neue",  size: 78)
    }
    
    
    @IBAction func challengeReportBtnTapped(_ sender: UIButton)
    {
      
        GCHelper.sharedInstance.getLeaderboardScore(identifier: Constants.LeaderBoardIds.personalRecord, completion: { (score,error) in
            
            let name = GCHelper.sharedInstance.localPLayer.alias
            let instrumentId = DataService.sharedInstance.currentInstrumentId
            let instrument = InstrumentService.getInstrument(instrumentId)
            
            let message = "\(name!) has challenged you! He played for \(Double(score)/100.0) seconds on \(self.targetNote!.friendlyName) on \(instrument!.name.rawValue) - try to beat his time!"
            
            
            GCHelper.sharedInstance.presentChallengeController(controller: self, identifier: Constants.LeaderBoardIds.personalRecord, message: message, score:  Int(score), completionHandler: { (controller, success, strings) in
                
                print("success")
                print(success)
                self.dismiss(animated: true, completion: nil)
            })
            
            
        })

        /*
        let actionsheet = UIAlertController(title: "Select Action", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let action1 = UIAlertAction(title: "Invite Friends", style: UIAlertActionStyle.default) { (action) in
            //let controller = GCHelper.sharedInstance.friendRequestController(message: "")
            //self.present(controller, animated: true, completion: nil)
        }
        
        
        let action2 = UIAlertAction(title: "Challenge Friends", style: UIAlertActionStyle.default) { (action) in
            GCHelper.sharedInstance.getLeaderboardScore(identifier: Constants.LeaderBoardIds.personalRecord, completion: { (score) in
                
                let name = GCHelper.sharedInstance.localPLayer.alias
                let instrumentId = DataService.sharedInstance.currentInstrumentId
                let instrument = InstrumentService.getInstrument(instrumentId)
                
                let message = "\(name!) has challenged you! He played for \(Double(score)/100.0) seconds on \(self.targetNote!.friendlyName) on \(instrument!.name.rawValue) - try to beat his time!"

                
                GCHelper.sharedInstance.presentChallengeController(controller: self, identifier: Constants.LeaderBoardIds.personalRecord, message: message, score:  Int(score), completionHandler: { (controller, success, strings) in
                    
                    print("success")
                    print(success)
                    self.dismiss(animated: true, completion: nil)
                })
                
                
            })

        }
        
        let action3 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        
        //actionsheet.addAction(action1)
        actionsheet.addAction(action2)
        actionsheet.addAction(action3)
        
        
        self.present(actionsheet, animated: true, completion: nil)
        
        */
    }
        
    override func updateTimingUI()
    {
        timerLbl.text = String(format:"%06.02f",currentTime)
        
        if isPartOfTheDifficultyLevel == true
        {
            if currentTime < targetLength
            {
                timerLbl.textColor = UIColor(red: 128/255.0, green: 0, blue: 0, alpha: 1.0)
            }
            else
            {
                timerLbl.textColor = UIColor(red: 0, green: 128/255.0, blue: 0, alpha: 1.0)
            }
        }
    }
    
    override func tryAgainUIUpdate()
    {
        tryAgainBtn.isEnabled = false
        timerLbl.text = "000.00"
        completionView.isHidden = true
        
        
        if isPartOfTheDifficultyLevel == true
        {
            timerLbl.textColor = UIColor(red: 128/255.0, green: 0, blue: 0, alpha: 1.0)
        }

        if let showCompletionTask = showCompletionTask
        {
            showCompletionTask.cancel()
        }
    }
    
    override func loadScene() {
        return
    }
    
    override func noteDidHit()
    {
        return
    }
    
    override func noteDidFailed()
    {
        GCHelper.sharedInstance.reportLeaderboardIdentifier(Constants.LeaderBoardIds.personalRecord, score: Int(currentTime*100))
        
        tryAgainBtn.isEnabled = true
        
        if isPartOfTheDifficultyLevel
        {
            
            if currentTime >= targetLength
            {
                rescheduleShowCompletion()
            }
            
        }
        
        return
    }
    
    
    override func reportExerciseCompletion() {

        if isPartOfTheDifficultyLevel
        {
            return
        }
        
        var time:Float = 0.0
        
        if isExerciseSuccess
        {
            time = Float(targetLength)
        }
        else
        {
            time = Float(currentTime)
        }
        
        DataService.sharedInstance.setExerciseCompletion(instrumentId:DataService.sharedInstance.currentInstrumentId,
            noteId: "\(DataService.sharedInstance.currentNoteId)",
            difficultyId: DataService.sharedInstance.currentDifficultyId,
            time: time)
        

    }
    
    @IBAction func nextLevelBtnTapped(_ sender:UIButton)
    {
        UIGraphicsBeginImageContext((self.navigationController?.view.frame.size)!)
        self.navigationController?.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.delegate.exerciseWasFinished(controller: self, screenshot: image!)

    }
    
    @IBAction func shareBtnTapped(_ sender:UIButton)
    {
        //self.shareToInstagram(image: completionImgView.image!)
        shareToEverywhere(image: completionImgView.image!)
    }

    @IBAction func instagramBtnTapped(_ sender:UIButton)
    {
        self.shareToInstagram(image: completionImgView.image!)
    }
    
    // MARK: - Sharing
    
    func shareToEverywhere(image: UIImage)
    {
        
        //let shareText = "Hello, world!"
        
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        present(vc, animated: true, completion: nil)

    }

    
    func shareToInstagram(image: UIImage) {
        
        let instagramURL = NSURL(string: "instagram://app")
        
        if (UIApplication.shared.canOpenURL(instagramURL! as URL)) {
            
            let imageData = UIImageJPEGRepresentation(image, 100)
            
            let captionString = "caption"
            
            let writePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("instagram.igo")
            
            do
            {
                try imageData?.write(to: URL(fileURLWithPath: writePath))
            }
            catch
            {
                return
            }
            
            
            
            let fileURL = NSURL(fileURLWithPath: writePath)
            
            self.documentController = UIDocumentInteractionController(url: fileURL as URL)
            
            //self.documentController.delegate = self
            
            self.documentController.uti = "com.instagram.exlusivegram"
            
            self.documentController.annotation = NSDictionary(object: captionString, forKey: "InstagramCaption" as NSCopying)
            self.documentController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
            
            
            
        } else {
            let alertController = UIAlertController(title: "Error", message: "Instagram is not installed", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    

    
    // MARK: - Helpers 
    
    func completionImage(difficultyNumber:Int, username:String) -> UIImage?
    {
        var img:UIImage?
        
        img = UIImage(named: "Completion-level-0\(difficultyNumber).png")
        
        UIGraphicsBeginImageContext(img!.size)
        img?.draw(at: CGPoint.zero)
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        
        let lineHeight:CGFloat = 54.0
        var usernameRect = CGRect(x: 0, y: 32, width: img!.size.width, height: lineHeight)
        
        var textColor = UIColor.white
        var shadowColor = UIColor.black
        
        switch difficultyNumber {
        case 1:
            usernameRect = CGRect(x: 0, y: img!.size.height - 125 - lineHeight, width: img!.size.width, height: lineHeight)
            textColor = UIColor(red: 0.773, green: 0.882, blue: 0.957, alpha: 1.00)
            shadowColor = UIColor(red: 0.184, green: 0.196, blue: 0.400, alpha: 1.00)
        case 2:
            usernameRect = CGRect(x: 0, y: img!.size.height - 129 - lineHeight, width: img!.size.width, height: lineHeight)
            textColor = UIColor(red: 0.310, green: 0.545, blue: 0.263, alpha: 1.00)
            shadowColor = UIColor(red: 0.184, green: 0.196, blue: 0.400, alpha: 1.00)
        case 3:
            usernameRect = CGRect(x: 0, y: img!.size.height - 219 - lineHeight, width: img!.size.width, height: lineHeight)
            shadowColor = UIColor(red: 0.114, green: 0.114, blue: 0.192, alpha: 1.00)
        case 4:
            usernameRect = CGRect(x: 37, y: img!.size.height - 547 - lineHeight, width: img!.size.width - 2*37, height: lineHeight)
            textColor = UIColor(red: 0.573, green: 0.706, blue: 0.333, alpha: 1.00)
            shadowColor = UIColor(red: 0.184, green: 0.196, blue: 0.400, alpha: 1.00)
            paragraphStyle.alignment = .left
        case 5:
            usernameRect = CGRect(x: 0, y: img!.size.height - 120 - lineHeight, width: img!.size.width, height: lineHeight)
            textColor = UIColor(red: 0.792, green: 0.322, blue: 0.416, alpha: 1.00)
            shadowColor = UIColor(red: 0.184, green: 0.196, blue: 0.400, alpha: 1.00)
        case 6:
            usernameRect = CGRect(x: 0, y: img!.size.height - 220 - lineHeight, width: img!.size.width - 43, height: lineHeight)
            textColor = UIColor(red: 0.451, green: 0.322, blue: 0.584, alpha: 1.00)
            shadowColor = UIColor(red: 0.949, green: 0.882, blue: 0.600, alpha: 1.00)
            paragraphStyle.alignment = .right
        default:
            break
        }
        

        
        let attrs = [NSFontAttributeName: UIFont(name: "Carlisle", size: 46)!, NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName : textColor]
        let attrsShadow = [NSFontAttributeName: UIFont(name: "Carlisle", size: 46)!, NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName : shadowColor]

        let string = username
        string.draw(with: usernameRect.offsetBy(dx: 1, dy: 3), options: .usesLineFragmentOrigin, attributes: attrsShadow, context: nil)
        string.draw(with: usernameRect, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        
        return image
    }
    
    
    func rescheduleShowCompletion()
    {
        if let showCompletionTask = showCompletionTask
        {
            showCompletionTask.cancel()
        }
        
        showCompletionTask = DispatchWorkItem {
            self.completionView.isHidden = false
            self.tryAgainBtn.isHidden = true
            
            self.timerLbl.text = ""
            
            self.nextLevelBtn.isEnabled = true
            
            self.completionImgView.image = self.completionImage(difficultyNumber: DataService.sharedInstance.currentDifficultyId + 1,username: self.localPLayerName)
            let imgActualRect = AVMakeRect(aspectRatio: self.completionImgView.image!.size, insideRect: self.completionImgView.bounds);
            
            
            self.shareButtonTrailing.constant = imgActualRect.origin.x
            self.instagramButtonTrailing.constant = imgActualRect.origin.x
        }
        
        // execute task in 2 seconds
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: showCompletionTask!)
        
        // optional: cancel task
        //task.cancel()
        
        
        //showCompletionTimer = Timer(timeInterval: 0, target: self, selector: #selector(showCompletion), userInfo: nil, repeats: false)
        
    }
    
}
