//
//  PerfSampleAmplitudeTrackerV2.swift
//  PlayTunes-debug
//
//  Created by Scott Freshour on 2/5/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//

import Foundation


class sortOfCirularBuffer {
    
    var buffer: [Double] = [Double]()
    
    private var bufferSize: Int
    private var currVirtualIndex:  Int = -1
    private var windowSize: Int = 2
    
    init(bufferSize: Int, windowSize: Int) {
        _ = ASSUME( bufferSize >= windowSize )
        self.bufferSize = bufferSize
        self.windowSize = windowSize
        self.buffer = Array(repeating: 0.0, count: bufferSize)
    }
    
    func reset() {
        currVirtualIndex = -1
    }
    
    func setWindowSize(newSize: Int) {
        self.windowSize = newSize
    }
    
    func addSample(sample: Double) {
        currVirtualIndex += 1
        let currIndex = getIndexForVirtualIndex(virtIdx: currVirtualIndex)
        buffer[currIndex] = sample
    }
    
    func getVirtualCount() -> Int {
        return currVirtualIndex
    }
    
    func getValueAtCurrentIndex() -> Double {
        if currVirtualIndex < 0 {
            return 0.0
        } else {
            let idx = getIndexForVirtualIndex(virtIdx: currVirtualIndex)
            return buffer[idx]
        }
    }
    
    func getIndexForVirtualIndex(virtIdx: Int) -> Int {
        let retVal = virtIdx % bufferSize
        if retVal < 0  {
            itsBad()
            return 0
        }
        return retVal
    }
    
    func getIndexForStartOfWindow() -> Int {
        guard currVirtualIndex >= windowSize else {
            return -1
        }
        let virtStartIdx = currVirtualIndex - (windowSize - 1)
        let startIndex = getIndexForVirtualIndex(virtIdx: virtStartIdx)
        return startIndex
    }
    
    func getMaxRangeForWindow() -> Double {
        var countingIdx = getIndexForStartOfWindow()
        guard countingIdx >= 0  else {
            print("In getMaxRangeForWindow, countingIdx is not > 0; returning 0")
            return 0.0
        }
        let startIdx = countingIdx
        var min = buffer[countingIdx]
        var max = buffer[countingIdx]

        var count = 1
        while count < windowSize {
            count += 1
            countingIdx += 1
            let idx = getIndexForVirtualIndex(virtIdx: countingIdx)
            if buffer[idx] > max {
                max = buffer[idx]
            }
            if buffer[idx] < min {
                min = buffer[idx]
            }
        }
        print ("min = \(min), max = \(max);  window size: \(windowSize);   indexes used: start: \(startIdx), end: \(countingIdx)")
        let range = max - min
        return range
    }
}

typealias tSoundAmpVal = Double

class PerfSampleAmplitudeTrackerV2 {
    
    let bufferSz = 35
    var audioBuffer = sortOfCirularBuffer(bufferSize: 30,
                                          windowSize: Int(gSamplesInAnalysisWindow))
    var timeBuffer  = sortOfCirularBuffer(bufferSize: 30,
                                          windowSize: Int(gSamplesInAnalysisWindow))
    
    // gSkipBeginningSamples  explanation:
    //   This class determines that a new sound is occurring by sensing if the
    //   amplitude rises quickly. (E.g., When notes are tongued, the amplitude
    //   drops and then rise quickly.)
    //   If we don't ignore the first rise, *it* will trigger the detection. So we
    //   have to let so many samples go before beginning to look for another rise.

    var numRunningSamples: UInt = 0
    
    // 10 * 10 ms = .1 second
    // 30 * 10 ms = .3 second
    
    typealias tAmpAndTime = ( amp: tSoundAmpVal, absTime: TimeInterval )
    
    var killSoundTime: TimeInterval = 0.0
    var currSoundIsDead = false
    var doCreateNewSound  = false
    var noSignal   = false
    var numSamplesSinceSoundIsDead  = 0
    var finished = false

    var lastAmpSample: tSoundAmpVal = 0.0
    
    var ampAtKillPoint: tSoundAmpVal = 0.0
    
    var runningAvg:             tSoundAmpVal = 0.0
    var runningAvgInTolRng:     tSoundAmpVal = 0.0
    var runningAvgAfterTolRng:  tSoundAmpVal = 0.0

    func shouldKillCurrSOundAndCreateNewOne() -> Bool {
        return doCreateNewSound
    }
    
