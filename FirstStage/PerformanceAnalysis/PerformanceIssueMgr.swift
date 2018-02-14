//
//  PerformanceIssueMgr.swift
//  FirstStage
//
//  Created by Scott Freshour on 1/3/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

/*
 
  Ideas:
    - field(s) for recurring issues: One of this particular issue not so
        bad, but this is the nth time the student did this.
 */

enum issueType {
    case notSet
    case overall
    case pitch
    case attack
    case duration
}

class PerfIssue {
    var perfNoteID:       Int32 // ID of the PerformanceNote object (not MIDI ID)
    var issueCode:        performanceRating
    var issueType:        issueType
    var issueScore:       Int // lowest (0) is best; e.g., 7, okay; 15 very bad, etc.
    
    // issueSubcodes allow for getting more specific when defining the errorCode.
    // Examples could include:
    // - if very sharp, how many half steps sharp
    // - instrument specific error subcodes: If the error code is for a higher
    //   partial these could be used to define which partial.
    var issueSubcode1:    Int32
    var issueSubcode2:    Int32
    
    var videoID:          Int     // Is there a video available?
    var alertID:          Int     // If no video, the alert ID for this
    
    init() {
        perfNoteID      = 0
        issueCode       = .notRated
        issueType       = .notSet
        issueScore      = 0
        issueSubcode1   = 0
        issueSubcode2   = 0
        
        videoID         = vidIDs.kVid_NoVideoAvailable
        alertID         = alertIDs.kAlt_NoAlertMsgAvailable
    }
    
    convenience init( perfNoteID: Int32 ) {
        self.init()
        self.perfNoteID      = perfNoteID
    }
}

class PerformanceIssueMgr {
    
    static let instance = PerformanceIssueMgr()
    
    private var perfIssues:[PerfIssue] = []
    var sortedPerfIssues:[PerfIssue] = []
    
    // To be able to filter issues by pitch, attack, duration, highest of any
    // category, or highest cumulative.
    enum sortCriteria {
        case byAttackRating
        case byDurationRating
        case byPitchRating
        case byIndividualRating // highest score, regardless of category - default
        case byOverallRating    // highest cumulative (sum of all categories)
    }
    static let kNumSortCriteria = 5
    
    var perfIssueCount: Int {
        return perfIssues.count
    }
    
    var sortedPerfIssueCount: Int {
        return sortedPerfIssues.count
    }
    
    func getPerfIssue( atIndex index: Int) -> PerfIssue? {
        guard sortedPerfIssues.count >= 1 && index < sortedPerfIssues.count
            else { return nil }
        return sortedPerfIssues[0]
    }
    
    // Since the issues will have been sorted by issue severity, first is worst
    func getFirstPerfIssue() -> PerfIssue? {
        guard sortedPerfIssues.count >= 1 else { return nil }
        return sortedPerfIssues[0]
    }
    
    func clearExisitingIssues() {
        perfIssues.removeAll()
        sortedPerfIssues.removeAll()
    }
    
    ///////////////////////////////////////////////////////////////////////////
    // This func is the whole point of this file. Called after post-performance
    // grading has occured, to capture the issues (using the specified criteria) 
    // for each note and then sort the issues by severity. When finished,
    // sortedPerfIssues contains, from worst to least, any problems with the
    // performance.
    func scanPerfNotesForIssues(_ sortCrit: sortCriteria = .byIndividualRating ) {
        
        clearExisitingIssues()
        
        func handle_ByIndividualRating( perfNote: PerformanceNote,
                                        perfIssue: inout PerfIssue ) {
            // 3-way "max".   First, attack vs duration
            if perfNote.attackScore > perfNote.durationScore {
                perfIssue.issueCode  = perfNote.attackRating
                perfIssue.issueScore = perfNote.attackScore
                perfIssue.issueType  = .attack
            } else {
                perfIssue.issueCode  = perfNote.durationRating
                perfIssue.issueScore = perfNote.durationScore
                perfIssue.issueType  = .duration
            }
            // Now, pitch vs winner of above
            if perfNote.pitchScore > perfIssue.issueScore {
                perfIssue.issueCode  = perfNote.pitchRating
                perfIssue.issueScore = perfNote.pitchScore
                perfIssue.issueType  = .pitch
            }
        }
        
        for onePerfNote in PerformanceTrackingMgr.instance.performanceNotes {
            var perfIssue = PerfIssue(perfNoteID: onePerfNote.perfNoteID)
            
            switch sortCrit {
            case .byAttackRating:
                perfIssue.issueCode  = onePerfNote.attackRating
                perfIssue.issueScore = onePerfNote.attackScore
                perfIssue.issueType  = .attack
            case .byDurationRating:
                perfIssue.issueCode  = onePerfNote.durationRating
                perfIssue.issueScore = onePerfNote.durationScore
                perfIssue.issueType  = .duration
            case .byPitchRating:
                perfIssue.issueCode  = onePerfNote.pitchRating
                perfIssue.issueScore = onePerfNote.pitchScore
                perfIssue.issueType  = .pitch
            case .byOverallRating:
                perfIssue.issueCode  = .cumulative
                perfIssue.issueScore = onePerfNote.weightedScore
                perfIssue.issueType  = .overall
            case .byIndividualRating:
                handle_ByIndividualRating( perfNote: onePerfNote,
                                           perfIssue: &perfIssue )
            }
            
            perfIssue.videoID = mapPerfIssueToVideoID(perfIssue.issueCode)
            if perfIssue.videoID == vidIDs.kVid_NoVideoAvailable {
                perfIssue.alertID = mapPerfIssueToAlertID( perfIssue.issueCode)
            }
            
            perfIssues.append(perfIssue)
        }
        
        // Finally, sort the issues by score severity, highest score to lowest.
        // Note: sorted -> separate array, for debugging purposes. (Can look at 
        //       unsorted array as well if needed.)
        sortedPerfIssues = perfIssues.sorted {
            let er0 = $0.issueScore, er1 = $1.issueScore
            return er0 > er1 ? true : false
        }
    }
}


