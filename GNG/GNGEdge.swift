//
//  GNGEdge.swift
//  GNG
//
//  Created by Andre Valdivia on 3/05/16.
//  Copyright © 2016 Andre Valdivia. All rights reserved.
//

import Foundation
import SceneKit

class GNGEdge{
    var id = 0
    var from :GNGNode
    var to :GNGNode
    var geometryNode:  SCNNode
    var pos: Point
    var bet:Float
    var render:Bool
    var pick:Bool
    
    var age:Int = 0
    
    static var counter : Int = 0
    
    init(_ from:GNGNode, _ to : GNGNode) {
        self.pick = false
        self.render = false
        self.from = from
        self.to = to
        
        self.id = GNGEdge.counter
        GNGEdge.counter += 1
        
        var geometry: SCNGeometry
        
        let height = sqrt(powf(from.SceneNode.position.x - to.SceneNode.position.x, 2) + powf(from.SceneNode.position.y - to.SceneNode.position.y , 2) + powf(from.SceneNode.position.z - to.SceneNode.position.z , 2))
        
        geometry = SCNCylinder(radius: 0.1, height: CGFloat(height))
        geometry.materials.first?.diffuse.contents = UIColor.red
        
        geometryNode = SCNNode(geometry: geometry)
        
        var beta = acos((to.SceneNode.position.y-from.SceneNode.position.y)/height)
        if (to.vector[0] < from.vector[0]){
            beta = -beta
        }
        geometryNode.eulerAngles = SCNVector3(0,0,-beta)
        
        let x = (from.SceneNode.position.x + to.SceneNode.position.x)/2
        let y = (from.SceneNode.position.y + to.SceneNode.position.y)/2
        let z = (from.SceneNode.position.z + to.SceneNode.position.z)/2
        
        geometryNode.position = SCNVector3(x,y,z)
        pos = Point(x, y, z)
        bet = Float(beta)
        
    }
    
    func updateScene() {
        let height = sqrt(powf(from.SceneNode.position.x - to.SceneNode.position.x, 2) + powf(from.SceneNode.position.y - to.SceneNode.position.y , 2) + powf(from.SceneNode.position.z - to.SceneNode.position.z , 2))
    
        let geo = self.geometryNode.geometry as! SCNCylinder
        geo.height = CGFloat(height)
        
        var beta = acosf((to.SceneNode.position.y-from.SceneNode.position.y)/height)
        if (to.vector[0] < from.vector[0]){
            beta = -beta
        }
        geometryNode.eulerAngles = SCNVector3(0,0,-beta)
        
        let x = (from.SceneNode.position.x + to.SceneNode.position.x)/2
        let y = (from.SceneNode.position.y + to.SceneNode.position.y)/2
        let z = (from.SceneNode.position.z + to.SceneNode.position.z)/2
        
        geometryNode.position = SCNVector3(x,y,z)
        
//        pos = Point(dimension: <#T##Int#>)
        bet = Float(beta)
    }
}