    func canCalcAmpChange() -> Bool {
        let numElems = audioBuffer.getVirtualCount()

        if numElems >= Int(gSkipBeginningSamples)  &&
            numElems >= Int(gSamplesInAnalysisWindow) {
            return true
        } else {
            return false
        }
    }
    
    func enqueue(_ newAmp: tSoundAmpVal, _ newTime: TimeInterval) {
        //        print ("--------------------------------------------------------------------------")
        //        print ("    Enqueuing:  \(newAmp)")
        //        print ("    Queue before append:  \(queue)")
        
        lastAmpSample = newAmp
        if newAmp < kAmplitudeThresholdForIsSound {
            noSignal         = true // should stop tracking sound . . .
            finished         = true
            doCreateNewSound = false
            printSoundRelatedMsg(msg: "\nAmpTracker: declaring sound dead bc dropped below 'is sound' threshold")
        } else if currSoundIsDead {
            noSignal = false
            numSamplesSinceSoundIsDead += 1
            if numSamplesSinceSoundIsDead > kNumSamplesForStillSound {
                doCreateNewSound = true
            }
            
            // RETHINK.  THis logic is part of the "if sounds drops some amount"
            //           instead of "if sound rises some amount"
            if newAmp > ampAtKillPoint { // amplitude going back up
                doCreateNewSound = true
                finished         = true
            }
        }
        
        // RETHINK - perhaps comment this out - Buffer is taking care of this.
        numRunningSamples += 1
        if numRunningSamples < gSkipBeginningSamples { return } // then skip this one
        
        audioBuffer.addSample(sample: newAmp)
        timeBuffer.addSample(sample: newTime)

        _ = isDiffNoteBCofAmpChange()
    }
    
    func reset() {
        audioBuffer.reset()
        timeBuffer.reset()
        killSoundTime = 0.0
        currSoundIsDead = false
        doCreateNewSound  = false
        noSignal   = false
        numSamplesSinceSoundIsDead  = 0
        ampAtKillPoint = 0.0
        finished = false
    }
    
    func getAmpRiseOverWindow() -> tSoundAmpVal {
        return audioBuffer.getMaxRangeForWindow()
    }
    
    func isDiffNoteBCofAmpChange() -> Bool {
        if !canCalcAmpChange() { // not enough data to attempt calc
            print ("isDiffNoteBCofAmpChange: returning false b/c !canCalcAmpChange")
            return false
        } else {
            var ampDiff = audioBuffer.getMaxRangeForWindow()
            ampDiff = abs(ampDiff)
            if ampDiff > gAmpRiseForNewSound {
                if !currSoundIsDead {
                    let currSongzTime = currentSongTime()
                    printSoundRelatedMsg(msg: "  CURRENT SOUND DONE  BC of AMP Rise! At: \(currSongzTime)   Amp Diff: \(ampDiff)")
                }
                currSoundIsDead = true
                ampAtKillPoint  = audioBuffer.getValueAtCurrentIndex()
                killSoundTime   = timeBuffer.getValueAtCurrentIndex()  
                return true
            } else {
                print("  Is NOT new note:  Amp Diff: \(ampDiff)")
                return false
            }
        }
    }
    
    
    
 /*
    
    
    func testBuffer() {
        var i = 0
        var val: Double = 0.01
        while i < 200 {
            val = 1.1 * val
            circDuBuffer.addSample(sample: val)
            let rng = circDuBuffer.getMaxRangeForWindow()
            print ("Range == \(rng)")
            i += 1
            var diddly = 0
            if i == 28 {
                diddly = 2
            }
        }
        
        circDuBuffer.reset()
        circDuBuffer.setWindowSize(newSize: 5)
        
        i = 0
        val = 0.01
        while i < 200 {
            val = 1.1 * val
            circDuBuffer.addSample(sample: val)
            let rng = circDuBuffer.getMaxRangeForWindow()
            print ("Range == \(rng)")
            i += 1
            var diddly = 0
            if i == 28 {
                diddly = 2
            }
        }
        
        circDuBuffer.reset()
        circDuBuffer.setWindowSize(newSize: 2)
        
        i = 0
        val = 0.01
        while i < 100 {
            val = 1.1 * val
            circDuBuffer.addSample(sample: val)
            let rng = circDuBuffer.getMaxRangeForWindow()
            print ("Range == \(rng)")
            i += 1
            var diddly = 0
            if i == 28 {
                diddly = 2
            }
        }
        
    }
*/
}







