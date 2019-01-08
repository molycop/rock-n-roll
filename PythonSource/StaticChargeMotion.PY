# -*- coding: utf-8 -*-
"""
    ===============================================================================
    
    STATIC CHARGE MOTION MODEL
    --------------------------
    
    Created on Mon Apr 16 16:25:44 2018
    
    @author: kewmartisu
    
    Sudarshan Martins, PEng, PhD
    Technical Support Engineer
    Product Research, Technology & Development
    Mining and Aggregates, Minerals Consumables
    Metso Minerals Inc.
    795 George-V
    Lachine, Quebec, Canada H8S 2R9
    
    Phone: +1 514 485 4254
    sudarshan.martins@metso.com
    
    ===============================================================================
    References:
    
    GRANULAR FLOW MODELLING IN TUMBLING MILLS, Indresan Govender, Maximillian
    Richter, Gary Tupper and Aubrey Mainza, XXVI INTERNATIONAL MINERAL
    PROCESSING CONGRESS(IMPC) 2012 PROCEEDINGS / NEW DELHI, INDIA / 24 - 28
    SEPTEMBER 2012
    
    Modélisation de la comminution en fonction du concassage, du cascadage
    et du broyage dans un broyeur à boulets [microforme], Peter Radziszewski,
    Thèse (M.Sc.) - Université Laval, 1988
    
    Rose, H. E., & Sullivan, R. M. E. (1958). A treatise on the internal
    mechanics of ball, tube, and rod mills. New York: Chemical Pub. Co.
    
    CORRELACIÓN EMPIRICA PARA LA EVALUACIÓN DE CONSUMOS DE BOLAS EN
    APLICACIONES DE MOLIENDA, Héctor Benavente Valcárcel and Levi Guzman
    Rivera, X SIMPOSIUM SOBRE PROCESAMIENTO DE MINERALES (2005)
    
    
    
    ===============================================================================
    Changelog:
    
    Changing the falling profile to agree with Trajit
    Rewrite to clean up the code
    Transformed some of the code to objects
    Corrected some profiles
    Added top up ball calculation
    Corrected Minas Rio model
    
    TRAJIT VERSION
    
    #ΑΒΓΔΕΖΗΘΙΚΛΞΠΣΦΨΩαβγδεζηθλμνξπρστφχψω
    """
#==============================================================================
# dependencies
#==============================================================================

from shapely.geometry import Polygon, LineString
from shapely.affinity import translate, rotate
from descartes import PolygonPatch
import numpy as np
import matplotlib.pyplot as plt
from pandas import read_csv
import timeit

#==============================================================================
# class declarations
#==============================================================================
class wear:
    def Bond(self, Ai):
        #Ω = 0.023*(Ai)**0.5# dry, not really used for us
        try:
            #Ω = 0.159*(Ai - 0.015)**0.33# wet
            Ω = 0.159*(Ai - 0.015)**1.3# wet, our case
        except:
            Ω = np.nan
        return Ω, 'kg/kWh','Bond'
    def Benavente(self, Ai, F80, pH, Dball):
        try:
            Ω = 3942/1e6/Dball*((Ai - 0.015)/0.20)**0.33*(F80/5000)**0.13*(pH/10)**-0.68# wet, our case
        except:
            Ω = np.nan
        return Ω, 'kg/kWh','Benavente'
    def Guzman(self, Ai, F80, pH, Dball):
        try:
            Ω = 3942/1e6/Dball*((Ai - 0.05)/0.20)**0.166*(F80/5000)**0.069*(pH/10)**-0.243# wet, our case
        except:
            Ω = np.nan
        return Ω, 'kg/kWh','Guzman'
    def MartinsRadziszewski(self, Ai, Dball, F80, pH, H, Sol, SiO2, rain, Temp):
        Ω = 2253/Dball*((Ai - 0.026)/0.026)**0.31*(F80/5000)**0.14*(pH/10)**-0.4# wet, our case
        C0 = 1.27
        CH = (63.5/H)
        Csolids = (Sol/63.54)**-0.055
        Csilica = (SiO2/1100)**0.32
        Cenv = (rain/1.58)**0.002*(Temp/22.0)**0.14
        Ω = Ω*C0*CH*Csolids*Csilica*Cenv/1000
        if Ω < 0:
            Ω = np.inf
        return Ω,'kg/kWh','Martins-Radziszewski'

