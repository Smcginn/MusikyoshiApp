//
//  PerformanceTrackingMgr.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/11/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//
//    [Some of this code was originaly commited in StudentPerfomanceData.swift 
//    (which I've now deleted), which was created on 11/6/17.]

import Foundation

//   SCFTODO
//
// - When playing legato, and a new note is detected by pitch change, should the
//   old sound provide the dif samples for the new sound?
// 
// - change performanceSounds to non-optionals ?

///////////////////////////////////////////////////////////////////////////////
//  Issues to be aware of for post alpha
//      - The functions below that convert MusicXML durations/start times accept
//        BPM and beats per measure, etc. At a meta level, the use of
//        these funtions is correct as long as the Tempo and Meter (beats
//        per measure) are constant throughout the song.
//
//        If we add songs that vary the tempo or meter, then other vars (at
//        a higher level, within the caller of these funcs) will need to be
//        added to store the interval up to the beginning of a specific
//        bar, etc. Also, the funcs will need to be adjusted as well.
//

// So other code can use much shorter "PerfTrkMgr.instance" instead of unmanagable
// "PerformanceTrackingMgr.instance"
typealias PerfTrkMgr = PerformanceTrackingMgr

class PerformanceTrackingMgr {

    // PerformanceTrackingMgr keeps track of:
    //
    //    PerfNotesAndRests: there is one of these for every note or rest in the
    //       score. A PerformanceNoteOrRest contains the expectatations and the actual
    //       values of the studuent's performance for things like start time and
    //       duration, and for notes, pitch, etc.
    //
    //    PerformanceSounds: every sound that is made by the student is represented
    //       by one of these; they contain start time, pitch, duration, etc.
    //
    //    If a PerformanceSound occurs within the expected timing window of a 
    //    PerformanceNote, the two will be linked (at the moment this based
    //    entirely on the timing threshold); the PerformanceSound's data is used
    //    for the  "actual" values of the PerformanceNote.
    //
    //    If a PerformanceSound is not linked to a PerformanceNote, it's possible 
    //    to give feedback on timing issues (not implemented yet).
    
    static let instance = PerformanceTrackingMgr()

    // When modified so thresholds are reset with level advancement, these need to
    // be changed to vars, and reset at that time as well.
    let rhythmAnalyzer = NoteRhythmPerformanceAnalyzer.init()
    var pitchAnalyzer  = BrassPitchPerformanceAnalyzer.init()    
    let restAnalyzer   = RestPerformanceAnalyzer.init()
    var sampleAmplitudeTrkr: PerfSampleAmplitudeTrackerV2

    init() {
        let currInst = getCurrentStudentInstrument()
        setCurrentAmpRiseValsForInstrument(forInstr: currInst)
        sampleAmplitudeTrkr = PerfSampleAmplitudeTrackerV2()

        userDefsTimingThreshold =
            UserDefaults.standard.double(forKey: Constants.Settings.TimingThreshold)
        if UIDevice.current.modelName == "Simulator" {
            print("In Simulator")
            kRunningInSim = true
            kAmplitudeThresholdForIsSound = kAmpThresholdForIsSound_Sim
            kSoundStartAdjustment = kSoundStartAdjustment_Sim
            kMetronomeTimingAdjustment = kMetronomeTimingAdjustment_Sim
            gAmplitudePrintoutMultiplier = kAmplitudePrintoutMultiplier_Sim
            kRunningInSim = true
        } else {
            print("In Real Device")
            kRunningInSim = false
            kAmplitudeThresholdForIsSound = kAmpThresholdForIsSound_HW
            kSoundStartAdjustment = kSoundStartAdjustment_HW
            kMetronomeTimingAdjustment = kMetronomeTimingAdjustment_HW
            gAmplitudePrintoutMultiplier = kAmplitudePrintoutMultiplier_HW
            kRunningInSim = false
        }
        
        let storedIsASoundThreshold =
            UserDefaults.standard.double(forKey: Constants.Settings.UserNoteThresholdOverride)
        if storedIsASoundThreshold > 0.01 {  // it's been set if not == 0.0
            kAmplitudeThresholdForIsSound = storedIsASoundThreshold
        }
        
        // sampleAmplitudeTrkr.testBuffer()
    }

    ///////////////////////////////////////////////////////////////////////////
    //
    //  MARK: -     PerformanceNote and PerformanceRest related
    //
    ///////////////////////////////////////////////////////////////////////////
    
