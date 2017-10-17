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
    
    // MARK: - Getters/Setters
    
    func setCurrentLessonNumber(lessonNumber: Int) {
        let lessonNumber = lessonNumber
        self.currentLessonNumber = lessonNumber
    }
    
    func getCurrentLessonNumber() -> Int {
        return self.currentLessonNumber
    }
}
