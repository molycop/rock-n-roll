//
//  Power.swift
//  Rock&Roll
//
//  Created by Elnaz Taqizadeh on 2018-02-14.
//

import Foundation
import GEOSwift


class Power{
    let geoRef = GeoRef()
    let mathRef = MathRef()
    
    var P_measured: Double = 0.0                //measured power [W]
    var units = "kW"
    var abrasion = [Double]()                   //model abrasion power
    var impact = [Double]()                     //model impact power
    var measured = [Double]()                   //measured power
    var model = [Double]()                      //model total power
    
    
    
//    //
//    func addValues(Pa: Double, Pi: Double, Pmodel: Double, Pmeasured: Double) {
//        self.abrasion.append(Pa)
//        self.impact.append(Pi)
//        self.model.append(Pmodel)
//        self.measured.append(Pmeasured)
//    }

    //Define Power
    func power(rho: Double, J: Double, R: Double, L: Double, g: Double, phi: Double, xcm_R: Double) -> Double {
        return rho*J*(.pi)*pow(R,2.5)*L*pow(g,1.5)*phi*xcm_R
    }
    

    //
    func calcPower(mill: Mill, charge: Charge, chargePoly: Geometry) -> (Double, Double, Double) {
        let cntrWKT = chargePoly.centroid()!.WKT!
        let cntr = geoRef.geometryPoints(str: cntrWKT)

        let rhoCEff = charge.rhoC*1.119655113013032/(1+(1-4.1*pow(mill.phi,0.1)*mill.j)*(1-1.7*pow(mill.phi,0.1)*mill.j)*(1+0.6341*mill.j))/(1+0.2*pow(mill.phi, 0.1)*mill.j)
        var Pwr = self.power(rho: rhoCEff, J: mill.j, R: mill.R, L: mill.L, g: mill.g, phi: mill.phi, xcm_R: cntr[0].x/mill.R)

        if !mill.dischargeIsGrate {
            let shellPoly = mill.shell(R: mill.R)
            let slurryPoly = mill.slurry(R: mill.R, dTrommel: mill.dTrommel, shellPoly: shellPoly, dischargeIsGrate: mill.dischargeIsGrate)
            
            let BuoyPoly = chargePoly.intersection(slurryPoly)
            let cntrBPWKT = BuoyPoly!.centroid()!.WKT!
            let cntrBP = geoRef.geometryPoints(str: cntrBPWKT)
            let rhoSEff = charge.rhoS*1.119655113013032/(1+(1-4.1*pow(mill.phi,0.1)*mill.j)*(1-1.7*pow(mill.phi,0.1)*mill.j)*(1+0.6341*mill.j))/(1+0.2*pow(mill.phi,0.1)*mill.j)
            Pwr = Pwr - self.power(rho: rhoSEff, J: mill.j, R: mill.R, L: mill.L, g: mill.g, phi: mill.phi, xcm_R: cntrBP[0].x/mill.R)
        }

        let Pa = 0.000
        let Pi = 0.000
        return (Pwr, Pa, Pi)
}
   
    
    //Abrasion Power
//    func pAbrasion(charegePoly: Geometry, rCentrifuge: Double, DbF80: Double, muS: Double, g: Double, R: Double, phi: Double, L: Double, rhoC: Double) -> Double {
//        let r = rCentrifuge - DbF80/2
//
//
//    }
  
    
    
//    //Impact Power
//    func pImpact(charegePoly: Geometry, rCentrifuge: Double, DbF80: Double, muS: Double, g: Double, R: Double, phi: Double, L: Double, rhoC: Double, McivorLine2: Geometry) -> Double {
//        let mcivorLinePnts = geoRef.geometryPoints(str: McivorLine2.WKT!)
//        var arg: Double
//        for points in mcivorLinePnts {
//            let x = points.x
//            let y = points.y
//            arg = pow(x, 2) + pow(y, 2)
//        }
//        return 0.0
//    }
}
