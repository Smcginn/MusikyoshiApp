//
//  DifficultyViewController.swift
//  longtones
//
//  Created by Adam Kinney on 6/26/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import UIKit


class DifficultyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellIdentifier = "Cell"
    let difficulties = DifficultyService.getAllDifficulties()
    var selectedNote : Note?

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        selectedNote = NoteService.getNote(DataService.sharedInstance.currentNoteId)
        
        let navItem = UINavigationItem(title: "Pick a Difficulty for \(selectedNote!.friendlyName)")
        navItem.rightBarButtonItem = UIBarButtonItem(title: Constants.Title.cancel, style: .plain, target: self, action:#selector(cancelBtnTapped))
        navBar.items = [navItem]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let index = difficulties.index(where: {$0.orderId == DataService.sharedInstance.currentDifficultyId})!
        let rowToSelect:IndexPath = IndexPath(row: index, section: 0);
        tableView.selectRow(at: rowToSelect, animated: true, scrollPosition: .middle)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelBtnTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return difficulties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil{
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        }
        
        cell.textLabel!.text = difficulties[(indexPath as NSIndexPath).row].name.rawValue
//        let diceRoll = Int(arc4random_uniform(4) + 1)
//        cell.detailTextLabel!.text = "\(diceRoll) / 4 stars"
        cell.backgroundColor = UIColor.clear

        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DataService.sharedInstance.currentDifficultyId = difficulties[(indexPath as NSIndexPath).row].orderId
        self.dismiss(animated: true, completion: nil)
    }
}
