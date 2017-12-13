//
//  NotePitchAnalysisCriteria.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/1/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.

////////////////////////////////////////////////////////////////////////////////
//
//  A NotePitchAnalysisCriteria object is used when analyzing a single note in a 
//  student's performance, to rate how close the performed pitch is to the target. 
//  There are 5 zones, with a freq range assigned to each:
//
//   ---------------------------------------------------------------------
//  |   Very Low  |  A Bit Low  |   Correct   |  A Bit High |   Very High |
//  |             |             |             |             |             |
//  | loFr...hiFr | loFr...hiFr | loFr...hiFr | loFr...hiFr | loFr...hiFr |
//   ---------------------------------------------------------------------
//
//  Zone ranges must be generated/re-generated based on two factors:
//    - The instrument. In the case of transposing instruments, the actual
//      expected frequency (which will be concert pitch) is different from
//      the score's note frequency.
//    - The tolerence (a percentage). As the student progresse through the
//      exercises, the allowed variances from the target pitch will tighten.
//
//  Also included are instrument-specific vars for identifying any issues that
//  might be unique to the instrument; e.g., for a Trumpet, a Table of Partials.
//
////////////////////////////////////////////////////////////////////////////////

import Foundation

// The zones shown in the comment above
enum pitchZone: Int {
    case veryLow  = 0
    case aBitLow  = 1
    case correct  = 2
    case aBitHigh = 3
    case veryHigh = 4
}

///////////////////////////////////////////////////////////////////////////////
//
//  Pitch grading criteria for a single note
//
struct NotePitchAnalysisCriteria {
    
    var correctPitchData: tNoteFreqRangeData = kEmptyNoteFreqRangeData
    
    var veryLowRange:  tFrequencyRange    = kEmptyNoteFreqRange
    var aBitLowRange:  tFrequencyRange    = kEmptyNoteFreqRange
    var correctRange:  tFrequencyRange    = kEmptyNoteFreqRange
    var aBitHighRange: tFrequencyRange    = kEmptyNoteFreqRange
    var veryHighRange: tFrequencyRange    = kEmptyNoteFreqRange
    
    // CorrectPitchData was calculated elsewhere and is assigned untouched. It
    // contains the info needed, along with the Percentages, to calculate the
    // other values.
    // param bitToVeryBoundaryPercent:   Used to calc the boundaries between aBitLow
    //                                   and veryLow, and aBitHigh and veryHigh
    // param veryOutsideBoundaryPercent: Used to calc the lower boundary of aBitLow,
    //                                   the upper boundary of aBitHigh. (Past these 
    //                                   points, the pitch is considered a completely 
    //                                   different note.)
    // param veryLowLowerBound: if non-nil, used to override veryLowRange.lowerBound
    mutating func calculateAndSetZoneValues( pitchData: tNoteFreqRangeData,
                                             bitToVeryBoundaryPercent: Double,
                                             veryOutsideBoundaryPercent: Double ) {
        correctPitchData = pitchData
        correctRange = pitchData.freqRange
        
        // calc remaining ranges
        let centerFreq = correctPitchData.concertFreq
        let veryLowLowerBoundary   = 0.0 //centerFreq * veryOutsideBoundaryPercent
        let aBitToVeryLowBoundary  = centerFreq * bitToVeryBoundaryPercent
        let aBitToVeryHighBoundary = centerFreq / bitToVeryBoundaryPercent
        let veryHighUpperBoundary  = 3000.0 // centerFreq / veryOutsideBoundaryPercent
        
        // It's okay that some of these ranges include the same "edges" (e.g.,
        // aBitLow.lowerBound == veryLow.UpperBound) - exclusivity is not an issue 
        // since the zones will be used one at a time moving out from the center 
        // zone. If an inner zone contains a given frequency, the search will not 
        // proceed to the next zone.
        veryLowRange  = veryLowLowerBoundary...aBitToVeryLowBoundary
        aBitLowRange  = aBitToVeryLowBoundary...correctRange.lowerBound
        aBitHighRange = correctRange.upperBound...aBitToVeryHighBoundary
        veryHighRange = aBitToVeryHighBoundary...veryHighUpperBoundary
    }
    
