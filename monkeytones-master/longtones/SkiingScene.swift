//
//  SkiingScene.swift
//  monkeytones
//
//  Created by 1 1 on 04.11.16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
import SpriteKit

class SkiingScene: BasicScene {
    
    var monkeySprt:SKSpriteNode!
    var monkeyParent:SKNode!
    var groundSprt:SKSpriteNode!
    var treesSprt:SKSpriteNode!
    var treesBackSprt:SKSpriteNode!
    var mountainsBackSprt:SKSpriteNode!
    
    var monkeyFallenAnim:SKAction!
    var monkeyInSnowAnim:SKAction!
    var monkeySuccessAnim:SKAction!
    
    var noteHit = false
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.green
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        let bgdSprite = SKSpriteNode(imageNamed: "Monkey_Skiing-Sky-01.png")
        bgdSprite.anchorPoint = CGPoint(x: 0,y: 0)
        bgdSprite.position = CGPoint(x: 0, y: 0)
        bgdSprite.zPosition = -1
        bgdSprite.size = view.bounds.size
        self.addChild(bgdSprite)
        
        
        let bgdSprite1 = SKSpriteNode(imageNamed: "Monkey_Skiing-clouds.png")
        bgdSprite1.anchorPoint = CGPoint(x: 0,y: 1)
        bgdSprite1.position = CGPoint(x: 0, y: view.frame.height)
        bgdSprite1.zPosition = 1
        self.addChild(bgdSprite1)
        
        mountainsBackSprt = SKSpriteNode(imageNamed: "Monkey_Skiing_montains back.png")
        mountainsBackSprt.anchorPoint = CGPoint(x: 0,y: 0)
        mountainsBackSprt.position = CGPoint(x: 0, y: 0)
        mountainsBackSprt.zPosition = 2
        self.addChild(mountainsBackSprt)
        
        treesBackSprt = SKSpriteNode(imageNamed: "Monkey_Skiing_tress back.png")
        treesBackSprt.anchorPoint = CGPoint(x: 0,y: 0)
        treesBackSprt.position = CGPoint(x: 0, y: 0)
        treesBackSprt.zPosition = 3
        self.addChild(treesBackSprt)
        
        
        groundSprt = SKSpriteNode(imageNamed: "Monkey_Skiing_snow monkey.png")
        groundSprt.anchorPoint = CGPoint(x: 0,y: 0)
        groundSprt.position = CGPoint(x: -60, y: -100)
        groundSprt.setScale(1.9)
        groundSprt.zPosition = 4
        self.addChild(groundSprt)
        
        monkeyParent = SKNode()
        monkeyParent.position = CGPoint(x: 0,y:0)
        groundSprt.addChild(monkeyParent)
        
        // Monkey
        
        monkeySprt = SKSpriteNode(imageNamed: "Monkey_Skiing_01.png")
        monkeySprt.position = CGPoint(x: 90, y: 140)
        monkeySprt.zPosition = 7
        monkeySprt.zRotation = -0.3
        monkeyParent.addChild(monkeySprt)
        
        let mAction1 = SKAction.moveBy(x: 0, y: 5, duration: 1.5)
        let mAction2 = SKAction.moveBy(x: 0, y: -5, duration: 1.5)
        let mSeq = SKAction.sequence([mAction1,mAction2])
        let mRepeat = SKAction.repeatForever(mSeq)
        monkeySprt.run(mRepeat)
        
        // Flags
        
        initFlags()
        
        // Frame Animations
        
        monkeyFallenAnim = SKAction.animate(with: [SKTexture(imageNamed:"Monkey_Skiing_04.png")], timePerFrame: 0.1, resize: true, restore: false)
        
        monkeyInSnowAnim = SKAction.animate(with: [SKTexture(imageNamed:"Monkey_Skiing_05.png")], timePerFrame: 0.1, resize: true, restore: false)
        monkeySuccessAnim = SKAction.animate(with: [SKTexture(imageNamed:"Monkey_Skiing_06.png")], timePerFrame: 0.1, resize: true, restore: false)
        
