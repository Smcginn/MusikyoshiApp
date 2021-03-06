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

class PerformanceTrackingMgr {

    // PerformanceTrackingMgr keeps track of:
    //
    //    PerformanceNotes: there is one of these for every note in the score.
    //       A PerformanceNotes contains the expectatations and the actual
    //       values of the studuent's performance for things like start time,
    //       duration, pitch, etc.
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
    
    init() {
        userDefsTimingThreshold =
            UserDefaults.standard.double(forKey: Constants.Settings.TimingThreshold)
        if UIDevice.current.modelName == "Simulator" {
            print("In Simulator")
            kAmplitudeThresholdForIsSound = kAmpThresholdForIsSound_Sim
        } else {
            print("In Real Device")
            kAmplitudeThresholdForIsSound = kAmpThresholdForIsSound_HW
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////
    //
    //  MARK:      PerformanceNote related
    //
    ///////////////////////////////////////////////////////////////////////////
    
    // Container of Expected Notes. These are created as a note appears in the 
    // score, and the "expectations" and "reality" are stored here. If there was 
    // a Sound that started within the Note's expected start window (and it's not 
    // already linked to another Note), the Note and the Sound are linked. The 
    // Sound's data is the basis for the "reality" portion, and can be compared 
    // to the expectations for the given note.
    var performanceNotes = [PerformanceNote]()
    
    // If there is a current active Note from the score (that the student should 
    // be playing) these will be set (cleared when the Note ends, set for the next 
    // note, etc.)
    public weak var currentPerfNote : PerformanceNote?
    var currentlyInAScoreNote = false

    ///////////////////////////////////////////////////////////////////////////
    //
    //  MARK:      PerformanceSound related
    //
    ///////////////////////////////////////////////////////////////////////////
    
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
    func endTrackedSoundAsSignalStopped(soundEndTime: TimeInterval,
                                        noteOffset: TimeInterval ) {
        guard currentlyTrackingSound, let currSound = currentSound else { return }
        
        currSound.endTime = soundEndTime
        
        if let soundsNote = currSound.linkedNoteObject {
            soundsNote.endTime = soundEndTime - noteOffset
        }
        
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
        currSound.endTime = splitTime
        
        if let soundsNote = currSound.linkedNoteObject {
            soundsNote.endTime = splitTime - noteOffset
        }
        
        // stop current sound
        currSound.printSoundResults()
        currentSound = nil
        currentlyTrackingSound = false
    }
    
    ///////////////////////////////////////////////////////////////////////////
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
    
    var currTempoBPM: Int = 60
    var currBeatsPerBar: Int = 4
    var qtrNoteTimeInterval: TimeInterval = 1.0
    func setPlaybackVals( tempoInBPM: Int, beatsPerBar: Int )
    {
        currTempoBPM    = tempoInBPM
        currBeatsPerBar = beatsPerBar
        let bpmRatio: TimeInterval = secsPerMin / TimeInterval(tempoInBPM)
        qtrNoteTimeInterval = TimeInterval(1.0) * bpmRatio
    }
    
    ///////////////////////////////////////////////////////////////////////////
    //
    //  MARK:      Miscellaneous funcs . . .
    //
    ///////////////////////////////////////////////////////////////////////////
    
    // If starting a new performance (e.g., Press Play), clear data from last one
    func resetSoundAndNoteTracking() {
        currentPerfNote = nil
        currentSound = nil
        performanceNotes.removeAll()
        performanceSounds.removeAll()
        PerformanceSound.resetUniqueSoundID()
        PerformanceNote.resetUniqueNoteID()
        currentlyInAScoreNote  = false
        currentlyTrackingSound = false
    }
    
    // called when either a new note begins in the score, or new sound is detected
    func linkCurrSoundToCurrNote() {
        guard currentlyInAScoreNote && currentlyTrackingSound else { return }
        guard let currPerfNote : PerformanceNote = currentPerfNote else { return }
        guard let currSound : PerformanceSound = currentSound else { return }
        guard !currSound.isLinkedToNote && !currPerfNote.isLinkedToSound else { return }
        
        let diff = abs( soundTimeToNoteTime(songStart: currSound.startTime) -
                        currPerfNote.expectedStartTime  )
        // if (diff <= userDefsTimingThreshold) {
        let attackTol = PerformanceAnalysisMgr.instance.currTolerances.rhythmTolerance
        if (diff <= attackTol) {
            currPerfNote.linkToSound(soundID: currSound.soundID, sound: currSound)
            currSound.linkToNote(noteID: currPerfNote.perfNoteID, note: currPerfNote)
            currPerfNote.actualStartTime = soundTimeToNoteTime(songStart: currSound.startTime)
            currPerfNote.actualFrequency = currSound.averagePitchRunning
        }
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
    
    // Do post-performance analysis and grading: Pitch and Rhythm accuracy
    func analyzePerformance() {
        
        let rhythmAnalyzer = NoteRhythmPerformanceAnalyzer.init()
        let pitchAnalyzer  = TrumpetPitchPerformanceAnalyzer.init()
        
        // Uncomment this to test Partial lookup
//        runPreAnalysisPartialTestingSetup()
        
        // Visit each Note, have analyzers grade and rate performance of that
        // Note compared with expectations
        for onePerfNote in performanceNotes {
            onePerfNote.weightedScore = 0
            rhythmAnalyzer.analyzeNote( perfNote: onePerfNote )
            pitchAnalyzer.analyzeNote( perfNote: onePerfNote )
        }
        
        PerformanceIssueMgr.instance.scanPerfNotesForIssues( kPerfIssueSortCriteria )

        if kMKDebugOpt_PrintPerfAnalysisResults {
            print ( "\nPerformance Results:\n")
            for onePerfNote in performanceNotes {
                print ( "--------------------------")
                print ( " Note #\(onePerfNote.perfNoteID):" )
                print ( "   Attack rating:   \(onePerfNote.attackRating)" )
                print ( "   Duration rating: \(onePerfNote.durationRating)" )
                print ( "   Pitch rating:    \(onePerfNote.pitchRating)" )
                print ( "   Weighted rating: \(onePerfNote.weightedScore)" )
            }
        }
    }
    
    // Pops up an Alert with the details of the Performed Note's accuracy.
    //   This is intended for debugging, or to show what can potentially be 
    //   displayed. Not for user consumption.
    func displayPerfInfoAlert( perfNoteID: Int32,
                               parentVC: UIViewController ) {
        let possibleNote: PerformanceNote? =
            findPerformanceNoteByID(perfNoteID: perfNoteID)
        guard let foundNote = possibleNote else { return }
        
        let titleStr: String = "Info for Note  \(foundNote.perfNoteID)"
        var msgStr: String = ""
        foundNote.constructSummaryMsgString( msgString: &msgStr )
        
        let alert = UIAlertController( title: titleStr,
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
                NSParagraphStyleAttributeName: paragraphStyle
            ]
        )
        messageText.addAttribute(NSFontAttributeName,
                                 value:fnt!,
                                 range: NSRange.init(location: 0,
                                                     length: msgStr.characters.count))
        alert.setValue(messageText, forKey: "attributedMessage")
        
        // Add the OK button
        let action = UIAlertAction( title: "OK",
                                    style: .default,
                                    handler: nil )
        alert.addAction(action)
        parentVC.present( alert, animated:true, completion: nil)
    }

    ///////////////////////////////////////////////////////////////////////////
    //
    //  MARK:      Funcs for finding a Sound or a Note in arrays, 
    //             using various criteria
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

    func findPerformanceNoteByID(perfNoteID: Int32) -> PerformanceNote? {
        var returnNote : PerformanceNote? = nil
        for onePerformanceNote in performanceNotes {
            if ( onePerformanceNote.perfNoteID == perfNoteID ) {
                returnNote = onePerformanceNote
                break;
            }
        }
        return returnNote
    }
    
    func findPerformanceNoteByStartTime(start: TimeInterval) -> PerformanceNote? {
        
        var returnNote : PerformanceNote? = nil
        
        let lowBound  = start - userDefsTimingThreshold
        let highBound = start + userDefsTimingThreshold
        
        for onePerformanceNote in PerformanceTrackingMgr.instance.performanceNotes {
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
        
        for onePerformanceNote in PerformanceTrackingMgr.instance.performanceNotes {
            let xPos = onePerformanceNote.xPos
            if ( xPos >= lowBoundXpos && xPos <= highBoundXpos ) {
                returnNote = onePerformanceNote
                break;
            }
        }
        
        return returnNote
    }

} // end of PerformanceTrackingManager

/////////////////////////////////////////////////////////////////////////
//
//  MARK:   Helper functions for working with Pitch change detection, 
//          and MusicXML and Time Intervals
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
//    These are needed when creating PerformanceNotes from MusicXML data
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
                             startBarIndex : Int32,
                             noteStartWithinBar: Int32 ) -> TimeInterval {
    let beatsToBeginningOfBar = startBarIndex * beatsPerBar
    let numBeatsToBarBeginAsIntvl = TimeInterval(beatsToBeginningOfBar)
    let intervalToBarBegin =
        PerformanceTrackingMgr.instance.qtrNoteTimeInterval * numBeatsToBarBeginAsIntvl
    let noteStartInterval =
        intervalToBarBegin + Double(noteStartWithinBar) / 1000.0
    return noteStartInterval
}

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
    for onePerfNote in PerformanceTrackingMgr.instance.performanceNotes {
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
    for onePerfNote in PerformanceTrackingMgr.instance.performanceNotes {
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
