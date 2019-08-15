//
//  Generator.swift
//  GNG
//
//  Created by Andre Valdivia on 3/05/16.
//  Copyright © 2016 Andre Valdivia. All rights reserved.
//

import Foundation

class Generator {
    static func plano2D(centre:(UInt32,UInt32), largo:Int) -> Point {
        let ret:Point = Point(dimension: 2)
        ret.point[0] = Float(Int(arc4random_uniform(centre.0 + UInt32(largo)*2)) - largo);
        ret.point[1] = Float(Int(arc4random_uniform(centre.1 + UInt32(largo)*2)) - largo);
        ret.point[2] = 0
        return ret
    }
    
    static func circulo2D(centre:(UInt32,UInt32), radio:Int) -> Point{
        let ret:Point = Point(dimension: 2)
        ret.point[0] = Float(Int(arc4random_uniform(centre.0 + UInt32(radio)*2)) - radio);

        ret.point[1] = Float(Int(arc4random_uniform(centre.1 + UInt32(radio)*2)) - radio);
        if(ret.point[1] > sqrt(pow(Float(radio), 2) + pow(ret.point[0],2)) ){
            ret.point[1] = sqrt(pow(Float(radio), 2) + pow(ret.point[0],2))
        }
        else if(ret.point[1] < sqrt(pow(Float(radio), 2) + pow(ret.point[0],2))){
            ret.point[1] = sqrt(pow(Float(radio), 2) + pow(ret.point[0],2))
        }
        ret.point[2] = 0
        return ret
    }
}
