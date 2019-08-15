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

class GNGViewController: UIViewController {

    enum AlgorithmState{
        case training, classifing, none, drawing
    }
    
    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var spawnTime: TimeInterval = 0

    var counterClass:Int = 0
    var gng: GNG
    var data: Data
    
    let progressView = UIProgressView(progressViewStyle: .bar)
    let labelProgress = UILabel(frame: .zero)
    var state: AlgorithmState = .none {
        didSet{
            DispatchQueue.main.async {
                switch self.state {
                case .none:
                    self.labelProgress.isHidden = true
                    self.progressView.isHidden = true
                case .classifing:
                    self.labelProgress.isHidden = false
                    self.progressView.isHidden = false
                    self.labelProgress.text = "Classifing"
                case .training:
                    self.labelProgress.isHidden = false
                    self.progressView.isHidden = false
                    self.labelProgress.text = "Training"
                case .drawing:
                    self.labelProgress.isHidden = false
                    self.progressView.isHidden = false
                    self.labelProgress.text = "Drawing"
                }
            }
        }
    }
    
    var progress: Float = 0{
        didSet{
            DispatchQueue.main.async {
                self.progressView.setProgress(self.progress, animated: true)
            }
        }
    }
    
    fileprivate func drawData() {
        //Draw Data
        let radioData: CGFloat = 0.1
        for _ in 0..<self.data.numData{
            let (point, _) = self.data.readPointProgressive()
            let node = SCNNode(geometry: SCNSphere(radius: radioData))
            node.position = SCNVector3(point)
            self.scnScene.rootNode.addChildNode(node)
        }
    }
    
    ///Entrenar
    fileprivate func train() {
        self.state = .training
        while(self.gng.parameters.numIteraciones < self.gng.parameters.maxIteraciones){
            self.progress = Float(self.gng.parameters.numIteraciones) / Float(self.gng.parameters.maxIteraciones)
            self.gng.iteration(input: self.data.readPoint().point)
        }
        self.state = .drawing
        self.drawtrain()
        self.state = .none
    }
    
    fileprivate func classify() {
        //Clasificar
        if let numClasses = data.classes{
            self.state = .classifing
            self.gng.initClassification(numClases: numClasses)
            for _ in 0..<self.data.numData{
                let (point, clas) = self.data.readPointProgressive()
                self.gng.trainClass(data: point, clase: clas)
            }
            self.state = .drawing
            self.drawClassification()
            self.state = .none
        }
    }
    
    init(data: Data) {
        self.gng = GNG(dimension: data.dimension)
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        print("GNG deinitilized")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupCamera()
        setupProgress()
        
        scnView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        DispatchQueue.global(qos: .background).async {
            self.drawData()
            self.train()
            self.classify()
        }
    }
    
    func setupView(){
        //Set sceneView and constraints
        scnView = SCNView() 
        view.addSubview(scnView)
        view.backgroundColor = .black
        scnView.backgroundColor = .black
        scnView.translatesAutoresizingMaskIntoConstraints = false
        scnView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scnView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scnView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scnView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        //Set some variables
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
    
    fileprivate func setupProgress() {
        view.addSubview(progressView)
        progressView.progressTintColor = .lightGray
        progressView.trackTintColor = .darkGray
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        progressView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressView.layer.cornerRadius = 5
        progressView.layer.masksToBounds = true
        
        view.addSubview(labelProgress)
        labelProgress.textColor = .white
        labelProgress.textAlignment = .center
        labelProgress.translatesAutoresizingMaskIntoConstraints = false
        labelProgress.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        labelProgress.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        labelProgress.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 5).isActive = true
        
    }

    @objc func handleTap(gestureRecognize: UIGestureRecognizer) {
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

            SCNTransaction.animationDuration = 0.5

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
    
    func drawtrain( ) {
        gng.updateScene()
        //Imprimir Nodos
        var counterNodos:Int = 0
        for entry in gng.graph.container{
            if (entry.vertex.rendered == false){
                scnScene.rootNode.addChildNode(entry.vertex.SceneNode)
                entry.vertex.rendered = true
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
        gng.updateScene()
        for entry in gng.graph.container{
            
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

extension GNGViewController: SCNSceneRendererDelegate {
    
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