    // Container of Expected Notes. These are created as a note appears in the 
    // score, and the "expectations" and "reality" are stored here. If there was 
    // a Sound that started within the Note's expected start window (and it's not 
    // already linked to another Note), the Note and the Sound are linked. The 
    // Sound's data is the basis for the "reality" portion, and can be compared 
    // to the expectations for the given note.
    var perfNotesAndRests = [PerformanceScoreObject]()
    
    // If there is a current active Note from the score (that the student should 
    // be playing) these will be set (cleared when the Note ends, set for the next 
    // note, etc.)
    public weak var currentPerfNote : PerformanceNote?
    var currentlyInAScoreNote = false
    public weak var currentPerfRest : PerformanceRest?
    var currentlyInAScoreRest = false

    ///////////////////////////////////////////////////////////////////////////
    //
    //  MARK: -    PerformanceSound related
    //
    ///////////////////////////////////////////////////////////////////////////
    
    // To be able to trigger one of the "No Sound" videos
    var doDetectedDuringPerformance     = true
    var signalDetectedDuringPerformance = false
    var perfLongEnoughToDetectNoSound   = false
    
    // Container of Sounds as they occured in real time. (A Sound may or may not be
    // linked to Note.)
    var performanceSounds = [PerformanceSound?]()
    
    // If there is a current active Sound, these will be set (cleared when the Sound
    // ends, set for the next Sound, etc.)
    public weak var currentSound : PerformanceSound?
    var currentlyTrackingSound = false

    // Create a new PerformanceSound and add it to collection of sounds
    @discardableResult
    func startTrackingPerformanceSound( startAt: TimeInterval,
                                        soundMode: soundType,
                                        noteOffset: TimeInterval )
        -> (PerformanceSound?) {
            
            guard (!currentlyTrackingSound) else { return nil }
            let newSound : PerformanceSound? =
                                PerformanceSound.init(start: startAt,
                                                      mode:soundMode,
                                                      noteOffset: noteOffset)
            guard newSound != nil  else {return nil}
            
            currentSound = newSound
            performanceSounds.append(newSound!)
            currentlyTrackingSound = true
            
            return newSound
    }

    // End current sound if signal stopped.  (Non-legato note change)
    // soundEndTime is in SoundTime, not SongTime
    func endTrackedSoundAsSignalStopped(soundEndTime: TimeInterval,
                                        noteOffset: TimeInterval ) {
        guard currentlyTrackingSound,
              let currSound = currentSound   else { return }
        
        currSound.setEndTimeAbs(endTimeAbs: soundEndTime)
        
        if let soundsNote = currSound.linkedNoteObject {
            soundsNote.setActualEndTimeAbs( endTimeAbs: soundEndTime )
        }
        print("\n")
        printSoundRelatedMsg(msg: "Sound #\(currSound.soundID) stopped bc sound stopped at (comp) \(currSound._endTime_comp)\n")
        currSound.printSoundResults()
        currentSound = nil
        currentlyTrackingSound = false
    }

    // End current sound if new note detected while playing legato
    // - param splitTime: on return, set to when the old note ended and the new note started
    func endCurrSoundAsNewPitchDetected( noteOffset: TimeInterval,
                                         splitTime: inout TimeInterval ) {
        guard currentlyTrackingSound, let currSound = currentSound else { return }
        
        splitTime = currSound.diffPitchSplitTime // end of old, start of new
        currSound.setEndTimeAbs(endTimeAbs: splitTime)

        if let soundsNote = currSound.linkedNoteObject {
            soundsNote.setActualEndTimeAbs( endTimeAbs: splitTime )
        }
        
        // stop current sound
        currSound.printSoundResults()
        currentSound = nil
        currentlyTrackingSound = false
    }
    
    ///////////////////////////////////////////////////////////////////////////
    // MARK: - Amplitude tracking
    
    func addAmplitudeValue( ampVal: tSoundAmpVal, absTime: TimeInterval ) {
        sampleAmplitudeTrkr.enqueue(ampVal, absTime)
    }
    
    // returns true if should stop the current sound, and create a new one
    func isANewNoteBCofAmpChange() -> Bool {
        //return sampleAmplitudeTrkr.isDiffNoteBCofAmpChange()
        return sampleAmplitudeTrkr.doCreateNewSound
    }
    
    // returns true if should stop the current sound, and signal is
    // not strong enough for new sound
    func isDeadSound() -> Bool {
        return sampleAmplitudeTrkr.isDiffNoteBCofAmpChange()
    }
    
