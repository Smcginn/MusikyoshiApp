//
//  LessonSeriesViewController.swift
//  FirstStage
//
//  Created by Monday Ayewa on 11/15/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import UIKit

class LessonSeriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    var lessonId = 0;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1;
    }
    
  
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  tableView.dequeueReusableCell(withIdentifier: "LessonSeriesTableViewCell", for: indexPath) as! LessonSeriesTableViewCell
        cell.lessonTitle.text = "lesson 1"
        return cell
        

    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        lessonId = indexPath.row
        performSegue(withIdentifier: "LessonSegue", sender: self)
    }
   



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
