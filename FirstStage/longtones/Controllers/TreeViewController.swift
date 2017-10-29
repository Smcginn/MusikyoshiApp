//
//  TreeViewController.swift
//  longtones
//
//  Created by Adam Kinney on 6/7/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import UIKit

protocol TreeControllerProtocol{
    func treeController(controller:TreeViewController, didSelect note:Note, difficulty:Difficulty)
}

class TreeViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    static let cellId = "cellId"
    static let names = ["1st","2nd","3th","4th","5th","6th","7th","8th"]
    
    static let starInactiveImage = #imageLiteral(resourceName: "Screen fruit-star W.png")
    static let starActiveImage = #imageLiteral(resourceName: "Screen fruit-star C.png")
    
    @IBOutlet var tableView:UITableView!
    
    var delegate:TreeControllerProtocol?

    var notes:[Note]!
    var difficulties:[Difficulty]!
    
    var exercisesData:NSDictionary!
    
    override func viewWillAppear(_ animated: Bool) {
        
        let ins = InstrumentService.getInstrument(DataService.sharedInstance.currentInstrumentId)
        
        self.navigationItem.title = ins!.name.rawValue + " Progress"
        updateFruits()
                
        exercisesData = DataService.sharedInstance.exerciseDictionary()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "TreeViewCell", bundle: nil), forCellReuseIdentifier: TreeViewController.cellId)
        tableView.rowHeight = 53
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateFruits(){
        //let instrumentId = DataService.sharedInstance.currentInstrumentId
    }
    
    //MARK: - Actions
    
    func buttonTapped(sender:UITintButton)
    {
        let cell = sender.userData as! TreeViewCell
        let noteIdx = tableView.indexPath(for: cell)!.section
        let difIdx = cell.buttons.index(of: sender)
        
        self.delegate?.treeController(controller: self, didSelect: notes[noteIdx], difficulty: difficulties[difIdx!])
    }
    
    //MARK: - UITableviewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TreeViewController.cellId, for: indexPath) as! TreeViewCell
        
        let string = TreeViewController.names[indexPath.section]
        let attributedString = NSMutableAttributedString(string:string)
        let range = NSMakeRange(0, 1)
        let range2 = NSMakeRange(1, attributedString.length - 1)
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.init(name: Constants.GlobalFontName.fontName, size: 30)! , range: range)
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.init(name: Constants.GlobalFontName.fontName, size: 11)! , range: range2)
        cell.label.attributedText = attributedString

        
        let instrumentId = DataService.sharedInstance.currentInstrumentId
        let instrument = InstrumentService.getInstrument(instrumentId)
        let noteId = InstrumentService.getInstrumentNotes(instrumentId)[indexPath.section].orderId
        let instrumentIdStr = "\(instrumentId.rawValue)"
        let noteIdStr = "\(noteId!)"
        
        
        // Buttons && images
        
        for i in 0..<cell.buttons.count
        {
            
            let difId = DifficultyService.getAllDifficulties()[i].orderId
            let difIdStr = "\(difId!)"
            
            let value = DataService.sharedInstance.exerciseValueFor(instrumentId: instrumentIdStr, noteId: noteIdStr, difficultyId: difIdStr)
                
            let but = cell.buttons[i]
            but.addTarget(self, action: #selector(buttonTapped(sender:)), for: UIControlEvents.touchUpInside)
            (but as? UITintButton)?.userData = cell
            
            let imgView = but.superview?.viewWithTag(1) as? UIImageView
            
            let starsTimes = DifficultyService.getTargetStarsTimes(difId!, instrument: instrument!)

            let imgName = value >= starsTimes[0] ? Constants.FruitsImagesNames.imagesNames[i] + "C-v2.png" : Constants.FruitsImagesNames.imagesNames[i] + "G-v2.png"
            imgView?.image = UIImage(named: imgName)
            
            for j in 0..<cell.starContainers[i].subviews.count
            {
                let star = cell.starContainers[i].subviews[j] as! UIImageView
                
                let starValue = starsTimes[j]
                if starValue <= value
                {
                    star.image = TreeViewController.starActiveImage
                }
                else
                {
                    star.image = TreeViewController.starInactiveImage
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }

}
