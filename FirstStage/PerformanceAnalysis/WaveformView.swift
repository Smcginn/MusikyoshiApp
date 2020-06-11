//
//  WaveformView.swift
//  FirstStage
//
//  Created by Scott Freshour on 8/29/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//

import Foundation
import UIKit

class WaveformView: UIScrollView {
    
    var isShowing = false

    var numHtPix:CGFloat = 0.0
    var htMult:CGFloat   = 0.0
    var wdMult:CGFloat   = 5.0
    var valueMult:Double = 100.0
    var skipWindowPix: CGFloat    = 0.0
    var ampRiseWindowPix: CGFloat = 0.0
    var legatoPitchWindowPix: CGFloat = 0.0
    var rhythmTolWindowPix: CGFloat = 0.0
    
    func changeZoom(zoom: Double) {
        wdMult = CGFloat(zoom)
        calcHeightMulitplier()
        setNeedsDisplay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        numHtPix = self.frame.height
        self.backgroundColor = UIColor.white.withAlphaComponent(1.0)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported for WaveformView")
    }

    func displayAmplitude() {
        clearScreen()
        adjustSize()
        calcHeightMulitplier()
        setNeedsDisplay()
        
    }
    
    func adjustSize() {
        let numEntries = RTEventMgr.sharedInstance.count()
        let desiredWd:CGFloat = wdMult * CGFloat(numEntries)
        
        self.contentSize.width = desiredWd
    }

    func drawAmpValAt( x: CGFloat, amplitude: CGFloat ) {
        
    }
    
    func clearScreen() {
    
    }
    
    func calcHeightMulitplier() {
        let numEntries = RTEventMgr.sharedInstance.count()
        if numEntries == 0 {
            itsBad()
        }
        var loudestVal = RTEventMgr.sharedInstance.largestAmpValue
        if loudestVal == 0 {
            itsBad()
        }
        loudestVal *= 1.05 // leave a little room at the top
        loudestVal *= valueMult
        htMult = numHtPix/CGFloat(loudestVal)
        
        let currInst = getCurrentStudentInstrument()
        let skipSize = getAmpRiseSamplesToSkip(forInstr: currInst)
        skipWindowPix = CGFloat(skipSize) * wdMult
        
        let riseWindowSize = getNumSamplesInAnalysisWindow(forInstr: currInst)
        ampRiseWindowPix = CGFloat(riseWindowSize+2) * wdMult
        
        let legatoPitchWindowPixSize = getSamplesForLegatoPitchChange()
        //let legatoPitchWindowPixSize = gDifferentPitchSampleThreshold
        legatoPitchWindowPix = CGFloat(legatoPitchWindowPixSize) * wdMult
        
        let attackTol = PerformanceAnalysisMgr.instance.currTolerances.rhythmTolerance
        rhythmTolWindowPix = CGFloat(attackTol) * 100 * wdMult
    }
    
    func invertY( y: CGFloat) -> CGFloat {
        return numHtPix - y
    }
    
    func getConvertedIsASoundThreshold() -> CGFloat {
        var adjIsASoundThreshold = CGFloat(getIsASoundThreshold())
        // return retVal
        
        /*
        let storedIsASoundThreshold = UserDefaults.standard.double(forKey: Constants.Settings.UserNoteThresholdOverride)
        var currIsASoundThreshold   = kAmplitudeThresholdForIsSound
        if storedIsASoundThreshold > 0.01 { // it's been set if not == 0.0
            currIsASoundThreshold = storedIsASoundThreshold
        }
        */
        
        adjIsASoundThreshold *= CGFloat(valueMult)
        adjIsASoundThreshold *= htMult
        adjIsASoundThreshold = invertY(y: adjIsASoundThreshold)
        
        return adjIsASoundThreshold
    }
    
    func getConvertedAmpRiseThreshold() -> CGFloat {
        var adjAmpRiseThreshold = CGFloat(gEighthIsSoundThreshold)  * CGFloat(valueMult)
        adjAmpRiseThreshold *= htMult
        adjAmpRiseThreshold = invertY(y: adjAmpRiseThreshold)
        
        return adjAmpRiseThreshold
    }

