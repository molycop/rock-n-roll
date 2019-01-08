//
//  MathRef.swift
//  Rock&Roll
//
//  Created by Elnaz Taqizadeh on 2018-02-12.
//  Required Mathematical Functions
//

import Foundation

class MathRef {
   
    /* Takes a funciton f, start values [a, b], tolerance value (optional) TOL and max number of
     iterations (optional) NMAX and returns the root of the equation using the bisection method */
    func bisection(_ f: (Double) -> Double, a: Double, b: Double, TOL: Double, NMAX: Int) -> Double {
        var n = 1
        var a1 = a
        var b1 = b
        
        while n <= NMAX {
            let c = Double((a1+b1)/2.0)
            if (f(c) == 0.0000 || (b1-a1)/2.0 < TOL) {
                return c
            }
            else{
                n += 1
                if f(c)*f(a1) > 0.0000 {
                    a1 = c
                }
                else{
                    b1 = c
                }
            }
        }
        return -1
    }
    
    
    //Return evenly spaced numbers over the interval [low, up].
    func linspace(low: Double, up: Double, length: Int) -> Array<Double> {
        let step = (up-low)/Double(length)
        
        var list = [Double]()
        for i in 0...length {
            list.append(low+Double(i)*step)
        }
        return list
    }
    
    
    //
    func gravityObjectiveError(x0: Double, y0: Double, x: Double, y: Double) -> Double {
        let  r = sqrt(pow(x, 2) + pow(y, 2))
        let r0 = sqrt(pow(x0, 2) + pow(y0, 2))
        return r-r0
    }

    //Give the stability position of the charge
    func thetaStability(mill: Mill) -> Double {
        return atan(mill.muS)
    }
    
    
    //Convert the charge fill to a charge height
    func JtoH(J: Double, R: Double) -> Double {
        var theta = linspace(low: 0, up: 2*(.pi), length: 512)
        var idx = 0
        for th in theta{
            if th-sin(th)-2*(.pi)*J < 0 {
                idx += 1
            }
        }
        let angle = theta[idx]
        return R*(1-cos(angle/2))
    }
    
    
    //Find the angle of flight using McIvor's theory
    func mcivorAngle(betha: Double, mu: Double, fr: Double, r: Double, R: Double) -> Double {
        let theta = atan(mu)
        let r_R = r/R
        var arg = fr*r_R*cos(theta-betha)
        arg = min(arg, 1)
        return min(theta - betha + asin(arg), .pi/2)
    }
    
    
    //Define the effective lifter angle as a function of position
    //F80/Db effect in the calculation  - to be added properly.
    func bethaAngle(betha_ball: Double, betha_lifter: Double, lifter_height: Double, r: Double, R: Double, Db: Double) -> Double {
        return 0.5*(betha_ball + betha_lifter + (betha_lifter-betha_ball)*tanh((r-R+lifter_height+1.5*Db)/(1.5*Db)))
    }
    
    func gravitySlip(x0: Double, y0: Double, dxdt0: Double, dydt0: Double, g: Double, phi: Double, criticalSpeed: Double, R: Double) -> ([Double], [Double], [Double]) {
        
        var t = [Double]()
        var x = [Double]()
        var y = [Double]()
        
        let dt = 4*(.pi)/(phi*criticalSpeed*1024)
        t.append(0)
        x.append(x0)
        y.append(y0)
        
        let RSquared = pow(R, 2)
        while  pow(x[x.count-1], 2) + pow(y[y.count-1], 2) < RSquared {
            let t1 = t[t.count-1] + dt
            let x1 = x0 + dxdt0*t[t.count-1]
            let y1 = y0 + dydt0*t[t.count-1] - 0.5*g*pow(t[t.count-1], 2)
            
            x.append(x1)
            y.append(y1)
            t.append(t1)
        }
        func f(tf: Double) -> Double {
            let xf = x0 + dxdt0*tf
            let yf = y0 + dydt0*tf - 0.5*g*pow(tf, 2)
            return pow(xf, 2) + pow(yf, 2) - RSquared
        }
        
        var tTarget: Double
        if t.count > 2 {
            tTarget = bisection(f, a: t[t.count-3], b: t[t.count-1], TOL: 0.000001, NMAX: 100)
        }
        else {
            tTarget = t[t.count-1]
        }
        
        let xTmp = x0 + dxdt0*tTarget
        let yTmp = y0 + dydt0*tTarget - 0.5*g*pow(tTarget, 2)
        
        var xFinal = x.dropLast(3)
        xFinal.append(xTmp)
        
        var yFinal = y.dropLast(3)
        yFinal.append(yTmp)
        
        var tFinal = t.dropLast(3)
        tFinal.append(tTarget)
        
        
        return (Array(tFinal), Array(xFinal), Array(yFinal))
    }
    
    
    //
    func profile(mill: Mill, betha: Double, theta: Double, R: Double, l: Double) -> ([Double], [Double]) {
        let g = mill.g
        let omega = mill.omegaC * mill.phi
        let phi = mill.phi
        let muS = mill.muS
        
        var x = [Double]()
        var y = [Double]()
        
        if l > 0 {
            //slip corrected prifle
            let acc = abs(-g*cos(theta)*muS*sin(betha) + g*sin(theta) - pow(omega, 2)*R)
            let vf = sqrt(2*acc*l/cos(betha))
            let deltaT = vf/acc
            let t = linspace(low: 0, up: deltaT, length: 64)
            
            var angle = [Double]()
            var r = [Double]()
            for ti in t {
                angle.append(theta + (omega-vf*sin(betha)/R)*ti)
                r.append(R - vf*cos(betha)*ti/2)
            }
            
            var xSlip = [Double]()
            var ySlip = [Double]()
            var refinedT = [Double]()
            for idx in 0..<r.count{
                if r[idx]*cos(angle[idx]) > 0 {
                    xSlip.append(r[idx]*cos(angle[idx]))
                    ySlip.append(r[idx]*sin(angle[idx]))
                    refinedT.append(t[idx])
                }
                
            }
            
            var dx = [Double]()
            var dy = [Double]()
            var dt = [Double]()
            for idx in 1..<xSlip.count{
                dx.append(xSlip[idx]-xSlip[idx-1])
                dy.append(ySlip[idx]-ySlip[idx-1])
                dt.append(refinedT[idx]-refinedT[idx-1])
            }
            
            var Vx = [Double]()
            var Vy = [Double]()
            for idx in 0..<dx.count{
                Vx.append(dx[idx]/dt[idx])
                Vy.append(dy[idx]/dt[idx])
            }
            
            let gravitySlip = self.gravitySlip(x0: xSlip[xSlip.count-1], y0: ySlip[ySlip.count-1], dxdt0: Vx[Vx.count-1], dydt0: Vy[Vy.count-1], g: g, phi: phi, criticalSpeed: omega, R: R)
            let xSlip2 = gravitySlip.1
            let ySlip2 = gravitySlip.2
            
            x += xSlip + xSlip2
            y += ySlip + ySlip2
        }
        else {
            let xSlip = R*cos(theta)
            let ySlip = R*sin(theta)
            let gravitySlip = self.gravitySlip(x0: xSlip, y0: ySlip, dxdt0: -omega*ySlip, dydt0: omega*xSlip, g: g, phi: phi, criticalSpeed: omega, R: R)
            x = gravitySlip.1
            y = gravitySlip.2
        }
        return (x, y)
    }
}
