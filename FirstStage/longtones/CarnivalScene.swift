//
//  CarnivalScene.swift
//  monkeytones
//
//  Created by 1 1 on 19.10.16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
//
//  MonkeyScene.swift
//  monkeytones
//
//  Created by 1 1 on 17.10.16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
import SpriteKit

class CarnivalScene: BasicScene {
    
    var headSprt:SKSpriteNode!
    var gumSprt:SKSpriteNode!
    
    static let startBallonSize:CGFloat = 0.2
    static let maxBallonSize:CGFloat = 1.3
    
    override func didMove(to view: SKView) {
        
        let bgdSprite = SKSpriteNode(imageNamed: "Monkey_Ballon_Sky.png")
        bgdSprite.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        bgdSprite.position = CGPoint(x: size.width/2, y: size.height/2)
        bgdSprite.zPosition = -1
        self.addChild(bgdSprite)
        self.aspectStretch(sprite: bgdSprite, toHeight: self.size.height)

        
        let bgdSprite2 = SKSpriteNode(imageNamed: "Monkey_Ballon-roller coaster.png")
        bgdSprite2.anchorPoint = CGPoint(x: 0,y: 0)
        bgdSprite2.position = CGPoint(x: 0, y: 0)
        bgdSprite2.zPosition = 1
        self.addChild(bgdSprite2)
        
        let bgdSprite3 = SKSpriteNode(imageNamed: "Monkey_Ballon-trees-01.png")
        bgdSprite3.anchorPoint = CGPoint(x: 0,y: 0)
        bgdSprite3.position = CGPoint(x: 0, y: 0)
        bgdSprite3.zPosition = 2
        self.addChild(bgdSprite3)
        self.aspectStretch(sprite: bgdSprite3, toWidth: self.frame.width)
        
        // Wheel
        
        let wheel1 = SKSpriteNode(imageNamed: "Monkey_Ballon-treadmill part2.png")
        wheel1.anchorPoint = CGPoint(x: 0,y: 0)
        wheel1.position = CGPoint(x: view.frame.width - 1.15*wheel1.frame.width/2 , y: 0)
        wheel1.zPosition = 3
        self.addChild(wheel1)
        
        let wheel2 = SKSpriteNode(imageNamed: "Monkey_Ballon-treadmill part1.png")
        wheel2.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        wheel2.position = CGPoint(x: wheel1.frame.width/2 , y: wheel1.frame.height-15)
        wheel2.zPosition = 3
        wheel1.addChild(wheel2)
        let wheelAction = SKAction.rotate(byAngle: CGFloat(2*M_PI), duration: 12.0)
        let wheelRepeat = SKAction.repeatForever(wheelAction)
        wheel2.run(wheelRepeat)

        let cabinCount = 8
        let angleStep = 2*CGFloat.pi / CGFloat(cabinCount)
        for i in 0..<cabinCount
        {
            let cabin = SKSpriteNode(imageNamed: "ferris wheel house_0\(i+1).png")
            cabin.anchorPoint = CGPoint(x: 0.5,y: 1)
            
            let x = cos(CGFloat(i)*angleStep) * (wheel2.frame.width/2 - 2)
            let y = sin(CGFloat(i)*angleStep) * (wheel2.frame.width/2 - 2)
            //x += wheel2.frame.width/2
            //y += wheel2.frame.width/2
            
            
            cabin.position = CGPoint(x: x , y: y)
            cabin.zPosition = 1
            wheel2.addChild(cabin)
            
            
            let wheelAction = SKAction.rotate(byAngle: CGFloat(-2*M_PI), duration: 12.0)
            let wheelRepeat = SKAction.repeatForever(wheelAction)
            cabin.run(wheelRepeat)
            
        }
        
        //
        
        let bgdSprite4 = SKSpriteNode(imageNamed: "Monkey_Ballon-tent.png")
        bgdSprite4.anchorPoint = CGPoint(x: 0.5,y: 0)
        bgdSprite4.position = CGPoint(x: 1.25*view.frame.width/2, y: 0)
        bgdSprite4.zPosition = 17
        self.addChild(bgdSprite4)
        
        let bgdSprite5 = SKSpriteNode(imageNamed: "Monkey_Ballon-shrubbery.png")
        bgdSprite5.anchorPoint = CGPoint(x: 0,y: 0)
        bgdSprite5.position = CGPoint(x: 0, y: 0)
        bgdSprite5.zPosition = 18
        self.addChild(bgdSprite5)
        self.aspectStretch(sprite: bgdSprite5, toWidth: self.frame.width/2)
        
        
        let bgdSprite6 = SKSpriteNode(imageNamed: "Monkey_Ballon-carousel.png")
        bgdSprite6.anchorPoint = CGPoint(x: 0,y: 0)
        bgdSprite6.position = CGPoint(x: 0, y: 0)
        bgdSprite6.zPosition = 19
        self.addChild(bgdSprite6)
        
        // Head
        
        headSprt = SKSpriteNode(imageNamed: "Monkey_Ballon-Face01.png")
        headSprt.position = CGPoint(x: 1.15 * view.frame.width/2, y: 1.32*view.frame.height/2)
        headSprt.zPosition = 20
        self.addChild(headSprt)

        gumSprt = SKSpriteNode(imageNamed: "Monkey_Ballon-ballon 05.png")
        gumSprt.setScale(CarnivalScene.startBallonSize)
        gumSprt.zPosition = 1
        gumSprt.position = CGPoint(x: 0, y: -38)
        headSprt.addChild(gumSprt)
        
    }
    
    
    // MARK: - BasicScene
    
    override func startStream()
    {
        headSprt.texture = SKTexture(imageNamed: "Monkey_Ballon-Face02.png")
    }
    
    override func showSuccess(completion: @escaping () -> Void)
    {

        //let action = SKAction.scale(to: 1.0, duration: 0.5)
        //let block = SKAction.run {
            //self.gumSprt.position = CGPoint(x: 0, y: -38)
            self.gumSprt.texture = SKTexture(imageNamed: "Monkey_Ballon-ballon explode.png")
            self.gumSprt.run(SKAction.fadeOut(withDuration: 0.2))
            self.gumSprt.run(SKAction.scale(to: CarnivalScene.startBallonSize + CarnivalScene.maxBallonSize + 0.2, duration: 0.2))
            
            let particle = SKEmitterNode(fileNamed: "BaloonParticle.sks")
            particle?.position = self.gumSprt.position
            particle?.zPosition = 40
            particle?.targetNode = self.headSprt
            self.headSprt.addChild(particle!)
        
        let particle2 = SKEmitterNode(fileNamed: "BaloonParticle.sks")
        particle2?.particleTexture = SKTexture(imageNamed: "Baloon-piece-2.png")
        particle2?.position = self.gumSprt.position
        particle2?.zPosition = 40
        particle2?.targetNode = self.headSprt
        self.headSprt.addChild(particle2!)

        let delay = SKAction.wait(forDuration: 1.5)
        let block = SKAction.run {
            completion()
        }
        let seq = SKAction.sequence([delay,block])
        self.run(seq)
        
        //}
        //let seq = SKAction.sequence([action,block])
        //gumSprt.run(seq)

    }
    
    override func updateProgress(progress: CGFloat) {
        
        //print("progress: \(progress)")
        self.gumSprt.setScale(CarnivalScene.startBallonSize + CarnivalScene.maxBallonSize * progress )
    }
    
    override func showFail()
    {
        self.isPaused = true
    }
}
