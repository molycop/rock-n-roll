//
//  Charge.swift
//  mill.Rock&Roll
//
//  Created by Elnaz Taqizadeh on 2018-04-23.
//

import Foundation
import GEOSwift


class Charge {
    let mathRef = MathRef()
    let geoRef = GeoRef()
    
    var chargeEnMassPoly: Geometry
    var fallPoly: Geometry
    var mcivorPoly: Geometry
    var chargePoly: Geometry
    var centrifugePoly: Geometry
    var porosity: Double                    //charge porosity
    var rhoC: Double                        //mill charge specific gravity
    var rhoS: Double                        //slurry specific gravity


    
    //Charge Initializer
    init(porosity: Double, rhoC: Double, rhoS: Double) {
        self.porosity = porosity
        self.rhoC = rhoC
        self.rhoS = rhoS
        self.centrifugePoly = geoRef.emptyPoly()
        self.chargeEnMassPoly = geoRef.emptyPoly()
        self.fallPoly = geoRef.emptyPoly()
        self.mcivorPoly = geoRef.emptyPoly()
        self.chargePoly = geoRef.emptyPoly()
        self.centrifugePoly = geoRef.emptyPoly()
        
    }
    

    //Define the centrifuging geometry
    func createCentrifugePoly(mill: Mill) -> Geometry {
        
        var rCntr: Double
        if mill.phi <= 1 {
            return geoRef.emptyPoly()
        }
        else{
            let jCntr = 1-1/pow(mill.phi, 4)
            if mill.j > jCntr {
                rCntr = mill.R/pow(mill.phi, 2)
            }
            else{
                rCntr = mill.R*pow((1-mill.j), 0.5)
            }
            let shellPoly = mill.shell(R: mill.R)
            let cntrCrd = geoRef.getCoordinate(R: rCntr)
            let centrifugingGeo = (shellPoly.difference(geoRef.createPolygon(coord: cntrCrd)))
            return centrifugingGeo!.union(geoRef.emptyPoly())!
        }
    }

    
    //
    func sanitizeFalling(xf: [Double], yf: [Double], rMinZero: Double) -> ([Double], [Double]) {
        var r : [Double] = []
        var theta : [Double] = []
        for i in 0..<xf.count{
            r.append(sqrt(pow(xf[i], 2)+pow(yf[i], 2)))
            theta.append(atan2(yf[i], xf[i]))
        }
        
        for i in 0..<theta.count{
            if theta[i] < 0 {
                theta[i] = theta[i] + 2*(.pi)
            }
        }
        
        var theta2 : [Double] = []
        var r2 : [Double] = []
        for i in 0..<theta.count {
            if theta[i] >= ((.pi)/2) {
                theta2.append(theta[i])
                r2.append(r[i])
            }
        }
        
        var x : [Double] = []
        var y : [Double] = []
        for i in 0..<theta2.count {
            x.append(r2[i]*cos(theta2[i]))
            y.append(r2[i]*sin(theta2[i]))
        }
        
        var thetaAdd : [Double] = []
        var rAdd : [Double] = []
        var xAdd : [Double] = []
        var yAdd : [Double] = []
        
        let r0 = r2.min()
        if (theta2.max())! < 2*(.pi) {
            thetaAdd = mathRef.linspace(low: theta2.max()!, up: 2*(.pi), length: 10)
            thetaAdd.removeFirst()
            thetaAdd.removeLast()
            
            var lnSpc = mathRef.linspace(low: 0, up: 1, length: 128)
            lnSpc.removeFirst()
            lnSpc.removeLast()
            
            for i in 0..<lnSpc.count {
                rAdd.append(r0! + (rMinZero-r0!)*lnSpc[i])
            }
        }
        for i in 0..<thetaAdd.count {
            xAdd.append(rAdd[i]*cos(thetaAdd[i]))
            yAdd.append(rAdd[i]*sin(thetaAdd[i]))
        }
        
        
        xAdd.reverse()
        yAdd.reverse()
        
        xAdd += x
        yAdd += y
        
        return (xAdd, yAdd)
    }
    


