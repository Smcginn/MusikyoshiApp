//
//  LakeScene.swift
//  monkeytones
//
//  Created by 1 1 on 21.10.16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
import SpriteKit

class LakeScene: BasicScene {
    
    var monkeySprt:SKSpriteNode!
    var windSprt:SKSpriteNode!
    var splashSprt:SKSpriteNode!
    
    var treeBgSprt:SKSpriteNode!
    
    var idleAnimation:SKAction!
    
    override func didMove(to view: SKView) {
        
        let bgdSprite = SKSpriteNode(imageNamed: "Monkey_Lake_Sky.png")
        bgdSprite.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        bgdSprite.position = CGPoint(x: size.width/2, y: size.height/2)
        bgdSprite.zPosition = -1
        self.addChild(bgdSprite)
        self.aspectStretch(sprite: bgdSprite, toHeight: self.size.height)

        
        let bgdSprite1 = SKSpriteNode(imageNamed: "Monkey_Lake-clouds.png")
        bgdSprite1.anchorPoint = CGPoint(x: 0,y: 0)
        bgdSprite1.zPosition = 1
        bgdSprite1.position = CGPoint(x: -140,y: 20)
        self.addChild(bgdSprite1)
        self.aspectStretch(sprite: bgdSprite1, toHeight: self.size.height)
        
        let bgdSprite2 = SKSpriteNode(imageNamed: "Monkey_Lake-plants 03.png")
        bgdSprite2.anchorPoint = CGPoint(x: 0,y: 0)
        bgdSprite2.zPosition = 2
        bgdSprite2.position = CGPoint(x: -20, y: 20)
        self.addChild(bgdSprite2)
        self.aspectStretch(sprite: bgdSprite2, toWidth: self.size.width+20)

        
        let bgdSprite3 = SKSpriteNode(imageNamed: "Monkey_Lake-plants 02.png")
        bgdSprite3.anchorPoint = CGPoint(x: 0,y: 0)
        bgdSprite3.zPosition = 3
        bgdSprite3.position = CGPoint(x: -20, y: 20)
        self.addChild(bgdSprite3)
        self.aspectStretch(sprite: bgdSprite3, toWidth: self.size.width+20)

        
        let bgdSprite4 = SKSpriteNode(imageNamed: "Monkey_Lake-plants 01.png")
        bgdSprite4.anchorPoint = CGPoint(x: 0,y: 0)
        bgdSprite4.zPosition = 4
        bgdSprite4.position = CGPoint(x: -20, y: 20)
        self.addChild(bgdSprite4)
        self.aspectStretch(sprite: bgdSprite4, toWidth: self.size.width+20)

        
        treeBgSprt = SKSpriteNode(imageNamed: "Monkey_Lake-Lake and tree.png")
        treeBgSprt.anchorPoint = CGPoint(x: 0,y: 0)
        treeBgSprt.zPosition = 5
        treeBgSprt.position = CGPoint(x: 0, y: -2)
        self.addChild(treeBgSprt)
        self.aspectStretch(sprite: treeBgSprt, toWidth: self.size.width)

        let bgdSprite5_m = SKSpriteNode(imageNamed: "Monkey_Lake-tree-mirrored.png")
        bgdSprite5_m.anchorPoint = CGPoint(x: 0,y: 0)
        bgdSprite5_m.zPosition = 5
        bgdSprite5_m.position = CGPoint(x: treeBgSprt.size.width * 0.045, y: -2)
        self.addChild(bgdSprite5_m)
        self.aspectStretch(sprite: bgdSprite5_m, toWidth: self.size.width)

        
        let bgdSprite6 = SKSpriteNode(imageNamed: "branch.png")
        bgdSprite6.anchorPoint = CGPoint(x: 0,y: 0)
        bgdSprite6.zPosition = 6
        bgdSprite6.position = CGPoint(x: treeBgSprt.size.width * 0.095, y: treeBgSprt.size.height*0.47)
        self.addChild(bgdSprite6)

        let bgdSprite6_m = SKSpriteNode(imageNamed: "branch.png")
        bgdSprite6_m.anchorPoint = CGPoint(x: 0,y: 0)
        bgdSprite6_m.xScale = -1
        bgdSprite6_m.zPosition = 6
        bgdSprite6_m.position = CGPoint(x: treeBgSprt.size.width - treeBgSprt.size.width * 0.050, y: treeBgSprt.size.height*0.47)
        self.addChild(bgdSprite6_m)

        
        // Monkey
        monkeySprt = SKSpriteNode(imageNamed: "monkey-branch.png")
        monkeySprt.anchorPoint = CGPoint(x: 0.5,y: 0)
        monkeySprt.zPosition = 7
        monkeySprt.position = CGPoint(x: treeBgSprt.size.width * 0.23, y: treeBgSprt.size.height*0.49)
        self.addChild(monkeySprt)

        idleAnimation = SKAction.animate(with: [SKTexture(imageNamed: "monkey-branch.png")], timePerFrame: 0.1)
        
        //Wind
        windSprt = SKSpriteNode(imageNamed: "Monkey_Lake-wind.png")
        windSprt.anchorPoint = CGPoint(x: 0,y: 0.5)
        windSprt.zPosition = 8
        windSprt.position = CGPoint(x: 30, y: view.frame.height/2)
        self.addChild(windSprt)
        
        windSprt.alpha = 0
        windSprt.setScale(0.4)
        
        
        let action1 = SKAction.run({
            let y = Int(UInt32(arc4random()) % UInt32(50)) - 25
            self.windSprt.position = CGPoint(x:self.windSprt.position.x, y: view.frame.height/2 + CGFloat(y))
            self.windSprt.run(SKAction.move(by: CGVector(dx: 60, dy: 0), duration: 3.0))
        }, queue: DispatchQueue.global())
    
        
        let action2 = SKAction.fadeIn(withDuration: 1.5)
        let action3 = SKAction.fadeOut(withDuration: 1.5)
        let block = SKAction.run { 
            self.windSprt.position = CGPoint(x: 30, y: view.frame.height/2)
        }
        let wait = SKAction.wait(forDuration: 1.5)
        let seq = SKAction.sequence([action2,action3,block,wait])
        
        let spawn = SKAction.group([action1,seq])
        
        let repeatFrvr = SKAction.repeatForever(spawn)
        
        windSprt.run(repeatFrvr)
        
        
        // Splash 
        
        splashSprt = SKSpriteNode(imageNamed: "Monkey_Lake-Splash.png")
        splashSprt.anchorPoint = CGPoint(x: 0.5,y: 0)
        splashSprt.zPosition = 9
        splashSprt.position = CGPoint(x: 30, y: 0)
        splashSprt.alpha = 0
        self.addChild(splashSprt)

        /*
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.startStream()
        }
        
        let deadlineTime2 = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime2) {
            self.showSuccess {
                
            }
        }
        
        */
        
    }
    
    
    // MARK: - BasicScene
    
