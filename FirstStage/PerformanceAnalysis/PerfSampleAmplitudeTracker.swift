//
//  PerfSampleAmplitudeTracker.swift
//  FirstStage
//
//  Created by Scott Freshour on 9/10/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

// The amplitude drop required to consider end of current sound
let kAmpDropForNewSound_Sim: tSoundAmpVal = 0.20
let kAmpDropForNewSound_HW:  tSoundAmpVal = 0.20
var kAmpDropForNewSound:     tSoundAmpVal = kAmpDropForNewSound_HW



// The number of samples AFTER the amplitude drop required to say:
//   "the signal after the amplitude drop is still a sound; so create a new sound"
let kNumSamplesForStillSound = 8


typealias tSoundAmpVal = Double

class PerfSampleAmplitudeTracker {
    
    let kNumTolAmpSamples   =  4    // num in tolerance zone
    let kMaxAmpSamples      = 25    // max stored in Queue
    let kMinReqdAmpSamples  = 10    // min number reqired to calc in/out tolerance
    
    typealias tAmpAndTime = ( amp: tSoundAmpVal, absTime: TimeInterval )
    
    var killSoundTime: TimeInterval = 0.0
    var currSoundIsDead = false
    var doCreateNewSound  = false
    var noSignal   = false
    var numSamplesSinceSoundIsDead  = 0
    var finished = false
    var canCalcAmpChange    = false

    
    var ampAtKillPoint: tSoundAmpVal = 0.0
    
    var runningAvg:             tSoundAmpVal = 0.0
    var runningAvgInTolRng:     tSoundAmpVal = 0.0
    var runningAvgAfterTolRng:  tSoundAmpVal = 0.0
    var queue:[tSoundAmpVal] = [] //0.10, 0.10, 0.10, 0.10, 0.10, 0.10, 0.10, 0.10]
    var timeQueue:[TimeInterval] = []

    func shouldKillCurrSOundAndCreateNewOne() -> Bool {
        return doCreateNewSound
    }
    
    func enqueue(_ newAmp: tSoundAmpVal, _ newTime: TimeInterval) {
//        print ("--------------------------------------------------------------------------")
//        print ("    Enqueuing:  \(newAmp)")
//        print ("    Queue before append:  \(queue)")
        
        if newAmp < kAmplitudeThresholdForIsSound {
            noSignal         = true // should stop tracking sound . . .
            finished         = true
            doCreateNewSound = false
            print("\nAmpTracker: declaring sound dead bc dropped below 'is sound' threshold")
        } else if currSoundIsDead {
            noSignal = false
            numSamplesSinceSoundIsDead += 1
            if numSamplesSinceSoundIsDead > kNumSamplesForStillSound {
                doCreateNewSound = true
            }
            if newAmp > ampAtKillPoint { // amplitude going back up
                doCreateNewSound = true
                finished         = true
            }
        }
        
        timeQueue.insert(newTime, at: 0)
        queue.insert(newAmp, at: 0)
        if queue.count > kMaxAmpSamples {
            _ = queue.remove(at: kMaxAmpSamples) // dropFirst()
            _ = timeQueue.remove(at: kMaxAmpSamples) // dropFirst()
        }
        let numElems = queue.count
//        print ("    Queue after append:  \(queue)")

        canCalcAmpChange = numElems >= kMinReqdAmpSamples
        
        // calc avg in tolerance range
        var sumInTolRng: tSoundAmpVal = 0.0
        var numElemsInTolRng = 1
        //var elemsInTolRngSlice:[tSoundAmpVal] = []
        if numElems >= kNumTolAmpSamples {
            // .prefix(upTo: Idx) does not include elem at index "Idx"
            let elemsInTolRngSlice = queue.prefix(upTo:kNumTolAmpSamples)
            numElemsInTolRng = elemsInTolRngSlice.count
            sumInTolRng   = elemsInTolRngSlice.reduce(0, +)
//            print ("      Elems In Tol Rng: \(elemsInTolRngSlice), Sum In Tol Rng: \(sumInTolRng)")
         } else {
            numElemsInTolRng = numElems
            sumInTolRng = queue.reduce(0, +)
            runningAvgInTolRng = sumInTolRng/tSoundAmpVal(numElemsInTolRng)
        }
        runningAvgInTolRng = sumInTolRng/tSoundAmpVal(numElemsInTolRng)
//        print ("    running Avg In Tol Rng: \(runningAvgInTolRng)")

        // calc avg after tolerance range
        var sumAfterTolRng: tSoundAmpVal = 0.0
        if numElems > kNumTolAmpSamples {
            // .suffix(from: Idx) // includes elem at index Idx
            let elemsAfterTolRng = queue.suffix(from: kNumTolAmpSamples)
            sumAfterTolRng   = elemsAfterTolRng.reduce(0, +)
//            print ("      Elems After Tol Rng: \(elemsAfterTolRng), Sum After Tol Rng: \(sumAfterTolRng)")
            runningAvgAfterTolRng = sumAfterTolRng/tSoundAmpVal(elemsAfterTolRng.count)
            //print ("    running Avg After Tol Rng: \(runningAvgAfterTolRng)")
        } else {
            runningAvgAfterTolRng = runningAvgInTolRng
//            print ("      No Elems After Tol Rng")
            //print ("    running Avg After Tol Rng: \(runningAvgAfterTolRng)")
        }
//        print ("    running Avg After Tol Rng: \(runningAvgAfterTolRng)")
//        print ("--------------------------------------------------------------------------")
        
        _ = isDiffNoteBCofAmpChange()
    }
    