    var specialEventIndexes = [Int]()
    var soundRects = [CGRect]()
    var noteRects  = [CGRect]()

    
    func createSoundObjRects() {
        let kXOffset = contentOffset.x
        let kNoSoundStartEntry: CGFloat = -10000.0
        var currSoundStartX: CGFloat = kNoSoundStartEntry
        
        let numSpecialEvents = specialEventIndexes.count
        for spIdx in 0..<numSpecialEvents {
            let idx = specialEventIndexes[spIdx]
            let event = RTEventMgr.sharedInstance.getEventAt(index: idx)
            var newX = convertTimeToPixel(ts: event.timestamp)
            if event.eventType == kRuntimeEventType_NewSound {
                newX -= kXOffset
                currSoundStartX = newX
            }
            if event.eventType == kRuntimeEventType_SoundEnded {
                if currSoundStartX < kNoSoundStartEntry+1.0  {
                    currSoundStartX = -((skipWindowPix + 20.0) * wdMult)
                }
                newX -= kXOffset
                let soundRect = CGRect(x: currSoundStartX, y: 0,
                                       width: newX-currSoundStartX, height: numHtPix)
                soundRects.append(soundRect)
            }
        }
    }
    enum tPattern {
        case diag1
        case diag2
        case parallel
    }
    
    func drawCrossHatchRect(crossRect: CGRect, color: UIColor, pattern: tPattern) {

        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState()
        
        let path:UIBezierPath = UIBezierPath(roundedRect: crossRect, cornerRadius: 0)
        
        path.addClip()
        
        var Y: CGFloat = 0.0
        var X: CGFloat = 0.0
        if pattern == .diag1 {
            X = crossRect.origin.x
            repeat {
                Y += 10.0
                X += 10.0
                let p1 = CGPoint(x:crossRect.origin.x, y:Y)
                let p2 = CGPoint(x:X, y:0)
                path.move(to: p1)
                path.addLine(to: p2)
                color.set()
                path.stroke()
                path.removeAllPoints()
            } while Y < crossRect.size.height + crossRect.size.width
        } else if pattern == .diag2 {
            Y = -crossRect.size.width
            X = crossRect.origin.x
            repeat {
                Y += 10.0
                //X += 10.0
                let p1 = CGPoint(x: crossRect.origin.x, y: Y)
                let p2 = CGPoint(x: crossRect.origin.x+crossRect.size.width, y: Y+crossRect.size.width)
                path.move(to: p1)
                path.addLine(to: p2)
                color.set()
                path.stroke()
                path.removeAllPoints()
            } while Y < crossRect.size.height + crossRect.size.width
        } else {
            X = crossRect.origin.x
            repeat {
                Y += 10.0
                let p1 = CGPoint(x: crossRect.origin.x, y: Y)
                let p2 = CGPoint(x: crossRect.origin.x + crossRect.size.width, y: Y)
                path.move(to: p1)
                path.addLine(to: p2)
                color.set()
                path.stroke()
                path.removeAllPoints()
            } while Y < crossRect.size.height + crossRect.size.width
        }
        
        ctx?.restoreGState()
    }
    
    var alternateY = CGFloat(0.0)
    func drawSoundID(id: Int, x: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        let attribs: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font:UIFont( name: "Futura", size: 18.0)!,
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor : UIColor.black]
        
        let retAttrStr =
            NSMutableAttributedString(
                string: "\(id)",
                attributes: attribs )
        // if retAttrStr.length == 0 {
        
        if alternateY < 1.0 {
            alternateY = 40.0
        } else {
            alternateY = 0.0
        }
        let Y = numHtPix - (50 + alternateY)

