//
//  Entry.swift
//  GNG
//
//  Created by Andre Valdivia on 3/05/16.
//  Copyright © 2016 Andre Valdivia. All rights reserved.
//

import Foundation

class Entry {
    var vertex : GNGNode
    var edges = [GNGNode: (GNGNode, GNGEdge)]()
    
    init (_ v: GNGNode) {
        vertex = v
    }
}