//
//  FirebaseService.swift
//  monkeytones
//
//  Created by 1 1 on 21.12.16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class FirebaseService:NSObject
{
    static let shared = FirebaseService()
    var ref = FIRDatabase.database().reference()

    func saveProfileData(email:String?,username:String?) -> Void
    {
        let query = ref.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email)
        query.observe(.value, with: { (snapshot) in
            
            var entry:FIRDatabaseReference? = nil  // Check if user with email already exists
            for childSnapshot in snapshot.children {
                entry = (childSnapshot as! FIRDataSnapshot).ref
            }
            
            
            if entry == nil  // If not, create new user
            {
                entry = self.ref.child("users").childByAutoId()
            }
            
            
            entry?.setValue(["username": username,"email": email])
            
            UserDefaults.standard.set(entry?.key, forKey: Constants.SettingsKeys.userId)
            UserDefaults.standard.synchronize()
        })

    }
    
    func saveExerciseDate(userId:String?,difName:String?, date:Date)
    {
        let trackers = ref.child("trackers/\(userId!)/\(difName!)")
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = dateFormat.string(from: date)
        
        trackers.setValue(dateString)
    }
    
    
}
