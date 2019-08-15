//
//  Data.swift
//  GNG
//
//  Created by Andre Valdivia on 3/05/16.
//  Copyright © 2016 Andre Valdivia. All rights reserved.
//

import Foundation

struct OneData{
    var clase:Int
    var data = [Float]()
}

class Data {
    var numData:UInt32 = 0
    private var data = [OneData]()
    private var counter:Int = 0
    
    func insert(data:[Float], clase:Int){
        self.data.append(OneData(clase: clase, data: data))
        numData += 1
    }
    
    ///Devuelve data randomicamente
    func readPoint() -> (point: Point,clase: Int){
        let oneData = read()
        let point = Point(data: oneData.data)
        return (point, oneData.clase)
    }
    
    ///Devuelve la data en el ordende ingreso
    func readPointProgressive() -> (point: Point,clase: Int){
        let oneData = readProgressive()
        let point = Point(data: oneData.data)
        return (point, oneData.clase)
    }
    
    private func readProgressive() -> OneData{
        if(counter >= data.count - 1){
            counter = 0
        }else{
            counter += 1
        }
        return data[counter]
    }
    
    private func read() -> OneData{
        let randNum = Int(arc4random_uniform(numData))
        return data[randNum]
    }
}
