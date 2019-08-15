//
//  GNG.swift
//  GNG
//
//  Created by Andre Valdivia on 3/05/16.
//  Copyright © 2016 Andre Valdivia. All rights reserved.
//

import Foundation

/// Paper: https://papers.nips.cc/paper/893-a-growing-neural-gas-network-learns-topologies.pdf
/// http://www.booru.net/download/MasterThesisProj.pdf

class GNG{
    var parameters  = Parameters()
    var graph = Graph()
    
    init(dimension:Int){
        let node1 = GNGNode(Point(data: Array(repeating: 0, count: dimension)))
        graph.insert(vertex: node1)
        let node2 = GNGNode(Point(data: Array(repeating: 3, count: dimension)))
        graph.insert(vertex: node2)
        graph.connect(from: node1, to: node2, withEdge: GNGEdge(node1,node2))
    }
    
    func initTrain(numClases:Int){
        for node in graph.container{
            for _ in 0..<numClases{
                node.vertex.clases.append(0)
            }
        }
    }
    
    func trainClass(data:Point,clase:Int){
        let nearestNode = findNearestNode(input: data)
        nearestNode.clases[clase-1] += 1
    }
    
    func whatClass(data:Point) -> Int{
        let nearestNode = findNearestNode(input: data)
        var ret:Int?
        var valMax:Int = 0
        for (index, val) in nearestNode.clases.enumerated(){
            if (val > valMax){
                valMax = val
                ret = index
            }
        }
        return ret!
    }
    
    // 1
    func iteration(input: Point){
        // 2
        let (Ws,Wt) = findNearestNodes(input: input)
        //3
//        Ws.error = Ws.error + powf(Ws.vector.squaredDistance(input), 2)
//        Ws.error = Ws.error + Ws.vector.euclideanDistance(input)
        Ws.error = Ws.error + Ws.vector.squaredDistance(other: input)
        //4
        Ws.update(Ws.vector + (input - Ws.vector) * parameters.Ew )
        for (node, edge) in graph.neighbours(node: Ws){
            node.update(node.vector + (input - node.vector) * parameters.En)
            edge.updateScene()
            //5
            edge.age += 1
        }
        //6
        let conectionWs_Wt = graph.connection(V1: Ws, Wt)
        if conectionWs_Wt == nil{
            graph.connect(from: Ws, to: Wt, withEdge: GNGEdge(Ws,Wt))
        }
        else{
            conectionWs_Wt?.age = 0
        }
        //7
        for Entry in graph.container {
            for (VO2,(_,VE)) in Entry.edges{
                if VE.age > parameters.Amax{
                    //Eliminar coneccion
                    graph.removeConnection(from: Entry.vertex, to: VO2)
                    VE.geometryNode.removeFromParentNode()
                    
                    //Eliminar nodos sueltos
                    if(Entry.edges.count == 0){
                        //Aqui falta eliminar de la escena
                        Entry.vertex.SceneNode.removeFromParentNode()
                        graph.removeNode(Node: Entry.vertex)
                    }
                    if let indexVO2 = graph.find(vertex: VO2){
                        if graph.container[indexVO2].edges.count == 0{
                            //Aqui falta eliminar de la escena
                            VO2.SceneNode.removeFromParentNode()
                            graph.container.remove(at: indexVO2)
                            
                        }
                    }
                }
            }
        }
        
        //8
        if parameters.numIteraciones % parameters.lambda == 0 && graph.container.count < parameters.maxNodos{
            let (u,v) = findUAndV()
            let r = graph.insertBetween(u, v)
            u.error = parameters.alpha * u.error
            v.error = parameters.alpha * v.error
            r.error = u.error
        }
        
        //9
        for node in graph.container{
            node.vertex.error = node.vertex.error - (parameters.beta*node.vertex.error)
        }
        parameters.numIteraciones += 1
    }
    
    /// Encuentra los dos nodos mas cercanos
    func findNearestNodes(input:Point) -> (nearest: GNGNode, secNearest: GNGNode){
        var nearest:GNGNode = graph.container[0].vertex
        var nearestSec:GNGNode = graph.container[0].vertex
        var dist1 = Float.greatestFiniteMagnitude
        var dist2 = Float.greatestFiniteMagnitude
        for node in graph.container{
            let dist = input.squaredDistance(other: node.vertex.vector)
            if(dist < dist1){
                dist2 = dist1
                dist1 = dist
                nearestSec = nearest
                nearest = node.vertex
            }else if(dist < dist2){
                nearestSec = node.vertex
                dist2 = dist
            }
        }
        return (nearest,nearestSec)
    }
    
    ///Encuentra el nodo mas cercano
    func findNearestNode(input:Point) -> GNGNode{
        var nearest:GNGNode = graph.container[0].vertex
        var dist1 = Float.greatestFiniteMagnitude
        for node in graph.container{
            let dist = input.squaredDistance(other: node.vertex.vector)
            if(dist < dist1){
                dist1 = dist
                nearest = node.vertex
            }
        }
        return nearest
    }
    
    ///Encuentra el nodo u con el error más grande, y el nodo v con el error más grande entre los vecinos de u
    func findUAndV() -> (u: GNGNode,v: GNGNode){
        var u:GNGNode? = nil// Error mas grande
        var v:GNGNode? = nil// Error segundo mas grande
        
        var errorMax:Float = -1
        
        for i in graph.container {
            if i.vertex.error > errorMax {
                u = i.vertex
                errorMax = i.vertex.error
            }
        }
        errorMax = -1
        for i in graph.neighbours(node: u!){
            if i.0.error > errorMax{
                v = i.0
                errorMax = v!.error
            }
        }
        return (u!,v!)
    }
    
}
