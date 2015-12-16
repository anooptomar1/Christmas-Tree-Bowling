//
//  ViewController.swift
//  Christmas-Tree-Bowling
//
//  Created by Simon Gladman on 15/12/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//


import UIKit
import SceneKit

class ViewController: UIViewController
{
    lazy var sceneKitView: SCNView =
    {
        let scene = SCNScene()
        let view = SCNView()
        
        view.backgroundColor = UIColor.blackColor()
        view.scene = scene
        
        view.showsStatistics = true
        
        return view
    }()
    
    lazy var christmasTreeCompositeNode: SCNNode =
    {
        let cone = SCNCone(topRadius: 0, bottomRadius: 0.5, height: 1.5)
        let trunk = SCNCylinder(radius: 0.25, height: 0.5)
        let bauble = SCNSphere(radius: 0.1)
        
        let coneNode = SCNNode(geometry: cone)
        let trunkNode = SCNNode(geometry: trunk)
        let baubleNode = SCNNode(geometry: bauble)
        
        coneNode.position = SCNVector3(0, 0.5, 0)
        trunkNode.position = SCNVector3(0, -0.5, 0)
        baubleNode.position = SCNVector3(0, 1.2, 0)
        
        let coneMaterial = SCNMaterial()
        coneMaterial.diffuse.contents = UIColor.greenColor()
        cone.materials = [coneMaterial]
        
        let trunkMaterial = SCNMaterial()
        trunkMaterial.diffuse.contents = UIColor.brownColor()
        trunk.materials = [trunkMaterial]
        
        let baubleMaterial = SCNMaterial()
        baubleMaterial.reflective.contents = UIImage(named: "reflection.jpg")
        baubleMaterial.reflective.intensity = 0.5
        baubleMaterial.diffuse.contents = UIColor(red: 1, green: 0.75, blue: 9.75, alpha: 1)
        baubleMaterial.shininess = 0.5
        baubleMaterial.specular.contents = UIColor.whiteColor()
        bauble.materials = [baubleMaterial]
        
        let christmasTreeCompositeNode = SCNNode()
        christmasTreeCompositeNode.addChildNode(coneNode)
        christmasTreeCompositeNode.addChildNode(trunkNode)
        christmasTreeCompositeNode.addChildNode(baubleNode)
        
        return christmasTreeCompositeNode
    }()
    
    var scene: SCNScene
    {
        return sceneKitView.scene!
    }
    
    let touchCatchingPlaneNode = SCNNode(geometry: SCNPlane(width: 20, height: 20))
   
    let ballNode = SCNNode(geometry: SCNSphere(radius: 0.25))
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.addSubview(sceneKitView)
        
        setupSceneKit()
    }
    
    // MARK: Touch handling
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        guard let touch = touches.first else
        {
            return
        }
        
        ballNode.physicsBody = nil
        
        positionBallFromTouch(touch)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        guard let touch = touches.first else
        {
            return
        }
        
        positionBallFromTouch(touch)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        let physicsBodyBall = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic,
            shape: SCNPhysicsShape(geometry: ballNode.geometry!, options: nil))
        
        ballNode.physicsBody = physicsBodyBall
        
        physicsBodyBall.applyForce(SCNVector3(0, 0, -40), impulse: true)
    }
    
    func positionBallFromTouch(touch: UITouch)
    {
        guard let hitTestResult:SCNHitTestResult = sceneKitView.hitTest(touch.locationInView(view),
            options: nil)
            .filter( { $0.node == touchCatchingPlaneNode }).first else
        {
            return
        }
        
        ballNode.position = SCNVector3(hitTestResult.localCoordinates.x,
            hitTestResult.localCoordinates.y,
            5)
    }
    
    // MARK: SceneKit set up
    
    func setupSceneKit()
    {
        // Camera
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 7)
        
        scene.rootNode.addChildNode(cameraNode)
        
        // Omni light
        
        for lightPosition in [SCNVector3(-10, 0, 10), SCNVector3(10, 10, -10)]
        {
            let light = SCNLight()
            light.type =  SCNLightTypeOmni
            
            let lightNode = SCNNode()
            lightNode.light = light
            
            lightNode.position = lightPosition
            
            scene.rootNode.addChildNode(lightNode)
        }
        
        // Christmas Trees
        
        for z in 0 ... 4
        {
            for x in 0 ... z
            {
                let christmasTreeeNode = christmasTreeCompositeNode.flattenedClone()
                
                christmasTreeeNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic,
                    shape: SCNPhysicsShape(geometry: christmasTreeeNode.geometry!, options: nil))
                
                let spacing = Float(2.5)
                
                christmasTreeeNode.position = SCNVector3((-spacing * Float(z) / 2) + (Float(x) * spacing),
                    -1,
                    -Float(z) * spacing)
                
                scene.rootNode.addChildNode(christmasTreeeNode)
            }
        }
        
        // Box
        ballNode.position = SCNVector3(0, 0, 5)
        ballNode.rotation = SCNVector4(0.2, 0.3, 0.4, 1)
        
        scene.rootNode.addChildNode(ballNode)

        // Floor
        
        let floorMaterial = SCNMaterial()
        floorMaterial.normal.contents = UIImage(named: "bumpMap.jpg")
        floorMaterial.normal.wrapS = SCNWrapMode.Repeat
        floorMaterial.normal.wrapT = SCNWrapMode.Repeat
        floorMaterial.normal.contentsTransform = SCNMatrix4MakeScale(25, 25, 1)
        floorMaterial.normal.intensity = 0.25
   
        floorMaterial.diffuse.contents = UIColor(red: 0.95, green: 0.95, blue: 1, alpha: 1)
        floorMaterial.ambient.contents = UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1)
        floorMaterial.specular.contents = UIColor.whiteColor()
        
        let floor = SCNFloor()
        floor.reflectivity = 0.1
      
        floor.materials = [floorMaterial]
        
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0, -1, 0)
        
        scene.rootNode.addChildNode(floorNode)
      
        // Physics for floor
        
        let physicsBodyFloor = SCNPhysicsBody(type: SCNPhysicsBodyType.Static,
            shape: SCNPhysicsShape(geometry: floorNode.geometry!, options: nil))
        
        floorNode.physicsBody = physicsBodyFloor
        
        // Touch catching plane
        
        touchCatchingPlaneNode.opacity = 0.000001
        
        scene.rootNode.addChildNode(touchCatchingPlaneNode)
        touchCatchingPlaneNode.position = ballNode.position
    }
    
    override func viewDidLayoutSubviews()
    {
        sceneKitView.frame = view.bounds
    }
    
}
