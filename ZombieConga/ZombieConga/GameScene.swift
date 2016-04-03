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
    var lives = 5
    var gameOver = false
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    let catMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    let playableRect: CGRect
    var lastTouchLocation = CGPoint.zero
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    let zombieAniamtion: SKAction
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    var zombieInvincible = false
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight)
        
        var textures:[SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        
        zombieAniamtion = SKAction.animateWithTextures(textures, timePerFrame: 0.1)
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }
    
    override func didMoveToView(view: SKView) {
        playBackgroundMusic("backgroundMusic.mp3")
        
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
        zombie.zPosition = 100
        //zombie1.setScale(2)
        addChild(zombie)
        //        zombie.runAction(SKAction.repeatActionForever(zombieAniamtion))
        
        // Add enemy
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnEnemy), SKAction.waitForDuration(2.0)])))
        
        // Add cat
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnCat), SKAction.waitForDuration(1.0)])))
        
        // Debug
        // debugDrawPlayableArea()
    }
    
    override func update(currentTime: NSTimeInterval) {
        let distance = (lastTouchLocation - zombie.position).length()
        
        if distance <= zombieMovePointsPerSec * CGFloat(dt) {
            zombie.position = lastTouchLocation
            velocity = CGPoint.zero
            stopZombieAnimation()
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
        moveTrain()
        if lives <= 0 && !gameOver {
            gameOver = true
            let gameOverScene = GameOverScene(size: size, won: false)
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            view?.presentScene(gameOverScene, transition: reveal)
            print("You lose!")
            backgroundMusicPlayer.stop()
        }
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
        startZombieAnimation()
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
        enemy.name = "enemy"
        enemy.position = CGPoint(x: size.width + enemy.size.width/2,
                                 y: CGFloat.random(
                                    min: CGRectGetMinY(playableRect) + enemy.size.height/2,
                                    max: CGRectGetMaxY(playableRect) - enemy.size.height/2))
        
        addChild(enemy)
        
        let actionMove = SKAction.moveToX(-enemy.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(x: CGFloat.random(min: CGRectGetMinX(playableRect), max: CGRectGetMaxX(playableRect)),
                               y: CGFloat.random(min: CGRectGetMinY(playableRect), max: CGRectGetMaxY(playableRect)))
        cat.setScale(0)
        addChild(cat)
        
        let appear = SKAction.scaleTo(1.0, duration: 0.5)
        
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotateByAngle(π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        let wiggleWait = SKAction.repeatAction(fullWiggle, count: 10)
        
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, wiggleWait, disappear, removeFromParent]
        cat.runAction(SKAction.sequence(actions))
    }
    
    func startZombieAnimation() {
        if zombie.actionForKey("animation") == nil {
            zombie.runAction(SKAction.repeatActionForever(zombieAniamtion), withKey: "animation")
        }
    }
    
    func stopZombieAnimation() {
        zombie.removeActionForKey("animation")
    }
    
    func zombieHitCat(cat: SKSpriteNode) {
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1)
        cat.zRotation = 0
        cat.runAction(SKAction.colorizeWithColor(UIColor.greenColor(), colorBlendFactor: 1.0, duration: 0.2))
        runAction(catCollisionSound)
    }
    
    func moveTrain() {
        var targetPosition = zombie.position
        var trainCount = 0
        
        enumerateChildNodesWithName("train") {
            (node, _) in
            trainCount += 1
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position // a
                let direction = offset.normalized() // b
                let amountToMovePerSec = self.catMovePointsPerSec * CGFloat(actionDuration) // c
                let amountToMove = direction * amountToMovePerSec // d
                let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration) // e
                node.runAction(moveAction)
            }
            targetPosition = node.position
        }
        
        if trainCount >= 15 && !gameOver {
            gameOver = true
            print("You win!")
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: size, won: true)
            gameOverScene.scaleMode = scaleMode
            
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func zombieHitEnemy(enemy: SKSpriteNode) {
        enemy.removeFromParent()
        zombieInvincible = true
        runAction(enemyCollisionSound)
        loseCats()
        lives -= 1
        
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customActionWithDuration(duration) { (node, elapsedTime) in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime) % Double(slice)
            node.hidden = remainder > Double(slice) / 2
        }
        
        let hiddenAction = SKAction.runBlock { 
            self.zombie.hidden = false
            self.zombieInvincible = false
        }
        
        zombie.runAction(SKAction.sequence([blinkAction, hiddenAction]))
    }
    
    func loseCats() {
        var loseCount = 0
        enumerateChildNodesWithName("train") { (node, stop) in
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            
            node.name = ""
            node.runAction(
            SKAction.sequence([
                SKAction.group([
                    SKAction.rotateByAngle(π * 4, duration: 1.0),
                    SKAction.moveTo(randomSpot, duration: 1.0),
                    SKAction.scaleTo(0, duration: 1.0)
                    ]),
                SKAction.removeFromParent()
                ]))
            loseCount += 1
            if loseCount >= 2 {
                stop.memory = true
            }
        }
    }
    
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodesWithName("cat") { node, _ in
            let cat = node as! SKSpriteNode
            if CGRectIntersectsRect(cat.frame, self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHitCat(cat)
        }
        
        if !zombieInvincible {
            var hitEnemies: [SKSpriteNode] = []
            enumerateChildNodesWithName("enemy") { (node, _) in
                let enemy = node as! SKSpriteNode
                if CGRectIntersectsRect(CGRectInset(node.frame, 20, 20), self.zombie.frame) {
                    hitEnemies.append(enemy)
                }
            }
            for enemy in hitEnemies {
                zombieHitEnemy(enemy)
            }
        }
    }
    
    // SK Delegate
    override func didEvaluateActions() {
        checkCollisions()
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
