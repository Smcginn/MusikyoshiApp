//
//  LessonSeriesTableViewController.swift
//  FirstStage
//
//  Created by Monday Ayewa on 11/17/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class LessonSeriesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var intstrumentJson: JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        if let file = Bundle.main.path(forResource: "instruments", ofType: "json"){
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: file))
            let allInstrumentsJson = try? JSON(data: jsonData!)
            
            for (_, subJson) :(String, JSON) in  allInstrumentsJson! {
                //TODO this is value will be based on user default configuration
                if(subJson["name"] == "trumpet"){
                    intstrumentJson =  subJson
                    break
                }
            }
            let jsonString = String(data: jsonData!, encoding: .utf8)
            print(jsonString!)
            print(intstrumentJson!)
        }else{
            print("unable to open instrument.json file")
        }
       
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    public func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let count = intstrumentJson?["levels"].count {
            
            return count
        }
        return 0
        
    }

    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonSeriesViewCell", for: indexPath)

        // Configure the cell...
        if let levels = intstrumentJson?["levels"]{
            
              cell.textLabel?.text = levels[indexPath.row]["title"].string
        }
        

        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //Here we are going to seguae to the lesson that the user selected
        performSegue(withIdentifier: "LessonSegue", sender: indexPath.row )
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let levels = intstrumentJson?["levels"]{
            if let destination = segue.destination as? LessonOverviewViewController{
                
                if let row = sender as? Int {
                   destination.lessonsJson = levels[row]["lessons"]
                }
            }
        }
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
