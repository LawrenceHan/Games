//
//  GameScene.swift
//  ZombieConga
//
//  Created by Hanguang on 3/16/16.
//  Copyright (c) 2016 Hanguang. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    let playableRect: CGRect
    var lastTouchLocation = CGPoint.zero
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight) // 4
        super.init(size: size) // 5
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }
    
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
        
        // Add zombie1
        zombie.position = CGPoint(x: 400, y: 400)
        //zombie1.setScale(2)
        addChild(zombie)
        
        // Add enemy
        spawnEnemy()
        
        // Debug
        debugDrawPlayableArea()
    }
    
    override func update(currentTime: NSTimeInterval) {
        let distance = (lastTouchLocation - zombie.position).length()
        
        if distance <= zombieMovePointsPerSec * CGFloat(dt) {
            zombie.position = lastTouchLocation
            velocity = CGPoint.zero
        } else {
            moveSprite(zombie, velocity: velocity)
            rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
        }
        
        boundsCheckZombie()
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        // 1
        let amountToMove = velocity * CGFloat(dt)
        
        // 2
        sprite.position += amountToMove
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let angle1 = sprite.zRotation
        let angle2 = direction.angle
        let shortest = shortestAngleBetween(angle1, angle2: angle2)
        let amountToRotate = rotateRadiansPerSec * CGFloat(dt)
        
        if abs(shortest) < amountToRotate {
            sprite.zRotation += shortest
        } else {
            sprite.zRotation += amountToRotate * shortest.sign()
        }
    }
    
    // MARK: - Touches methods
    
    func sceneTouched(touchLocation:CGPoint) {
        moveZombieToward(touchLocation)
    }
    
    func moveZombieToward(location: CGPoint) {
        let offset = location - zombie.position
        let direction = offset.normalized()
        velocity = direction * zombieMovePointsPerSec
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
        lastTouchLocation = touchLocation
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
        lastTouchLocation = touchLocation
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    // MARK: - Game logic
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: size.height/2)
        addChild(enemy)
        
        let actionMidMove = SKAction.moveByX(-size.width/2 - enemy.size.width/2,
                                             y: -CGRectGetHeight(playableRect)/2 + enemy.size.height/2,
                                             duration: 1.0)
        let actionMove = SKAction.moveByX(-size.width/2 - enemy.size.width/2,
                                          y: CGRectGetHeight(playableRect)/2 - enemy.size.height/2,
                                          duration: 1.0)
        let logMessage = SKAction.runBlock {
            print("Reached bottom")
        }
        let wait = SKAction.waitForDuration(0.25)
        let halfSequence = SKAction.sequence([actionMidMove, logMessage, wait, actionMove])
        let sequence = SKAction.sequence([halfSequence, halfSequence.reversedAction()])
        let repeatAction = SKAction.repeatActionForever(sequence)
        enemy.runAction(repeatAction)
    }
    
    
    // MARK: - DEBUG
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
}