    func resetAmpTracker() {
        sampleAmplitudeTrkr.reset()
    }
    
    func currentSoundWillEnd() -> Bool {
        return sampleAmplitudeTrkr.currSoundIsDead
    }
    
    func currentSoundFinished() -> Bool {
        return sampleAmplitudeTrkr.finished
    }
    
    var pitchForNewSound: Double = 0.0
    
    var absTimeForNewSound: Double {
        return sampleAmplitudeTrkr.killSoundTime
    }
    
    ///////////////////////////////////////////////////////////////////////////
    //
    // MARK: - Misc Vars, Settings for determining begin/end of sound, etc.
    //
    // Vars/settings relating to the beginning of analysis, and the start of
    // song playback (slightly different times). These are used for determining
    // beginning and end of a Sound, and therefore, if a Note is linked to a
    // Sound, the beginning and suration of a Note.
    //
    ///////////////////////////////////////////////////////////////////////////
    
    // Note startTime is relative to songStart;
    // Sound startTime is relative to analysis Start.
    //    (Two are necessary to be able to determine if first note is played early)
    var soundToNoteOffset : TimeInterval = 0.0
    
    // Needed by student Note and Sound Performance data and methods
    var songStartTime : Date = Date()
    
    var songStarted = false
    
    // For setting start time of note, adjusting for:
    //      note startTime is relative to songStart;
    //      sound startTime is relative to analysis Start.
    func soundTimeToNoteTime( songStart: TimeInterval ) -> TimeInterval {
        return songStart - songStartTimeOffset
    }
    
    var songStartTimeOffset : TimeInterval = 0.0
    
    // Used to determine rhythmic accuracy. (This is the Orignal First Stage 
    // stuff; perhaps change to timing zones, similar to the pitch zones.)
    var userDefsTimingThreshold: Double
    
    var currTempoBPM:    Int = 60
    var currBeatsPerBar: Int = 4
    var currOneBarLen:   Int = 4
    var qtrNoteTimeInterval: TimeInterval = 1.0
    
    func setPlaybackVals( tempoInBPM: Int,   beatsPerBar: Int,
                          lenOneBeat: Int,   lenOneBar:   Int )
    {
        currTempoBPM    = tempoInBPM
        currBeatsPerBar = beatsPerBar
        currOneBarLen   = lenOneBar
        let bpmRatio: TimeInterval = secsPerMin / TimeInterval(tempoInBPM)
        qtrNoteTimeInterval = TimeInterval(1.0) * bpmRatio
    }
    
    ///////////////////////////////////////////////////////////////////////////
    //
    //  MARK: -      Miscellaneous funcs . . .
    //
    ///////////////////////////////////////////////////////////////////////////
    
    // If starting a new performance (e.g., Press Play), clear data from last one
    func resetSoundAndNoteTracking() {
        currentPerfNote = nil
        currentSound = nil
        perfNotesAndRests.removeAll()
        performanceSounds.removeAll()
        PerformanceSound.resetUniqueSoundID()
        PerformanceScoreObject.resetUniqueIDs()
        currentlyInAScoreNote  = false
        currentlyTrackingSound = false
    }
    
