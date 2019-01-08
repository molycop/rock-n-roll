//
//  Wear.swift
//  Rock&Roll
//
//  Created by Elnaz Taqizadeh on 2018-04-23.
//

import Foundation

class Wear{
    func Bond(Ai: Double) -> (Double, String, String) {
        
        if(0.015 < Ai){
            //wet, our,  case
            return (0.159*pow((Ai - 0.015),1.3), "kg/kWh", "Bond")
        }
        return (0.0, "kg/kWh", "Bond")
    }
    
    func Benavente(Ai: Double, f80: Double, PH: Double, dBall: Double) -> (Double, String, String) {
        if (0.015 < Ai && 0 < f80 && 0 < PH && PH < 14) {
            //wet, our,  case
            return (3942/1e6/dBall*pow(((Ai - 0.015)/0.20), 0.33)*pow((f80/5000), 0.13)*pow((PH/10), -0.68), "kg/kWh","Benavente")
        }
        return (0.0, "kg/kWh","Benavente")
    }

    func Guzman(Ai: Double, f80: Double, PH: Double, dBall: Double) ->(Double, String, String){
        if (0.015 < Ai && 0 < f80 && 0 < PH && PH < 14) {
            //wet, our,  case
            return (3942/1e6/dBall*pow(((Ai - 0.05)/0.20),0.166)*pow((f80/5000), 0.069)*pow((PH/10), -0.243), "kg/kWh","Guzman")
        }
        return (0.0, "kg/kWh","Guzman")
    }
    
    func MartinsRadziszewski (Ai: Double, dBall: Double, F80: Double, ph: Double, h: Double, Sol: Double, SiO2: Double, rain: Double, tmprt: Double) -> (Double, String, String) {
        //wet, our case
        var omega = 2253/dBall * pow(((Ai - 0.026)/0.026),0.31) * pow((F80/5000), 0.14) * pow((ph/10),-0.4)
        let C0 = 1.27
        let CH = (63.5/h)
        let Csolids = pow((Sol/63.54), -0.055)
        let Csilica = pow((SiO2/1100), 0.32)
        let Cenv = pow((rain/1.58), 0.002) * pow((tmprt/22.0),0.14)
        omega = omega*C0*CH*Csolids*Csilica*Cenv/1000
        if omega < 0 {
            omega = Double.greatestFiniteMagnitude
        }
        return (omega, "kg/kWh", "Martins-Radziszewski")
    }
    
}
