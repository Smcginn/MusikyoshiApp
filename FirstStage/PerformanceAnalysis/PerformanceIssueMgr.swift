//
//  PerformanceIssueMgr.swift
//  FirstStage
//
//  Created by Scott Freshour on 1/3/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation


let kFourStars  = 4
let kThreeStars = 3
let kTwoStars   = 2
let kOneStar    = 1
let kNoStars    = 0

struct StarThresholds {
    var fourStarMaxScore:  Int
    var threeStarMaxScore: Int
    var twoStarMaxScore:   Int
    var oneStarMaxScore:   Int // Ejector seat?
    
    init() {
        self.fourStarMaxScore   = kDefaultMaxScore_FourStars
        self.threeStarMaxScore  = kDefaultMaxScore_ThreeStars
        self.twoStarMaxScore    = kDefaultMaxScore_TwoStars
        self.oneStarMaxScore    = kDefaultMaxScore_OneStars
    }
    init( fourStarMaxScore:  Int,
          threeStarMaxScore: Int,
          twoStarMaxScore:   Int,
          oneStarMaxScore:   Int ) {
        self.fourStarMaxScore   = fourStarMaxScore
        self.threeStarMaxScore  = threeStarMaxScore
        self.twoStarMaxScore    = twoStarMaxScore
        self.oneStarMaxScore    = oneStarMaxScore
    }
}


/*
 
  Ideas:
    - field(s) for recurring issues: One of this particular issue not so
        bad, but this is the nth time the student did this.
 */

let kNoneAvailable: Int = -1

enum issueType: Int {
    case notSet     = 0
    case overall    = 1
    case pitch      = 2
    case attack     = 3  // includes notes played over rests  RESTCHANGE
    case duration   = 4
}

class PerfIssue {
    var perfScoreObjectID:  Int32 // ID of the PerformanceNote object (not MIDI ID)
    var issueCode:          performanceRating
    var issueType:          issueType
    var issueScore:         Int // lowest (0) is best; e.g., 7, okay; 15 very bad, etc.
    
    // issueSubcodes allow for getting more specific when defining the errorCode.
    // Examples could include:
    // - if very sharp, how many half steps sharp
    // - instrument specific error subcodes: If the error code is for a higher
    //   partial these could be used to define which partial.
    var issueSubcode1:      Int32
    var issueSubcode2:      Int32
    
    var videoID:            Int     // Is there a video available?
    var alertID:            Int     // If no video, the alert ID for this
    
    init() {
        perfScoreObjectID   = 0
        issueCode           = .notRated
        issueType           = .notSet
        issueScore          = 0
        issueSubcode1       = 0
        issueSubcode2       = 0
        
        videoID             = vidIDs.kVid_NoVideoAvailable
        alertID             = alertIDs.kAlt_NoAlertMsgAvailable
    }
    
    convenience init( perfScoreObjID: Int32 ) {
        self.init()
        self.perfScoreObjectID  = perfScoreObjID
    }
}

class PerformanceIssueMgr {
    
    var starThresholds = StarThresholds()
    
    
    static let instance = PerformanceIssueMgr()
    
    private var perfIssues:[PerfIssue] = []
    var sortedPerfIssues:[PerfIssue] = []
    
    private var justNotesPerfIssues:[PerfIssue] = []
    var sortedJustNotesPerfIssues:[PerfIssue] = []

