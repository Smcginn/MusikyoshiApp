//
//  PlaneScene.swift
//  monkeytones
//
//  Created by 1 1 on 06.11.16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

//
//  CarnivalScene.swift
//  monkeytones
//
//  Created by 1 1 on 19.10.16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
import SpriteKit

class PlaneScene: BasicScene {
    
    var planeSprt:SKSpriteNode!
    var monkeySprt:SKSpriteNode!
    var waveHandSprt:SKSpriteNode!
    var steadyHandSprt:SKSpriteNode!
    
    var buildingsSprt:SKSpriteNode!
    var towerSprt:SKSpriteNode!

    var planeFlagSprt:SKSpriteNode!
    var towerFlagSprt:SKSpriteNode!

    var planeAction1:SKAction!
    var planeAction2:SKAction!
    
    var successMonkeyAnim:SKAction!
    
    var forwardMonkeyAnim:SKAction!
    var backMonkeyAnim:SKAction!
    
    var planeParent:SKNode!
    
    override func didMove(to view: SKView) {
        
        let bgdSprite = SKSpriteNode(imageNamed: "Monkey_Plane-part02-Sky-01.png")
        bgdSprite.anchorPoint = CGPoint(x: 0,y: 0)
        bgdSprite.position = CGPoint(x: 0, y: 0)
        bgdSprite.zPosition = -1
        bgdSprite.size = view.bounds.size
        self.addChild(bgdSprite)
             
        let bgdSprite1 = SKSpriteNode(imageNamed: "Monkey_Plane-part01_clouds.png")
        bgdSprite1.anchorPoint = CGPoint(x: 0,y: 0)
        bgdSprite1.position = CGPoint(x: 0, y: -60)
        bgdSprite1.zPosition = 1
        self.addChild(bgdSprite1)

        buildingsSprt = SKSpriteNode(imageNamed: "Monkey_Plane-part01_Buildings.png")
        buildingsSprt.anchorPoint = CGPoint(x: 0,y: 0)
        buildingsSprt.position = CGPoint(x: 0, y: -10)
        buildingsSprt.zPosition = 2
        self.addChild(buildingsSprt)

        towerSprt = SKSpriteNode(imageNamed: "Monkey_Plane-part02-Tower.png")
        towerSprt.anchorPoint = CGPoint(x: 0.5,y: 0)
        towerSprt.position = CGPoint(x: view.frame.width/2 , y: -10)
        towerSprt.zPosition = 7
        self.addChild(towerSprt)
        
        // Plane
        
        planeParent = SKNode()
        planeParent.zPosition = 0
        self.addChild(planeParent)
        
        planeSprt = SKSpriteNode(imageNamed: "Monkey_Plane-part02-Plane.png")
        planeSprt.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        planeSprt.zPosition = 10
        planeParent.addChild(planeSprt)
        
        let propellerSprt = SKSpriteNode(imageNamed: "Monkey_Plane-part02-propeller_frame 01.png")
        propellerSprt.anchorPoint = CGPoint(x: 0,y: 0.5)
        propellerSprt.position = CGPoint(x: planeSprt.frame.width/2-7, y: 3)
        propellerSprt.zPosition = 1
        planeSprt.addChild(propellerSprt)
        
        var propTextures = [SKTexture]()
        for i in 0...5
        {
            propTextures.append(SKTexture(imageNamed: "Monkey_Plane-part02-propeller_frame 0\(i+1).png"))
        }

        let propAnimation = SKAction.animate(with: propTextures, timePerFrame: 0.05, resize: true, restore: false)
        let pRepeat = SKAction.repeatForever(propAnimation)
        propellerSprt.run(pRepeat)
        
        
        monkeySprt = SKSpriteNode(imageNamed: "Monkey_Plane-part01_Monkey 01.png")
        monkeySprt.position = CGPoint(x: 4, y: 30)
        monkeySprt.zPosition = -1
        monkeySprt.setScale(1.3)
        planeSprt.addChild(monkeySprt)
        
        forwardMonkeyAnim = SKAction.animate(with: [SKTexture(imageNamed: "Monkey_Plane-part01_Monkey 02.png")], timePerFrame: 0.1, resize: true, restore: false)
        backMonkeyAnim = SKAction.animate(with: [SKTexture(imageNamed: "Monkey_Plane-part01_Monkey 01.png")], timePerFrame: 0.1, resize: true, restore: false)
        
        successMonkeyAnim = SKAction.animate(with: [SKTexture(imageNamed: "Monkey_Plane-part02-Monkey 01.png")], timePerFrame: 0.1, resize: true, restore: false)

        monkeySprt.run(forwardMonkeyAnim)
        
        waveHandSprt = SKSpriteNode(imageNamed: "Monkey_Plane-part02-Monkey arm 02.png")
        waveHandSprt.anchorPoint = CGPoint(x: 1,y: 0)
        waveHandSprt.position = CGPoint(x: 2, y: -11)
        waveHandSprt.zPosition = 1
        waveHandSprt.zRotation = -0.5
        waveHandSprt.alpha = 0
        monkeySprt.addChild(waveHandSprt)
        
        steadyHandSprt = SKSpriteNode(imageNamed: "Monkey_Plane-part01_Monkey 02 arm.png")
        steadyHandSprt.anchorPoint = CGPoint(x: 0,y: 0)
        steadyHandSprt.position = CGPoint(x: 2, y: -11)
        steadyHandSprt.zPosition = 3
        steadyHandSprt.alpha = 1
        monkeySprt.addChild(steadyHandSprt)
        
        let waveAction1 = SKAction.rotate(byAngle: 0.4, duration: 0.2)
        let waveAction2 = SKAction.rotate(byAngle: -0.4, duration: 0.2)
        let waveSeq = SKAction.sequence([waveAction1,waveAction2])
        let waveRepeat = SKAction.repeatForever(waveSeq)
        waveHandSprt.run(waveRepeat)
        
        
        // Flags
        
        planeFlagSprt = SKSpriteNode(imageNamed: "Monkey_Plane-part02-flag-frame 01.png")
        planeFlagSprt.anchorPoint = CGPoint(x: 1,y: 0)
        planeFlagSprt.position = CGPoint(x: 36, y: 23)
        planeFlagSprt.zPosition = 2
        planeSprt.addChild(planeFlagSprt)
        planeFlagSprt.xScale = 0
        
        var flagTextures = [SKTexture]()
        for i in 0...5
        {
            flagTextures.append(SKTexture(imageNamed: "Monkey_Plane-part02-flag-frame 0\(i+1).png"))
        }
        
        let flagAnimation = SKAction.animate(with: flagTextures, timePerFrame: 0.05, resize: true, restore: false)
        let fRepeat = SKAction.repeatForever(flagAnimation)
        planeFlagSprt.run(fRepeat)

        
        towerFlagSprt = SKSpriteNode(imageNamed: "Monkey_Plane-part02-flag-frame 01.png")
        towerFlagSprt.anchorPoint = CGPoint(x: 1,y: 0)
        towerFlagSprt.position = CGPoint(x: 0, y: towerSprt.frame.height)
        towerFlagSprt.zPosition = 1
        towerSprt.addChild(towerFlagSprt)
        towerFlagSprt.alpha = 0
        
        towerFlagSprt.run(fRepeat)

        // Idle 
        
        planeSprt.setScale(0.7)
        planeSprt.position = CGPoint(x: planeSprt.frame.width/2 , y: 30)

        //planeAction1 = SKAction.moveBy(x: view.frame.width + 2*planeSprt.frame.width/2, y: 0, duration: 3.0)
        //planeAction2 = SKAction.moveBy(x: -view.frame.width - 2*planeSprt.frame.width/2, y: 0, duration: 3.0)
        
        planeAction1 = SKAction.move(to: CGPoint(x:view.frame.width - planeSprt.frame.width/2,y: planeSprt.position.y), duration: 6.0)
        planeAction2 = SKAction.move(to: CGPoint(x: planeSprt.frame.width/2,y: planeSprt.position.y), duration: 6.0)
        
        let block = SKAction.run { 
            self.planeSprt.xScale = -self.planeSprt.xScale
            if self.planeSprt.xScale < 0
            {
                self.planeSprt.zPosition = 5
                self.steadyHandSprt.alpha = 0
                self.monkeySprt.run(self.backMonkeyAnim)
                self.monkeySprt.position = CGPoint(x: 10, y: 30)
                self.planeFlagSprt.zPosition = -2
            }
            else
            {
                self.planeSprt.zPosition = 10
                self.steadyHandSprt.alpha = 1
                self.monkeySprt.run(self.forwardMonkeyAnim)
                self.monkeySprt.position = CGPoint(x: 4, y: 30)
                self.planeFlagSprt.zPosition = 2
            }
        }
        
        let seq = SKAction.sequence([planeAction1,block,planeAction2,block])
        let plRepeat = SKAction.repeatForever(seq)
        
        planeSprt.run(plRepeat)
        
        
        
        /*
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.startStream()
        }
        
        let deadlineTime2 = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime2) {
            self.showFail()
        }
        */
        

    }
    
    
    // MARK: - BasicScene
    
