//
//  InstrumentViewController.swift
//  monkeytones
//
//  Created by Adam Kinney on 8/14/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import UIKit


protocol InstrumentControllerDelegate
{
    func instrumentWasSelect(controller:InstrumentViewController)
}


class InstrumentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate:InstrumentControllerDelegate!
    
    let cellIdentifier = "Cell"
    let instruments = InstrumentService.getAllInstruments()

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        let navItem = UINavigationItem(title: "Pick an Instrument")
        navItem.rightBarButtonItem = UIBarButtonItem(title: Constants.Title.cancel, style: .plain, target: self, action:#selector(cancelBtnTapped))
        navBar.items = [navItem]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let index = instruments.index(where: {$0.orderId == DataService.sharedInstance.currentInstrumentId})!
        let rowToSelect:IndexPath = IndexPath(row: index, section: 0);
        tableView.selectRow(at: rowToSelect, animated: true, scrollPosition: .middle)
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
        return instruments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil{
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        }
        
        cell.textLabel!.text = instruments[(indexPath as NSIndexPath).row].name.rawValue
        cell.backgroundColor = UIColor.clear

        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DataService.sharedInstance.currentInstrumentId = instruments[(indexPath as NSIndexPath).row].orderId
        delegate.instrumentWasSelect(controller: self)
        self.dismiss(animated: true, completion: nil)
    }
}
