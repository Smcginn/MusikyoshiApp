//
//  SignInViewController.swift
//  PlayTunes-debug
//
//  Created by Sidney Hough on 12/6/20.
//  Copyright © 2020 Musikyoshi. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
            } else {
                
                if let id = Auth.auth().currentUser?.uid {
                    Firestore.firestore().collection("users").document(id).getDocument { (doc, error2) in
                        if let error2 = error2 {
                            print(error2)
                        } else {
                            if let doc = doc {
                                let data = doc.data()!
                                let username = data["username"] as? String ?? ""
                                let defaults = UserDefaults.standard
                                defaults.set(username, forKey: "username")
                                strongSelf.performSegue(withIdentifier: "toMainNav", sender: nil)
                            }
                        }
                    }
                }
                
            }
        }
        
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}
