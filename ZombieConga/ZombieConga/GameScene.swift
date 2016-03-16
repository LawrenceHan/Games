//
//  GameScene.swift
//  ZombieConga
//
//  Created by Hanguang on 3/16/16.
//  Copyright (c) 2016 Hanguang. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
        background.zPosition = -1
        //background.zRotation = CGFloat(M_PI) / 8
        addChild(background)
        
        let mySize = background.size
        print("Size: \(mySize)")
    }
}