    func reset() {
        queue.removeAll()
        timeQueue.removeAll()
        killSoundTime = 0.0
        currSoundIsDead = false
        doCreateNewSound  = false
        noSignal   = false
        numSamplesSinceSoundIsDead  = 0
        canCalcAmpChange    = false
        ampAtKillPoint = 0.0
        finished = false
   }
    
    func getRunningAverage() -> tSoundAmpVal {
        if queue.count <= 0 {
            return 0.0
        } else {
            let sum: tSoundAmpVal = queue.reduce(0, +)
            let retVal = sum/tSoundAmpVal(queue.count)
            return retVal
        }
    }
    
    func isDiffNoteBCofAmpChange() -> Bool {
        if !canCalcAmpChange { // no enough data to attempt calc
            return false
        } else {
            let ampDiff:tSoundAmpVal = runningAvgAfterTolRng - runningAvgInTolRng
            let runAvgInTR = runningAvgInTolRng
            let runAvgAftrTR = runningAvgAfterTolRng
            print("\nAAAAA Amp Diff: \(ampDiff), runningAvgInTolRng: \(runAvgInTR),runningAvgAfterTolRng: \(runAvgAftrTR)\n")
            if ampDiff > kAmpDropForNewSound {
                if !currSoundIsDead {
                    let currSongzTime = currentSongTime()
                    print("  CURRENT SOUND DONE  BC of AMP Drop! At: \(currSongzTime)   Amp Diff: \(ampDiff)")
                }
                currSoundIsDead = true
                ampAtKillPoint  = queue[0]
                killSoundTime   = timeQueue[0]
                return true
            } else {
//                print("  Is NOT new note:  Amp Diff: \(ampDiff)")
                return false
            }
        }
    }
    
    /*
    func test() {
        var isDiffNote = false
        
        self.enqueue(0.14, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.14, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.14, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.14, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.11, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.08, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.09, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.11, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.14, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.16, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.14, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.15, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.15, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.15, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.15, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.11, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.03, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.02, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.02, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.04, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()
        self.enqueue(0.03, 0.0)
        isDiffNote = isDiffNoteBCofAmpChange()

        
        self.reset()
        
        print ("After clear: \(queue)")
    }
*/
    
    
    
    
    
    /*
    func test2() {
        var runAvg: tSoundAmpVal = 0.0
        
        self.enqueue(1.0)
        self.enqueue(2.0)
        self.enqueue(3.0)
        runAvg = getRunningAverage()
        print ("\(queue),  Running Avg: \(runAvg)")
        
        self.enqueue(4.0)
        runAvg = getRunningAverage()
        print ("\(queue),  Running Avg: \(runAvg)")
        
        self.enqueue(5.0)
        runAvg = getRunningAverage()
        print ("\(queue),  Running Avg: \(runAvg)")
        
        self.enqueue(6.0)
        runAvg = getRunningAverage()
        print ("\(queue),  Running Avg: \(runAvg)")
        
        self.enqueue(7.0)
        runAvg = getRunningAverage()
        print ("\(queue),  Running Avg: \(runAvg)")
        
        self.enqueue(8.0)
        runAvg = getRunningAverage()
        print ("\(queue),  Running Avg: \(runAvg)")
        
        self.enqueue(9.0)
        runAvg = getRunningAverage()
        print ("\(queue),  Running Avg: \(runAvg)")
        
        self.clear()
        print ("\(queue),  Running Avg: \(runAvg)")
    }
 */
}








