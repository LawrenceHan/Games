//
//  GameViewController.swift
//  ZombieConga
//
//  Created by Hanguang on 3/16/16.
//  Copyright (c) 2016 Hanguang. All rights reserved.
//

import UIKit
import SpriteKit

@available(iOS 9.0, *)
class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = MainMenuScene(size:CGSize(width: 2048, height: 1536))
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
