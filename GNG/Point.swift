//
//  Point.swift
//  GNG
//
//  Created by Andre Valdivia on 3/05/16.
//  Copyright © 2016 Andre Valdivia. All rights reserved.
//


import Foundation

class Point{
    var point = [Float]()
    
    var dimension: Int {
        return point.count
    }
    
    init(dimension: Int) {
        self.point = Array(repeating: 0, count: dimension)
    }
    
    init(_ x : Float, _ y : Float, _ z : Float) {
        self.point = [x, y, z]
    }
    
    init(data: Array<Float>) {
        self.point = data
    }
    
    static func +(lhs: Point, rhs: Point) -> Point {
        let newPoint = Point(dimension: lhs.dimension)
        for index in 0..<newPoint.point.count{
            newPoint[index] = lhs.point[index] + rhs.point[index]
        }
        return newPoint
    }
    
    static func -(lhs: Point, rhs: Point) -> Point {
        let newPoint = Point(dimension: lhs.dimension)
        for index in 0..<newPoint.point.count{
            newPoint[index] = lhs.point[index] - rhs.point[index]
        }
        return newPoint
    }
    
    static func *(lhs: Point, rsh: Float) -> Point{
        let newPoint = Point(dimension: lhs.dimension)
        for (index, dimension) in lhs.point.enumerated(){
            newPoint[index] = dimension * rsh
        }
        return newPoint
    }
    
    subscript(index: Int) -> Float{
        get{
            return point[index]
        }
        set{
            point[index] = newValue
        }
    }
    
    func euclideanDistance (other:Point) -> Float {
        var distance: Float = 0.0
        for (index, p) in point.enumerated(){
            distance += pow(p - other.point[index], 2)
        }
        return sqrt(distance)
    }
    
    func squaredDistance (other:Point) -> Float {
        var distance: Float = 0.0
        for (index, p) in point.enumerated(){
            distance += pow(p - other.point[index], 2)
        }
        return distance
    }
    
    func pointBetween(secondPoint:Point) -> Point{
        let newPoint:Point = Point(dimension: secondPoint.dimension)
        for (index ,_ ) in self.point.enumerated(){
            newPoint.point[index] = (self.point[index] + secondPoint.point[index])/2
        }
        return newPoint
    }
}
