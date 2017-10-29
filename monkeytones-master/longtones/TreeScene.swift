//
//  TreeScene.swift
//  monkeytones
//
//  Created by Adam Kinney on 8/31/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import SpriteKit

class TreeScene: BasicScene {
    
    var timer: Timer!
    
    var treeSprite: SKSpriteNode!
    var monkeySprt: SKSpriteNode!
    
    var bushes:[SKSpriteNode] = [SKSpriteNode]()
    var progressRanges:[CGFloat]!
    
    var successAnimation:SKAction!
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = UIColor.green
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        let bgdSprite = SKSpriteNode(imageNamed: "bonsaiBgd")
        bgdSprite.anchorPoint = CGPoint(x: 0,y: 0)
        bgdSprite.position = CGPoint(x: 0, y: 0)
        bgdSprite.zPosition = -1
        bgdSprite.size = view.bounds.size
        self.addChild(bgdSprite)
                
        let barSprite = SKSpriteNode(color: UIColor.init(rgba: "#463720"), size: CGSize(width: view.bounds.size.width, height: 2))
        barSprite.anchorPoint = CGPoint(x: 0,y: 0)
        barSprite.position = CGPoint(x: 0, y: 0)
        barSprite.zPosition = 1
        self.addChild(barSprite)
        
        treeSprite = self.childNode(withName: "tree") as! SKSpriteNode!
        treeSprite.position = CGPoint(x: view.bounds.width/2, y: treeSprite.size.height/2)
        
        monkeySprt = treeSprite.childNode(withName: "monkey") as! SKSpriteNode!
        
        bushes.append(treeSprite.childNode(withName: "bush-1") as! SKSpriteNode!)
        bushes.append(treeSprite.childNode(withName: "bush-2") as! SKSpriteNode!)
        bushes.append(treeSprite.childNode(withName: "bush-3") as! SKSpriteNode!)
        bushes.append(treeSprite.childNode(withName: "bush-4") as! SKSpriteNode!)
        bushes.append(treeSprite.childNode(withName: "bush-5") as! SKSpriteNode!)
        bushes.append(treeSprite.childNode(withName: "bush-6") as! SKSpriteNode!)
        
        progressRanges = [0.15,0.3,0.45,0.6,0.75,0.95]
        
        successAnimation = SKAction.animate(with: [SKTexture(imageNamed: "bonsai-monkey-2.png")], timePerFrame: 0.1, resize: true, restore: false)
        
        //self.startStream()
    }
    
    func releaseLeaf()
    {
        
        if bushes.count == 0
        {
            return
        }
        
        let bushIndex = Int(arc4random_uniform(UInt32(bushes.count)))
        
        let pos = bushes[bushIndex].position
        
        let leaf = SKSpriteNode(imageNamed: "bonsai-leaf.png")
        leaf.position = pos
        treeSprite.addChild(leaf)
        leaf.setScale(0)
        leaf.zRotation = CGFloat(arc4random_uniform( UInt32(Float.pi * 100.0))) / 100.0
        leaf.zPosition = 5
        
        let move = SKAction.moveBy(x:size.width, y: 0, duration: 4.0)
        let scale = SKAction.scale(to: 0.6, duration: 0.3)
        let rotate = SKAction.rotate(byAngle: CGFloat(arc4random_uniform( UInt32(Float.pi * 100.0))) / 100.0, duration: 5.0)
        
        leaf.run(move, completion:{
            leaf.removeFromParent()
        })
        leaf.run(scale)
        leaf.run(rotate)
    }
    
    override func startStream(){
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.releaseLeaf), userInfo: nil, repeats: true)
    }
    
    override func updateProgress(progress: CGFloat)
    {
        if progressRanges.count == 0
        {
            return
        }
        
        if progress > progressRanges[0]
        {
            
            let particle = SKEmitterNode(fileNamed: "bonsai-particle.sks")
            particle?.position = bushes[0].position
            particle?.zPosition = 5
            particle?.targetNode = self
            particle?.particlePositionRange = CGVector(dx: bushes[0].size.width/2.0, dy: bushes[0].size.height/2)
            treeSprite.addChild(particle!)

            
            let move = SKAction.moveBy(x: size.width, y: 0, duration: 0.5)
            move.timingMode = .easeIn
            bushes[0].run(move)
            //bushes[0].removeFromParent()
            
            bushes.removeFirst()
            progressRanges.removeFirst()
            

        }
    }
    
    override func showSuccess(completion: @escaping () -> Void)
    {
        monkeySprt.run(successAnimation)
        self.run(SKAction.sequence([SKAction.wait(forDuration: 2.5),SKAction.run(completion)]))
    }
    
    override func showFail()
    {
        self.isPaused = true
    }
    
}