class BallTopSize:
    def SAG(self, TopSize, ρ_ore, ε, ρ_media):
        #TopSize in μm, ρ_ore in specific gravity, ε is the fraction efficiency of
        #KE transfer, ρ_media is the specific gravity of the media
        α = 2/ε*(1-np.sqrt(1-ε))-1
        return TopSize*(ρ_ore/(ρ_media*α))**(1/3)*1e-3#ball diameter in mm
    def Bond(self, F80, Wi, φ, D, ρ):
        #Wi in kWh/t, F80 in μm, D in m, ρ feed in specific gravity,
        #φ in fraction critical speed
        D = D*3.2808399# D meters to ft
        C = 200.0
        N = φ*100.0#speed in fract critical to %critical
        D = ((F80*Wi)/(C*N))**0.5*ρ**0.25*(D)**-0.125#in in
        return D*25.4# ball diameter in mm
    def Nipping(self, TopSize, μ):
        #TopSize in μm, μ is the kinematic friction coefficient.
        return TopSize/np.sqrt(np.sqrt(1+μ**2)-1)*1e-3#ball diameter in mm
    def Azzaroni(self, F80, Wi, φ, D, ρ, ωc):
        #Wi in kWh/t, F80 in μm, D in m, ρ feed in specific gravity,
        #φ in fraction critical speed, ωc is critical speed in rad/s
        '''
            dB* = Ideal Make-up Ball Size, mm
            F80 = 80% Passing Size in the Fresh Feed Stream, microns
            ρ   = Ore Density, ton/m 3
            Wi  = Bond's Work Index of the ore, kWh/ton (metric)
            N = Rotational Mill Speed, rpm
            Nc  = Rotational Mill Speed, as a percentage of the Mill Critical Speed.
            D = Effective Mill Diameter, feet.
            '''
        D = D*3.2808399# D meters to ft
        Nc = ωc*30/np.pi
        N = Nc*φ
        return 4.5*F80**0.263*(ρ*Wi)**0.4/(N*D)**0.25#ball diameter in mm
    def AllisChalmers(self, F80, φ, ρ, Wi, D):
        #Wi in kWh/t, F80 in μm, D in m, ρ feed in specific gravity, φ in fraction critical speed
        '''
            dB* = Ideal Make-up Ball Size, mm
            F80 = 80% Passing Size in the Fresh Feed Stream, microns
            ρ   = Ore Density, ton/m 3
            Wi  = Bond's Work Index of the ore, kWh/ton (metric)
            N = Rotational Mill Speed, rpm
            Nc  = Rotational Mill Speed, as a percentage of the Mill Critical Speed.
            D = Effective Mill Diameter, feet.
            '''
        D = D*3.2808399# D meters to ft
        Nc = 100*φ
        return 1.354*(F80)**0.5*(ρ*Wi/(Nc*D**0.5))**(1/3)#in mm

class mill_parameters:#mill parameters with one test case as initial conditions
    Name = 'Meadowbank'# mill name
    φ = 0.75# mill speed, fraction critical
    D = 7.7# mill diameter [m]
    R = D/2# mill radius in [m]
    L = 3.35# effective mill length [m]
    D_trommel = 1.925# trommel diameter
    J = 0.3#0.226# mill fill
    Jb = 0.135# mill ball fill
    l_l = 0.385# lifter height
    N_l = 33# number of lifter rows
    w_l = 0.231# width of the lifters
    μs = 0.4# friction coefficient
    porosity = 0.63# charge porosity
    β_lifter = 0.7853*30/45#0.5363*32/45# lifter angle
    β_ball = 1.2217# ball effective lifter angle (70 degrees)
    ρc = 5.839071*1000# mill charge density [kg/m^3]
    ρs = 2.45*1000# slurry density [kg/m^3]
    discharge_is_grate = False# bool, grate discharge is true,overflow is false
    F80 = 0.1925#feed size
    Db = 0.1925#top up media size
    DbF80 = max(F80, Db)# largest paricles in the charge
    P_measured = 3190# measured power [kW]
    Ai = 0.5# Bond abrasion index
    T = 50 + 273.15#slury temperature in K
    pH = 10#pH of the slurry
    ṁ = 300#throughput tonnes/hr
    g = 9.81# [m/s^2] gravitational acceleration
    TimeRun = True
    ωc_Ristow = (1 - J + 0.000001)**-0.25#in fraction ωc
    Fr = φ**2# Froude number
    ωc = np.sqrt(g/R)#critical speed
    
    def listvalues(self):
        str = '\n=======\tParameters ============================'+\
            '\n\tname:\t\t {}'.format(self.Name)+\
            '\n\tφ:\t\t {:.3}'.format(self.φ)+\
            '\n\tωc_Ristow:\t {:.3}'.format(self.ωc_Ristow)+\
            '\n\tJ:\t\t {:.3}'.format(self.J)+\
            '\n\tD:\t\t {:.3} m '.format(self.D)+\
            '\n\tL:\t\t {:.3} m'.format(self.L)+\
            '\n\tl:\t\t{:6.3f} m'.format(self.l_l)+\
            '\n\ttype:\t\t {}'.format('Grate Discharge' \
                                      if self.discharge_is_grate else 'Overflow Discharge' )+\
                                      '\n\tρc:\t\t {:.1} kg/m^3'.format(self.ρc)+\
                                          '\n\tρs:\t\t {:.1} kg/m^3'.format(self.ρs)+\
                                          '\n==============================================='
        print(str)
        return