    // called when a new sound is detected, to see if an existing note needs a sound
    func linkCurrSoundToCurrNote() {

        print ("Link Sound to Note - in version 1")

        guard let currPerfNote : PerformanceNote = currentPerfNote
            else { return }

        guard currentlyInAScoreNote && currentlyTrackingSound else { return }
        guard let currSound : PerformanceSound = currentSound else { return }
        guard !currSound.isLinkedToNote && !currPerfNote.isLinkedToSound else { return }
        
        let diff = abs( currSound.startTime_comp - currPerfNote.expectedStartTime  )
        let attackTol = PerformanceAnalysisMgr.instance.currTolerances.rhythmTolerance
        print("   SO to NO Linking: For Note \(currPerfNote.perfNoteOrRestID), exp/act start diff = \(diff), attackTol = \(attackTol)")
        if (diff <= attackTol) {
            currPerfNote.linkToSound(soundID: currSound.soundID, sound: currSound)
            currSound.linkToNote(noteID: currPerfNote.perfNoteOrRestID, note: currPerfNote)
            currPerfNote.actualStartTime_song = currSound.startTime_song
            currPerfNote.actualFrequency      = currSound.averagePitchRunning
        }
    }
    
  
    // called when either a new note or rest begins in the score, or new sound is detected
    func linkCurrSoundToCurrScoreObject(isNewScoreObject: Bool) {
        
        print("\n")
        if isNewScoreObject {
            printLinkingRelatedMsg(msg: "SO to SC Linking: New Note or Rest, looking for Sound")
        } else {
            printLinkingRelatedMsg(msg: "SO to SC Linking: New Sound, looking for Note or Rest")
        }
        
        // Confirm in A Sound, we can get it, and it is not already linked
        guard currentlyTrackingSound   else {
            printLinkingRelatedMsg(msg: "    - rejecting; not currently Tracking Sound\n");     return
        }
        guard let currSound : PerformanceSound = currentSound   else {
            printLinkingRelatedMsg(msg: "    - rejecting; cannot get currSound\n");       return
        }
        guard !(currSound.isLinkedToNote || currSound.isLinkedToRest)   else {
            printLinkingRelatedMsg(msg: "    - rejecting; currSound already Linked to Note or Rest\n");  return
        }
        
        // Confirm in a Note or Rest
        guard (currentlyInAScoreNote || currentlyInAScoreRest) else {
            printLinkingRelatedMsg(msg: "    - rejecting; not in a current Note or Rest\n");  return
        }

        if currentlyInAScoreNote {
            guard let currPerfNote : PerformanceNote = currentPerfNote else {
                printLinkingRelatedMsg(msg: "    - rejecting; cannot get current Note\n");   return
            }
            guard !currPerfNote.isLinkedToSound   else {
                printLinkingRelatedMsg(msg: "    - rejecting; currPerfNote already Linked to Sound\n");  return
            }
            
            let diff = abs( currSound.startTime_comp - currPerfNote.expectedStartTime  )
            let attackTol = PerformanceAnalysisMgr.instance.currTolerances.rhythmTolerance
            printLinkingRelatedMsg(msg: "SO to SC Linking: For Sound \(currSound.soundID), StartTime_song =  \(currSound.startTime_comp)")
            printLinkingRelatedMsg(msg: "SO to SC Linking: For Note  \(currPerfNote.perfNoteOrRestID), exp/act start diff = \(diff), attackTol = \(attackTol)")

            if (diff <= attackTol) {
                printLinkingRelatedMsg(msg: "SO to SC Linking: -> Note LINKED !\n")
                currPerfNote.linkToSound(soundID: currSound.soundID, sound: currSound)
                currSound.linkToNote(noteID: currPerfNote.perfNoteOrRestID, note: currPerfNote)
                currPerfNote.actualStartTime_song = currSound.startTime_song
                currPerfNote.actualFrequency = currSound.averagePitchRunning
            } else {
                printLinkingRelatedMsg(msg: "SO to SC Linking:   -> Rejecting, bc (diff <= attackTol)")
            }
        }
        
        else if currentlyInAScoreRest {
            guard let currPerfRest: PerformanceRest = currentPerfRest else {
                printLinkingRelatedMsg(msg: "    - rejecting; cannot get current Rest\n");   return
            }
            guard !currPerfRest.isLinkedToSound   else {
                printLinkingRelatedMsg(msg: "    - rejecting; currPerfRest already Linked to Sound\n");  return
            }
            printLinkingRelatedMsg(msg: "SO to SC Linking: rest's expectedEndTime: \(currPerfRest.expectedEndTimeMinusTolerance)")
            printLinkingRelatedMsg(msg: "SO to SC Linking: rest's  deactivateTime_comp: \(currPerfRest._deactivateTime_comp)")
            printLinkingRelatedMsg(msg: "SO to SC Linking: sound's cpmensated start time: \(currSound.startTime_comp)")
            
            currPerfRest.linkToSound(soundID: currSound.soundID, sound: currSound)
            printLinkingRelatedMsg(msg: "SO to SC Linking: -> Rest LINKED !  (not good)\n")
        }
        print("\n")
	}
    
    // called periodically to update sound with current average pitch, etc. Also, 
    // (if Sound linked to a Note) always called when a Sound ends, to update 
    // linked Note.
    func updateCurrentNoteIfLinked()
    {
        // Should actually do this directly through the Sound's LinkedNote optional?
        guard let currSound = currentSound else {return}
        currSound.updateCurrentNoteIfLinkedFinal()
    }
    
