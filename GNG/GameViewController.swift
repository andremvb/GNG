//
//  GameViewController.swift
//  GNG
//
//  Created by Andre Valdivia on 3/05/16.
//  Copyright (c) 2016 Andre Valdivia. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import CoreGraphics

class GameViewController: UIViewController {

    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var spawnTime: TimeInterval = 0

    
    var train:Bool = true
    var classificar:Bool = false
    var counterClass:Int = 0
    var gng = GNG(dimension: 2)
    var data = Data()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupCamera()
        
        //Leer la data
        let path = Bundle.main.path(forResource: "spiral", ofType:"txt")!
        let url = URL(fileURLWithPath: path)
        let fileContent = try? String(contentsOf: url, encoding: .utf8)
        readData(file: fileContent! as String,indexClass: 2)
        
        
////////COMENTAR///////
        
        //Entrenar
        while(gng.parameters.numIteraciones < gng.parameters.maxIteraciones){
            gng.iteration(input: data.readPoint().point)
        }
        classificar = true
        gng.initTrain(numClases: 3)
        drawtrain()
        
        //Clasificar
        gng.initTrain(numClases: 3)
        for _ in 0..<data.numData{
            let (point, clas) = data.readPointProgressive()
            let node = SCNNode(geometry: SCNSphere(radius: 0.1))
            node.position = SCNVector3(point)
            scnScene.rootNode.addChildNode(node)
            gng.trainClass(data: point, clase: clas)
        }
        drawClassification()
        
    }
    
    func setupView(){
        scnView = self.view as? SCNView
        scnView.showsStatistics = true
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.delegate = self
    }
    
    func setupScene(){
        scnScene = SCNScene()
        scnView.scene = scnScene
    }
    
    func setupCamera(){
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(20, 20, 50)
        scnScene.rootNode.addChildNode(cameraNode)
    }

    func handleTap(gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: nil)
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject! = hitResults[0]
            
            // get its material
            let material = result.node!.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
//            SCNTransaction.setAnimationDuration(0.5)
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
//            SCNTransaction
            
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                material.emission.contents = UIColor.black
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("¡Memory danger :O !")
        // Release any cached data, images, etc that aren't in use.
    }
    
    func readData(file:String,indexClass:Int){
        let dataLine = file.components(separatedBy: "\r\n")
        for line in dataLine{
            if line != ""{
                let arrayLine = line.components(separatedBy: "\t")
                var classMember:Int?
                var dataArray = [Float]()
                for (index,unitData) in arrayLine.enumerated(){
                    if(index == indexClass){
                        
                        classMember = Int(unitData)!
                    }else{
                        dataArray.append(Float(unitData)!)
                    }
                }
                data.insert(data: dataArray, clase: classMember!)
            }
        }
    }
    
    func drawtrain( ) {
        //Imprimir Nodos
        var counterNodos:Int = 0
        for entry in gng.graph.container{
            if (entry.vertex.render == false){
                scnScene.rootNode.addChildNode(entry.vertex.SceneNode)
                entry.vertex.render = true
            }else{
//                let action = SCNAction.moveTo(entry.vertex.SceneNode.position, duration: 0)
//                entry.vertex.SceneNode.runAction(action)
            }
            //Imprimir edges
            for edge in entry.edges{
                if(edge.1.1.render == false){
                    scnScene.rootNode.addChildNode(edge.1.1.geometryNode)
                    edge.1.1.render = true
                }else{
//                    let actionPos = SCNAction.moveTo(edge.1.1.geometryNode.position, duration: 0)
//                    let actionRot = SCNAction.rotateToAxisAngle(edge.1.1.geometryNode.rotation, duration: 0)
//                    edge.1.1.geometryNode.runAction(actionPos)
//                    edge.1.1.geometryNode.runAction(actionRot)
//                    NSLog("Pos: \(edge.1.1.pos.point) -> PosEdge: \(edge.1.1.geometryNode.position)")
//                    edge.1.1.geometryNode.runAction(SCNAction.moveTo(edge.1.1.geometryNode.position, duration: 0))
                    if(edge.1.1.pick == false){
//                        let Pos = SCNVector3(edge.1.1.pos.x,edge.1.1.pos.y,0)
//                        let action = SCNAction.moveTo(Pos, duration: 0)
//                        edge.1.1.geometryNode.runAction(action)
//                        NSLog("Pos \(edge.1.1.id) : \(Pos) -> \(edge.1.1.geometryNode.position)")
                        edge.1.1.pick = true
                    }else
                    {
                        edge.1.1.pick = false
                    }
                }
            }
            counterNodos += 1
        }
    }
    
    func drawClassification(){
        for entry in gng.graph.container{
            entry.vertex.updateScene()
            for (_, (_, edge)) in entry.edges{
                edge.updateScene()
            }
            switch entry.vertex.finalClass(){
            case 0:
                entry.vertex.SceneNode.geometry!.materials.first?.diffuse.contents = UIColor.blue
            case 1:
                entry.vertex.SceneNode.geometry!.materials.first?.diffuse.contents = UIColor.yellow
            case 2:
                entry.vertex.SceneNode.geometry!.materials.first?.diffuse.contents = UIColor.green
            default:
                entry.vertex.SceneNode.geometry!.materials.first?.diffuse.contents = UIColor.white
            }
        }
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

        //Entrenar
//        if(gng.parameters.numIteraciones >= gng.parameters.maxIteraciones){
//            train = false
//            classificar = true
//        }
//        
//        if(train){
//            let point = data.readProgressive().0
////            let point = data.readProgressive().0
//            gng.iteration(point)
//            let trainNode = SCNNode(geometry: SCNSphere(radius: 0.2))
//            trainNode.position = SCNVector3(point.x,point.y,point.z)
//            scnScene.rootNode.addChildNode(trainNode)
//            drawtrain()
//            let actionRemove = SCNAction.removeFromParentNode()
//            let actionReduce = SCNAction.scaleTo(0, duration: 1)
//            let actionSequence = SCNAction.sequence([actionReduce,actionRemove])
//            trainNode.runAction(actionSequence)
//        }
//        
//        //Clasificar
//        if(classificar == true){
//            if(counterClass == 0){
//                gng.initTrain(3)
//            }
//            if(counterClass < Int(data.numData)){
//
//                let (p,c) = data.readProgressive()
//                let node = SCNNode(geometry: SCNSphere(radius: 0.1))
//                node.position = SCNVector3(p.x,p.y,0)
//                node.runAction(SCNAction.scaleBy(2, duration: 1))
//                scnScene.rootNode.addChildNode(node)
//                //        let s = SCNNode (geometry: SCNSphere(radius: 0.5))
//                gng.trainClass(p, clase: c)
//                drawClassification()
//                
//                counterClass += 1
//            }
//            if(counterClass == Int(data.numData) - 1){
//                classificar = false
//                NSLog("Termino de clasificar")
//            }
//        }


        
    }
}