class charge:
    def __init__(self, p):
        #init the main charge consituents
        self.Charge_en_massPoly = self.emptyPoly()
        self.FallPoly = self.emptyPoly()
        self.McivorPoly = self.emptyPoly()
        self.ChargePoly = self.emptyPoly()
        self.CentrifugePoly = self.emptyPoly()
        #define the shell
        self.ShellPoly = self.circle(p.R)
        #define trommel and slurry
        if p.discharge_is_grate:
            self.TrommelPoly = self.emptyPoly()
            self.SlurryPoly = self.emptyPoly()
        else:
            self.TrommelPoly = self.circle(p.D_trommel/2)
            slurry_position = self.slurry_lvl(p)
            self.SlurryPoly = Polygon([(-1.1*p.R, -1.1*p.R), (-1.1*p.R, slurry_position), ( 1.1*p.R, slurry_position), ( 1.1*p.R, -1.1*p.R), (-1.1*p.R, -1.1*p.R)])
            self.SlurryPoly = self.SlurryPoly.intersection(self.ShellPoly)
        #define the liner
        self.LinerPoly = self.circle(p.R-p.l_l)
                return
def bake(self, p):
    if p.J == 1:
        self.McivorPoly = self.circle(p.R)
        self.FallPoly = self.emptyPoly()
        self.CentrifugePoly = self.emptyPoly()
        elif p.φ >= p.ωc_Ristow:#fully centrifuging
            self.McivorPoly = self.emptyPoly()
            self.FallPoly = self.emptyPoly()
            self.CentrifugePoly = self.centrifugePoly(p)
        elif p.φ > 1:
            self.McivorPoly, self.FallPoly = self.Mcivor(p)
            #self.FallPoly = self.circle(p.R)
            self.CentrifugePoly = self.centrifugePoly(p)
        elif p.φ < 0.3:
            self.McivorPoly = self.emptyPoly()
            self.FallPoly = self.emptyPoly()
            self.CentrifugePoly = self.emptyPoly()
    else:
        self.McivorPoly, self.FallPoly = self.Mcivor(p)
        self.CentrifugePoly = self.emptyPoly()
        if p.J == 0:
            self.McivorPoly = self.emptyPoly()
            self.FallPoly = self.emptyPoly()
            self.CentrifugePoly = self.emptyPoly()
    
        self.ChargePoly = (self.CentrifugePoly).union(self.McivorPoly)
        
        if self.ChargePoly.area/self.ShellPoly.area > p.J:#thin out the charge
            def thinObjective(J):
                def f(r):
                    exclusionPoly = self.circle(r)
                    thinPoly = self.ChargePoly.difference(exclusionPoly)
                    return thinPoly.area/(self.ShellPoly.area)-J
                return f
            fcn = thinObjective(p.J)
            Rexclusion = bisection(fcn, 0, p.R, TOL=0.000001, NMAX=100)
            self.ChargePoly = self.ChargePoly.difference(self.circle(Rexclusion))
            self.McivorPoly = self.McivorPoly.difference(self.circle(Rexclusion))
            self.CentrifugePoly = self.CentrifugePoly.difference(self.circle(Rexclusion))

