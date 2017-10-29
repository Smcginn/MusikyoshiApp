//
//  SceneProtocol.swift
//  monkeytones
//
//  Created by 1 1 on 17.10.16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation
import SpriteKit


class BasicScene:SKScene {
    
    func startStream(){}
    func showSuccess( completion: @escaping (() -> Void ) ){}
    func showFail(){}
    func updateProgress(progress:CGFloat){}
    func noteChanged(){}
    
    func aspectStretch(sprite:SKSpriteNode, toWidth width:CGFloat)
    {
        let spriteAspect = sprite.size.height/sprite.size.width
        
        let _width = width
        let _height = _width * spriteAspect
        
        sprite.size = CGSize(width: _width, height: _height)
        
    }
    
    func aspectStretch(sprite:SKSpriteNode, toHeight height:CGFloat)
    {
        let spriteAspect = sprite.size.height/sprite.size.width
        
        let _height = height
        let _width = _height / spriteAspect
        
        sprite.size = CGSize(width: _width, height: _height)
        
    }
}
