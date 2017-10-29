//
//  BuildingsScene.swift
//  monkeytones
//
//  Created by 1 1 on 02.11.16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
import SpriteKit

class BuildingsScene: BasicScene {
    
    var monkeySprt:SKSpriteNode!
    
    var zeroPosNode:SKNode!
    var monkeyParent:SKNode!
    
    var monkeyJumpAnimation:SKAction!
    var monkeySuccessAnimation:SKAction!
    
    var leftPositions = [CGPoint(x:110,y:210),CGPoint(x:110,y:139),CGPoint(x:110,y:62)]
    var rightPositions = [CGPoint(x:350,y:205),CGPoint(x:350,y:134),CGPoint(x:350,y:62)]
    
    var jumpPoints:[CGPoint]!
    var jumpPointIndex:Int = 0
    
    var shouldFinish = false
    var finisehdSuccessfully = false
    
    var completionBlock: (() -> Void )!
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.green
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        let bgdSprite = SKSpriteNode(imageNamed: "Monkey_Jumping Temples_Sky.png")
        bgdSprite.anchorPoint = CGPoint(x: 0,y: 0)
        bgdSprite.position = CGPoint(x: 0, y: 0)
        bgdSprite.zPosition = -1
        bgdSprite.size = view.bounds.size
        self.addChild(bgdSprite)
        
        let bgdSprite1 = SKSpriteNode(imageNamed: "Monkey_Jumping Temples_Stars.png")
        bgdSprite1.anchorPoint = CGPoint(x: 0,y: 1)
        bgdSprite1.position = CGPoint(x: 0, y: view.bounds.height)
        bgdSprite1.zPosition = 2
        self.addChild(bgdSprite1)

        let bgdSprite2 = SKSpriteNode(imageNamed: "Monkey_Jumping Temples_Clouds.png")
        bgdSprite2.anchorPoint = CGPoint(x: 0,y: 1)
        bgdSprite2.position = CGPoint(x: 0, y: view.bounds.height)
        bgdSprite2.zPosition = 3
        self.addChild(bgdSprite2)
        
        let bgdSprite3 = SKSpriteNode(imageNamed: "Monkey_Jumping Temples_temples back.png")
        bgdSprite3.anchorPoint = CGPoint(x: 0.5,y: 0)
        bgdSprite3.position = CGPoint(x: view.bounds.width/2+30, y: 0)
        bgdSprite3.zPosition = 4
        self.addChild(bgdSprite3)

        let bgdSprite4 = SKSpriteNode(imageNamed: "Monkey_Jumping Temples_trees.png")
        bgdSprite4.anchorPoint = CGPoint(x: 0.5,y: 0)
        bgdSprite4.position = CGPoint(x: view.bounds.width/2, y: -7)
        bgdSprite4.zPosition = 18
        self.addChild(bgdSprite4)
        
        let bgdSprite5 = SKSpriteNode(imageNamed: "Monkey_Jumping Temples_temples front.png")
        bgdSprite5.anchorPoint = CGPoint(x: 0.5,y: 0)
        bgdSprite5.position = CGPoint(x: view.bounds.width/2, y: 0)
        bgdSprite5.zPosition = 6
        self.addChild(bgdSprite5)
        
        zeroPosNode = SKNode()
        zeroPosNode.position = CGPoint(x:-bgdSprite5.frame.width/2,y:0)
        bgdSprite5.addChild(zeroPosNode)
    
        
        // Monkey 
        
        monkeyParent = SKNode()
        monkeyParent.position = leftPositions[0]
        zeroPosNode.addChild(monkeyParent)
        
        
        monkeySprt = SKSpriteNode(imageNamed: "Monkey_Jumping Temples_monkey 05.png")
        monkeySprt.anchorPoint = CGPoint(x: 0.5, y: 1)
        monkeySprt.zPosition = 7
        monkeyParent.addChild(monkeySprt)
        
        
        var textures = [SKTexture]()
        for i in 0...3
        {
            textures.append(SKTexture(imageNamed: "Monkey_Jumping Temples_monkey 0\(i+1).png"))
        }
        
        monkeyJumpAnimation = SKAction.animate(with: textures, timePerFrame: 0.2, resize: true, restore: true)
        
        monkeySuccessAnimation = SKAction.animate(with: [SKTexture(imageNamed: "Monkey_Jumping Temples_monkey 06.png")], timePerFrame: 0.1, resize: true, restore: false)
        
        /*
        for i in 0..<leftPositions.count
        {
            let node1 = SKSpriteNode(imageNamed: "Monkey_Jumping Temples_monkey 05.png")
            let node2 = SKSpriteNode(imageNamed: "Monkey_Jumping Temples_monkey 05.png")
            
            node1.anchorPoint = CGPoint(x: 0.5, y: 1)
            node2.anchorPoint = CGPoint(x: 0.5, y: 1)
            
            node2.zPosition = 10
            node1.zPosition = 10
            
            monkeyParent.addChild(node1)
            monkeyParent.addChild(node2)
            
            node1.position = leftPositions[i]
            node2.position = rightPositions[i]
        }
         */
        
        //jumpPoints = [leftPositions[0],rightPositions[0],rightPositions[1],leftPositions[1],leftPositions[2],rightPositions[2]]
        
        jumpPoints = [leftPositions[0],rightPositions[0],leftPositions[1],rightPositions[1],leftPositions[2],rightPositions[2]]
        