else:#fill up the charge
    # find the starting angle of the stable charge that corresponds to the right fill level
    def fillObjective(J):
        def f(Rpoly):
            ProposedChargePoly = (self.enMassPoly(p, Rpoly)).union(self.ChargePoly)
            return ProposedChargePoly.area/(self.ShellPoly.area)-J
                return f
            
            if p.φ < 0.1:
                y_ch = self.J_to_h(p.J, p.R)-p.R
                x_charge = np.array([-1.1*p.R, -1.1*p.R,  1.1*p.R,  1.1*p.R])
                y_charge = np.array([    y_ch, -1.1*p.R, -1.1*p.R,  y_ch])
                points = zip(x_charge, y_charge)
                self.Charge_en_massPoly = (Polygon(points)).intersection(self.ShellPoly)
                self.Charge_en_massPoly = rotate(self.Charge_en_massPoly, self.θ_stability(p)*180/np.pi, origin = (0.0,0.0,0.0))
        
        else:
            fcn = fillObjective(p.J)
            Rfill = bisection(fcn, p.R/p.φ**2 - p.R, p.R/p.φ**2 + p.R, TOL=0.000001, NMAX=100)
            self.Charge_en_massPoly = self.enMassPoly(p, Rfill)
        self.ChargePoly = (self.ChargePoly).union(self.Charge_en_massPoly)
                    return

def enMassPoly(self, p, Rpoly):
    θ = self.θ_stability(p)
    x0_stability = -p.R/p.φ**2*np.sin(θ)
    y0_stability =  p.R/p.φ**2*np.cos(θ)
    enMassFillPoly = translate(self.circle(Rpoly), x0_stability, y0_stability, 0.0)
    return self.ShellPoly.difference(enMassFillPoly)
    
    def J_to_h(self,J,R):
        # convert the charge fill to a charge height
        Θ = np.linspace(0,2*np.pi,256)
        idx = sum((Θ - np.sin(Θ) - 2*np.pi*J) < 0)
        angle = Θ[idx]
        h = R*(1-np.cos(angle/2))
        return h
    
    def θ_stability(self, p):
        # give the stabitity position of the charge
        return np.arctan(p.μs)
    
    def slurry_lvl(self, p):#this is a function that can be changed for HEBM
        return -p.D_trommel/2
    
    def emptyPoly(self):
        # define an empty polygon
        return Polygon()
    
    def emptyLineString(self):
        # define an empty LineString
        return LineString(self)
    
    def circle(self, R):
        # define a circle
        theta = np.linspace(0, 2*np.pi, 128)
        x_shell = R*np.cos(theta)
        y_shell = R*np.sin(theta)
        points =  zip(x_shell, y_shell)
        return Polygon(points)
    
    def centrifugePoly(self, p):
        if p.φ <= 1:
            return self.emptyPoly()
        else:
            J_centrifuge = 1-1/(p.φ**4)
            if p.J > J_centrifuge:
                r_centrifuge = p.R/(p.φ**2)
            else:
                r_centrifuge = p.R*(1-p.J)**0.5
            return self.ShellPoly.difference(self.circle(r_centrifuge))

