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
            // See if any active pso's transitioned to ended
            if onePSO.status == .ended {
                activePerfScoreObjects.remove(at: index)
            }
            index += 1
        }
        if index != startCount {
            print ("PROBLEM: index != startCount in inspectPerfScoreObjectsForTransitions() !!!! ")
        }
    }
        
    func checkStartTimeForActivating(perfScObj: PerformanceScoreObject) {
        // Must wait until the song started to schedule a note.
        guard PerfTrkMgr.instance.songStarted,
              perfScObj.status == .pendingStart,
              !perfScObj.completed     else {
                  print("Something screwed up in PSTMgr: PendingObject is completed")
                  return }
        
        let currSongTime = currentSongTime()
        if currSongTime > perfScObj.expectedStartTime {
            if perfScObj.isNote() {
                print ("Activating PerfNote #\(perfScObj.perfNoteOrRestID), at \(currSongTime)")
            } else {
                print ("Activating PerfRest #\(perfScObj.perfNoteOrRestID), at \(currSongTime)")
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
        if currSongTime > perfScObj._deactivateTime {
            if perfScObj.isNote() {
                print ("Attempting to deactivate PerfNote #\(perfScObj.perfNoteOrRestID), at \(currSongTime)")
                if let currPerfNote = PerfTrkMgr.instance.currentPerfNote {
                    if currPerfNote.perfNoteOrRestID == perfScObj.perfNoteOrRestID {
                        PerfTrkMgr.instance.currentPerfNote = nil
                        PerfTrkMgr.instance.currentlyInAScoreNote = false
                    }
                }
                perfScObj.status = .ended
            } else {
                print ("Attempting to deactivate PerfRest #\(perfScObj.perfNoteOrRestID), at \(currSongTime)")
                if let currPerfRest = PerfTrkMgr.instance.currentPerfRest {
                    if currPerfRest.perfNoteOrRestID == perfScObj.perfNoteOrRestID {
                        PerfTrkMgr.instance.currentPerfRest = nil
                        PerfTrkMgr.instance.currentlyInAScoreRest = false
                    }
                }
                perfScObj.status = .ended
            }
        }
    }
}
