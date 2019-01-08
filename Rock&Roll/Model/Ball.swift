//
//  Ball.swift
//  Rock&Roll
//
//  Created by Elnaz Taqizadeh on 2018-05-28.
//

import Foundation
class Ball{
    func SAG(topSize: Double, rhoOre: Double, e: Double, rhoMedia: Double) -> Double {
        //TopSize in μm, ρ_ore in specific gravity, ε is the fraction efficiency of
        //KE transfer, ρ_media is the specific gravity of the media
        let alpha = 2/e*(1-sqrt(1-e))-1
        return topSize * pow((rhoOre/(rhoMedia*alpha)), (1/3)) * 1e-3                  //ball diameter in mm
    }

    func Bond(f80: Double, wi: Double, phi: Double, d: Double, rho: Double) -> Double {
        //Wi in kWh/t, F80 in μm, D in m, ρ feed in specific gravity,
        //φ in fraction critical speed
        var dPrime = d*3.2808399                                                       //D meters to ft
        let c  = 200.0
        let n = phi*100.0                                                              //speed in fract critical to %critical
        dPrime = pow(((f80*wi)/(c*n)), 0.5) * pow(rho,0.25) * pow(dPrime,-0.1250)      //in in
        return dPrime*25.4                                                             //ball diameter in mm
    }
    
    
    func Nipping(topSize: Double, mu: Double) -> Double {
        //TopSize in μm, μ is the kinematic friction coefficient.
        return topSize/sqrt(sqrt(1+pow(mu,2))-1)*1e-3                                  //ball diameter in mm
    }
    
    
    func Azzaroni(f80: Double, wi: Double, phi: Double, d: Double, rho: Double, omegaC: Double) -> Double {
        //Wi in kWh/t, F80 in μm, D in m, ρ feed in specific gravity,
        //φ in fraction critical speed, ωc is critical speed in rad/s
        /*
        dB* = Ideal Make-up Ball Size, mm
        F80 = 80% Passing Size in the Fresh Feed Stream, microns
        ρ   = Ore Density, ton/m 3
        Wi  = Bond's Work Index of the ore, kWh/ton (metric)
        N = Rotational Mill Speed, rpm
        Nc  = Rotational Mill Speed, as a percentage of the Mill Critical Speed.
        D = Effective Mill Diameter, feet.
        */
        let dPrime = d*3.2808399                                                      //D meters to ft
        let Nc = omegaC*30/(.pi)
        let N = Nc*phi
        return 4.5*pow(f80,0.263)*pow((rho*wi), 0.4)/pow((N*dPrime), 0.25)            //ball diameter in mm
    }
    
    
    func AllisChalmers(f80: Double, phi: Double, rho: Double, wi: Double, d: Double) -> Double {
        //Wi in kWh/t, F80 in μm, D in m, ρ feed in specific gravity, φ in fraction critical speed
        /*
        dB* = Ideal Make-up Ball Size, mm
        F80 = 80% Passing Size in the Fresh Feed Stream, microns
        ρ   = Ore Density, ton/m 3
        Wi  = Bond's Work Index of the ore, kWh/ton (metric)
        N = Rotational Mill Speed, rpm
        Nc  = Rotational Mill Speed, as a percentage of the Mill Critical Speed.
        D = Effective Mill Diameter, feet.
        */
        let dPrime = d*3.2808399                                                      //D meters to ft
        let Nc = 100*phi
        return 1.354*pow((f80), 0.5)*pow((rho*wi/(Nc*pow(dPrime, 0.5))), (1/3))       //in mm
    }
}