def Mcivor(self, p):
    R = p.R
        r = np.append(np.linspace(0, R-3*p.l_l, 128, endpoint=False),np.linspace(R-3*p.l_l, R, 128))
        β = self.β_angle(p.β_ball, p.β_lifter, p.l_l, r, R, p.DbF80)
        θ_mcivor = self.mcivor_angle(β, p.μs, p.Fr, r, R)
        idx = θ_mcivor >= 0
        θ_mcivor = θ_mcivor[idx]
        r = r[idx]
        β = β[idx]
        idx = r > 0
        θ_mcivor = θ_mcivor[idx]
        r = r[idx]
        β = β[idx]
        # shoulder profile
        x_shoulder = r*np.cos(θ_mcivor)
        y_shoulder = r*np.sin(θ_mcivor)
        l = p.l_l - R + r
        l[l < 0] = 0
        #landing inner profile
        x, y = self.profile(p, β[0], θ_mcivor[0], r[0], l[0])
        x1 = x[-1]
        y1 = y[-1]
        θ1 = np.arctan2(y1, x1)
        if θ1 > np.pi/2:
            θ1 = θ1 - 2*np.pi
        r1 = r[0]
        #landing outer profile
        x, y = self.profile(p, β[-1], θ_mcivor[-1], r[-1], l[-1])
        x2 = x[-1]
        y2 = y[-1]
        θ2 = np.arctan2(y2, x2)
        if θ2 > np.pi/2:
            θ2 = θ2 - 2*np.pi
        r2 = r[-1]
        #construct toe profile.
        θ_fall = np.linspace(θ1, θ2, 64)
        r_fall = r1*np.ones_like(θ_fall) + (r2-r1)*np.linspace(0, 1, 64)
        x_fall = r_fall*np.cos(θ_fall)
        y_fall = r_fall*np.sin(θ_fall)
        x_fallen, y_fallen = self.sanitize_falling(x_fall,y_fall,np.min(r))
        
        #construct the mcivor charge
        x_mcivor = np.append(x_fallen[::-1],x_shoulder)
        y_mcivor = np.append(y_fallen[::-1],y_shoulder)
        if y_mcivor[0] > 0:# above the x axis, need to go left in the polygon
            x_mcivor = np.append(x_mcivor, [        1.5*R,  1.5*R, -1.5*R,       -1.5*R, x_mcivor[0]])
            y_mcivor = np.append(y_mcivor, [y_mcivor[-1], -1.5*R, -1.5*R, y_mcivor[0], y_mcivor[0]])
    else:# need to go down in the polygon
        x_mcivor = np.append(x_mcivor, [        1.5*R,  1.5*R, x_mcivor[0], x_mcivor[0]])
        y_mcivor = np.append(y_mcivor, [y_mcivor[-1], -1.5*R,       -1.5*R, y_mcivor[0]])
        points = zip(x_mcivor, y_mcivor)
        McivorPoly = (Polygon(points)).intersection(self.ShellPoly)
        
        #construct the falling profile
        if (len(x) > 1):
            if x[-1] > 0:
                x = np.append(x, [1.5*R, 1.5*R])
                y = np.append(y, [y[-1],  y[0]])
            else:
                x = np.append(x, [-1.5*R, -1.5*R,  1.5*R, 1.5*R])
                y = np.append(y, [y[-1],  -1.5*R, -1.5*R, y[0]])
            points =  zip(x, y)
            FallPoly = (Polygon(points)).intersection(self.ShellPoly)
        else:
            FallPoly = self.emptyPoly()
        
        return McivorPoly, FallPoly

    def sanitize_falling(self,xf,yf,rmin_atzero):
        r = np.sqrt(xf**2+yf**2)
        θ = np.arctan2(yf, xf)
        idx = θ < 0
        θ[idx] = θ[idx] + 2*np.pi
        idx = θ > np.pi/2
        θ = θ[idx]
        r = r[idx]
        
        x = r*np.cos(θ)
        y = r*np.sin(θ)
        r0 = np.min(r)
        if np.max(θ) < 2*np.pi:
            θ_add = np.linspace(np.max(θ), 2*np.pi, 128, endpoint=False)
            r_add = r0*np.ones_like(θ_add)+(rmin_atzero-r0)*np.linspace(0.0, 1, 128, endpoint=False)
            x_add = r_add*np.cos(θ_add)
            y_add = r_add*np.sin(θ_add)
        x_add = x_add[::-1]
        y_add = y_add[::-1]
        x = np.append(x_add[1:-1],x)
        y = np.append(y_add[1:-1],y)
        
                return x,y

def profile(self, p, β, θ, R, l):
    g = p.g
        ω = p.ωc*p.φ
        ωc = p.ωc
        φ = p.φ
        μ = p.μs
        if l > 0:
            #slip corrected profile
            acc = np.abs(-g*np.cos(θ)*μ*np.sin(β) + g*np.sin(θ) - ω**2*R)
            #acc = g*np.cos(theta + beta_lifter)*uk
            vf = np.sqrt(2*acc*l/np.cos(β))
            delta_t = vf/acc
            t = np.linspace(0, delta_t, 64)
            angle = θ + (ω-vf*np.sin(β)/R)*t
            r = R - vf*np.cos(β)*t/2
            x_slip2 = r*np.cos(angle)
            y_slip2 = r*np.sin(angle)
            idx = x_slip2 > 0
            x_slip2 = x_slip2[idx]
            y_slip2 = y_slip2[idx]
            t = t[idx]
            vx = np.diff(x_slip2)/np.diff(t)
            vy = np.diff(y_slip2)/np.diff(t)
            tt, x_slip3, y_slip3 = self.gravity_slip(x_slip2[-1], y_slip2[-1], vx[-1], vy[-1], g, φ, ωc, R)
            x = np.append(x_slip2, x_slip3)
            y = np.append(y_slip2, y_slip3)
        else:
            x_slip2 = R*np.cos(θ)
            y_slip2 = R*np.sin(θ)
            tt, x, y = self.gravity_slip(x_slip2, y_slip2, -ω*y_slip2, ω*x_slip2, g, φ, ωc, R)
    return x,y

