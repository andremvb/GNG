//
//  Graph.swift
//  GNG
//
//  Created by Andre Valdivia on 3/05/16.
//  Copyright © 2016 Andre Valdivia. All rights reserved.
//

import Foundation


class Graph{
    var container = [Entry]()
    var nodes: Set<GNGNode> = []
//    var edges: Set<GNGEdge>
    
    /// Inserta un nodo. Si no es repetido, retorna el id del nodo creado.
    func insert(entry: Entry) -> Int? {
        if find( vertex: entry.vertex ) == nil {
            let objVertex = Entry(entry.vertex)
            self.container.append ( objVertex )
            return self.container.count - 1
        }
        return  nil
    }
    
    /// Inserta un nodo entre node1 y node2. Retorna el nodo creado
    func insertBetween(_ node1: GNGNode,_ node2: GNGNode) -> GNGNode{
        let middlePoint = node1.vector.pointBetween(secondPoint: node2.vector)
        let middleNode:GNGNode = GNGNode(middlePoint)
        insert(vertex: middleNode)
        connect(from: node1, to: middleNode, withEdge: GNGEdge(node1, middleNode))
        connect(from: node2, to: middleNode, withEdge: GNGEdge(node2, middleNode))
        removeConnection(from: node1, to: node2)
        return middleNode
    }
    
    //Inserta un nodo. si es que no se encuentra, retorna su id
    @discardableResult func insert (vertex: GNGNode) -> Int? {
        if find( vertex: vertex ) == nil{
            let objVertex = Entry(vertex)
            self.container.append ( objVertex )
            return self.container.count - 1
        }else{
            return nil
        }
    }
    
    //Retorna un GNGNode segun
    func get (idx : Int) -> GNGNode {
        return self.container[idx].vertex
    }
    
    /**
    Encuentra el indice del nodo en el grafo.
    */
    func find (vertex : GNGNode) -> Int? {
        return container.firstIndex{ $0.vertex == vertex}
        
    }
    
    ///Retorna el Entry al que pertenece el nodo
    func getEntry(vertex : GNGNode) -> Entry? {
        return container.first{$0.vertex == vertex}
    }
    
    //Retorna el numero de nodos
    func count() -> Int {
        return  self.container.count
    }
    
    //Retorna el Entry dandole el id del nodo
    func getEntry(idx : Int) -> Entry {
        return self.container [idx]
        
    }
    
    /*
    Crea un GNGNode from, crea otro GNGNode to
    Crea el GNGEdge entre los dos (se almacena en el from y el to.edge)
    */
    func connect(from: GNGNode, to: GNGNode, withEdge: GNGEdge)  {
        guard let indexFrom = find(vertex: from),
            let indexTo = find(vertex: to) else {print("No hubo una correcta conexión"); return}
        
        self.container[indexFrom].edges[to] = (to, withEdge)
        self.container[indexTo].edges[from] = (from, withEdge)
    }
    
    //Crea un edge entre dos GNGNode
    func connect(indexFrom: Int, indexTo: Int, withEdge: GNGEdge)  {
        let from  = self.container[indexFrom]
        let to   = self.container[indexTo]
        
        self.container[indexFrom].edges[to.vertex] = (to.vertex, withEdge)
        self.container[indexTo].edges[from.vertex] = (from.vertex, withEdge)
    }
    
    //Eliminar un edge entre dos GNGNode
    func removeConnection(from: GNGNode, to: GNGNode) {
        let ulist = self.getEntry(vertex: from)        
        let vlist = self.getEntry(vertex: to)
        
        if ulist != nil {
            ulist!.edges[to]!.1.geometryNode.removeFromParentNode()
            ulist?.edges.removeValue(forKey: to)
        }
        if vlist != nil {
            vlist?.edges.removeValue(forKey: from)
        }
    }
    
    func removeNode(Node:GNGNode){
        if let VO = find(vertex: Node){
            container.remove(at: VO)
        }else{
            print("Se removió un nodo")
        }
    }
    
    //Devuelve los vecinos de un GNGNode
    func neighbours(node:GNGNode) -> Array<(node: GNGNode,edge: GNGEdge)>{
        var ret1 = Array<(GNGNode,GNGEdge)>()
        if let node = find(vertex: node){
            for i in container[node].edges{
                ret1.append((i.0,i.1.1))
            }
        }
        return ret1
    }
    
    
    ///Se supone que encuentra el path en el grafo
    func findPath(start:GNGNode, end:GNGNode ) -> Array<GNGNode>? {
        
        var path = Array<GNGNode>()
        path.append( start )
        NSLog("\(start) -> ")
        
        if start == end {
            return path
        }
        let ret = self.getEntry(vertex: start);
        if ret == nil{
            return nil
        }
        
        // var edges = [Int: (Int, GNGEdge)]();
        for (key, _) in ret!.edges {
//            let indexOfKey = path.indexOf(key);
            let indexOfKey = path.firstIndex(of: key)
            if indexOfKey == nil {
                let newpath = self.findPath(start: key, end:end)
                if newpath != nil  {
                    return newpath
                }
            }
        }
        return nil
    }
    
    func connection(V1: GNGNode,_ V2: GNGNode) -> GNGEdge?{
        if let index1 = find(vertex: V1){
            if  index1 >= 0{
                for i in container[index1].edges{
                    if i.0 == V2{
                        return i.1.1
                    }
                }
                return nil
            }else{
                return nil
            }
        }else{
            return nil
        }
    }
}
