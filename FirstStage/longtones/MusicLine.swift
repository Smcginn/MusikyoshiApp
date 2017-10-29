//
//  MusicLine.swift
//  longtones
//
//  Created by Adam Kinney on 6/7/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
import UIKit

class MusicLine: UIView {
    
    //    var isVerticalPrint = true {
    //        didSet{
    //            setNeedsDisplay()
    //        }
    //    }
    
    var exercise : Exercise?//{
//        didSet{
//            setNeedsDisplay()
//        }
    //}
    
    let fontColor = UIColor.black.cgColor
    let fontSize = CGFloat(40.0)
    let musicFont = CTFontCreateWithName("Bravura" as CFString?, 10, nil)
    
    var bassClef:Bool! = false
    
    override func draw(_ dirtyRect: CGRect) {
        drawMusic()
    }
    
    fileprivate func createMusicLayer(_ character : MusicFont, _ frame : CGRect) -> CATextLayer{
        return createTextLayer(character.rawValue, frame)
    }
    
    fileprivate func createTextLayer(_ text : String, _ frame : CGRect) -> CATextLayer{
        let layer = CATextLayer()
        layer.font = musicFont
        layer.fontSize = fontSize
        layer.foregroundColor = fontColor
        layer.contentsScale = UIScreen.main.scale
        layer.string = text
        layer.frame = frame
        
        return layer
    }
    