        let soundIDRect = CGRect(x: x, y: Y, width: 60, height: 35)
        retAttrStr.draw(in: soundIDRect)
    }

    func drawNoteRects() {
        
        let kXOffset = contentOffset.x
        let kNoNoteStartEntry: CGFloat = -10000.0
        var currNoteStartX: CGFloat = kNoNoteStartEntry
        let timeOffset = getNoteOffsetInPixels()

        let numSpecialEvents = specialEventIndexes.count
        for spIdx in 0..<numSpecialEvents {
            let idx = specialEventIndexes[spIdx]
            let event = RTEventMgr.sharedInstance.getEventAt(index: idx)
            var newX = convertTimeToPixel(ts: event.timestamp) // CGFloat(idx) * wdMult
            if event.eventType == kRuntimeEventType_NewNote {
                newX -= kXOffset
                currNoteStartX = newX + timeOffset
            }
            if event.eventType == kRuntimeEventType_NoteEnded {
                if currNoteStartX < kNoNoteStartEntry+1.0  {
                    currNoteStartX = -((skipWindowPix + 20.0) * wdMult)
                }
                newX -= kXOffset
                newX += timeOffset
                let noteRect = CGRect(x: currNoteStartX, y: 20,
                                       width: newX-currNoteStartX, height: 100)
                noteRects.append(noteRect)
            }
        }
    
        // Draw them
        let ctx = UIGraphicsGetCurrentContext()
        
        let numNoteRects = noteRects.count
        for idx in 0..<numNoteRects {
            ctx?.saveGState()
            
            let noteRect = noteRects[idx]
            let backColor = UIColor.magenta.withAlphaComponent(0.3)
            backColor.setFill()
            
            let bezierPath = UIBezierPath(roundedRect: noteRect, cornerRadius: 3.0)
            //            UIColor.yellow.setFill()
            bezierPath.fill()
            
            // Add the Rect x" text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.center
            let attribs: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.font:UIFont( name: "Futura", size: 18.0)!,
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor : UIColor.black]
            
            var retAttrStr =
                NSMutableAttributedString(
                    string: "\(idx+1)-Note",
                    attributes: attribs )
           // if retAttrStr.length == 0 {
            
            var noteIDRect = noteRect
            noteIDRect.size.height = 35
            retAttrStr.draw(in: noteIDRect)
            
            var attackTolPix = rhythmTolWindowPix
            let perfNote =
                PerformanceTrackingMgr.instance.getPerfNote(withID: idx+1)
            if perfNote == nil {
                itsBad()
            } else {
                var idText = "NotLinked"
                if perfNote!.isLinkedToSound {
                    let linkedID = perfNote!.linkedToSoundID
                    idText = "\(linkedID)-Sound"
                }
                retAttrStr =
                    NSMutableAttributedString(string: "\(idText)",
                                              attributes: attribs )
                noteIDRect.origin.y += 30
                retAttrStr.draw(in: noteIDRect)
                attackTolPix = getAttackTolInPix(note: perfNote)
            }
            
            let rhymX  = noteRect.origin.x - attackTolPix
            let rhymY  = noteRect.origin.y + noteRect.size.height - 5
            let rhymHt = CGFloat(10.0)
            let rhymWd = attackTolPix * 2.0
            let rhyTolRect = CGRect(x: rhymX, y: rhymY, width: rhymWd, height: rhymHt)
            let rhyTolPath = UIBezierPath(roundedRect: rhyTolRect, cornerRadius: 3.0)
            let rythColor = UIColor.gray.withAlphaComponent(0.4)
            rythColor.setFill()
            rhyTolPath.fill()
            
            ctx?.restoreGState()
        }
    }

    func getAttackTolInPix(note: PerformanceNote?) -> CGFloat {
        var attackTolPix: CGFloat = 0.0
        guard note != nil else { return attackTolPix }
        
        let attackTol = getRealtimeAttackTolerance(note!)
        //    InstSettingsMgr.sharedInstance.getAdjustedAttackTolerance(note!)

        attackTolPix = CGFloat(attackTol) * 100 * wdMult
        attackTolPix -= 1
        
        return attackTolPix
    }

    
    func drawSoundRects() {
        let ctx = UIGraphicsGetCurrentContext()
        
        var colorCycleNum = Int(0)
        let numSoundRects = soundRects.count
        for idx in 0..<numSoundRects {
            ctx?.saveGState()
            
            let soundRect = soundRects[idx]
            var backColor = UIColor.cyan.withAlphaComponent(0.05)
            switch colorCycleNum {
                case 1:  backColor = UIColor.yellow.withAlphaComponent(0.05)
                default: backColor = UIColor.cyan.withAlphaComponent(0.05)
            }
            colorCycleNum += 1
            if colorCycleNum > 1 {
                colorCycleNum = 0
            }
            backColor.setFill()
            
            let bezierPath = UIBezierPath(roundedRect: soundRect, cornerRadius: 0.0)
            bezierPath.fill()
            
            ctx?.restoreGState()
        }
    }
    
    func drawAmpRiseRects() {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState()
        
        let lineColor = UIColor.red.withAlphaComponent(0.9)
        let kXOffset = contentOffset.x
 //       let kNoSoundStartEntry: CGFloat = -10000.0
//        let currSoundStartX: CGFloat = kNoSoundStartEntry
        
        let numSpecialEvents = specialEventIndexes.count
        for spIdx in 0..<numSpecialEvents {
            let idx = specialEventIndexes[spIdx]
            let event = RTEventMgr.sharedInstance.getEventAt(index: idx)
            var newX = convertTimeToPixel(ts: event.timestamp) // CGFloat(idx) * wdMult
            if event.eventType == kRuntimeEventType_SoundEnded {
                if event.eventDetail1 == kRTEVDetail_SoundEnd_AmpRise {
                    newX -= kXOffset
                    let prevX = newX - ampRiseWindowPix
                    let ampRiseRect = CGRect(x: prevX, y: 0, width: newX-prevX, height: numHtPix)
                    drawCrossHatchRect(crossRect: ampRiseRect, color: lineColor, pattern: .diag2)
                }
            }
        }
        ctx?.restoreGState()
    }
    
    
    func drawLegatoPitchChangeRects() {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState()
        
        let lineColor = UIColor.orange.withAlphaComponent(1.0)
        let kXOffset = contentOffset.x
        let kNoSoundStartEntry: CGFloat = -10000.0//
//        let currSoundStartX: CGFloat = kNoSoundStartEntry
        
        let numSpecialEvents = specialEventIndexes.count
        for spIdx in 0..<numSpecialEvents {
            let idx = specialEventIndexes[spIdx]
            let event = RTEventMgr.sharedInstance.getEventAt(index: idx)
            var newX = convertTimeToPixel(ts: event.timestamp) // CGFloat(idx) * wdMult
            if event.eventType == kRuntimeEventType_SoundEnded {
                if event.eventDetail1 == kRTEVDetail_SoundEnd_Pitch {
                    newX -= kXOffset
                    let prevX = newX - legatoPitchWindowPix
                    let ampRiseRect = CGRect(x: prevX, y: 0, width: newX-prevX, height: numHtPix)
                    drawCrossHatchRect(crossRect: ampRiseRect, color: lineColor, pattern: .parallel)
                }
            }
        }
        ctx?.restoreGState()
    }

    func drawSkipWindowRects() {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState()
        
        let lineColor = UIColor.blue.withAlphaComponent(0.4)
        let numSoundRects = soundRects.count
        for idx in 0..<numSoundRects {
            let soundRect = soundRects[idx]
            var wRect = soundRect
            if ( soundRect.size.width > skipWindowPix) {
                wRect.size.width = skipWindowPix
            }
//            print("\nCrossHatchRect #\(idx),  x:\(wRect.origin.x), y:\(wRect.origin.y),   w:\(wRect.size.width), h:\(wRect.size.height)\n")
            drawCrossHatchRect(crossRect: wRect, color: lineColor, pattern: .diag1)
        }
        ctx?.restoreGState()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.backgroundColor = UIColor.white

        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState()

        //if self.isHidden == true {
        if !isShowing {
            return
        }
        
        specialEventIndexes.removeAll()
        soundRects.removeAll()
        noteRects.removeAll()
        
        let XOffset = contentOffset.x
        let wd = self.contentSize.width //  self.frame.size.width

        // IsASound threshold
        let threshY = getConvertedIsASoundThreshold()
        // Create  path
        let threshLine = UIBezierPath()
        threshLine.lineWidth = 2.0
        var threshPoint = CGPoint(x: CGFloat(0), y: threshY)
        threshLine.move(to: threshPoint)
        threshPoint = CGPoint(x: wd, y: threshY)
        threshLine.addLine(to: threshPoint)

        UIColor.red.setStroke()
        threshLine.stroke()
        
        
        // EighthIsASound threshold - ending sound when tongued
        if gUseEighthIsSoundThresholdInGeneral {
            let ampThreshY = getConvertedAmpRiseThreshold()
            let ampThreshLine = UIBezierPath()
            ampThreshLine.lineWidth = 2.0
            var ampThreshPoint = CGPoint(x: CGFloat(0), y: ampThreshY)
            ampThreshLine.move(to: ampThreshPoint)
            ampThreshPoint = CGPoint(x: wd, y: ampThreshY)
            ampThreshLine.addLine(to: ampThreshPoint)
            
            let dashPattern : [CGFloat] = [16, 16]
            ampThreshLine.setLineDash(dashPattern, count: 2, phase: 0)
            ampThreshLine.lineCapStyle = CGLineCap.round
            ampThreshLine.lineCapStyle = .butt
            
            UIColor.purple.setStroke()
            ampThreshLine.stroke()
        }
        
        // Create  path
        let graphLine = UIBezierPath()
        graphLine.lineWidth = 2.0
        
        var first = true
        let numEntries = RTEventMgr.sharedInstance.count()
        for idx in 0..<numEntries {
            let event = RTEventMgr.sharedInstance.getEventAt(index: idx)
            if event.eventType == kRuntimeEventType_Amplitude {
                var newX = convertTimeToPixel(ts: event.timestamp)
                if newX >= XOffset {
                    newX -= XOffset
                    let rawAmpl = CGFloat(event.value)
                    var adjAmpl = CGFloat(rawAmpl) * CGFloat(valueMult)
                    adjAmpl = CGFloat(adjAmpl * htMult)
                    let newY = invertY(y: adjAmpl)
                    let newPoint = CGPoint(x: newX, y: newY)
                    if first { // idx == 0 { // just starting
                        graphLine.move(to: newPoint)
                    } else {
                        graphLine.addLine(to: newPoint)
                    }
                    first = false
                }
            } else {
                specialEventIndexes.append(idx)
            }
            var yowser = 1
            if idx == 100 {
                yowser = 2
            }
        }
        
        UIColor.blue.setStroke()
        graphLine.stroke()

        createSoundObjRects()
        drawSoundRects()
        drawSkipWindowRects()
        drawAmpRiseRects()
        drawLegatoPitchChangeRects()
        drawNoteRects()
        
        let numSpecialEveents = specialEventIndexes.count
        for spIdx in 0..<numSpecialEveents {
            let idx = specialEventIndexes[spIdx]
            let event = RTEventMgr.sharedInstance.getEventAt(index: idx)
            var newX = convertTimeToPixel(ts: event.timestamp)
            if event.eventType == kRuntimeEventType_NewSound {
                if newX >= XOffset {
                    newX -= XOffset
                    var newPoint = CGPoint(x: newX, y: 0)
                    let soundLine = UIBezierPath()
                    soundLine.lineWidth = 3.0
                    soundLine.move(to: newPoint)
                    newPoint = CGPoint(x: newX, y: numHtPix)
                    soundLine.addLine(to: newPoint)
                    UIColor.green.setStroke()
                    soundLine.stroke()
                    let soundID = event.associatedID
                    drawSoundID(id: Int(soundID), x: newX)
                }
            }
            if event.eventType == kRuntimeEventType_SoundEnded {
                if newX >= XOffset {
                    newX -= XOffset
                    newX -= 2.0 // to be seen; can get overwritten by Start Line
                    var newPoint = CGPoint(x: newX, y: 0)
                    let soundLine = UIBezierPath()
                    soundLine.lineWidth = 4.0
                    soundLine.move(to: newPoint)
                    newPoint = CGPoint(x: newX, y: numHtPix)
                    soundLine.addLine(to: newPoint)
                    UIColor.red.setStroke()
                    soundLine.stroke()
                }
            }
        }
        ctx?.restoreGState()
    }
    
    func convertTimeToPixel(ts: TimeInterval) -> CGFloat {
        var x = CGFloat(0.0)
        let times100 = ts * 100.0
        x = CGFloat(times100)
        x *= wdMult
        return x
    }
    
    func getNoteOffsetInPixels() -> CGFloat {
        var offset = CGFloat(0.0)
        let soundStartAdjustment = getSoundStartOffset()
        let times100 = soundStartAdjustment * 100.0
        //let times100 = gSoundStartAdjustment * 100.0
        offset = CGFloat(times100)
        offset *= wdMult
        return offset
    }
}
