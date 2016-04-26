//: Playground - noun: a place where people can play

import UIKit
import SpriteKit
import XCPlayground

let sceneView = SKView(frame: CGRect(x: 0, y: 0, width: 480, height: 320))
let scene = SKScene(size: CGSize(width: 480, height: 320))
scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
sceneView.showsFPS = true
sceneView.presentScene(scene)

XCPlaygroundPage.currentPage.liveView = sceneView

let square = SKSpriteNode(imageNamed: "square")
square.name = "shape"
square.position = CGPoint(x: scene.size.width * 0.25,
                          y: scene.size.height * 0.50)

let circle = SKSpriteNode(imageNamed: "circle")
circle.name = "shape"
circle.position = CGPoint(x: scene.size.width * 0.50,
                          y: scene.size.height * 0.50)

let triangle = SKSpriteNode(imageNamed: "triangle")
triangle.name = "shape"
triangle.position = CGPoint(x: scene.size.width * 0.75,
                            y: scene.size.height * 0.50)

scene.addChild(square)
scene.addChild(circle)
scene.addChild(triangle)

circle.physicsBody = SKPhysicsBody(circleOfRadius: circle.size.width/2)