def gravity_slip(self, x0, y0, dxdt0, dydt0, g, φ, ωc, R):
    dt = 4*np.pi/(φ*ωc*1024)
    t = np.array([0])
    x = np.array([x0])
    y = np.array([y0])
    while(x[-1]**2 + y[-1]**2 < R**2):
        t1 = t[-1] + dt
        x1 = x0 + dxdt0*t[-1]
        y1 = y0 + dydt0*t[-1] -0.5*g*t[-1]**2
        x = np.append(x,x1)
        y = np.append(y,y1)
        t = np.append(t,t1)
        def f(t):
            x = x0 + dxdt0*t
            y = y0 + dydt0*t - 0.5*g*t**2
            return x**2 + y**2 - R**2
        if len(t) > 2:
            t_target = bisection(f, t[-3], t[-1])
        else:
            t_target = t[-1]
        x1 = x0 + dxdt0*t_target
        y1 = y0 + dydt0*t_target - 0.5*g*t_target**2
        x = np.append(x[:-3], x1)
        y = np.append(y[:-3], y1)
        t = np.append(t[:-3], t_target)
        return t,x,y
    
    def β_angle(self, β_ball, β_lifter, lifter_height, r, R, Db):#F80/Db effect in the calculation  - to be added properly.
        # define the effective lifter angle as a function of position
        return 0.5*(β_ball + β_lifter + (β_lifter-β_ball)*np.tanh( (r-R+lifter_height+1.5*Db)/(1.5*Db)) )
    
    def mcivor_angle(self, β, μ, Fr, r, R):
        # find the angle of flight using McIvor's theory
        Θ = np.arctan(μ)
        r_R = r/R
        argument = Fr*r_R*np.cos(Θ-β)
        argument = np.minimum(argument, 1)
        return np.minimum( Θ - β + np.arcsin( argument ), np.pi/2)

class power:
    units = 'kW'
    abrasion = []#model abrasion power
    impact = []#model impact power
    measured = []#measured power
    model = []#model total power
    
    def add_values(self, Pa, Pi, Pmodel, Pmeasured):
        self.abrasion.append(Pa)
        self.impact.append(Pi)
        self.model.append(Pmodel)
        self.measured.append(Pmeasured)
    
    def parity_plot(self, saveFlg = False):
        plt.style.use('seaborn-white')
        f, ax = plt.subplots()
        plt.title('Power Parity Plot')
        Pmax = max(max(self.model),max(self.measured))
        plt.axis((0.0,Pmax*1.05,0.0,Pmax*1.05))
        ax.set_aspect('equal', adjustable='box')
        plt.plot([0,Pmax*1.05], [0,Pmax*1.05], '0.6')
        plt.plot(self.model, self.measured, c = '#009fa0', marker = 'o', mfc='none', linestyle='None')
        plt.xlabel('P calculated [{}]'.format(self.units))
        plt.ylabel('P measured [{}]'.format(self.units))
        regression = np.polyfit(self.model, self.measured, 1)
        print('\nP_measured = {0} P_model + {1} [{2}]'.format(regression[0], regression[1],self.units) )
        corr = np.corrcoef(self.model, self.measured)
        r_coeff = corr[0,1]/np.sqrt(corr[0,0]*corr[1,1])
        print('R: {}'.format(r_coeff))
        if saveFlg:
            f.savefig('SCM_parity_plot.png')
        return
    
    def calc(self, p, C):
        xcm,ycm = C.ChargePoly.centroid.coords.xy
        ρc_eff = p.ρc*1.119655113013032/(1+(1-4.1*p.φ**0.1*p.J)*(1-1.7*p.φ**0.1*p.J)*(1+0.6341*p.J))/(1+0.2*p.φ**0.1*p.J)
        Pwr = self.P(ρc_eff, p.J, p.R, p.L, p.g, p.φ, xcm[0]/p.R)
        if not p.discharge_is_grate:
            BuoyPoly = C.ChargePoly.intersection(C.SlurryPoly)
            xb,yb = BuoyPoly.centroid.coords.xy
            ρs_eff = p.ρs*1.119655113013032/(1+(1-4.1*p.φ**0.1*p.J)*(1-1.7*p.φ**0.1*p.J)*(1+0.6341*p.J))/(1+0.2*p.φ**0.1*p.J)
            Pwr = Pwr - self.P(ρs_eff, p.J, p.R, p.L, p.g, p.φ, xb[0]/p.R)
        
        Pa = 0
        Pi = 0
        return Pwr, Pa, Pi
    
    def P(self, ρ, J, R, L, g, φ, xcm_R):
        Pwr = ρ*J*np.pi*R**2.5*L*g**1.5*φ*xcm_R/1000
        return Pwr

