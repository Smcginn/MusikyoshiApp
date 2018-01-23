//
//  LessonSeriesViewController.swift
//  FirstStage
//
//  Created by Caitlyn Chen on 1/22/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class LessonSeriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var instrumentJson: JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
        if let file = Bundle.main.path(forResource: "instruments", ofType: "json"){
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: file))
            let allInstrumentsJson = try? JSON(data: jsonData!)
            
            for (_, subJson) :(String, JSON) in  allInstrumentsJson! {
                //TODO this is value will be based on user default configuration
                if(subJson["name"] == "trumpet"){
                    instrumentJson =  subJson
                    break
                }
            }
            let jsonString = String(data: jsonData!, encoding: .utf8)
            print(jsonString!)
            print(instrumentJson!)
        } else {
            print("unable to open instrument.json file")
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    //    public func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 1
    //    }
    
    // public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    
    // }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = instrumentJson?["levels"].count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // Configure the cell...
        if let levels = instrumentJson?["levels"] {
            cell.textLabel?.text = levels[indexPath.row]["title"].string
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Here we are going to seguae to the lesson that the user selected
        performSegue(withIdentifier: "LessonSegue", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let levels = instrumentJson?["levels"] {
            if let destination = segue.destination as? LevelOverviewViewController {
                if let row = sender as? Int {
                    destination.lessonsJson = levels[row]["lessons"]
                }
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

