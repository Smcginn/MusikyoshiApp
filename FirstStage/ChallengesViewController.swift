//
//  ChallengesViewController.swift
//  PlayTunes-debug
//
//  Created by Sidney Hough on 12/21/20.
//  Copyright © 2020 Musikyoshi. All rights reserved.
//

import UIKit
import Firebase

struct Challenge {
    
    var issuer: String
    var responder: String
    var issuerScore: Int
    var responderScore: Int
    var turn: String
    var challengeId: String
    var lastPlayTime: TimeInterval
    
}

class ChallengesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var myTurnChallenges: [Challenge] = []
    var theirTurnChallenges: [Challenge] = []
    
    var selectedChallenge: Challenge!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        loadChallenges()
        
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func unwindToChallenges(_ segue: UIStoryboardSegue) {
        
    }
    
    func loadChallenges() {
        
        let username = UserDefaults.standard.string(forKey: "username")!
        
        Firestore.firestore().collection("challenges").whereField("issuer", isEqualTo: username).getDocuments { (querySnapshot, error) in
            if let error = error {
                print(error)
            } else {
                for document in querySnapshot!.documents {
                    
                    let data = document.data()
                    
                    let challenge = Challenge(issuer: data["issuer"] as? String ?? "", responder: data["responder"] as? String ?? "", issuerScore: data["issuerScore"] as? Int ?? 0, responderScore: data["responderScore"] as? Int ?? 0, turn: data["turn"] as? String ?? "", challengeId: document.documentID, lastPlayTime: TimeInterval()) // TODO: last argument is a placeholder
                    
                    if (challenge.turn == "issuer" && challenge.issuer == username) || (challenge.turn == "repsonder" && challenge.responder == username) {
                        self.myTurnChallenges.append(challenge)
                    } else {
                        self.theirTurnChallenges.append(challenge)
                    }
                    
                }
                self.tableView.reloadData()
            }
        }
        
        Firestore.firestore().collection("challenges").whereField("responder", isEqualTo: username).getDocuments { (querySnapshot, error) in
            if let error = error {
                print(error)
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    let challenge = Challenge(issuer: data["issuer"] as? String ?? "", responder: data["responder"] as? String ?? "", issuerScore: data["issuerScore"] as? Int ?? 0, responderScore: data["responderScore"] as? Int ?? 0, turn: data["turn"] as? String ?? "", challengeId: document.documentID, lastPlayTime: TimeInterval()) // TODO: last argument is a placeholder
                    
                    if (challenge.turn == "issuer" && challenge.issuer == username) || (challenge.turn == "repsonder" && challenge.responder == username) {
                        self.myTurnChallenges.append(challenge)
                    } else {
                        self.theirTurnChallenges.append(challenge)
                    }
                }
                self.tableView.reloadData()
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTuneExercise", let vc = segue.destination as? TuneExerciseViewController {
            vc.inChallengeMode = true
            vc.challengeId = selectedChallenge.challengeId
            vc.challengeIssuer = selectedChallenge.issuer
            vc.challengeResponder = selectedChallenge.responder
            vc.challengeTurn = selectedChallenge.turn
        }
    }
    
}

extension ChallengesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "My Turn" : "Their Turn"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return myTurnChallenges.count
        } else {
            return theirTurnChallenges.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        
        let username = UserDefaults.standard.string(forKey: "username")!
        
        var challenge: Challenge? = nil
        
        if indexPath.section == 0 && !myTurnChallenges.isEmpty {
            challenge = myTurnChallenges[indexPath.row]
        } else if indexPath.section == 1 && !theirTurnChallenges.isEmpty {
            challenge = theirTurnChallenges[indexPath.row]
        }
        
        if let challenge = challenge {
            if challenge.issuer == username {
                cell.textLabel?.text = challenge.responder
            } else {
                cell.textLabel?.text = challenge.issuer
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            // Can only respond to challenges when it is user's turn
            self.selectedChallenge = myTurnChallenges[indexPath.row]
            self.performSegue(withIdentifier: "toTuneExercise", sender: nil)
        }
    }
    
}