    fileprivate func drawMusic(){
        
        //ensure exercise is set
        guard let ex = exercise else {return}
        
        //function variables
        var exWidth = 0.0
        
        //determine full exercise width
        for m in ex.measures
        {
            exWidth += m.width
            let barlineLayer = createMusicLayer(.BarlineSingle, CGRect.init(x: exWidth, y: 0, width: 20, height: 100))
            layer.addSublayer(barlineLayer)
        }
        
        let remainder : Double = exWidth.truncatingRemainder(dividingBy: 20)
        if remainder > 0
        {
            exWidth = exWidth - remainder + 20
        }
        
        //draw staff lines
        let stavesNeeded = Int(exWidth / 20)
        var stavesStr = ""
        for _ in 1...stavesNeeded
        {
            stavesStr += MusicFont.Staff5LinesNarrow.rawValue
        }
        
        let stavesLayer = createTextLayer(stavesStr, CGRect.init(x: 0, y: 0, width: exWidth, height: 100))
        layer.addSublayer(stavesLayer)
        
        //draw clef
        let clef = (bassClef == true) ? MusicFont.BassClef : MusicFont.GClef
        let clefFrame = (bassClef == true) ? CGRect(x: 2, y: -30, width: 30, height: 160) : CGRect(x: 2, y: -10, width: 30, height: 160)
        let clefLayer = createMusicLayer( clef, clefFrame)
        layer.addSublayer(clefLayer)
        
        //draw time signature
        /*
        let timeLayer = createMusicLayer(.TimeSig4over4, CGRect.init(x: 40, y: 0, width: 20, height: 100))
        layer.addSublayer(timeLayer)
        */
        
        var xPos = 0.0
        for m in ex.measures
        {
            for n in m.notes
            {
                if !n.isRest
                {
                    let yPos = NoteService.getYPos(n.orderId)
                    let xNote = xPos + n.xPos
                    
                    
                    /*
                    if let so = NoteService.getNoteOffset(n.orderId)
                    {
                        let lineThroughLayer = createMusicLayer(so.character, CGRect.init(x: CGFloat(xNote + so.x), y: CGFloat(yPos + so.y), width: 23, height: 100))
                        layer.addSublayer(lineThroughLayer)
                    }*/
                    
                    
                    switch yPos {
                    case -50:
                        let lineThroughLayer = createMusicLayer(MusicFont.Staff1LineWide, CGRect.init(x: CGFloat(xNote  - 3), y: CGFloat(yPos + 20), width: 23, height: 100))
                        layer.addSublayer(lineThroughLayer)
                    case -55:
                        let lineThroughLayer = createMusicLayer(MusicFont.Staff1LineWide, CGRect.init(x: CGFloat(xNote  - 3), y: CGFloat(yPos + 25), width: 23, height: 100))
                        layer.addSublayer(lineThroughLayer)
                    case -60:
                        let lineThroughLayer = createMusicLayer(MusicFont.Staff2LineWide, CGRect.init(x: CGFloat(xNote  - 3), y: CGFloat(yPos + 25), width: 23, height: 100))
                        layer.addSublayer(lineThroughLayer)
                    case 10:
                        let lineThroughLayer = createMusicLayer(MusicFont.Staff1LineWide, CGRect.init(x: CGFloat(xNote  - 3), y: CGFloat(yPos + 20), width: 23, height: 100))
                        layer.addSublayer(lineThroughLayer)
                    case 15:
                        let lineThroughLayer = createMusicLayer(MusicFont.Staff1LineWide, CGRect.init(x: CGFloat(xNote  - 3), y: CGFloat(yPos + 15), width: 23, height: 100))
                        layer.addSublayer(lineThroughLayer)
                    case 20:
                        let lineThroughLayer = createMusicLayer(MusicFont.Staff2LineWide, CGRect.init(x: CGFloat(xNote  - 3), y: CGFloat(yPos + 15), width: 23, height: 100))
                        layer.addSublayer(lineThroughLayer)
                    case 25:
                        let lineThroughLayer = createMusicLayer(MusicFont.Staff2LineWide, CGRect.init(x: CGFloat(xNote  - 3), y: CGFloat(yPos + 10), width: 23, height: 100))
                        layer.addSublayer(lineThroughLayer)

                    default:
                        break
                    }
                    
                    
                    if n.name.contains("♭")
                    {
                        let flatLayer = createMusicLayer(.AccidentalFlat, CGRect.init(x: CGFloat(xNote - 12), y: CGFloat(yPos), width: 23, height: 100))
                        layer.addSublayer(flatLayer)
                    }
                    
                    if n.name.contains("#")
                    {
                        let flatLayer = createMusicLayer(.AccidentalSharp, CGRect.init(x: CGFloat(xNote - 12), y: CGFloat(yPos), width: 23, height: 100))
                        layer.addSublayer(flatLayer)
                    }
                    
                    var char = MusicFont.NoteHeadWhole
                    var stemNeeded = false
                    
                    if n.length == NoteLength.quarter
                    {
                        char = .NoteHeadBlack
                        stemNeeded = true
                    }
                    else if n.length == NoteLength.half
                    {
                        char = .NoteHeadHalf
                        stemNeeded = true
                    }
                    
                    let noteLayer = createMusicLayer(char, CGRect.init(x: CGFloat(xNote), y: CGFloat(yPos), width: 20, height: 100))
                    //noteLayer.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.2).CGColor
                    layer.addSublayer(noteLayer)
                    
                    if stemNeeded
                    {
                        var xxPos = CGFloat(xNote)
                        var yyPos = CGFloat(yPos)
                        if n.orderId > 59
                        {
                            yyPos += 38
                        }
                        else
                        {
                            xxPos += 11
                        }
                        
                        let stemLayer = createMusicLayer(.Stem, CGRect.init(x: xxPos, y: yyPos, width: 2, height: 100))
                        layer.addSublayer(stemLayer)
                    }
                }
                else
                {
                    let restLayer = createMusicLayer(.RestWhole, CGRect.init(x: xPos + (m.width / 2) - 5, y: -30, width: 11, height: 100))
                    layer.addSublayer(restLayer)
                }
            }
            
            xPos += m.width
        }
        
        //self.frame = CGRectMake(0, 0, CGFloat(xPos), 128)
        
        if let sv = self.superview as? UIScrollView
        {
            sv.contentSize = CGSize(width: self.frame.width, height: 0)
        }
    }
}
