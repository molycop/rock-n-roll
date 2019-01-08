//
//
//
//  Created by Elnaz Taqizadeh on 2017-08-01.
//  Copyright © 2017 Elnaz Taqizadeh. All rights reserved.
//
//
import Foundation
import GEOSwift


class Mill: MathRef{
    let mathRef = MathRef()
    let geoRef = GeoRef()
    
    var name: String                    //mill name
    var phi: Double                       //mill speed, fraction critical
    var D: Double                       //mill diameter [m]
    var L: Double                       //effective mill length [m]
    var dTrommel: Double               //trommel diameter [m]
    var j: Double                       //mill fill
    var jb: Double                      //mill ball fill
    var lifterHeight: Double                     //lifter height [m]
    //var numberOflifters: Double                   //number of lifter rows
    //var lifterWidth: Double                   //width of the lifters [m]
    var muS: Double                      //friction coefficient
    var bethaLifter: Double                //lifter angle [degrees]
    var bethaBall: Double                  //ball effective lifter angle (70 degrees)
    var dischargeIsGrate: Bool              //boolean - grate discharge is true, overflow is false
    var f80: Double                     //feed size [m]
    var db: Double                      //top up media size [m]
    var dbf80: Double                   //largest paricles in the charge [m]
    var Fr: Double                      //phi**2 Froude number
    var g = 9.81                        //gravitational acceleration [m/s^2]
    var R: Double                       //mill radius [m]
    var omegaC: Double                      //critical speed [rad/s]
    var omega: Double                       //mill speed [rad/s]
    var ristowSpeed: Double                //in fraction omegaC
    
    
    init(name: String, phi: Double, d: Double, L: Double, dTrommel: Double, j: Double, jb: Double, lifterHeight: Double,muS: Double, bethaLifter: Double, bethaBall: Double, dischargeIsGrate: Bool, f80: Double, db: Double, ristowSpeed: Double){
        
        self.name = name
        self.phi = phi
        self.D = d
        self.L = L
        self.dTrommel = dTrommel
        self.j = j
        self.jb = jb
        self.lifterHeight = lifterHeight
        // self.numberOflifters = numberOflifters
        // self.lifterWidth = lifterWidth
        self.muS = muS
        self.bethaLifter = bethaLifter
        self.bethaBall = bethaBall
        self.dischargeIsGrate = dischargeIsGrate
        self.f80 = f80
        self.db = db
        self.dbf80 = max(f80, db)
        self.R = D/2
        self.omegaC = pow((g/R), 0.5)
        self.omega = omegaC*phi
        self.Fr = pow(phi, 2)
        self.ristowSpeed = ristowSpeed
    }

    //Define the shell
    func shell(R: Double) -> Geometry {
        //Eventualy, lifters will have to be added
        //lifter()
        let coord : Array<Coordinate> =  geoRef.getCoordinate(R: R)
        return geoRef.createPolygon(coord: coord)
    }

    
    
    
    //Define the slurry geometry
    func slurry(R: Double, dTrommel: Double, shellPoly: Geometry, dischargeIsGrate: Bool) -> Geometry {

        //Define the slury geometry
        let slurryPos = -dTrommel/2
        if dischargeIsGrate {
            return geoRef.emptyPoly()
        }
        else {
            let coord = [Coordinate(x: -1.1*R, y: -1.1*R),
                         Coordinate(x: -1.1*R, y: slurryPos),
                         Coordinate(x: 1.1*R, y: slurryPos),
                         Coordinate(x: 1.1*R, y: -1.1*R)]

            let slurryPoly = geoRef.createPolygon(coord: coord)
            return slurryPoly.intersection(shellPoly)!
        }
    }
    
    
    
    //This is a function that canb e changed for HEBM
    func findSlurryLevel() -> Double {
        return -dTrommel/2;
    }
}