    func repairCurrentSoundIfNeeded() {
        if currentlyTrackingSound && currentSound != nil {
            currentSound!.makeAdjustmentsAfterSongStart()
        }
    }
    
    func analyzeOneScoreObject(perfScoreObj: PerformanceScoreObject) -> Bool {
        var retVal = true
    
        if perfScoreObj.isNote() {
            rhythmAnalyzer.resetAverages()
            rhythmAnalyzer.analyzeScoreObject( perfScoreObject: perfScoreObj )
            pitchAnalyzer.analyzeScoreObject( perfScoreObject: perfScoreObj )
        }
            
        else if perfScoreObj.isRest() {
            restAnalyzer.analyzeScoreObject( perfScoreObject: perfScoreObj )
        }

        if perfScoreObj.weightedScore > 5 {
            retVal = false
        }
        
        return retVal
    }
    
    // Do post-performance analysis and grading: Pitch and Rhythm accuracy
    func analyzePerformance() {

        if doDetectedDuringPerformance && !signalDetectedDuringPerformance {
            PerformanceIssueMgr.instance.createNoSoundIssue()
            print ( "\n--------------------------")
            print ( "  No Signal was detected . . . ")
            print ( "--------------------------\n")
            return
        }
        
        
        // Uncomment this to test Partial lookup
//        runPreAnalysisPartialTestingSetup()
        
        // Visit each Note, have analyzers grade and rate performance of that
        // Note compared with expectations
        rhythmAnalyzer.resetAverages()
        resetAttackDiffs()
        for onePerfScoreObj in perfNotesAndRests {
            onePerfScoreObj.weightedScore = 0
            if onePerfScoreObj.isNote() {
                rhythmAnalyzer.analyzeScoreObject( perfScoreObject: onePerfScoreObj )
                pitchAnalyzer.analyzeScoreObject( perfScoreObject: onePerfScoreObj )
            }
            
            else if onePerfScoreObj.isRest() {
                restAnalyzer.analyzeScoreObject( perfScoreObject: onePerfScoreObj )
             }
        }
        addCurrAttackDiffAvgToRunningAvg()
        
        // VIDREDO
        PerformanceIssueMgr.instance.scanPerfNotesForIssues( gPerfIssueSortCriteria )

        if kMKDebugOpt_PrintPerfAnalysisResults {
            print ( "\nPerformance Results:\n")
            for onePerfScoreObj in perfNotesAndRests {
                if onePerfScoreObj.isNote() {
                    guard let onePerfNote: PerformanceNote = onePerfScoreObj as? PerformanceNote
                        else { continue }
                    print ( "--------------------------")
                    print ( " Note #\(onePerfNote.perfNoteOrRestID):" )
                    print ( "   Attack rating:   \(onePerfNote.attackRating)" )
                    print ( "   Duration rating: \(onePerfNote.durationRating)" )
                    print ( "   Pitch rating:    \(onePerfNote.pitchRating)" )
                    print ( "   Weighted rating: \(onePerfNote.weightedScore)" )
                }
                // else RESTCHANGE
            }
        }
        
        let kMKDebugOpt_PrintNoteAndRestSummary = true
        if kMKDebugOpt_PrintNoteAndRestSummary {
            print ( "==================================================")
            print ( "\nNote and Rest Performance Summary:\n")
            for onePerfScoreObj in perfNotesAndRests {
                let isLinked = onePerfScoreObj.isLinkedToSound
                let isLinkedStr = isLinked
                    ?    "   Is Linked To Sound:              YES"
                    :    "   Is Linked To Sound:              NO"
                print ( "\n==================================================")
                if onePerfScoreObj.isNote() {
                    guard let onePerfNote: PerformanceNote = onePerfScoreObj as? PerformanceNote
                        else { continue }
                    print ( " Note #\(onePerfNote.perfNoteOrRestID):" )
                    print ( "   Expected StartTime:   \(onePerfNote.expectedStartTime)" )
                    if isLinked {
                        let formattedActTime = String(format: "%.4f", onePerfNote._actualStartTime_comp)
                        print ( "   Act, Comp StartTime:  \(formattedActTime)" )
                    }
                    print ( "   Expected EndTime:     \(onePerfNote.expectedEndTime)" )
                    print ( "   Expected Duration:    \(onePerfNote._expectedDuration)" )
                    print ( "   Comp Deactivate Time: \(onePerfNote._deactivateTime_comp)" )
                    print (isLinkedStr)
                    if isLinked {
                        print ( "     Attack rating:   \(onePerfNote.attackRating)" )
                        print ( "     Duration rating: \(onePerfNote.durationRating)" )
                        print ( "     Pitch rating:    \(onePerfNote.pitchRating)" )
                        print ( "     Weighted rating: \(onePerfNote.weightedScore)" )
                    }
                } else { // is Rest
                    guard let onePerfRest: PerformanceRest = onePerfScoreObj as? PerformanceRest
                        else { continue }
                    print ( " Rest #\(onePerfRest.perfNoteOrRestID):" )
                    print ( "   Expected StartTime:   \(onePerfRest.expectedStartTime)" )
                    print ( "   Expected EndTime:     \(onePerfRest.expectedEndTime)" )
                    print ( "   Exp End Time w/Tol:   \(onePerfRest._expectedEndTimeMinusTolerance)" )
                    print ( "   Comp Deactivate Time: \(onePerfRest._deactivateTime_comp)" )
                    print ( isLinkedStr )
                }
            }
            print ( "==================================================\n\n")
        }
    }
    