    func getPitchZoneFreqRange( zone: pitchZone ) -> tFrequencyRange {
        switch zone {
            case .veryLow:  return veryLowRange
            case .aBitLow:  return aBitLowRange
            case .correct:  return correctRange
            case .aBitHigh: return aBitHighRange
            case .veryHigh: return veryHighRange
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////
    //
    //    For Debugging and Testing from here to end of class
    //
    ///////////////////////////////////////////////////////////////////////////
    
    func printYourself()
    {
        guard kMKDebugOpt_PrintPerfAnalysisValues else { return }
        
        let trnsNoteName = correctPitchData.noteFullName
        let concNoteName = correctPitchData.concertNoteFullName
        
        let targetFreq  = String(format: "%.2f", correctPitchData.concertFreq)

        let vlLo  = String(format: "%.2f", veryLowRange.lowerBound)
        let vlHi  = String(format: "%.2f", veryLowRange.upperBound)
        
        let ablLo = String(format: "%.2f", aBitLowRange.lowerBound)
        let ablHi = String(format: "%.2f", aBitLowRange.upperBound)
        
        let corLo = String(format: "%.2f", correctPitchData.freqRange.lowerBound)
        let corHi = String(format: "%.2f", correctPitchData.freqRange.upperBound)
        
        let abhLo = String(format: "%.2f", aBitHighRange.lowerBound)
        let abhHi = String(format: "%.2f", aBitHighRange.upperBound)
        
        let vhLo  = String(format: "%.2f", veryHighRange.lowerBound)
        let vhHi  = String(format: "%.2f", veryHighRange.upperBound)
        
        print( "    -----------------------------------------------------------" )
        print( "    Analysis Crieria for Note: \(trnsNoteName) - Transposed   (Concert: \(concNoteName))" )
        print( "       Target Freq :   \(targetFreq)" )
        print( "         Very Low Range:  \(vlLo)   .. \(vlHi)" )
        print( "        A Bit Low Range:  \(ablLo) .. \(ablHi)" )
        print( "       Correct Range: --- \(corLo) .. \(corHi) ---   (Target: \(targetFreq))" )
        print( "        A Bit High Range: \(abhLo) .. \(abhHi)" )
        print( "         Very High Range: \(vhLo) .. \(vhHi)" )
        
        PerformanceAnalysisMgr.instance.printPartialsForThisNote(noteID: correctPitchData.noteID )
    }
}

///////////////////////////////////////////////////////////////////////////////
//  NotePitchAnalysisCriteriaTable
//
//    Pitch grading criteria for all notes: manages an array of
//    NotePitchAnalysisCriteria objects
//
struct NotePitchAnalysisCriteriaTable {
    
    static let instance = NotePitchAnalysisCriteriaTable()
    
    var pitchAnalysisCriteriaTable = [NotePitchAnalysisCriteria]()
    
    var currTolerances = pitchAndRhythmTolerances() // set with defaults

    init() {
    }

    mutating func rebuildTable( tolPercents: pitchAndRhythmTolerances,
                                noteFreqRngTable: NoteFreqRangeTable ) {
        currTolerances = tolPercents

        pitchAnalysisCriteriaTable.removeAll( keepingCapacity: true )
        var currID  = PerfAnalysisDefs.kFirstTableNoteId
        repeat {  // create an entry for each valid note for current instrument
            let noteFRData = noteFreqRngTable.getNoteFreqRangeData(noteID: currID)
            var notePACrit = NotePitchAnalysisCriteria()
            notePACrit.calculateAndSetZoneValues(
                    pitchData: noteFRData,
                    bitToVeryBoundaryPercent: currTolerances.aBitToVeryPC,
                    veryOutsideBoundaryPercent: currTolerances.veryBoundaryPC )
            pitchAnalysisCriteriaTable.append(notePACrit)
            currID += 1
        } while currID <= PerfAnalysisDefs.kLastTableNoteId
    }

    func getPitchAnalysisCriteria( noteID: NoteID) -> NotePitchAnalysisCriteria {
        var retCriteria = NotePitchAnalysisCriteria() // init'd to empty values
        
        guard (NoteIDs.validNoteIDRange).contains(noteID)
            else { return retCriteria }  // noteID out of range
        guard pitchAnalysisCriteriaTable.count == PerfAnalysisDefs.kNumTableIDs
            else { return retCriteria }  // table wasn't built
        
        // normalize index to range that starts at 0 for table lookup
        let idx = Int(noteID - PerfAnalysisDefs.kFirstTableNoteId)
        guard idx < pitchAnalysisCriteriaTable.count
            else { return retCriteria }
        
        retCriteria = pitchAnalysisCriteriaTable[idx]
        return retCriteria
    }
    
    ///////////////////////////////////////////////////////////////////////////
    //
    //    For Debugging and Testing from here to end of class
    //
    ///////////////////////////////////////////////////////////////////////////
    
    // Go through each entry (note) in the array, and print the details
    func printAllPitchAnalysisCritera() {
        guard kMKDebugOpt_PrintPerfAnalysisValues else { return }
        
        print( "\n  =============================================================\n" )
        print( "  Analysis Crieria For All Notes\n" )
        for oneNoteCrit in pitchAnalysisCriteriaTable {
            oneNoteCrit.printYourself()
            
        }
    }
}
