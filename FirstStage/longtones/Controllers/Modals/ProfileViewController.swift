//
//  ProfileViewController.swift
//  monkeytones
//
//  Created by 1 1 on 11.11.16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import SwiftValidator

class ProfileViewController:UIViewController, ValidationDelegate
{
    @IBOutlet weak var emailTextBox: UITextField!
    @IBOutlet weak var usernameTextBox: UITextField!

    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var usernameTitleLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var navBar: UINavigationBar!

    var completionBlock:(()->Void)?
    
    let validator = Validator()
    
    var predefinedUsername:String?
    
    override func viewDidLoad() {
        
        /*
        let navItem = UINavigationItem(title: Constants.Title.Settings)
        navItem.rightBarButtonItem = UIBarButtonItem(title: Constants.Title.Cancel, style: .plain, target: self, action:#selector(cancelBtnTapped))
        navBar.items = [navItem]
        */
        
        UIService.styleButton(doneButton)
        //UIService.styleButton(skipButton)
        
        validator.registerField(emailTextBox, errorLabel: emailErrorLabel, rules: [RequiredRule(), EmailRule()])
        
        if predefinedUsername == nil
        {
            validator.registerField(usernameTextBox, errorLabel: usernameErrorLabel, rules: [RequiredRule()])
        }
        else
        {
            usernameTextBox.isHidden = true
            usernameTitleLabel.isHidden = true
        }

        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(tapRecognizer)
        
    

    }
    
    override func viewDidLayoutSubviews() {
        
        emailErrorLabel.font = UIFont.init(name: Constants.GlobalFontName.fontName, size: 12)
        usernameErrorLabel.font = UIFont.init(name: Constants.GlobalFontName.fontName, size: 12)
        
        emailTextBox.font = UIFont.systemFont(ofSize: 17)
        usernameTextBox.font = UIFont.systemFont(ofSize: 17)

    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    
    func viewTapped()
    {
        self.view.endEditing(true)
    }
    
    @IBAction func skipTapped(_ sender:UIButton)
    {
        UserDefaults.standard.set("Player", forKey: "Username")
        UserDefaults.standard.synchronize()

        
        if let completion = completionBlock
        {
            completion()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneTapped(_ sender:UIButton)
    {
        emailErrorLabel.text = ""
        usernameErrorLabel.text = ""
        
        emailTextBox.layer.borderWidth = 0
        usernameTextBox.layer.borderWidth = 0
        
        validator.validate(self)
        
    }
    
    //MARK: - ValidationDelegate
    
    func validationSuccessful() {
        
        var username = self.usernameTextBox.text
        if self.predefinedUsername != nil
        {
            username = self.predefinedUsername
        }
        let email = emailTextBox.text

        UserDefaults.standard.set(username, forKey: Constants.SettingsKeys.username)
        UserDefaults.standard.set(email, forKey: Constants.SettingsKeys.userMail)
        UserDefaults.standard.synchronize()

        // Database 
        
        
        FirebaseService.shared.saveProfileData(email:email,username:username)

        // Complete
        
        if let completion = completionBlock
        {
            completion()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        // turn the fields to red
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = UIColor.red.cgColor
                field.layer.borderWidth = 1.0
            }
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.isHidden = false
        }
    }

}
