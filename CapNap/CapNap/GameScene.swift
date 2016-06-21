//
//  GameScene.swift
//  CapNap
//
//  Created by Hanguang on 4/24/16.
//  Copyright (c) 2016 Hanguang. All rights reserved.
//

import SpriteKit

protocol CustomNodeEvents {
    func didMoveToScene()
}

protocol InteractiveNode {
    func interact()
}

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Cat: UInt32 = 0b1 // 1
    static let Block: UInt32 = 0b10 // 2
    static let Bed: UInt32 = 0b100 // 4
    static let Edge: UInt32 = 0b1000 // 8
    static let Label: UInt32 = 0b10000 // 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bedNode: BedNode!
    var catNode: CatNode!
    var playable = true
    
    override func didMoveToView(view: SKView) {
        // Calculate playable margin
        
        let maxAspectRatio: CGFloat = 16.0/9.0 // iPhone 5
        let maxAspectRatioHeight = size.width / maxAspectRatio
        let playableMargin: CGFloat = (size.height - maxAspectRatioHeight) / 2
        
        let playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: size.height-playableMargin*2)
        
        physicsBody = SKPhysicsBody(edgeLoopFromRect: playableRect)
        physicsWorld.contactDelegate = self
        physicsBody!.categoryBitMask = PhysicsCategory.Edge
        
        bedNode = childNodeWithName("bed") as! BedNode
        catNode = childNodeWithName("//cat_body") as! CatNode
        
        enumerateChildNodesWithName("//*") { (node, _) in
            if let customNode = node as? CustomNodeEvents {
                customNode.didMoveToScene()
            }
        }
        
        SKTAudio.sharedInstance().playBackgroundMusic("backgroundMusic.mp3")
    }
   
    func inGameMessage(text: String) {
        let message = MessageNode(message: text)
        message.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
        addChild(message)
    }
    
    func newGame() {
        let scene = GameScene(fileNamed: "GameScene")
        scene!.scaleMode = scaleMode
        view!.presentScene(scene)
    }
    
    func lose() {
        // 1
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        runAction(SKAction.playSoundFileNamed("lose.mp3", waitForCompletion: false))
        
        // 2
        inGameMessage("Try again...")
        
        // 3
        performSelector(#selector(newGame), withObject: nil, afterDelay: 5)
        
        playable = false
        catNode.wakeUp()
    }
    
    func win() {
        playable = false
        
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        runAction(SKAction.playSoundFileNamed("win.mp3", waitForCompletion: false))
        
        inGameMessage("Nice job!")
        
        performSelector(#selector(newGame), withObject: nil, afterDelay: 5)
        
        catNode.curlAt(bedNode.position)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    // MARK: Contact test delegate
    func didBeginContact(contact: SKPhysicsContact) {
        if let labelNode = ((contact.bodyA.categoryBitMask == PhysicsCategory.Label) ?
            contact.bodyA.node : contact.bodyB.node) as? MessageNode {
            labelNode.didBounce()
        }
        
        if !playable {
            return
        }
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.Cat | PhysicsCategory.Bed {
            print("SUCCESS")
            win()
        } else if collision == PhysicsCategory.Cat | PhysicsCategory.Edge {
            print("FAIL")
            lose()
        }
        
    }
}
