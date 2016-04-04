//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Hanguang on 4/3/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Foundation
import SpriteKit

@available(iOS 9.0, *)
class MainMenuScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "MainMenu")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(background)
    }
    
    func sceneTapped() {
        let transition = SKTransition.doorwayWithDuration(1.5)
        let scene = GameScene(size: size)
        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: transition)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        sceneTapped()
    }
}
