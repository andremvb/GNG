//
//  FileManager.swift
//  GNG
//
//  Created by André Valdivia on 8/15/19.
//  Copyright © 2019 Andre Valdivia. All rights reserved.
//

import Foundation

class FileManager{
    
    ///Dataset: http://cs.joensuu.fi/sipu/datasets/spiral.txt
    static func spiral() -> Data{
        let path = Bundle.main.path(forResource: "spiral", ofType:"txt")!
        let url = URL(fileURLWithPath: path)
        let fileContent = try? String(contentsOf: url, encoding: .utf8)
        return readData(file: fileContent as! String, indexClass: 2, numberClasses: 3, dimension: 2)
    }
    
    static func readData(file:String, indexClass:Int, numberClasses: Int?, dimension: Int) -> Data{
        let data = Data(dimension: dimension, classes: numberClasses)
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
        return data
    }
}
