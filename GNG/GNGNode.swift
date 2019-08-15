//
//  GNGNode.swift
//  GNG
//
//  Created by Andre Valdivia on 3/05/16.
//  Copyright © 2016 Andre Valdivia. All rights reserved.
//

import Foundation
import SceneKit

class GNGNode: Hashable{
    var id = 0
    var error: Float = 0     //Error
    var SceneNode : SCNNode
    var clases = [Int]()
    var rendered: Bool
    
    var vector: Point //Wk
    
    static var counter : Int = 0
    
    init( _ point:Point) {
        self.SceneNode = SCNNode (geometry: SCNSphere(radius: 0.5))
        self.SceneNode.position = SCNVector3(point)
        self.id = GNGNode.counter
        vector = point
        GNGNode.counter += 1
        self.rendered = false
        
    }
    
    func update(_ vector: Point){
        self.vector = vector
    }
    
    func updateScene(){
        self.SceneNode.position = SCNVector3(vector)
    }
    
    func finalClass() -> Int{
        var clas = 0
        var maxClas = -1
        for (index,i) in clases.enumerated(){
            if clas < i{
                clas = i
                maxClas = index
            }
        }
        return maxClas
    }
    
    static func == (lhs: GNGNode, rhs: GNGNode) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