    func printSoundSamplesForNote(_ act: UIAlertAction) {
        let possibleScoreObj: PerformanceScoreObject? =
            findPerformanceScoreObjByID(perfScoreObjID: storedNoteID)
        guard let scoreObj = possibleScoreObj else { return }
        
        if scoreObj.isNote() {
            let noteObj = scoreObj as! PerformanceNote
            noteObj.printSoundsSamplesDetailed()
        }
    }
    
    var storedNoteID: Int32 = 0
    
    // Pops up an Alert with the details of the Performed Note's accuracy.
    //   This is intended for debugging, or to show what can potentially be 
    //   displayed. Not for user consumption.
    func displayPerfInfoAlert( perfNoteID: Int32,
                               parentVC: UIViewController ) {
        storedNoteID = 0
        let possibleScoreObj: PerformanceScoreObject? =
            findPerformanceScoreObjByID(perfScoreObjID: perfNoteID)
        guard let scoreObj = possibleScoreObj else { return }
        
        var msgStr: String = ""
        var titleStr: String = ""
        if scoreObj.isNote() {
            titleStr = "Info for Note  \(scoreObj.perfNoteOrRestID)"
        } else {
            titleStr = "Info for Rest  \(scoreObj.perfNoteOrRestID)"
        }
        scoreObj.constructSummaryMsgString( msgString: &msgStr )
        
        let alert = MyUIAlertController( title: titleStr,
                                       message: msgStr,
                                       preferredStyle: .alert )
        
        // Adjust Alert Message txt to use Courier font and left justification.
        // (The examples I found did this *after* adding the text to the alert;
        // not sure this is absolutely necessary.)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        let fnt = UIFont (name: "Courier", size: 12.0)
        let messageText = NSMutableAttributedString(
            string: msgStr,
            attributes: [
                NSAttributedStringKey.paragraphStyle: paragraphStyle
            ]
        )
        messageText.addAttribute(NSAttributedStringKey.font,
                                 value:fnt!,
                                 range: NSRange.init(location: 0,
                                                     length: msgStr.count))
        alert.setValue(messageText, forKey: "attributedMessage")
        
        // Add the OK button
        let action = UIAlertAction( title: "OK",
                                    style: .cancel,
                                    handler: nil )
        alert.addAction(action)
        if scoreObj.isNote() {
            storedNoteID = perfNoteID
            let action2 = UIAlertAction( title: "Print Samples",
                                        style: .default,
                                        handler: printSoundSamplesForNote )
            alert.addAction(action2)
        }
        parentVC.present( alert, animated:true, completion: nil)
    }

    ///////////////////////////////////////////////////////////////////////////
    //
    //  MARK: -      Funcs for finding a Sound or a Note in arrays,
    //               using various criteria
    //
    ///////////////////////////////////////////////////////////////////////////
    
    func findSoundBySoundID(soundID: Int32) -> PerformanceSound? {
        
        var returnSound : PerformanceSound? = nil
        
        // SCFTODO - change to Filter->Set pattern?
        for oneSound in performanceSounds {
            let oneSound = oneSound
            let thisID = oneSound?.soundID
            if ( thisID == soundID) {
                returnSound = oneSound
                break;
            }
        }
        
        return returnSound
    }

