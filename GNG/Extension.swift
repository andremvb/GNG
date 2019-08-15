//
//  Extension.swift
//  GNG
//
//  Created by André Valdivia on 8/14/19.
//  Copyright © 2019 Andre Valdivia. All rights reserved.
//

import Foundation
import SceneKit

extension SCNVector3{
    init(_ point: Point){
        switch point.dimension{
        case 0:
            fatalError("No debe de entrar aqui, no estan los puntos inicializados")
        case 1:
            self.init(point[0],0, 0)
        case 2:
            self.init(point[0],point[1], 0)
        case 3:
            self.init(point[0], point[1], point[2])
        default:
            self.init(point[0], point[1], point[2])
        }
    }
}
