//
//  NewChallengeViewController.swift
//  PlayTunes-debug
//
//  Created by Sidney Hough on 12/21/20.
//  Copyright © 2020 Musikyoshi. All rights reserved.
//

import UIKit
import InstantSearchClient

class NewChallengeViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let client = Client(appID: "OGSGB0IHAP", apiKey: "23a067d94af880bdb9e9684486bfcc27")
    
    var users: [(name: String, id: String)] = []
    
    var selectedUser: (name: String, id: String)!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        textField.delegate = self
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func fetchUsers(queryText: String) {
        
        self.users = []
        
        if queryText.isEmpty {
            return
        }

        let index = client.index(withName: "users")
        let query = Query(query: queryText)

        index.search(query) { (content, error) in
            if let error = error {
                print(error)
            } else {

                guard let hits = content!["hits"] as? [[String: AnyObject]] else {
                    return
                }

                for hit in hits {

                    let username = hit["username"] as! String
                    let id = hit["objectID"] as! String
                    
                    let ownUsername = UserDefaults.standard.string(forKey: "username")!
                    if username != ownUsername {
                        self.users.append((name: username, id: id))
                    }
                    
                }

                self.tableView.reloadData()

            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPickExercise", let vc = segue.destination as? PickChallengeExerciseViewController {
            vc.responderUsername = selectedUser.name
        }
        
    }

}

extension NewChallengeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let updatedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        self.fetchUsers(queryText: updatedText)
        
        return true
        
    }
    
}

extension NewChallengeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedUser = self.users[indexPath.row]
        self.performSegue(withIdentifier: "toPickExercise", sender: nil)
    }
    
}
