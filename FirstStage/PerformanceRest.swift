//
//  PerformanceRest.swift
//  FirstStage
//
//  Created by Scott Freshour on 7/20/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

public class PerformanceRest : PerformanceScoreObject
{
    // These are TimeIntervals since the beginning of song playback
    //   (Sound times are intervals since analysis start)
    var startTime : TimeInterval = noTimeValueSet
    var duration: TimeInterval = noTimeValueSet

    init () {
        super.init(noteOrRest : .rest)
        perfNoteOrRestID = PerformanceScoreObject.getUniqueRestID()
    }
    
    deinit {
        // here for debugging, making sure there are no reference cycles
        if kMKDebugOpt_PrintStudentPerformanceDataDebugOutput {
            print ( "De-initing Rest \(perfNoteOrRestID)" )
        }
    }
    
    // Used by an Alert to populate the messageString with data about this Note.
    //  (The Alert is a debug feature. It is not visible in release mode.)
    override func constructSummaryMsgString( msgString: inout String )
    {
        msgString = ""
        
        if isLinkedToSound {
            msgString += "Not Correct!\n\n"
            msgString += "One or more notes were played\n"
            msgString += "during the rest"
        } else {
            msgString += "Correct!\n\n"
        }
    }
}
