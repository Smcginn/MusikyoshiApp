//
//  CaveScene.swift
//  monkeytones
//
//  Created by 1 1 on 07.11.16.
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

class CaveScene: BasicScene {
    
    var monkeySprt:SKSpriteNode!
    var monkeyUnlockAction:SKAction!
    var monkeyLastUnlockAction:SKAction!
    var monkeyRunAction:SKAction!
    
    var monkeyLegLSprt:SKSpriteNode!
    var monkeyLegRSprt:SKSpriteNode!

    var monkeyArmLSprt:SKSpriteNode!
    var monkeyArmRSprt:SKSpriteNode!
    
    var bgSprt1:SKSpriteNode!
    var bgSprt2:SKSpriteNode!
    
    var chestSprt:SKSpriteNode!
    
    var chestOpenAnim:SKAction!
    var chestCloseAnim:SKAction!
    
    var boxMonkeySprt:SKSpriteNode!
    var boxMonkeyAnimations:[SKAction] = [SKAction]()
    
    
    var shouldFinish = false
    var completionBlock: (() -> Void )!
    
    var stopMoving = false
    var pauseMoving = false
    
    override func didMove(to view: SKView) {
        
        self.bgSprt1 = SKSpriteNode(imageNamed: "Monkey_The Cave-background-V2 mod.png")
        self.bgSprt1.anchorPoint = CGPoint(x: 0,y: 0)
        self.bgSprt1.position = CGPoint(x: 0, y: 0)
        self.bgSprt1.zPosition = -1
        self.addChild(self.bgSprt1)
    
        let bgAspect = self.bgSprt1.size.width / self.bgSprt1.size.height
        self.bgSprt1.size = CGSize(width: view.bounds.size.height * bgAspect , height: view.bounds.size.height)
        
        self.bgSprt2 = SKSpriteNode(imageNamed: "Monkey_The Cave-background-V2 mod.png")
        self.bgSprt2.anchorPoint = CGPoint(x: 0,y: 0)
        self.bgSprt2.position = CGPoint(x: self.bgSprt1.size.width, y: 0)
        self.bgSprt2.zPosition = -1
        self.addChild(self.bgSprt2)
        
        self.bgSprt2.size = CGSize(width: view.bounds.size.height * bgAspect , height: view.bounds.size.height)
        
        /*
        let bgAction1 = SKAction.moveBy(x: -2*self.bgSprt1.size.width + view.bounds.width, y: 0, duration: 2.0)
        let bgBlock1 = SKAction.run {
            self.bgSprt1.position = CGPoint(x: self.bgSprt1.size.width, y: 0)
        }
        let bgBlock2 = SKAction.run {
            self.bgSprt2.position = CGPoint(x: self.bgSprt2.size.width, y: 0)
        }
        
        let bgSeq1 = SKAction.sequence([bgAction1,bgBlock1])
        let bgSeq2 = SKAction.sequence([bgAction1,bgBlock2])
        
        let bgRepeat1 = SKAction.repeatForever(bgSeq1)
        let bgRepeat2 = SKAction.repeatForever(bgSeq2)
        
        self.bgSprt1.run(bgRepeat1)
        self.bgSprt2.run(bgRepeat2)
         */
        
        
        
        // Monkey 
        
        monkeySprt = SKSpriteNode(imageNamed: "Monkey_The Cave-Run-body.png")
        self.monkeySprt.position = CGPoint(x: 50, y: 80)
        self.monkeySprt.zPosition = 6
        self.addChild(self.monkeySprt)
        
        monkeyLegLSprt = SKSpriteNode(imageNamed: "Monkey_The Cave-Run-leg L.png")
        monkeyLegLSprt.anchorPoint = CGPoint(x: 0.1, y: 0.9)
        monkeyLegLSprt.position = CGPoint(x: -27, y: -17)
        monkeyLegLSprt.zPosition = -1
        monkeyLegLSprt.zRotation = -0.6
        monkeySprt.addChild(monkeyLegLSprt)
        
        monkeyLegRSprt = SKSpriteNode(imageNamed: "Monkey_The Cave-Run-leg R.png")
        monkeyLegRSprt.anchorPoint = CGPoint(x: 0.1, y: 0.9)
        monkeyLegRSprt.position = CGPoint(x: -27, y: -17)
        monkeyLegRSprt.zPosition = 7
        monkeyLegRSprt.zRotation = 0
        monkeySprt.addChild(monkeyLegRSprt)
        
        monkeyArmLSprt = SKSpriteNode(imageNamed: "Monkey_The Cave-Run-arm L.png")
        monkeyArmLSprt.anchorPoint = CGPoint(x: 0, y: 1)
        monkeyArmLSprt.position = CGPoint(x: -2, y: -1)
        monkeyArmLSprt.zPosition = -2
        monkeyArmLSprt.zRotation = 0
        monkeySprt.addChild(monkeyArmLSprt)
        
        monkeyArmRSprt = SKSpriteNode(imageNamed: "Monkey_The Cave-Run-arm R.png")
        monkeyArmRSprt.anchorPoint = CGPoint(x: 0, y: 1)
        monkeyArmRSprt.position = CGPoint(x: -2, y: -1)
        monkeyArmRSprt.zPosition = 8
        monkeyArmRSprt.zRotation = -0.6
        monkeySprt.addChild(monkeyArmRSprt)

        let faction1 = SKAction.rotate(byAngle: 0.7, duration: 0.3)
        let faction2 = SKAction.rotate(byAngle: -0.7, duration: 0.3)
        let frepeat = SKAction.repeatForever(SKAction.sequence([faction1,faction2]))
        
        let brepeat = SKAction.repeatForever(SKAction.sequence([faction2,faction1]))
        
        monkeyLegLSprt.run(frepeat)
        monkeyLegRSprt.run(brepeat)
        
        monkeyArmLSprt.run(brepeat)
        monkeyArmRSprt.run(frepeat)
        
        monkeyUnlockAction = SKAction.animate(with:  [SKTexture(imageNamed: "Monkey_The Cave-Open box_B.png")], timePerFrame: 0.2, resize: true, restore: false)
        
        monkeyLastUnlockAction = SKAction.animate(with:  [SKTexture(imageNamed: "Monkey_The Cave-Open box_B.png"), SKTexture(imageNamed: "Monkey_The Cave-Open box_A.png") ], timePerFrame: 0.2, resize: true, restore: false)
        
        monkeyRunAction = SKAction.animate(with:  [SKTexture(imageNamed: "Monkey_The Cave-Run-body.png")], timePerFrame: 0.2, resize: true, restore: false)

        
        // Chest
        
        chestSprt = SKSpriteNode(imageNamed: "Box close_part1.png")
        chestSprt.anchorPoint = CGPoint(x: 0, y: 0)
        chestSprt.position = CGPoint(x: view.bounds.width + 20, y: 10)
        chestSprt.zPosition = 8
        self.addChild(chestSprt)
        
        chestOpenAnim = SKAction.animate(with:  [SKTexture(imageNamed: "Box open_part1.png")], timePerFrame: 0.2, resize: true, restore: false)
        chestCloseAnim = SKAction.animate(with:  [SKTexture(imageNamed: "Box close_part1.png")], timePerFrame: 0.2, resize: true, restore: false)

        
        // Box monkey 
        
        boxMonkeySprt = SKSpriteNode(imageNamed: "Monkey_box-red 01.png")
        boxMonkeySprt.anchorPoint = CGPoint(x: 0.5, y: 0)
        boxMonkeySprt.position = CGPoint(x: 100, y: 10)
        boxMonkeySprt.zPosition = 7
        boxMonkeySprt.alpha = 0
        self.addChild(boxMonkeySprt)
        
        var boxMText = [SKTexture]()
        
        let boxMnames = ["Monkey_box-green 0", "Monkey_box-orange 0","Monkey_box-red 0","Monkey_box-gold 0"]
        
        
        for name in boxMnames
        {
            boxMText.removeAll()
            for i in 0..<3
            {
                boxMText.append(SKTexture(imageNamed: name + "\(i+1).png"))
            }
            
            boxMonkeyAnimations.append(SKAction.animate(with:boxMText, timePerFrame: 0.1, resize: true, restore: false))
        }
        
        /*
         let deadlineTime = DispatchTime.now() + .seconds(1)
         DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
         self.startStream()
         }
         
         let deadlineTime2 = DispatchTime.now() + .seconds(2)
         DispatchQueue.main.asyncAfter(deadline: deadlineTime2) {
            self.showSuccess {
                
            }
         }
        */
        
        self.isPaused = true

    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        if self.stopMoving || self.pauseMoving
        {
            return
        }
        
        let deltaX:CGFloat = -3.0
        
        self.bgSprt1.position = CGPoint(x:self.bgSprt1.position.x + deltaX,y:self.bgSprt1.position.y)
        self.bgSprt2.position = CGPoint(x:self.bgSprt2.position.x + deltaX,y:self.bgSprt2.position.y)
        self.chestSprt.position = CGPoint(x:self.chestSprt.position.x + deltaX,y:self.chestSprt.position.y)
        self.boxMonkeySprt.position = CGPoint(x:self.boxMonkeySprt.position.x + deltaX,y:self.boxMonkeySprt.position.y)
        
        if bgSprt1.position.x <= -bgSprt1.size.width
        {
            self.bgSprt1.position = CGPoint(x:self.bgSprt2.position.x + self.bgSprt2.size.width,y:self.bgSprt1.position.y)
        }
        
        if bgSprt2.position.x <= -bgSprt2.size.width
        {
            self.bgSprt2.position = CGPoint(x:self.bgSprt1.position.x + self.bgSprt1.size.width,y:self.bgSprt2.position.y)
        }
        
        if chestSprt.position.x <= 100
        {
            if shouldFinish == true
            {
                openLastChest()
            }
            else
            {
                openNextChest()
            }
        }
        
    }
    