    override func startStream()
    {
        // Wind
        
        windSprt.removeAllActions()
        
        windSprt.alpha = 0
        windSprt.setScale(1)
        
        
        let action1 = SKAction.run({
            let y = Int(UInt32(arc4random()) % UInt32(70)) - 35
            self.windSprt.position = CGPoint(x:self.windSprt.position.x, y: (self.view?.frame.height)!/2 + CGFloat(y))
            self.windSprt.run(SKAction.move(by: CGVector(dx: 100, dy: 0), duration: 1.0))
            }, queue: DispatchQueue.global())
        
        
        let action2 = SKAction.fadeIn(withDuration: 0.5)
        let action3 = SKAction.fadeOut(withDuration: 0.5)
        let block = SKAction.run {
            self.windSprt.position = CGPoint(x: 30, y: (self.view?.frame.height)!/2)
        }
        let wait = SKAction.wait(forDuration: 0.1)
        let seq = SKAction.sequence([action2,action3,block,wait])
        
        let spawn = SKAction.group([action1,seq])
        
        let repeatFrvr = SKAction.repeatForever(spawn)
        
        windSprt.run(repeatFrvr)
        
        // Monkey
        monkeySprt.setScale(0.8)
        monkeySprt.texture = SKTexture(imageNamed: "Monkey_Lake-monkey02.png")
        let mAction1 = SKAction.move(to: CGPoint(x: self.size.width/2+35, y: monkeySprt.position.y+60), duration: 0.4)
        mAction1.timingMode = SKActionTimingMode.easeOut
        
        let mAction2 = SKAction.run { 
            self.monkeySprt.texture = SKTexture(imageNamed: "Monkey_Lake-monkey03.png")
            
            let mmAction1 = SKAction.move(to: CGPoint(x: self.monkeySprt.position.x, y: self.monkeySprt.position.y + 10), duration: 0.3)
            let mmAction2 = SKAction.move(to: CGPoint(x: self.monkeySprt.position.x, y: self.monkeySprt.position.y - 10), duration: 0.3)
            mmAction1.timingMode = SKActionTimingMode.easeInEaseOut
            mmAction2.timingMode = SKActionTimingMode.easeInEaseOut
            let mmSeq1 = SKAction.sequence([mmAction1,mmAction2])
            let mmRepeat1 = SKAction.repeatForever(mmSeq1)
            
            self.monkeySprt.run(mmRepeat1)
            
            let mmAction3 = SKAction.rotate(byAngle: 2.0*CGFloat.pi, duration: 0.8)
            let mmRepeat2 = SKAction.repeatForever(mmAction3)
            self.monkeySprt.run(mmRepeat2)
        }
        
        
        let mSeq = SKAction.sequence([mAction1,mAction2])
        
        self.monkeySprt.run(mSeq)
    }
    