    func findPerformanceScoreObjByID(perfScoreObjID: Int32) -> PerformanceScoreObject? {
        var returnScoreObj : PerformanceScoreObject? = nil
        for onePerfObj in perfNotesAndRests {
            if ( onePerfObj.perfScoreObjectID == perfScoreObjID ) {
                returnScoreObj = onePerfObj
                break;
            }
        }
        return returnScoreObj
    }
    
    func findPerformanceNoteByStartTime(start: TimeInterval) -> PerformanceNote? {
        
        var returnNote : PerformanceNote? = nil
        
        let lowBound  = start - userDefsTimingThreshold
        let highBound = start + userDefsTimingThreshold
        
        for onePerfObj in PerformanceTrackingMgr.instance.perfNotesAndRests {
            guard let onePerformanceNote: PerformanceNote =
                onePerfObj as? PerformanceNote else { continue }
            
            let expStart = onePerformanceNote.expectedStartTime
            if ( expStart >= lowBound && expStart <= highBound ) {
                returnNote = onePerformanceNote
                break;
            }
        }
        
        return returnNote
    }

    func findPerformanceNoteByXPos(xPos: Int32) -> PerformanceNote? {
        
        var returnNote : PerformanceNote? = nil
        
        let lowBoundXpos  = xPos - 10
        let highBoundXpos = xPos + 10
        
        for onePerfObj in PerformanceTrackingMgr.instance.perfNotesAndRests {
            guard let onePerformanceNote: PerformanceNote =
                onePerfObj as? PerformanceNote else { continue }
            
            let xPos = onePerformanceNote.xPos
            if ( xPos >= lowBoundXpos && xPos <= highBoundXpos ) {
                returnNote = onePerformanceNote
                break;
            }
        }
        
        return returnNote
    }

} // end of PerformanceTrackingMgr


// For setting start time of note, adjusting for:
//      note startTime is relative to songStart;
//      sound startTime is relative to analysis Start.
func soundTimeToNoteTimeExt( soundStart: TimeInterval ) -> TimeInterval {
    return soundStart - PerformanceTrackingMgr.instance.songStartTimeOffset
}

func noteTimeToSoundTime( noteStart: TimeInterval ) -> TimeInterval {
    return noteStart + PerformanceTrackingMgr.instance.songStartTimeOffset
}

func currentSongTime() -> TimeInterval {
    let elapsed = Date().timeIntervalSince(PerfTrkMgr.instance.songStartTime)
    return elapsed
}


/////////////////////////////////////////////////////////////////////////
//
//  MARK: -  Helper functions for working with Pitch change detection,
//           and MusicXML and Time Intervals
//
/////////////////////////////////////////////////////////////////////////

// This much of a freq change must be a different note
//  (Diff between one note and another, say E4 to F4, is 0.944.)
let kDiffNotePercentage : Double = 0.955

// This is halfway between two adjacent note's center freqs.
let kDiffNotePercentageHalf : Double = 0.972

// Used for determining if a constant sound is transitioning from one
// note to another (legato playing)
func areDifferentNotes( pitch1: Double, pitch2: Double ) -> Bool {
    let pitch1LoStretch = pitch1 * kDiffNotePercentage
    let pitch1HiStretch = pitch1 / kDiffNotePercentage
    if pitch2 > pitch1LoStretch && pitch2 < pitch1HiStretch {
        return false
    } else {
        if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput {
            print ( "     Different notes: \(pitch1) vs \(pitch2)")
        }
        return true
    }
}

/////////////////////////////////////////////////////////////////////////
//    These are needed when creating perfNotesAndRests from MusicXML data
//
//   MusicXML note start times and durations are stored as values independant of
//   BPM, etc., using 1 quarter note = 1000  as the reference, regardless of tempo.

// Given the MusicXML startTime or duration, and the BPM, return TimeInterval
func musXMLNoteUnitToInterval( noteDur: Int32, bpm: Int32) -> TimeInterval {
    let bpmRatio: TimeInterval = secsPerMin / TimeInterval(bpm)
    let noteDurInQtrNotes: Double = Double(noteDur)/Double(musicXMLUnitsPerQuarterNote)
    let noteInterval: TimeInterval = TimeInterval( noteDurInQtrNotes )
    let adjustedNoteInterval: TimeInterval  = noteInterval * bpmRatio
    
    return adjustedNoteInterval
}

