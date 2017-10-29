//
//  NoteViewController.swift
//  longtones
//
//  Created by Adam Kinney on 7/3/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellIdentifier = "Cell"
    var notes:[Note]! //= [NoteService.getNote(49)!, NoteService.getNote(51)!, NoteService.getNote(53)!, NoteService.getNote(54)!, NoteService.getNote(56)!]

    var countLabels = ["1st Note - ", "2nd Note - ", "3rd Note - ", "4th Note - ", "5th Note - ", "6th Note - ", "7th Note - ", "8th Note - ",]
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        let navItem = UINavigationItem(title: "Pick a Note")
        navItem.rightBarButtonItem = UIBarButtonItem(title: Constants.Title.cancel, style: .plain, target: self, action:#selector(cancelBtnTapped))
        navBar.items = [navItem]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        notes = InstrumentService.getInstrumentNotes(DataService.sharedInstance.currentInstrumentId)
        // Do any additional setup after loading the view.
        var index = notes.index(where: {$0.orderId == DataService.sharedInstance.currentNoteId})
        
        index = index ?? 0
        
        let rowToSelect:IndexPath = IndexPath(row: index!, section: 0);
        tableView.selectRow(at: rowToSelect, animated: true, scrollPosition: .middle)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func cancelBtnTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil{
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        }
        
        cell.textLabel!.text = countLabels[indexPath.row] + notes[(indexPath as NSIndexPath).row].friendlyName
//        let diceRoll = Int(arc4random_uniform(5) + 1)
//        cell.detailTextLabel!.text = "\(diceRoll) / 5 completed"
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        if tableView.indexPathForSelectedRow == indexPath {
//            
//        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DataService.sharedInstance.currentNoteId = notes[(indexPath as NSIndexPath).row].orderId
        
        self.dismiss(animated: true, completion: nil)
    }
}