    func openNextChest()
    {
        self.monkeySprt.run(self.monkeyUnlockAction)
        self.chestSprt.run(self.chestOpenAnim)
        self.pauseMoving = true
        
        self.hideLimbs(hidden: true)
        
        self.monkeySprt.position = CGPoint(x:self.monkeySprt.position.x,y:self.monkeySprt.position.y - 20)
        

        self.chestSprt.run(SKAction.fadeOut(withDuration: 0.3))
        self.chestSprt.run(SKAction.sequence([SKAction.scaleX(to: 1.2, y: 0.7, duration: 0.1),
                                              SKAction.scaleX(to: 0.7, y: 1.0, duration: 0.1)] ))
        
        
        let wait = SKAction.wait(forDuration: 0.4)
        let block = SKAction.run { 
            self.chestSprt.position = CGPoint(x: self.view!.bounds.width, y: self.chestSprt.position.y)
            
            self.monkeySprt.run(self.monkeyRunAction)
            self.chestSprt.run(self.chestCloseAnim)
            self.pauseMoving = false
            self.hideLimbs(hidden: false)
            
            self.monkeySprt.position = CGPoint(x:self.monkeySprt.position.x,y:self.monkeySprt.position.y + 20)
            self.chestSprt.run(SKAction.fadeIn(withDuration: 0))
            self.chestSprt.run(SKAction.scale(to: 1.0, duration: 0))
            self.boxMonkeySprt.run(SKAction.fadeOut(withDuration: 0.8))
        }
        let seq = SKAction.sequence([wait,block])
        
        self.run(seq)
        
        
        // Monkey 
        
        boxMonkeySprt.position = CGPoint(x:chestSprt.position.x+9,y:chestSprt.position.y)
        boxMonkeySprt.alpha = 1.0
        boxMonkeySprt.setScale(0.2)
        
        let cgpath = CGMutablePath()
        let startingPoint = boxMonkeySprt.position
        let endingPoint = CGPoint(x:boxMonkeySprt.position.x + 100.0,y:boxMonkeySprt.position.y)
        
        let controlPoint1 = CGPoint(x: startingPoint.x + 10, y: endingPoint.y + 90)
        let controlPoint2 = CGPoint(x: startingPoint.x + 70, y: endingPoint.y + 90)
        
        cgpath.move(to: CGPoint(x: startingPoint.x, y: startingPoint.y))
        cgpath.addCurve(to: endingPoint, control1: controlPoint1, control2: controlPoint2)
        
        
        let jumpMonkey = SKAction.follow(cgpath, asOffset: false, orientToPath: false, duration: 0.3)
        boxMonkeySprt.run(jumpMonkey)
        
        let animNum = Int(arc4random() % 3)
        boxMonkeySprt.run(boxMonkeyAnimations[animNum])
        boxMonkeySprt.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    
    func openLastChest()
    {
        self.monkeySprt.run(self.monkeyLastUnlockAction)
        self.chestSprt.run(self.chestOpenAnim)
        self.stopMoving = true
        
        self.hideLimbs(hidden: true)
        
        self.monkeySprt.position = CGPoint(x:self.monkeySprt.position.x,y:self.monkeySprt.position.y - 20)
        
        //self.chestSprt.run(SKAction.sequence([SKAction.scaleX(to: 1.2, y: 0.7, duration: 0.1),SKAction.scaleX(to: 0.7, y: 1.0, duration: 0.1)] ))

        //self.chestSprt.run(SKAction.move(to: CGPoint(x: self.chestSprt.position.x + self.chestSprt.size.width/2, y: self.chestSprt.size.height), duration: 0.4))
        
        
        
        let wait = SKAction.wait(forDuration: 2.9)
        let block = SKAction.run {
            if self.completionBlock != nil
            {
                self.completionBlock()
            }
        }
        let seq = SKAction.sequence([wait,block])
        self.run(seq)
        
        // Main monkey anim 
        
        let cgpathM = CGMutablePath()
        let startingPointM = monkeySprt.position
        let endingPointM = CGPoint(x:monkeySprt.position.x + 130.0,y:monkeySprt.position.y + 10)
        
        let controlPoint1M = CGPoint(x: startingPointM.x + 10, y: endingPointM.y + 110)
        let controlPoint2M = CGPoint(x: startingPointM.x + 70, y: endingPointM.y + 110)
        
        cgpathM.move(to: CGPoint(x: startingPointM.x, y: startingPointM.y))
        cgpathM.addCurve(to: endingPointM, control1: controlPoint1M, control2: controlPoint2M)

        //let jumpMonkeyM = SKAction.follow(cgpathM, asOffset: false, orientToPath: false, duration: 0.3)

        let waitM = SKAction.wait(forDuration: 0.9)
        let blockM = SKAction.run {
            /*
            self.monkeySprt.run(self.monkeyRunAction)
            self.prepareLimbsForJump()
            self.monkeySprt.run(jumpMonkeyM)
            self.monkeySprt.zPosition = 11
            self.chestSprt.zPosition = 10
             */
        }
        self.run(SKAction.sequence([waitM,blockM]))
        
        
        
        
        // Box Monkey
        
        boxMonkeySprt.position = CGPoint(x:chestSprt.position.x+9,y:chestSprt.position.y)
        boxMonkeySprt.alpha = 1.0
        boxMonkeySprt.setScale(0.2)
        
        let cgpath = CGMutablePath()
        let startingPoint = boxMonkeySprt.position
        let endingPoint = CGPoint(x:boxMonkeySprt.position.x + 150.0,y:boxMonkeySprt.position.y-10)
        
        let controlPoint1 = CGPoint(x: startingPoint.x + 10, y: endingPoint.y + 90)
        let controlPoint2 = CGPoint(x: startingPoint.x + 70, y: endingPoint.y + 90)
        
        cgpath.move(to: CGPoint(x: startingPoint.x, y: startingPoint.y))
        cgpath.addCurve(to: endingPoint, control1: controlPoint1, control2: controlPoint2)
        
        
        let jumpMonkey = SKAction.follow(cgpath, asOffset: false, orientToPath: false, duration: 0.3)
        boxMonkeySprt.run(jumpMonkey)
        
        boxMonkeySprt.run(boxMonkeyAnimations[3])
        boxMonkeySprt.run(SKAction.scale(to: 1.0, duration: 0.3))
        
        
        // Chest animation 
        
        chestSprt.anchorPoint = CGPoint(x: 0.7, y: 0)
        chestSprt.position =  CGPoint(x: self.chestSprt.position.x + 1.2 * self.chestSprt.size.width, y: self.chestSprt.position.y )
        let cRotate = SKAction.rotate(toAngle: -CGFloat.pi/2.0, duration: 0.2)
        cRotate.timingMode = .easeIn
        
        chestSprt.run(cRotate,completion:{
            let delay = SKAction.wait(forDuration: 0.3)
            let move1 = SKAction.move(to: CGPoint(x: self.chestSprt.position.x, y: self.chestSprt.position.y + 30), duration: 0.1)
            let seq = SKAction.sequence([delay,move1])
            self.chestSprt.run(seq, completion: {
                self.chestSprt.run(SKAction.move(to: CGPoint(x: self.chestSprt.position.x, y: -self.chestSprt.size.height), duration: 0.3))
            })
        })

    }

    
    
    func hideLimbs(hidden:Bool)
    {
        
        let alpha:CGFloat = hidden == true ? 0.0 : 1.0
        
        self.monkeyArmLSprt.alpha = alpha
        self.monkeyArmRSprt.alpha = alpha
        
        self.monkeyLegLSprt.alpha = alpha
        self.monkeyLegRSprt.alpha = alpha
    }
    
    func prepareLimbsForJump()
    {
        
        self.monkeyArmLSprt.removeAllActions()
        self.monkeyArmRSprt.removeAllActions()
        
        self.monkeyLegLSprt.removeAllActions()
        self.monkeyLegRSprt.removeAllActions()

        
        self.monkeyArmLSprt.alpha = 1
        self.monkeyArmRSprt.alpha = 1
        monkeyArmRSprt.zRotation = 0
        monkeyArmLSprt.zRotation = 0
        
        self.monkeyLegLSprt.alpha = 1
        self.monkeyLegRSprt.alpha = 1
        
    }
    
    // MARK: - BasicScene
    
    override func startStream()
    {
        self.isPaused = false
    }
    
    override func showSuccess(completion: @escaping () -> Void)
    {
        self.completionBlock = completion
        self.shouldFinish = true
        
    }
    
    override func updateProgress(progress: CGFloat) {
        
    }
    
    override func showFail()
    {
        //self.isPaused = true
        self.stopMoving = true
        
        self.monkeyArmLSprt.removeAllActions()
        self.monkeyArmRSprt.removeAllActions()
        
        self.monkeyLegLSprt.removeAllActions()
        self.monkeyLegRSprt.removeAllActions()
        
        
        let cgpath = CGMutablePath()
        let startingPoint = chestSprt.position
        let endingPoint = CGPoint(x:chestSprt.position.x + 140.0,y: -self.chestSprt.size.height)
        
        let controlPoint1 = CGPoint(x: startingPoint.x + 10, y: endingPoint.y + 190)
        let controlPoint2 = CGPoint(x: startingPoint.x + 70, y: endingPoint.y + 190)
        
        cgpath.move(to: CGPoint(x: startingPoint.x, y: startingPoint.y))
        cgpath.addCurve(to: endingPoint, control1: controlPoint1, control2: controlPoint2)
        
        
        let jumpChest = SKAction.follow(cgpath, asOffset: false, orientToPath: false, duration: 0.6)
        self.chestSprt.run(jumpChest)

        
        /*chestSprt.run(SKAction.move(to: CGPoint(x: chestSprt.position.x, y: chestSprt.position.y + 10), duration: 0.1), completion: {
            self.chestSprt.run(SKAction.move(to: CGPoint(x: self.chestSprt.position.x, y: -self.chestSprt.size.height), duration: 0.3))
        })*/
        
    }
}
