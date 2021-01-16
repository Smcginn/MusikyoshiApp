//
//  SignUpViewController.swift
//  PlayTunes-debug
//
//  Created by Sidney Hough on 12/6/20.
//  Copyright © 2020 Musikyoshi. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        guard let username = usernameTextField.text?.lowercased(), !username.isEmpty, isValidUsername(username: username) else {
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            return
        }
        
        checkIfUsernameAlreadyTaken(username: username) { (taken, error) in
            if let error = error {
                print(error)
            } else {
                
                Auth.auth().createUser(withEmail: email, password: password) { (user, error1) in
                    if let error1 = error1 {
                        print(error1.localizedDescription)
                    } else {
                        
                        if let id = Auth.auth().currentUser?.uid {
                            Firestore.firestore().collection("users").document(id).setData(["username" : username]) { (error2) in
                                if let error2 = error2 {
                                    print(error2)
                                } else {
                                    
                                    let defaults = UserDefaults.standard
                                    defaults.set(username, forKey: "username")
                                    
                                    self.performSegue(withIdentifier: "toMainNav", sender: nil)
                                    
                                }
                            }
                            
                        }
                        
                    }
                }
                
            }
        }
        
    }
    
    
    
    func isValidUsername(username: String) -> Bool {

            // Between 4-16 characters
            if !(4...16 ~= username.count) {
                return false
            }
            
            // No whitespace / newline characters
            if !username.isAlphanumeric {
                return false
            }
            
            return true
            
        }
        
    func checkIfUsernameAlreadyTaken(username: String, completion: @escaping (Bool?, Error?) -> Void) {
        
        Firestore.firestore().collection("users").whereField("username", isEqualTo: username).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                let documents = querySnapshot!.documents
                if documents.count > 0 {
                    completion(true, nil)
                } else {
                    completion(false, nil)
                }
            }
        }
        
    }
    
    @IBAction func unwindToSignIn(_ segue: UIStoryboardSegue) {
        
    }
    
}