    override func startStream()
    {
        planeFlagSprt.run(SKAction.scaleX(to: 1, duration: 0.4))
        
        planeSprt.removeAllActions()
        
        
        var durBuf = 1.0
        var endPos = CGPoint(x:0,y:0)
        
        if planeSprt.xScale < 0
        {
            endPos = CGPoint(x: planeSprt.frame.width/2 ,y:planeSprt.position.y)
            durBuf = Double((planeSprt.position.x - planeSprt.frame.width/2) / (view!.frame.width - planeSprt.frame.width))
        }
        else
        {
            endPos = CGPoint(x: self.view!.frame.width - planeSprt.frame.width/2 ,y:planeSprt.position.y)
            durBuf = Double((view!.frame.width - planeSprt.frame.width/2 - planeSprt.position.x) / (view!.frame.width - planeSprt.frame.width))
        }
        
        
        let endAction = SKAction.move(to: endPos, duration: durBuf * 2.0)
        let endBlock = SKAction.run { 
            
            self.planeAction1 = SKAction.move(to: CGPoint(x:self.view!.frame.width - self.planeSprt.frame.width/2,y: self.planeSprt.position.y), duration: 2.0)
            self.planeAction2 = SKAction.move(to: CGPoint(x: self.planeSprt.frame.width/2,y: self.planeSprt.position.y), duration: 2.0)
            
            let block = SKAction.run {
                self.planeSprt.xScale = -self.planeSprt.xScale
                if self.planeSprt.xScale < 0
                {
                    self.planeSprt.zPosition = 5
                    self.steadyHandSprt.alpha = 0
                    self.monkeySprt.run(self.backMonkeyAnim)
                    self.monkeySprt.position = CGPoint(x: 10, y: 30)
                    self.planeFlagSprt.zPosition = -2
                }
                else
                {
                    self.planeSprt.zPosition = 10
                    self.steadyHandSprt.alpha = 1
                    self.monkeySprt.run(self.forwardMonkeyAnim)
                    self.monkeySprt.position = CGPoint(x: 4, y: 30)
                    self.planeFlagSprt.zPosition = 2
                }
            }
            
            
            var seq:SKAction
            if self.planeSprt.xScale<0
            {
                seq = SKAction.sequence([block,self.planeAction1,block,self.planeAction2])
            }
            else
            {
                seq = SKAction.sequence([block,self.planeAction2,block,self.planeAction1])

            }
            
            let plRepeat = SKAction.repeatForever(seq)
            self.planeSprt.run(plRepeat)

        }
        let endSeq = SKAction.sequence([endAction,endBlock])
        self.planeSprt.run(endSeq)
        
        
    }
    