        /*
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.startStream()
        }
        
        let deadlineTime2 = DispatchTime.now() + .seconds(4)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime2) {
            self.showSuccess {
                
                }
        }
        */
        
    }
    
    func initFlags()
    {
        let flagsSprite1 = SKSpriteNode(imageNamed: "Monkey_Skiing-yelow flags.png")
        flagsSprite1.anchorPoint = CGPoint(x: 0, y: 0)
        flagsSprite1.position = CGPoint(x: 130, y: -90)
        flagsSprite1.zPosition = 8
        monkeyParent.addChild(flagsSprite1)
        
        let flagsSprite2 = SKSpriteNode(imageNamed: "Monkey_Skiing-blue flags.png")
        flagsSprite2.anchorPoint = CGPoint(x: 0, y: 0)
        flagsSprite2.position = CGPoint(x: 185, y: -45)
        flagsSprite2.zPosition = 6
        monkeyParent.addChild(flagsSprite2)

        let action1 = SKAction.move(to: CGPoint(x: -60, y: 140), duration: 1.0)
        let block1 = SKAction.run {
            if !self.noteHit
            {
                flagsSprite1.position = CGPoint(x: 130, y: -90)
            }
        }
        let seq1 = SKAction.sequence([action1,block1])
        let repeat1 = SKAction.repeatForever(seq1)
        flagsSprite1.run(repeat1)
        
        
        let wait = SKAction.wait(forDuration: 0.3)
        let runWrap = SKAction.run { 
            let action2 = SKAction.move(to: CGPoint(x: -10, y: 170), duration: 1.0)
            let block2 = SKAction.run {
                if !self.noteHit
                {
                    flagsSprite2.position = CGPoint(x: 185, y: -45)
                }
            }
            let seq2 = SKAction.sequence([action2,block2])
            let repeat2 = SKAction.repeatForever(seq2)
            flagsSprite2.run(repeat2)
        }
        self.run(SKAction.sequence([wait,runWrap]))
        
        
    }
    
    func completAnimation()
    {
        
    }
    
    // MARK: - BasicScene
    
    override func startStream()
    {
        noteHit = true
        
        let longAnimDur = 60.0
        
        let scale = SKAction.scale(to: 1.0, duration: 0.6)
        let move = SKAction.move(to: CGPoint(x: -490, y: 0), duration: 2.0)
        groundSprt.run(scale)
        groundSprt.run(move)
        
        let gWait = SKAction.wait(forDuration: 2.0)
        let gMove = SKAction.moveBy(x: -250, y: 0, duration: longAnimDur)
        let gSeq = SKAction.sequence([gWait,gMove])
        groundSprt.run(gSeq)
        
        
        // Trees 
        
        treesSprt = SKSpriteNode(imageNamed: "Monkey_Skiing_tress front.png")
        treesSprt.anchorPoint = CGPoint(x:0,y:0)
        treesSprt.position = CGPoint(x:900,y:-50)
        treesSprt.zPosition = 2
        monkeyParent.addChild(treesSprt)
        
        
        let tMove = SKAction.move(to: CGPoint(x: -30, y: treesSprt.position.y), duration: 3.0)
        let tBlock = SKAction.run {
            self.treesSprt.position = CGPoint(x: 900, y: self.treesSprt.position.y)
        }
        let tSeq = SKAction.sequence([tMove,tBlock])
        let tRepeat = SKAction.repeatForever(tSeq)
        treesSprt.run(tRepeat)
        
        let tMove2 = SKAction.moveBy(x: -700, y: 0, duration: longAnimDur)
        treesBackSprt.run(tMove2)
        
        let tMove3 = SKAction.moveBy(x: -700, y: 0, duration: 1.5*longAnimDur)
        mountainsBackSprt.run(tMove3)
        
        // monkey
        //monkeySprt.zRotation = 0
        
        let cgpath = CGMutablePath()
        let startingPoint = monkeySprt.position
        let endingPoint = CGPoint(x:380,y:220)
        
        let controlPoint1 = CGPoint(x:350, y:-95)
        let controlPoint2 = CGPoint(x:350, y:260)
        
        cgpath.move(to: CGPoint(x: startingPoint.x, y: startingPoint.y))
        cgpath.addCurve(to: CGPoint(x: endingPoint.x, y: endingPoint.y), control1: CGPoint(x: controlPoint1.x, y: controlPoint1.y), control2: CGPoint(x: controlPoint2.x, y: controlPoint2.y))

        let mMove = SKAction.follow(cgpath, asOffset: false, orientToPath: false, duration: 1.0)
        let mRotation = SKAction.rotate(toAngle: 1.6, duration: 0.7)
        
        let mMove2 = SKAction.moveBy(x: 210, y: -40, duration: 1.0)
        let mRotation2 = SKAction.rotate(toAngle: 0.7, duration: 1.0)
        mRotation2.timingMode = .easeIn
        
        let group = SKAction.group([mMove2,mRotation2])
        
        let seq = SKAction.sequence([mMove,group])
        
        monkeySprt.run(seq)
        monkeySprt.run(mRotation)
        
        let mLongMove = SKAction.moveBy(x: 250, y: 0, duration: longAnimDur)
        monkeyParent.run(mLongMove)
        

    }
    
    override func showSuccess(completion: @escaping (() -> Void ))
    {
        groundSprt.removeAllActions()
        monkeyParent.removeAllActions()
        treesBackSprt.removeAllActions()
        treesSprt.removeAllActions()
        mountainsBackSprt.removeAllActions()
        monkeySprt.removeAllActions()
        
        treesSprt.run(SKAction.moveBy(x: 0, y: -treesSprt.frame.size.height, duration: 0.5))

        let move = SKAction.move(to: CGPoint(x: groundSprt.position.x, y: 0), duration: 0.2)
        let scale = SKAction.scale(to: 1.0, duration: 0.2)
        groundSprt.run(scale)
        groundSprt.run(move)
        
        let mMove = SKAction.move(to: CGPoint(x: monkeySprt.position.x + 50, y: 46), duration: 0.5)
        mMove.timingMode = .easeIn
        let mRotate = SKAction.rotate(toAngle: 0.4, duration: 0.29)
        mMove.timingMode = .easeIn
        
        let block = SKAction.run {
            self.monkeySprt.run(self.monkeySuccessAnim)
            self.monkeySprt.zRotation = 0
            
            self.run(SKAction.sequence([SKAction.wait(forDuration: 2.5),SKAction.run(completion)]))

            
            let yeahSprite = SKSpriteNode(imageNamed: "Monkey_Skiing_yeah.png")
            yeahSprite.anchorPoint = CGPoint(x: 0, y: 0)
            yeahSprite.position = CGPoint(x: self.monkeySprt.size.width - 60, y: self.monkeySprt.size.height - 40)
            self.monkeySprt.addChild(yeahSprite)
            yeahSprite.setScale(0)
            yeahSprite.run(SKAction.scale(to: 1.0, duration: 0.1))
            
        }
        let seq = SKAction.sequence([mMove,block])
        monkeySprt.run(seq)
        monkeySprt.run(mRotate)
    }
    
    override func showFail()
    {
        groundSprt.removeAllActions()
        monkeyParent.removeAllActions()
        treesBackSprt.removeAllActions()
        treesSprt.removeAllActions()
        mountainsBackSprt.removeAllActions()
        monkeySprt.removeAllActions()

        treesSprt.run(SKAction.moveBy(x: 0, y: -treesSprt.frame.size.height, duration: 0.5))
        
        let move = SKAction.move(to: CGPoint(x: groundSprt.position.x, y: 0), duration: 0.2)
        let scale = SKAction.scale(to: 1.0, duration: 0.2)
        groundSprt.run(scale)
        groundSprt.run(move)

        let mMove = SKAction.move(to: CGPoint(x: monkeySprt.position.x + 50, y: 26), duration: 0.5)
        mMove.timingMode = .easeIn
        
        let block = SKAction.run {
            let mMove2 = SKAction.moveBy(x: 60, y: 20, duration: 0.7)
            let rotate = SKAction.rotate(byAngle: -2*CGFloat.pi, duration: 0.3)
            let mRepeat = SKAction.repeatForever(rotate)
            let mScale = SKAction.scale(to: 1.5, duration: 0.7)
            
            let mBlock = SKAction.run({
                self.monkeySprt.removeAllActions()
                self.monkeySprt.zRotation = 0
                self.monkeySprt.run(self.monkeyInSnowAnim)
                
                
                //self.run(SKAction.sequence([SKAction.wait(forDuration: 2.0),SKAction.run(completion)]))
                
            })
            
            let seq = SKAction.sequence([mMove2,mBlock])
            
            self.monkeySprt.run(seq)
            self.monkeySprt.run(mRepeat)
            self.monkeySprt.run(mScale)
            
        }
        let seq = SKAction.sequence([mMove,block])
        monkeySprt.run(seq)
        monkeySprt.run(monkeyFallenAnim)

    }
}