        jumpPointIndex = 0
        
        
        /*
         let deadlineTime = DispatchTime.now() + .seconds(1)
         DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
         self.startStream()
         }
        
         let deadlineTime2 = DispatchTime.now() + .seconds(6)
         DispatchQueue.main.asyncAfter(deadline: deadlineTime2) {
            self.showSuccess {
                
            }
         }
 */
        
        
        
    }
    
    
    func jumpToNext()
    {
        jumpPointIndex += 1
        
        if jumpPointIndex >= jumpPoints.count
        {
            jumpPointIndex = 0
        }
        
        let cgpath = CGMutablePath()
        let startingPoint = monkeyParent.position
        let endingPoint = jumpPoints[jumpPointIndex]
        
        let distanceX = endingPoint.x - startingPoint.x
        
        let controlPoint1 = CGPoint(x: startingPoint.x + distanceX/4, y: endingPoint.y + 90)
        let controlPoint2 = CGPoint(x: startingPoint.x + 3*distanceX/4, y: endingPoint.y + 70)
        
        cgpath.move(to: CGPoint(x: startingPoint.x, y: startingPoint.y))
        cgpath.addCurve(to: CGPoint(x: endingPoint.x, y: endingPoint.y), control1: CGPoint(x: controlPoint1.x, y: controlPoint1.y), control2: CGPoint(x: controlPoint2.x, y: controlPoint2.y))
        
        /*
        let pathNode = SKShapeNode(path: cgpath)
        pathNode.strokeColor = SKColor.black
        pathNode.fillColor = SKColor.clear
        pathNode.lineWidth = 4.0
        pathNode.position = CGPoint.zero
        pathNode.zPosition = 100
        zeroPosNode.addChild(pathNode)
        */
        
        let jumpMonkey = SKAction.follow(cgpath, asOffset: false, orientToPath: false, duration: 0.7)
        
        //let jumpMonkey = SKAction.move(to: endingPoint, duration: 0.7)
        
        let blockJump = SKAction.run {
            
            
            self.monkeyParent.position = self.jumpPoints[self.jumpPointIndex]
            
            /*
            let pathNode1 = SKShapeNode(circleOfRadius: 30)
            pathNode1.strokeColor = SKColor(colorLiteralRed: 1, green: 0, blue: 0, alpha: 0.3)
            pathNode1.fillColor = SKColor.clear
            pathNode1.lineWidth = 1.0
            pathNode1.position = self.monkeyParent.position
            pathNode1.zPosition = 100
            self.zeroPosNode.addChild(pathNode1)
            */
            
            self.monkeySprt.xScale = -self.monkeySprt.xScale

            if self.jumpPointIndex == 0
            {
                self.monkeySprt.xScale = 1
            }
            
            
            
        }
        let seq = SKAction.sequence([jumpMonkey,blockJump])
        monkeyParent.run(seq)

        if !self.shouldFinish
        {
            monkeySprt.run(monkeyJumpAnimation, withKey: "jump")
        }
        
        
        // Next jump
        let block = SKAction.run {
            if !self.shouldFinish
            {
                self.run(SKAction.sequence([SKAction.wait(forDuration: 1.3),SKAction.run({self.jumpToNext()} )]))
            }
            
            /*
            if self.finisehdSuccessfully
            {
                let particleParent = SKNode()
                particleParent.zPosition = 6
                self.monkeyParent.addChild(particleParent)
                
                let particle = SKEmitterNode(fileNamed: "BananaParticle.sks")
                particle?.position = self.monkeySprt.position
                particle?.targetNode = particleParent
                particleParent.addChild(particle!)
                particle?.zPosition = 0
            }
 */

        }
        let wait = SKAction.wait(forDuration: 0.7)
        let sequence = SKAction.sequence([wait,block])
        self.run(sequence)

        
    }
    
    
    func completAnimation()
    {
        self.monkeySprt.run(self.monkeySuccessAnimation)
        
        let block = SKAction.run {
            self.completionBlock()
        }
        let wait = SKAction.wait(forDuration: 2.0)
        let sequence = SKAction.sequence([wait,block])
        self.run(sequence)

    }
    
    // MARK: - BasicScene
    
    override func startStream()
    {
        self.jumpToNext()
    }
    
    override func showSuccess(completion: @escaping (() -> Void ))
    {
        shouldFinish = true
        finisehdSuccessfully = true
        completionBlock = completion
        monkeyParent.removeAllActions()
        self.removeAllActions()
        
        //if self.monkeySprt.action(forKey: "jump") != nil
        //{
            self.monkeySprt.removeAction(forKey: "jump")
            self.completAnimation()
        //}
        
        let particleParent = SKNode()
        particleParent.zPosition = 6
        self.monkeyParent.addChild(particleParent)
        
        let particle = SKEmitterNode(fileNamed: "BananaParticle.sks")
        particle?.position = self.monkeySprt.position
        particle?.targetNode = particleParent
        particleParent.addChild(particle!)
        particle?.zPosition = 0

    }
    
    override func showFail()
    {
        shouldFinish = true
        //self.isPaused = true
        monkeyParent.removeAllActions()
        
        let absPosY = monkeyParent.position.y
        let duration = absPosY / 180.0
        
        let fRotate = SKAction.rotate(byAngle: 2 * CGFloat.pi, duration: 3.0)
        let fMove = SKAction.moveBy(x: 0, y: -absPosY - 170, duration: TimeInterval(duration))
        monkeyParent.run(fMove, completion: {
            
        })
        monkeyParent.run(SKAction.repeatForever(fRotate))


    }
}