#==============================================================================
# function declarations
#==============================================================================

def bisection(f, a, b, TOL=0.000001, NMAX=100):
    """
        Takes a function f, start values [a,b], tolerance value(optional) TOL and
        max number of iterations(optional) NMAX and returns the root of the
        equation using the bisection method.
        """
    n=1
    while n<=NMAX:
        c = (a+b)/2.0
        if f(c)==0 or (b-a)/2.0 < TOL:
            return c
        else:
            n = n+1
            if f(c)*f(a) > 0:
                a=c
            else:
                b=c
    return False

def engine(p):
    
    if p.TimeRun:
        start_time = timeit.default_timer()# start timer for the charge calc
    C = charge(p)
    C.bake(p)
    if p.TimeRun:
        elapsed = timeit.default_timer() - start_time# end the timer
        print('Time to run a calculation: {:.6f}s'.format(elapsed))
    plot_mill(p, C)
    
    return p, C

def plot_mill(p, C):
    #==========================================================================
    # plot the results
    #==========================================================================
    plt.style.use('seaborn-white')
    f, ax = plt.subplots()
    plt.title('Charge Configuration - '+ p.Name)
    plt.axis('equal')
    ax.set_xlim([-1.1*p.R,1.1*p.R])
    ax.set_ylim([-1.1*p.R,1.1*p.R])
    
    # plot shell outline
    if not C.ShellPoly.is_empty:
        shell_patch = PolygonPatch(C.ShellPoly, facecolor=[1, 1, 1], edgecolor=[0.3, 0.3, 0.3], alpha=1.0)
        ax.add_patch(shell_patch)
    
    # plot liner outline
    if not C.LinerPoly.is_empty:
        liner_patch = PolygonPatch(C.LinerPoly, facecolor=[1, 1, 1], edgecolor=[0.8, 0.8, 0.8], alpha=0.5)
        ax.add_patch(liner_patch)
    
    # plot trommel
    if not p.discharge_is_grate:
        trommel_patch = PolygonPatch(C.TrommelPoly, facecolor=[1, 1, 1], edgecolor=[0.8,0.8,0.8], alpha=1.0, linestyle='dashed')
        ax.add_patch(trommel_patch)
        slurry_patch = PolygonPatch(C.SlurryPoly, facecolor=[0.2,0.510,0.821], edgecolor=[1, 1, 1], alpha=0.25)
        ax.add_patch(slurry_patch)
    
    # plot the centrifuge charge
    if not C.CentrifugePoly.is_empty:
        centrifuge_patch = PolygonPatch(C.CentrifugePoly, facecolor=[1, 0.63, 0.14], edgecolor=[0.5, 0.5, 0.5], alpha=0.5)
        ax.add_patch(centrifuge_patch)
    
    # plot lifted patch (McIvor model)
    if not C.McivorPoly.is_empty:
        mcivor_patch = PolygonPatch(C.McivorPoly, facecolor=[1, 0.63, 0.14], edgecolor=[0.5, 0.5, 0.5], alpha=0.5)
        ax.add_patch(mcivor_patch)
    
    # plot falling patch
    if not C.FallPoly.is_empty:
        fall_patch = PolygonPatch(C.FallPoly, facecolor=[1, 0.63, 0.14], edgecolor=[0.5, 0.5, 0.5], alpha=0.5)
        ax.add_patch(fall_patch)
    
    # plot en mass patch
    if not C.Charge_en_massPoly.is_empty:
        enmass_patch = PolygonPatch(C.Charge_en_massPoly, facecolor=[1, 0.63, 0.14], edgecolor=[0.5, 0.5, 0.5], alpha=0.5)
        ax.add_patch(enmass_patch)
    
    plt.show()
    plt.close()
    return

