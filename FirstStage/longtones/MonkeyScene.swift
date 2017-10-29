//
//  MonkeyScene.swift
//  monkeytones
//
//  Created by 1 1 on 17.10.16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
import SpriteKit

class MonkeyScene: BasicScene {
    
    var monkeyOnRopeSprt:SKSpriteNode!
    var bananaSprt:SKSpriteNode!
    var monkeyWithBananaSprt:SKSpriteNode!
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.green
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        let bgdSprite = SKSpriteNode(imageNamed: "d-note-bg.png")
        bgdSprite.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        bgdSprite.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        bgdSprite.zPosition = -1
        self.addChild(bgdSprite)
        self.aspectStretch(sprite: bgdSprite, toHeight: self.size.height)
        
        let barSprite = SKSpriteNode(color: UIColor.init(rgba: "#463720"), size: CGSize(width: view.bounds.size.width, height: 2))
        barSprite.anchorPoint = CGPoint(x: 0,y: 0)
        barSprite.position = CGPoint(x: 0, y: 0)
        barSprite.zPosition = 1
        self.addChild(barSprite)
        
        // Monkey on the rope
        monkeyOnRopeSprt = SKSpriteNode(imageNamed: "d-note-monkey-w-rope.png")
        monkeyOnRopeSprt.anchorPoint = CGPoint(x: 0.1,y: 1)
        monkeyOnRopeSprt.position = CGPoint(x: view.bounds.width/2, y: view.bounds.height)
        monkeyOnRopeSprt.zRotation = CGFloat(M_PI/4.0)
        self.addChild(monkeyOnRopeSprt)
        
        let monkeyAction1 = SKAction.rotate(toAngle: -CGFloat(M_PI/4.0), duration: 1.0)
        monkeyAction1.timingMode = .easeInEaseOut
        let monkeyAction2 = SKAction.rotate(toAngle: CGFloat(M_PI/4.0), duration: 1.0)
        monkeyAction2.timingMode = .easeInEaseOut
        let monkeySeq = SKAction.sequence([monkeyAction1,monkeyAction2])
        let monkeyRepeat = SKAction.repeatForever(monkeySeq)
        monkeyOnRopeSprt.run(monkeyRepeat)
        
        // Banana
        bananaSprt = SKSpriteNode(imageNamed: "d-note-banana.png")
        bananaSprt.setScale(0.8)
        bananaSprt.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        bananaSprt.position = CGPoint(x: bananaSprt.size.width/2, y: view.bounds.height - bananaSprt.size.height/2)
        self.addChild(bananaSprt)
        
        let bananaAction1 = SKAction.rotate(toAngle: -CGFloat(M_PI/7.0), duration: 0.1)
        let bananaAction2 = SKAction.rotate(toAngle: CGFloat(M_PI/7.0), duration: 0.1)
        let bananaAction3 = SKAction.rotate(toAngle: CGFloat(0), duration: 0.1)
        let bananaDelay = SKAction.wait(forDuration: 0.7)
        let bananaDelay2 = SKAction.wait(forDuration: 1.0)
        let bananaSeq = SKAction.sequence([bananaDelay,bananaAction1,bananaAction2,bananaAction3,bananaDelay2])
        let bananaRepeat = SKAction.repeatForever(bananaSeq)
        bananaSprt.run(bananaRepeat)
        
        // Monkey with the banana
        
        monkeyWithBananaSprt = SKSpriteNode(imageNamed: "d-note-monkey-w-banana")
        monkeyWithBananaSprt.position = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
        self.addChild(monkeyWithBananaSprt)
        
        
        monkeyOnRopeSprt.alpha = 0
        bananaSprt.alpha = 0
        monkeyWithBananaSprt.alpha = 0
    }

    
    // MARK: - BasicScene 
    
    override func startStream()
    {
        
        monkeyOnRopeSprt.run(SKAction.fadeIn(withDuration: 0.1))
        bananaSprt.run(SKAction.fadeIn(withDuration: 0.1))
    }
    
    override func showSuccess(completion: @escaping (() -> Void ))
    {
        monkeyOnRopeSprt.run(SKAction.fadeOut(withDuration: 0.1))
        bananaSprt.run(SKAction.fadeOut(withDuration: 0.1))
        
        monkeyWithBananaSprt.setScale(1.2)
        monkeyWithBananaSprt.zPosition = 3
        monkeyWithBananaSprt.run(SKAction.fadeIn(withDuration: 0.3))
        let action = SKAction.scale(to: 1.0, duration: 0.3)
        let block = SKAction.run { 
            let particle = SKEmitterNode(fileNamed: "BananaParticle.sks")
            particle?.position = self.monkeyWithBananaSprt.position
            particle?.zPosition = 2
            particle?.targetNode = self
            self.addChild(particle!)
        }
        let delay = SKAction.wait(forDuration: 1.5)
        let block2 = SKAction.run {
            completion()
        }
        let seq = SKAction.sequence([action,block,delay,block2])
        monkeyWithBananaSprt.run(seq)
        
    }
    
    override func showFail()
    {
        monkeyOnRopeSprt.run(SKAction.fadeOut(withDuration: 0.1))
        bananaSprt.run(SKAction.fadeOut(withDuration: 0.1))

    }
}