    //
    func mcivor(mill: Mill) -> (Geometry, Geometry) {
        var r = mathRef.linspace(low: 0, up: mill.R-3*mill.lifterHeight, length: 128)
        r.removeLast()
        r += mathRef.linspace(low: mill.R-3*mill.lifterHeight, up:mill.R, length: 128)

        var betha = [Double]()
        for ridx in r{
            betha.append(mathRef.bethaAngle(betha_ball: mill.bethaBall, betha_lifter: mill.bethaLifter, lifter_height:  mill.lifterHeight, r: ridx, R: mill.R, Db: mill.dbf80))
        }

        var thetaMcivor = [Double]()
        for idx in 0..<r.count{
            thetaMcivor.append(mathRef.mcivorAngle(betha: betha[idx], mu: mill.muS, fr: mill.Fr, r: r[idx], R: mill.R))
        }

        
        var thetaPrime = [Double]()
        var rPrime = [Double]()
        var bethaPrime = [Double]()
        for i in 0..<thetaMcivor.count {
            if thetaMcivor[i] >= 0 && r[i] > 0 {
                thetaPrime.append(thetaMcivor[i])
                rPrime.append(r[i])
                bethaPrime.append(betha[i])
            }
        
        }
        

        //Shoulder profile
        var xShoulder = [Double]()
        var yShoulder = [Double]()
        for i in 0..<rPrime.count {
            xShoulder.append( rPrime[i]*cos(thetaPrime[i]) )
            yShoulder.append( rPrime[i]*sin(thetaPrime[i]) )
        }
        
        var l = [Double]()
        for ri in rPrime {
            let tmpL = mill.lifterHeight - mill.R + ri
            if tmpL < 0 {
                l.append(0)
            }
            else {
                l.append(tmpL)
            }
        }


        //Landing inner profile
        var profile = mathRef.profile(mill: mill, betha: bethaPrime[0], theta: thetaPrime[0], R: rPrime[0], l: l[0])
        var x = profile.0
        var y = profile.1
        

        let x1 = x[x.count-1]
        let y1 = y[y.count-1]
        var theta1 = atan2(y1, x1)
        if theta1 > (.pi)/2 {
            theta1 = theta1 - 2*(.pi)
        }
        let r1 = rPrime[0]
        

        //landing outer profile
        profile = mathRef.profile(mill: mill, betha: bethaPrime[bethaPrime.count-1], theta: thetaPrime[thetaPrime.count-1], R: rPrime[rPrime.count-1], l: l[l.count-1])
        x = profile.0
        y = profile.1
        
        let x2 = x[x.count-1]
        let y2 = y[y.count-1]
        var theta2 = atan2(y2, x2)
        if theta2 > (.pi)/2{
            theta2 = theta2 - 2*(.pi)
        }
        let r2 = rPrime[rPrime.count-1]
        
        //construct toe profile.
        let thetaFall = mathRef.linspace(low: theta1, up: theta2, length: 128)
        let lnSpc = mathRef.linspace(low: 0, up: 1, length: 128)
        
        var rFall = [Double]()
        for i in 0..<lnSpc.count{
            rFall.append(r1 + (r2-r1)*lnSpc[i])
        }

        
        
        var Xfall = [Double]()
        var Yfall = [Double]()
        for i in 0..<thetaFall.count {
            Xfall.append(rFall[i]*cos(thetaFall[i]))
            Yfall.append(rFall[i]*sin(thetaFall[i]))
        }

        var xFallen = [Double]()
        var yFallen = [Double]()
        let sanitizeFalling = self.sanitizeFalling(xf: Xfall,yf: Yfall,rMinZero: rPrime.min()!)
        xFallen = sanitizeFalling.0
        yFallen = sanitizeFalling.1

        
        //construct the mcivor charge
        var Xmcivor = [Double]()
        var Ymcivor = [Double]()

        Xmcivor = xFallen.reversed()
        Ymcivor = yFallen.reversed()

        
//        for xi in 0..Int(mill.R+1){
//            Xmcivor.append(Double(xi))
//            Ymcivor.append(0)
//        }
        
        Xmcivor += xShoulder
        Ymcivor += yShoulder
        
        var mcivorPoly: Geometry = geoRef.emptyPoly()
        let shellPoly = mill.shell(R: mill.R)
        
        if Ymcivor[0] > 0 {
            //above the x axis, need to go left in the polygon
            Xmcivor += [1.5*mill.R, 1.5*mill.R, -1.5*mill.R, -1.5*mill.R]
            Ymcivor += [Ymcivor[Ymcivor.count-1], -1.5*mill.R, -1.5*mill.R, Ymcivor[0]]
        }
        else {
            //need to go down in the polygon
            Xmcivor += [1.5*mill.R,  1.5*mill.R, Xmcivor[0], Xmcivor[0]]
            Ymcivor += [Ymcivor[Ymcivor.count-1], -1.5*mill.R, -1.5*mill.R, Ymcivor[0]]
        }
        
        var MCpoints = [Coordinate]()
        for idx in 0..<Xmcivor.count{
            MCpoints.append(Coordinate(x: Xmcivor[idx], y: Ymcivor[idx]))
        }
        mcivorPoly = geoRef.createPolygon(coord: MCpoints)
        mcivorPoly = mcivorPoly.intersection(shellPoly)!
        
        
        //construct the falling profile
        var FallPoly: Geometry = geoRef.emptyPoly()
        if x.count > 1 {
            if x[x.count-1] > 0{
                x += [1.5*mill.R, 1.5*mill.R]
                y += [y[y.count-1],  y[0]]
            }
            else{
                x += [-1.5*mill.R, -1.5*mill.R,  1.5*mill.R, 1.5*mill.R]
                y += [y[y.count-1],  -1.5*mill.R, -1.5*mill.R, y[0]]
            }
            var fallPoints = [Coordinate]()
            for idx in 0..<x.count{
                fallPoints.append(Coordinate(x: x[idx], y: y[idx]))
            }
            FallPoly = geoRef.createPolygon(coord: fallPoints)
            FallPoly = FallPoly.intersection(shellPoly)!
        }
        else {
            FallPoly = geoRef.emptyPoly()
        }
        
        return (mcivorPoly, FallPoly)
    }
    
    

    func createEnMassPoly(mill: Mill, Rpoly: Double) -> Geometry {
        let theta = mathRef.thetaStability(mill: mill)
        let x0_stability = -mill.R/pow(mill.phi, 2)*sin(theta)
        let y0_stability = mill.R/pow(mill.phi, 2)*cos(theta)
        
        
        let coord = geoRef.getCoordinate(R: Rpoly)
        var translated = [Coordinate]()
        for crd in coord{
            translated.append(Coordinate(x: crd.x+x0_stability, y: crd.y+y0_stability))
        }
        
        let shellPoly = mill.shell(R: mill.R)
        let enMassPoly = geoRef.createPolygon(coord: translated)
        return shellPoly.difference(enMassPoly)!
    }


}
