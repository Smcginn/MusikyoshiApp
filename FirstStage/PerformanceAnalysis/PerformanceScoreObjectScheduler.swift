//
//  PerformanceScoreObjectScheduler
//  FirstStage
//
//  Created by Scott Freshour on 8/13/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

var gCurrNoteID = Int32(0)
let kWillEndSoonInterval = 0.005

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
                printNoteRelatedMsg(msg: "ACTIVATING ACTIVATING  PerfNote #\(perfScObj.perfNoteOrRestID), at \(currSongTime)\n")
//                let csid = PerfTrkMgr_CurrSoundID()
                printNoteInfo(perfNote: perfScObj)
//                print("\t\t(currSoundID == \(csid))")
            } else {
                printNoteRelatedMsg(msg: "Activating PerfRest #\(perfScObj.perfNoteOrRestID), at \(currSongTime)\n")
            }

            perfScObj.status = .active
            PerfTrkMgr.instance.perfNotesAndRests.append( perfScObj )
             if perfScObj.isNote() {
                PerfTrkMgr.instance.currentPerfNote = perfScObj as? PerformanceNote
                gCurrNoteID = perfScObj.perfNoteOrRestID
                PerfTrkMgr.instance.currentlyInAScoreNote = true
                PerfTrkMgr.instance.linkCurrSoundToCurrScoreObject(isNewScoreObject: true)
                
                if let currSound : PerformanceSound = PerformanceTrackingMgr.instance.currentSound {
                    if currSound.isLinkedToNote {
                        print("Activating Note #\(gCurrNoteID); curr sound \(currSound.soundID) is linked to Note")
                    } else {
                        print("Activating Note #\(gCurrNoteID); curr sound \(currSound.soundID) is NOT linked to Note")
                    }
                    gCurrSoundIsLinkedAndNewNoteStarted = currSound.isLinkedToNote
                }
//                else { // no current sound
//                    gCurrSoundIsLinkedAndNewNoteStarted = false
//                    gCurrSoundsLinkedNoteWillEndSoon    = false
//                    gCurrSoundsLinkedNoteIsEnded        = false
//                }
                

                
 //               PerfTrkMgr.instance.evaluateSkipWindows()
                
                
                // NS_1
                let elapsedTime = Date().timeIntervalSince(PerfTrkMgr.instance.songStartTime)
                let ampEvt = createNoteStartEvent( newNoteID: perfScObj.perfNoteOrRestID,
                                                   timestamp: elapsedTime)
                RTEventMgr.sharedInstance.addEntry( newEvent: ampEvt)
                
                let id = Int(perfScObj.perfNoteOrRestID)
                MusicXMLNoteTracker.instance.nowOnNote(noteID: id)
                
                let expDur = perfScObj.expectedDurAdjusted
                PerfTrkMgr.instance.setDurationOfCurrentNote(noteDur: expDur)

//                if gUseEighthIsSoundThresholdInGeneral   &&
//                   perfScObj.expectedDuration < kEighthIsSoundThresholdDurationCutoff {
//                     print (")))))))) Turning gUseEighthIsSoundThresholdNow  ON")
//                     gUseEighthIsSoundThresholdNow.set(1)
//                }
            } else {
                PerfTrkMgr.instance.currentPerfRest = perfScObj as? PerformanceRest
                PerfTrkMgr.instance.currentlyInAScoreRest = true
                PerfTrkMgr.instance.linkCurrSoundToCurrScoreObject(isNewScoreObject: false)
            }
            if tuneExerVC != nil {
                let perfID = perfScObj.perfScoreObjectID
                print ("\n  CURSOR MOVE: At \(currSongTime), for PerfObj #\(perfID), moving cursor to \(perfScObj.xPos)\n")
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
        
        if currSongTime + kWillEndSoonInterval > deactivateTime &&
           perfScObj.isNote()  {
            perfScObj.willEndSoon = true
        }
        
        if currSongTime > deactivateTime {    // perfScObj._deactivateTime_comp {
            var isGood = true
            if perfScObj.isNote() {
                gCurrNoteID = 0
                print("\n")
                printNoteRelatedMsg(msg: "DEACTIVATE DEACTIVATE   Attempting to deactivate PerfNote #\(perfScObj.perfNoteOrRestID), at \(currSongTime)\n")
//                let csid = PerfTrkMgr_CurrSoundID()
//                print("\t\t(currSoundID == \(csid))")
                printNoteInfo(perfNote: perfScObj)
                let currPerfNote = PerfTrkMgr.instance.currentPerfNote
                if currPerfNote != nil {
                    if doEjectorSeat {
                        // only do preformance analysis here if doing ejector
                        scanNoteForIssuesForEjection(perfNote: currPerfNote)
                    }
                    if currPerfNote!.perfNoteOrRestID == perfScObj.perfNoteOrRestID {
                        PerfTrkMgr.instance.checkCurrNoteForLinking()
                        PerfTrkMgr.instance.currentPerfNote = nil
                        PerfTrkMgr.instance.currentlyInAScoreNote = false
                    }
                }
                perfScObj.status = .ended
                let elapsedTime = Date().timeIntervalSince(PerfTrkMgr.instance.songStartTime)
                let ampEvt = createNoteEndEvent( noteID: perfScObj.perfNoteOrRestID,
                                                 timestamp: elapsedTime)
                RTEventMgr.sharedInstance.addEntry( newEvent: ampEvt)
                
                PerformanceTrackingMgr.instance.clearDurationOfCurrentNote()
                MusicXMLNoteTracker.instance.endingCurrentNote()

//                if gUseEighthIsSoundThresholdNow.get() > 0 {
//                    print (")))))))) Turning gUseEighthIsSoundThresholdNow  OFF")
//                    gUseEighthIsSoundThresholdNow.set(0)
//                }
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
    
    func scanNoteForIssuesForEjection(perfNote: PerformanceNote?) {
        guard doEjectorSeat && perfNote != nil else { return }

        let isGood = PerfTrkMgr.instance.analyzeOneScoreObject(perfScoreObj:perfNote!)
        if !isGood {
            let issue: PerfIssue =
                PerformanceIssueMgr.instance.scanPerfScoreObjForIssues(
                    perfScoreObj: perfNote!,
                    sortCrit: gPerfIssueSortCriteria )
            if issue.issueScore >= IssueWeight.kNoteDuringRest {
                print("\n   >>>>> Would have called Ejector Seat for Missed Note or Note During Rest\n")
            }
            if doEjectorSeat &&
                issue.issueScore > kStopPerformanceThreshold {
                tuneExerVC?.stopPlaying() // Ejector Seat !!!!
            }
        }
    }
}

func printNoteInfo(perfNote: PerformanceScoreObject) {
    guard let perfNote = perfNote as? PerformanceNote else {
        return
    }
    
    printNoteInfo(perfNote: perfNote)
 }

func printNoteInfo(perfNote: PerformanceNote) {
    guard perfNote.isNote() else {
        return
    }
    
    let noteID = perfNote.perfNoteOrRestID
    let attackTol = getRealtimeAttackTolerance(perfNote)
    let noteStartTime = perfNote.expectedStartTime
    let noteDuration  = perfNote.expectedDuration
    let noteEndTime   = perfNote.expectedEndTime
    let minAttackTime = noteStartTime - attackTol
    let maxAttackTime = noteStartTime + attackTol
    
    let soundStartOffset = getSoundStartOffset()
    let noteStartTimeComp = noteStartTime + soundStartOffset
    let noteEndTimeComp = noteEndTime + soundStartOffset

    print("For Note #\(noteID)")
    print("  Start Time: \(noteStartTime),       Attack Tolereance: \(attackTol)")
    print("  Duration:   \(noteDuration),       End Time: \(noteEndTime)")
    print("    ('Compenstated' Start Time:  \(noteStartTimeComp))")
    print("    ('Compenstated' End Time:    \(noteEndTimeComp))")

    print("  Min Attack Time: \(minAttackTime)")
    print("  Max Attack Time: \(maxAttackTime)")
}