    override func showSuccess(completion: @escaping () -> Void)
    {
        windSprt.removeAllActions()
        windSprt.run(SKAction.fadeOut(withDuration: 0.3))
        
        monkeySprt.removeAllActions()
        monkeySprt.xScale = -1
        monkeySprt.zPosition = 12
        var newRot =  monkeySprt.zRotation.truncatingRemainder(dividingBy: 2.0*CGFloat.pi)
        newRot = 2.0*CGFloat.pi - newRot
        
        
        let mmAction1 = SKAction.move(to: CGPoint(x: treeBgSprt.size.width - treeBgSprt.size.width * 0.2, y: treeBgSprt.size.height*0.51), duration: 0.8)
        let mmAction2 = SKAction.rotate(byAngle:  newRot , duration: 0.6)
        mmAction1.timingMode = SKActionTimingMode.easeIn
        let mmAction3 = SKAction.run {
            
            let delay = SKAction.wait(forDuration: 1.5)
            let block = SKAction.run {
                completion()
            }
            let seq = SKAction.sequence([delay,block])
            self.run(seq)
            
            let particleParent = SKNode()
            particleParent.zPosition = 11
            self.addChild(particleParent)
            
            let particle = SKEmitterNode(fileNamed: "BananaParticle.sks")
            particle?.position = self.monkeySprt.position
            particle?.targetNode = particleParent
            particleParent.addChild(particle!)
            particle?.zPosition = 0

        }
        


        let mmSeq = SKAction.sequence([mmAction2,mmAction3])
        monkeySprt.run(idleAnimation)
        monkeySprt.run(mmSeq)
        monkeySprt.run(mmAction1)

    }
    
    override func updateProgress(progress: CGFloat)
    {
        
    }
    
    override func showFail()
    {
        windSprt.removeAllActions()
        windSprt.run(SKAction.fadeOut(withDuration: 0.3))
        
        monkeySprt.removeAllActions()
        
        var newRot =  monkeySprt.zRotation.truncatingRemainder(dividingBy: 2.0*CGFloat.pi)
        newRot = 2.0*CGFloat.pi - newRot
        //let rotDur = 4.0 *  newRot / (2.0*CGFloat.pi)
        
        let mmAction1 = SKAction.move(to: CGPoint(x: self.monkeySprt.position.x, y: -10), duration: 0.8)
        let mmAction2 = SKAction.rotate(byAngle:  newRot , duration: 0.6)
        mmAction1.timingMode = SKActionTimingMode.easeIn
        let mmAction3 = SKAction.run {
            self.splashSprt.position = CGPoint(x: self.monkeySprt.position.x - 10, y: self.splashSprt.position.y
            )
            self.splashSprt.setScale(0.5)
            
            let sAction1 = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            let sAction2 = SKAction.scale(to: 2.6, duration: 0.2)
            sAction2.timingMode = SKActionTimingMode.easeOut
            
            let sAction3 = SKAction.fadeAlpha(to: 0, duration: 1.0)
            //let sAction4 = SKAction.scale(to: 0.5, duration: 1.5)
            let sAction4 = SKAction.scaleX(to: 1.2, y: 0, duration: 1.0)
            sAction4.timingMode = SKActionTimingMode.easeIn
            
            let sGroup1 = SKAction.group([sAction1,sAction2])
            let sGroup2 = SKAction.group([sAction3,sAction4])
            
            let wait = SKAction.wait(forDuration: 0.05)
            
            let block = SKAction.run({
                let pos = self.monkeySprt.position
                self.monkeySprt.removeFromParent()
                let monkeySprt1 = SKSpriteNode(imageNamed: "Monkey_Lake-monkey04.png")
                monkeySprt1.anchorPoint = CGPoint(x: 0, y: 0)
                monkeySprt1.position = CGPoint(x: pos.x, y: 0)
                monkeySprt1.setScale(1.0)
                monkeySprt1.zRotation = 0
                monkeySprt1.zPosition = 6
                self.addChild(monkeySprt1)

                /*
                let delay = SKAction.wait(forDuration: 1.0)
                let block = SKAction.run {
                    completion()
                }
                let seq = SKAction.sequence([delay,block])
                self.run(seq)
                 */
                
            })
            
            let sSeq = SKAction.sequence([sGroup1,wait,block,sGroup2])
            
            self.splashSprt.run(sSeq)
            
        }
        
        
        let mmSeq = SKAction.sequence([mmAction2,mmAction3])
        monkeySprt.run(mmSeq)
        monkeySprt.run(mmAction1)

        
        //self.isPaused = true
    }
}
