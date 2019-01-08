//
//  GeoRef.swift
//  Rock&Roll
//
//  Created by Elnaz Taqizadeh on 2018-02-12.
//  Basic Geometry functions
//

import Foundation
import GEOSwift

class GeoRef {
    let mathRef = MathRef()
    
    //Define an array of points
    func getCoordinate(R: Double) -> Array<Coordinate>{
        var theta = mathRef.linspace(low: 0, up: 2*Double.pi, length: 512)
        var coord = [Coordinate]()
        
        for i in 0..<theta.count {
            coord.append(Coordinate(x: R * cos(theta[i]), y: R * sin(theta[i])))
        }
        return coord
    }
    
    
    //Find Polygon Area
    func polygonArea(points: Array<Coordinate>) -> Double {
        //Accumulates area in the loop
        var area = 0.0
        //The last vertes is the 'previous' one to the first
        var j = points.count-1
        for i in 0..<points.count{
            area = area + (points[j].x+points[i].x)*(points[j].y-points[i].y)
            //j is previous vertex to i
            j = i
        }
        return area/2
    }
    
    //Find Coordinates of Geometry Points
    func geometryPoints(str: String) -> Array<Coordinate> {
        
        var xStr = ""
        var yStr = ""
        var outStr = ""
        var x = 0.0000
        var y = 0.0000
        var xStored = false
        //        var start = false
        var points = [Coordinate]()
        
        for char in str.characters{
            if(("A" <= char && char <= "Z") || char == "(" || char == ")") {
                continue
            }
            else{
                outStr.append(char)
            }
        }
        outStr.append(",")
        
        for char in outStr.characters{
            if(char != " " && xStored == false){
                xStr.append(char)
            }
            else if(char == " " && xStr != ""){
                x = Double(xStr)!
                xStored = true
                xStr = ""
            }
            else if(char != "," && xStored == true){
                yStr.append(char)
            }
            else if(char == "," && yStr != ""){
                y = Double(yStr)!
                points.append(Coordinate(x: x, y: y))
                xStored = false
                yStr = ""
            }
        }
        return points
    }
    
    
    //Create a polygon from an array of points
    func createPolygon(coord: Array<Coordinate>) -> Polygon {
        if coord.isEmpty{
            return emptyPoly() as! Polygon
        }
        
        var polygonStr = "POLYGON(("
        for p in coord{
            polygonStr += String(format: "%.4f", p.x) + " " + String(format: "%.4f", p.y) + ", "
        }
        polygonStr += String(format: "%.4f", coord[0].x) + " " + String(format: "%.4f", coord[0].y)
        polygonStr += "))"
        return Polygon.init(WKT: polygonStr)!
    }
    
    
    //Define an empty polygon
    func emptyPoly() -> Geometry {
        let poly1 = Geometry.create("POLYGON((0 0, 0 0, 0 0, 0 0))")
        let poly2 = Geometry.create("POLYGON((1 1, 1 1, 1 1, 1 1))")
        return poly1!.intersection(poly2!)!
    }
    
    
    //Define an empty linestring
    func emptyLineString() -> LineString {
        let coord = [Coordinate]()
        return LineString.init(points: coord)!
    }
    
    
    
    //Returns a rotated geometry on a 2D plane. Origin: (0.0, 0.0, 0.0)
    func rotatePolygon(geometry: Geometry, alpha: Double) -> Geometry {
        let polyCrd = self.geometryPoints(str: geometry.WKT!)
        
        var rotatedPnts = [Coordinate]()
        for pnt in polyCrd {
            let xPrime = Double(pnt.x)*cos(alpha) - Double(pnt.y)*sin(alpha)
            let yPrime = Double(pnt.x)*sin(alpha) + Double(pnt.y)*cos(alpha)
            rotatedPnts.append(Coordinate(x: xPrime, y: yPrime))
        }
        return self.createPolygon(coord: rotatedPnts)
    }
}