// Given the start time within the bar, the BPM, and Bar index, return the
// time interval since song startTime (which is 0) for a given note
func mXMLNoteStartInterval ( bpm: Int32,
                             beatsPerBar: Int32,
                             beatType: Int32,
                             startBarIndex : Int32,
                             noteStartWithinBar: Int32 ) -> TimeInterval {
    let beatsToBeginningOfBar = startBarIndex * beatsPerBar
    let numBeatsToBarBeginAsIntvl = TimeInterval(beatsToBeginningOfBar)
    let intMult = beatType == 8 ? PerformanceTrackingMgr.instance.qtrNoteTimeInterval / 2.0
        : PerformanceTrackingMgr.instance.qtrNoteTimeInterval
    //    let intervalToBarBegin =
    //        PerformanceTrackingMgr.instance.qtrNoteTimeInterval * numBeatsToBarBeginAsIntvl
    let intervalToBarBegin = intMult * numBeatsToBarBeginAsIntvl
    let noteStartInterval =
        intervalToBarBegin + Double(noteStartWithinBar) / 1000.0
    return noteStartInterval
}

/* was:       (this version screwed up tracking 6/8 badly
func mXMLNoteStartInterval ( bpm: Int32,
                             beatsPerBar: Int32,
                             startBarIndex : Int32,
                             noteStartWithinBar: Int32 ) -> TimeInterval {
    let beatsToBeginningOfBar = startBarIndex * beatsPerBar
    let intervalToBeginningOfBar = 
    let intervalNoteStartWithinBar = Double(noteStartWithinBar) / 1000.0
    
    
    let numBeatsToBarBeginAsIntvl = TimeInterval(beatsToBeginningOfBar)
    let intervalToBarBegin =
        PerformanceTrackingMgr.instance.qtrNoteTimeInterval * numBeatsToBarBeginAsIntvl
    let noteStartInterval =
        intervalToBarBegin + Double(noteStartWithinBar) / 1000.0
    return noteStartInterval
}
*/

// Needed to determine if running in simulator or on actual device. Note: if needed,
// this could be expanded to detect the actual model of the iOS hardware.
public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "i386",
             "x86_64":   return "Simulator"
        default:         return "Device"
        }
    }
}

////////////////////////////////////////////////////////////////////////////
//
//   Testing-related from this point on
//
////////////////////////////////////////////////////////////////////////////

func runPreAnalysisPartialTestingSetup() {
    // Force changes, after the performance, the detected freq and note of the
    // first 5 performed notes to a partial of the expected note.
    //
    //        Uncomment only ONE of these for loops
    
    var count = 1
    
    /*  Don't delete:  Commented out becasue this is an alternate test
    // Version one - use with "Rhythm Party 8 - tpt", which is all E4's
    for onePerfNote in PerformanceTrackingMgr.instance.perfNotesAndRests {
        switch(count) {
        case 1:
            onePerfNote.actualMidiNote = NoteIDs.G3
            onePerfNote.actualFrequency = 197.0
        case 2:
            onePerfNote.actualMidiNote = NoteIDs.D4
            onePerfNote.actualFrequency = 293.0
        case 3:
            onePerfNote.actualMidiNote = NoteIDs.G4
            onePerfNote.actualFrequency = 392.0
        case 4:
            onePerfNote.actualMidiNote = NoteIDs.B4
            onePerfNote.actualFrequency = 494.0
        case 5:
            onePerfNote.actualMidiNote = NoteIDs.D5
            onePerfNote.actualFrequency = 587.3
        default: break
        }
        count += 1
    }
    */
    
    // Version two - use with any test that is all C's, like "Rhythm Party 5 - tpt"
    for onePerfObj in PerformanceTrackingMgr.instance.perfNotesAndRests { //hyar
        if !onePerfObj.isNote() {
            continue
        }
        
        guard let onePerfNote : PerformanceNote = onePerfObj as? PerformanceNote
            else { return }
        
        switch(count) {
        case 1:
            onePerfNote.actualMidiNote = NoteIDs.F4
            onePerfNote.actualFrequency = 349.0
        case 2:
            onePerfNote.actualMidiNote = NoteIDs.Bb4
            onePerfNote.actualFrequency = 466.0
        case 3:
            onePerfNote.actualMidiNote = NoteIDs.D5
            onePerfNote.actualFrequency = 587.0
        case 4:
            onePerfNote.actualMidiNote = NoteIDs.F5
            onePerfNote.actualFrequency = 698.0
        case 5:
            onePerfNote.actualMidiNote = NoteIDs.Ab5
            onePerfNote.actualFrequency = 830.6
        default: break
        }
        count += 1
    }
}
