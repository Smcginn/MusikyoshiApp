//
//  PerformanceScoreObjectScheduler
//  FirstStage
//
//  Created by Scott Freshour on 8/13/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

typealias PerfScoreObjScheduler = PerformanceScoreObjectScheduler

class PerformanceScoreObjectScheduler {
    
    static let instance = PerformanceScoreObjectScheduler()
    
    var tuneExerVC: TuneExerciseViewController? = nil
    func setVC(vc: TuneExerciseViewController?) {
        tuneExerVC = vc
    }

    var activePerfScoreObjects: [PerformanceScoreObject] = []
    
    func addPerfScoreObj( perfScoreObj: PerformanceScoreObject) {
        activePerfScoreObjects.append(perfScoreObj)
    }
    
    func clearEntries() {
        activePerfScoreObjects.removeAll()
    }
    
    func inspectPerfScoreObjectsForTransitions() {
        let startCount = activePerfScoreObjects.count
        var index = 0
        for onePSO in activePerfScoreObjects {
            switch onePSO.status {
            case .pendingStart:  checkStartTimeForActivating(perfScObj: onePSO)
            case .active:        checkTimeForDeactivating(perfScObj: onePSO)
            case .ended:         break
            }
            index += 1
        }
        if index != startCount {
            print ("PROBLEM: index != startCount in inspectPerfScoreObjectsForTransitions() !!!! ")
        }
        // See if any active pso's transitioned to ended
        index = 0
        for onePSO in activePerfScoreObjects {
            if onePSO.status == .ended {
                activePerfScoreObjects.remove(at: index)
                break
           }
           index += 1
        }
    }
        
    func checkStartTimeForActivating(perfScObj: PerformanceScoreObject) {
        // Must wait until the song started to schedule a note.
        guard PerfTrkMgr.instance.songStarted else { return }
        
        guard perfScObj.status == .pendingStart else {
            print("Something screwed up in PSTMgr: PendingObject is not .pendingStart")
            return
        }
        
        guard !perfScObj.completed else {
            print("Something screwed up in PSTMgr: PendingObject is completed")
            return
        }

        let currSongTime = currentSongTime()
        if currSongTime > perfScObj.expectedStartTime {
            print("\n")
            if perfScObj.isNote() {
                printNoteRelatedMsg(msg: "Activating PerfNote #\(perfScObj.perfNoteOrRestID), at \(currSongTime)\n")
            } else {
                printNoteRelatedMsg(msg: "Activating PerfRest #\(perfScObj.perfNoteOrRestID), at \(currSongTime)\n")
            }

            perfScObj.status = .active
            PerfTrkMgr.instance.perfNotesAndRests.append( perfScObj )
             if perfScObj.isNote() {
                PerfTrkMgr.instance.currentPerfNote = perfScObj as? PerformanceNote
                PerfTrkMgr.instance.currentlyInAScoreNote = true
                PerfTrkMgr.instance.linkCurrSoundToCurrScoreObject(isNewScoreObject: true)
            } else {
                PerfTrkMgr.instance.currentPerfRest = perfScObj as? PerformanceRest
                PerfTrkMgr.instance.currentlyInAScoreRest = true
                PerfTrkMgr.instance.linkCurrSoundToCurrScoreObject(isNewScoreObject: false)
            }
            if tuneExerVC != nil {
                tuneExerVC!.drawCurrNoteLineAt(xPos: CGFloat(perfScObj.xPos))
            }
        }
    }
    
    func checkTimeForDeactivating(perfScObj: PerformanceScoreObject) {
        guard perfScObj.status == .active,
             !perfScObj.completed     else {
                 print("Something screwed up in PSTMgr: PendingObject is not active")
                 return }
        
        let currSongTime = currentSongTime()
        let deactivateTime = perfScObj.isNote() ? perfScObj._deactivateTime_comp
                                                : perfScObj._deactivateTime_comp
        if currSongTime > deactivateTime {    // perfScObj._deactivateTime_comp {
            var isGood = true
            if perfScObj.isNote() {
                print("\n")
                printNoteRelatedMsg(msg: "Attempting to deactivate PerfNote #\(perfScObj.perfNoteOrRestID), at \(currSongTime)\n")
                let currPerfNote = PerfTrkMgr.instance.currentPerfNote
                if currPerfNote != nil {
                    isGood = PerfTrkMgr.instance.analyzeOneScoreObject(perfScoreObj:currPerfNote!)
                    if !isGood {
                        let issue: PerfIssue =
                            PerformanceIssueMgr.instance.scanPerfScoreObjForIssues(
                                perfScoreObj: currPerfNote!,
                                sortCrit: gPerfIssueSortCriteria )
                        if issue.issueScore >= IssueWeight.kNoteDuringRest {
                            print("\n   >>>>> Would have called Ejector Seat for Missed Note or Note During Rest\n")
                        }
                        if doEjectorSeat &&
                           issue.issueScore > kStopPerformanceThreshold {
                            tuneExerVC?.stopPlaying() // Ejector Seat !!!!
                        }
                    }
                    if currPerfNote!.perfNoteOrRestID == perfScObj.perfNoteOrRestID {
                        PerfTrkMgr.instance.currentPerfNote = nil
                        PerfTrkMgr.instance.currentlyInAScoreNote = false
                    }
                }
                perfScObj.status = .ended
            } else { // it's a rest
                print("\n")
                printNoteRelatedMsg(msg: "Attempting to deactivate PerfRest #\(perfScObj.perfNoteOrRestID), at \(currSongTime)\n")
                let currPerfRest = PerfTrkMgr.instance.currentPerfRest
                if currPerfRest != nil {
                    isGood = PerfTrkMgr.instance.analyzeOneScoreObject(perfScoreObj:currPerfRest!)
                    if !isGood {
                        let issue: PerfIssue =
                            PerformanceIssueMgr.instance.scanPerfScoreObjForIssues(
                                perfScoreObj: currPerfRest!,
                                sortCrit: gPerfIssueSortCriteria )
                        if doEjectorSeat &&
                           issue.issueScore > kStopPerformanceThreshold {
                            tuneExerVC?.stopPlaying() // Ejector Seat !!!!
                        }
                    }
                    if currPerfRest!.perfNoteOrRestID == perfScObj.perfNoteOrRestID {
                        PerfTrkMgr.instance.currentPerfRest = nil
                        PerfTrkMgr.instance.currentlyInAScoreRest = false
                    }
                }
                perfScObj.status = .ended
            }
        }
    }
}