def main(filename = ''):
    print('\n=============================================')
    print('  Tumbling Mill Static Charge Model (2018)')
    print('   contact: sudarshan.martins@metso.com')
    print('=============================================\n')
    
    # initialize the model data structures
    parameters = mill_parameters()
    P = power()
    wear_rate = wear()
    Dball = BallTopSize()
    
    #test values
    
    Ω = wear_rate.Bond(0.5)
    print('{0} Wear rate Ω: {1:.3} {2}'.format(Ω[2],Ω[0],Ω[1]))
    Ω = wear_rate.Benavente(0.5, 5000, 10, 0.1)
    print('{0} Wear rate Ω: {1:.3} {2}'.format(Ω[2],Ω[0],Ω[1]))
    Ω = wear_rate.Guzman(0.5, 5000, 10, 0.1)
    print('{0} Wear rate Ω: {1:.3} {2}'.format(Ω[2],Ω[0],Ω[1]))
    Ω = wear_rate.MartinsRadziszewski(0.29, 63.5, 1000, 7.8, 63.5, 56.08, 1121.52, 2.612, 23)
    print('{0} Wear rate Ω: {1:.3} {2}'.format(Ω[2],Ω[0],Ω[1]))
    
    print('\nBall refill diameters')
    Db = Dball.Azzaroni(2000,13,0.75,3,2.5,np.sqrt(9.81/3))
    print('Db Azzaroni: {:.4} in'.format(Db/25.4))
    Db = Dball.Bond(2000, 13, 0.75, 3, 2.5)
    print('Db Bond: {:.4} in'.format(Db/25.4))
    Db = Dball.Nipping(3*2000,0.2)
    print('Db Nipping: {:.4} in'.format(Db/25.4))
    Db = Dball.AllisChalmers(2000, 0.75, 2.5, 13.0, 3.0)
    print('Db Allis Chalmers: {:.4} in'.format(Db/25.4))
    Db = Dball.SAG(150000, 2.5, 0.8, 7.8)
    print('Db SAG: {:.4} in'.format(Db/25.4))
    
    if filename == '':
        print('\nProcessing default values')
        parameters.listvalues()
        p, C = engine(parameters)
        Pwr, Pwra, Pwri = P.calc(p, C)
        print(Pwr, parameters.P_measured)
    
    else:
        print('\nProcessing {} data file'.format(filename))
        mill_data = read_csv(filename)# get the mill data
        for i in range(len(mill_data)):
            d = mill_data.iloc[i]# mill data row
            parameters.Name = d['Name']# mill name
            parameters.φ = d['phi']# mill speed, fraction critical
            parameters.D = d['D']# mill diameter [m]
            parameters.R = parameters.D/2# mill diameter [m]
            parameters.L = d['L']# effective mill length [m]
            parameters.D_trommel = d['D_trommel']# trommel diameter
            parameters.J = d['J']# mill fill
            parameters.Jb = d['Jb']# mill ball fill
            parameters.l_l = d['l_l']# lifter height
            parameters.N_l = d['N_l']# number of lifter rows
            parameters.w_l = d['w_l']# width of the lifters
            parameters.μs = d['mu']# friction coefficient
            parameters.porosity = d['porosity']# charge porosity
            parameters.β_lifter = d['beta_lifter']# lifter angle
            parameters.β_ball = d['beta_ball']# ball effective lifter angle
            parameters.ρc = d['rho_c']*1000# mill charge density [kg/m^3]
            parameters.ρs = d['rho_s']*1000# slurry density [kg/m^3]
            parameters.discharge_is_grate = d['discharge_is_grate']# boolean grate discharge is true, overflow is false
            parameters.F80 = d['F80']#feed size
            parameters.Db = d['Db']#top up media size
            parameters.DbF80 = max(parameters.F80, parameters.Db)# largest paricles in the charge
            parameters.P_measured = d['Power']# measured power [W]
            parameters.TimeRun = False
            #all oter values are default
            parameters.ωc_Ristow = (1 - parameters.J + 0.000001)**-0.25#in fraction ωc
            parameters.Fr = parameters.φ**2# Froude number
            parameters.ωc = np.sqrt(parameters.g/parameters.R)#critical speed
            #parameters.listvalues()
            p, C = engine(parameters)
            Pwr, Pwra, Pwri = P.calc(p, C)
            #print(Pwr, parameters.P_measured)
            P.add_values(Pwra, Pwri, Pwr, parameters.P_measured)
        P.parity_plot()
    return

if __name__ == "__main__":
    #main('analysisdata6.csv')
    main()