    override func showSuccess(completion: @escaping () -> Void)
    {
        
        planeSprt.removeAllActions()
        planeSprt.zPosition = 10
        
        
        if planeSprt.xScale < 0 && planeSprt.position.x < frame.width/2
        {
           planeSprt.xScale = -planeSprt.xScale
        }
        if planeSprt.xScale > 0 && planeSprt.position.x > frame.width/2
        {
           planeSprt.xScale = -planeSprt.xScale
        }
        
        let action1 = SKAction.move(to: CGPoint(x:frame.width/2,y:planeSprt.position.y), duration: 2.0)
        let block1 = SKAction.run {
            
            self.planeFlagSprt.alpha = 0
            
            self.towerFlagSprt.alpha = 1
            self.towerFlagSprt.xScale = 0
            
            self.towerFlagSprt.run(SKAction.scaleX(to: 1, duration: 0.5))
            
            self.monkeySprt.run(self.successMonkeyAnim)
            self.waveHandSprt.alpha = 1
            
            var endPoint:CGPoint
            
            if self.planeSprt.xScale < 0
            {
                endPoint = CGPoint(x: -self.planeSprt.frame.width/2,y:self.planeSprt.position.y)
            }
            else
            {
                endPoint = CGPoint(x: self.frame.width + self.planeSprt.frame.width/2,y:self.planeSprt.position.y)
            }
            
            let sAction1 = SKAction.move(to: endPoint, duration: 4.5)
            
            self.planeSprt.run(SKAction.sequence([sAction1, SKAction.run(completion)]))
            
            
        }
        
        planeSprt.run(SKAction.sequence([action1,block1]))
        
        
        
    }
    
    override func updateProgress(progress: CGFloat) {
        
        planeParent.position = CGPoint(x:0,y:progress * (towerSprt.frame.height - 60))
    }
    
    override func showFail()
    {
        planeSprt.removeAllActions()
        
        let absPosY = planeParent.position.y
        let duration = absPosY / 40.0
        
        let fRotate = SKAction.rotate(byAngle: 2 * CGFloat.pi, duration: 3.0)
        let fMove = SKAction.moveBy(x: 0, y: -absPosY - 170, duration: TimeInterval(duration))
        planeFlagSprt.run(fMove, completion: {
            
        })
        planeFlagSprt.run(SKAction.repeatForever(fRotate))
        //self.isPaused = true
    }
}
