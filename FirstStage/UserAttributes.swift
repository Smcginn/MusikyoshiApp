//
//  UserAtributes.swift
//  FirstStage
//
//  Created by John Cook on 10/17/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

import Foundation
import CoreData

class UserAttributes: NSManagedObject {
    
    @NSManaged var currentLessonNumber: Int   
    
    //init(countSharps: Int, countFlats: Int, countEarly: Int, countLate: Int) {
        
    //}
    
    var countFlats: Int = 0 
    var countSharps: Int = 0
    var countEarly: Int = 0
    var countLate: Int = 0
    var rating: Int = 0
    
    // Detects error, and increment the count of that kind of error.
    func detectFlatNote() {
        countFlats += 1
    }
    
    func detectSharpNote() {
        countSharps += 1
    }
    
    func detectEarlyNote() {
        countEarly += 1
    }
    
    func detectLateNote() {
        countLate += 1
    }
    
    /* Computes the student's score for an exercise on a 1 through 4-star scale.
     -1 star for each error; this scoring system is probably too simplistic,
     and should be changed later
     */
    func computeScore() {
        rating = 4 - (countFlats + countSharps + countEarly + countLate)
        
        //negative stars would be too disappointing
        if rating <= 0 {
            rating = 0
        }
    }
        
    // MARK: - Getters/Setters
    
    func setCurrentLessonNumber(lessonNumber: Int) {
        self.currentLessonNumber = lessonNumber
    }
    
    func getCurrentLessonNumber() -> Int {
        return self.currentLessonNumber
    }
    
    func setCountFlatNotes(countFlats: Int) {
        self.countFlats = countFlats
    }
    
    func setCountSharpNotes(countSharps: Int) {
        self.countSharps = countSharps
    }
    
    func setCountEarlyNotes(countEarly: Int) {
        self.countEarly = countEarly
    }
    
    func setCountLateNotes(countLate: Int) {
        self.countLate = countLate
    }
}