    // To be able to filter issues by pitch, attack, duration, highest of any
    // category, or highest cumulative.
    enum sortCriteria {
        case byAttackRating
        case byDurationRating
        case byAttackAndDurationRating // for Rhythm Prep
        case byPitchRating
        case byIndividualRating // highest score, regardless of category - default
        case byOverallRating    // highest cumulative (sum of all categories)
    }
    static let kNumSortCriteria = 6
    
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
        justNotesPerfIssues.removeAll()
        sortedJustNotesPerfIssues.removeAll()
   }
    
    func worstScore() -> Int {
        var retVal: Int = kNoneAvailable
        
        if let worstPerfIssue = getFirstPerfIssue() {
            retVal = worstPerfIssue.issueScore
        }
        
        return retVal
    }
    
    func averageScore(justForNotes: Bool) -> Double {
        var retVal: Double = Double(kNoneAvailable)
        
        var total: Double = 0.0
        if justForNotes {
            if justNotesPerfIssues.count > 0 {
                for onePerfIssue in perfIssues {
                    total += Double(onePerfIssue.issueScore)
                }
                retVal = total/Double(justNotesPerfIssues.count)
            }
        } else {    // Notes and Rests, too
            if perfIssues.count > 0 {
                for onePerfIssue in perfIssues {
                    total += Double(onePerfIssue.issueScore)
                }
                retVal = total/Double(perfIssues.count)
            }
        }
        
        return retVal
    }
    
    func createNoSoundIssue() {
        clearExisitingIssues()
        let perfIssue = PerfIssue(perfScoreObjID: 0)
        perfIssue.issueCode   = .noSound
        perfIssue.issueType   = .attack
        perfIssue.issueScore  = IssueWeight.kNoSound
        perfIssue.videoID     = mapPerfIssueToVideoID(perfIssue.issueCode)
        
        perfIssues.append(perfIssue)
        justNotesPerfIssues.append(perfIssue)
        
        sortedPerfIssues = perfIssues.sorted {
            let er0 = $0.issueScore, er1 = $1.issueScore
            return er0 > er1 ? true : false
        }
        sortedJustNotesPerfIssues = justNotesPerfIssues.sorted {
            let er0 = $0.issueScore, er1 = $1.issueScore
            return er0 > er1 ? true : false
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////
    // This func is the whole point of this file. Called after post-performance
    // grading has occured, to capture the issues (using the specified criteria) 
    // for each note and then sort the issues by severity. When finished,
    // sortedPerfIssues contains, from worst to least, any problems with the
    // performance.
    func scanPerfNotesForIssues(_ sortCrit: sortCriteria = .byIndividualRating ) {
        
        clearExisitingIssues()
        
        for onePerfScoreObj in PerformanceTrackingMgr.instance.perfNotesAndRests {
            let perfIssue =
                       scanPerfScoreObjForIssues( perfScoreObj: onePerfScoreObj,
                                                  sortCrit: sortCrit )
            perfIssues.append(perfIssue)
            
            if onePerfScoreObj.isNote() {
                justNotesPerfIssues.append(perfIssue)
            }
        }
        
        // Finally, sort the issues by score severity, highest score to lowest.
        // Note: sorted -> separate array, for debugging purposes. (Can look at 
        //       unsorted array as well if needed.)
        sortedPerfIssues = perfIssues.sorted {
            let er0 = $0.issueScore, er1 = $1.issueScore
            return er0 > er1 ? true : false
        }
        sortedJustNotesPerfIssues = justNotesPerfIssues.sorted {
            let er0 = $0.issueScore, er1 = $1.issueScore
            return er0 > er1 ? true : false
        }
    }
    
    // Can be called for single note/rest ("Ejector Seat"), as well as
    // in loop of scanPerfNotesForIssues method above
    func scanPerfScoreObjForIssues( perfScoreObj: PerformanceScoreObject,
                                    sortCrit: sortCriteria = .byIndividualRating )
        -> PerfIssue {
        var perfIssue = PerfIssue(perfScoreObjID: perfScoreObj.perfScoreObjectID)

        switch sortCrit {
        case .byAttackRating:
            perfIssue.issueCode  = perfScoreObj.attackRating
            perfIssue.issueScore = perfScoreObj.attackScore
            perfIssue.issueType  = .attack
        case .byDurationRating:
            perfIssue.issueCode  = perfScoreObj.durationRating
            perfIssue.issueScore = perfScoreObj.durationScore
            perfIssue.issueType  = .duration
        case .byAttackAndDurationRating:
            handle_ByAttackAndDurationRating( perfNote: perfScoreObj,
                                              perfIssue: &perfIssue )
        case .byPitchRating:
            perfIssue.issueCode  = perfScoreObj.pitchRating
            perfIssue.issueScore = perfScoreObj.pitchScore
            perfIssue.issueType  = .pitch
        case .byOverallRating:
            perfIssue.issueCode  = .cumulative
            perfIssue.issueScore = perfScoreObj.weightedScore
            perfIssue.issueType  = .overall
        case .byIndividualRating:
            handle_ByIndividualRating( perfNote: perfScoreObj,
                                       perfIssue: &perfIssue )
        }
        
        perfIssue.videoID = mapPerfIssueToVideoID(perfIssue.issueCode)
        if perfIssue.videoID == vidIDs.kVid_NoVideoAvailable {
            perfIssue.alertID = mapPerfIssueToAlertID( perfIssue.issueCode)
        }
            
        return perfIssue
    }
    
    // support method for scanPerfScoreObjForIssues method
    func handle_ByAttackAndDurationRating( perfNote: PerformanceScoreObject,
                                    perfIssue: inout PerfIssue ) {
        // return worst of attack or duration
        if perfNote.attackScore > perfNote.durationScore {
            perfIssue.issueCode  = perfNote.attackRating
            perfIssue.issueScore = perfNote.attackScore
            perfIssue.issueType  = .attack
        } else {
            perfIssue.issueCode  = perfNote.durationRating
            perfIssue.issueScore = perfNote.durationScore
            perfIssue.issueType  = .duration
        }
    }

    // support method for scanPerfScoreObjForIssues method
    func handle_ByIndividualRating( perfNote: PerformanceScoreObject,
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
    
    func setStarThresholds( fourStarMaxScore:  Int,
                            threeStarMaxScore: Int,
                            twoStarMaxScore:   Int,
                            oneStarMaxScore:   Int ) {
        starThresholds.fourStarMaxScore   = fourStarMaxScore
        starThresholds.threeStarMaxScore  = threeStarMaxScore
        starThresholds.twoStarMaxScore    = twoStarMaxScore
        starThresholds.oneStarMaxScore    = oneStarMaxScore
    }
    func setStarThresholds( thresholds: StarThresholds ) {
        starThresholds = thresholds
    }
    func getStarScoreForPerformanceAverage( perfAvg: Int ) -> Int {
        if perfIssues.count <= 0 {
            return kNoStars
        } else if perfAvg <= starThresholds.fourStarMaxScore {
            return kFourStars
        } else if perfAvg <= starThresholds.threeStarMaxScore {
            return kThreeStars
        } else if perfAvg <= starThresholds.twoStarMaxScore {
            return kTwoStars
        } else if perfAvg <= starThresholds.oneStarMaxScore {
            return kOneStar
        } else {
            return kNoStars
        }
    }
    func getStarScoreForPerformanceAverage( perfAvgFlt: Float ) -> Int {
        //var retVal = Int(round(floatScore))

        let avgAsInt = Int(round(perfAvgFlt))
        return getStarScoreForPerformanceAverage(perfAvg: avgAsInt)
    }
    
    func getStarScoreForMostRecentPerformance() -> Int {
        let avgScoreFlt = Float(averageScore(justForNotes: true))
        let starScoreInt = getStarScoreForPerformanceAverage( perfAvgFlt: avgScoreFlt)
        return starScoreInt
    }
    
    func getSeverity(issueScore: Int) -> Int {
        if issueScore <=  kGreenSeverityThreshold  {
            return kSeverityGreen
        } else if issueScore <= kYellowSeverityThreshold {
            return kSeverityYellow
        } else {
            return kSeverityRed
        }
    }
}


