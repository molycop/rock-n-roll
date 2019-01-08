//
//  GraphView.swift
//  plotting
//
//  Created by Elnaz Taqizadeh on 2017-07-31.
//  Copyright © 2017 Elnaz Taqizadeh. All rights reserved.
//

import UIKit
import Foundation
import GEOSwift
import Eureka
import TPPDF


struct cellData {
    var opened = Bool()
    var title = String()
    var caption = String()
    var unit = String()
    var singleValue = String()
    var values = [(String, Double)]()
}

class PlotViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
//    @IBOutlet weak var UIStackView: UIStackView!
    @IBOutlet weak var PlotUIView: UIView!
    
    @IBOutlet weak var restartButton: UIBarButtonItem!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var exportButton: UIBarButtonItem!
    
    //MARK: - INFO SCREEN
    @IBOutlet var infoView: UIView!
    @IBOutlet weak var TableView: UITableView!

    @IBOutlet weak var Xbutton: UIButtonX!
    let geoRef = GeoRef()
    let mathRef = MathRef()
    let power = Power()
    let wearRate = Wear()
    let ballTopSize = Ball()
    
    var inputValue: [String: Any?] = [:]
    var StrCV: String?
    
    var name = ""                        //mill name
    var phi = 0.0000                     //mill speed in percent critical
//    var D = 0.0000                       //mill diameter [m]
//    var L = 0.0000                       //effective mill length [m]
    var dTrommel = 0.0000                //trommel diameter
    var j = 0.0000                       //mill fill
    var jb = 0.0000                      //mill ball fill
    var lifterHeight = 0.0000            //lifter height
    var lifterWidth = 0.0000             //lifter width
    var bethaLifter = 0.0000             //lifter angle
//    var chargeDensity = 0.0000           //mill charge density [kg/m^3]
//    var slurryDensity = 0.0000           //slurry density [kg/m^3]
    var dischargeIsGrate = false         //grate discharge is true, overflow is false
    var f80 = 0.0000                     //feed size
    var db = 0.0000                      //top up media size
//    var msredPower = 0.0000              //measured power [W]
    var ai = 0.0000                      //Abrasion Index
    var crticialSpeed = 0.000            //Critical Speed
    var ristowSpeed = 0.0000             //in fraction - Ristow Critical Speed
    var oreDensity = 0.0000              // ore density [kg/m^3]
    var linerPlate = 0.0000              // liner plate thickness [m]
    var dShell = 0.0000                  // shell inner diameter [m]
    var Wi = 0.0000                      //Bond’s work index [kWh/ton]
    var percentSolids = 0.0000           //Percent Solids
    var lBelly = 0.0000                  //mill belly length [m] --
                                         //NOTE, if only the effective length is available,
                                         //use this number for both -- yes, you have to enter it twice!
    var lCenterLine = 0.0000            //mill centerline length [m]
    var slurrytemp = 0.0000              //slury temperature in K
    var ph = 0.0000                      //PH of the slurry
    var m = 0.0000                       //Throughput [tonnes/hr]
    
    //Hidden Variables
    var g = 9.81                         //gravitational acceleration [m/s^2]
    var muS = 0.4                        //friction coefficient
    var e = 0.8                          //the fraction efficiency of KE transfer
    var porosity = 0.63                  //charge porosity
    var bethaBall = 70.000               //ball effective lifter angle (70 degrees)
    var steelDensity = 7.8               //steel density [kg/m^3] - THIS SHOULD BE A HIDDEN VARIABLE
    var waterDensity = 1.0               //water density [kg/m^3] - THIS SHOULD BE A HIDDEN VARIABLE
    
    var dbAzz = 0.0000
    var dbBond = 0.0000
    var dbNipp = 0.0000
    var dballChal = 0.0000
    var dbSag = 0.0000
    
    var bondValue = 0.0000
    var benValue = 0.0000
    var guzValue = 0.0000
    var mrValue = 0.0000
    
    var pwrRslt = ""
    
    //Table View
    var tableData = [cellData]()
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableData[section].opened == true {
            return tableData[section].values.count + 1
        } else {
            return 1    }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let dataIndex = indexPath.row - 1
        let cell = TableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ExpandedTableViewCell

        if indexPath.row == 0 {
            cell.mainLabel.text = tableData[indexPath.section].title
            cell.mainLabel.font = UIFont(name: "Helvetica-Light", size: 16)

            cell.captionLabel.text = tableData[indexPath.section].caption
            cell.captionLabel.font = UIFont(name: "AvenirNext-UltraLight", size: 14)

            cell.valueLabel.text = tableData[indexPath.section].singleValue
            cell.valueLabel.font = UIFont(name: "Helvetica-Light", size: 15.5)
            
            cell.unitLabel.text = tableData[indexPath.section].unit
            cell.unitLabel.font = UIFont(name: "AvenirNext-UltraLight", size: 14)
        }
        else {
            print(tableData[indexPath.section].values[dataIndex].0, String(tableData[indexPath.section].values[dataIndex].1))
            
            
            cell.mainLabel.text = tableData[indexPath.section].values[dataIndex].0
            cell.valueLabel.font = UIFont(name: "Helvetica-Light", size: 15.5)

            cell.valueLabel.text = String(tableData[indexPath.section].values[dataIndex].1)
            cell.mainLabel.font = UIFont(name: "AvenirNext-UltraLight", size: 14.5)
            
            cell.unitLabel.text = ""
            cell.captionLabel.text = ""
            }
        return cell
    }


    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = tableData[indexPath.section].title
        if tableData[indexPath.section].opened == true {
            tableData[indexPath.section].opened = false
            print("if title:", title)
            if ( title == "▾Wear" || title == "▾Db"){
                tableData[indexPath.section].title = "▸" + String(title.dropFirst())
            }
            let sections = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(sections, with: .none )
        }
        else {
            tableData[indexPath.section].opened = true
//            let tmp = String(tmp.dropFirst())
            print("else:", title)
            if ( title == "▸Wear" || title == "▸Db"){
            tableData[indexPath.section].title = "▾" + String(title.dropFirst())
            }
            let sections = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(sections, with: .none )
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
//        //Stack View Setup
//        UIStackView.addArrangedSubview(PlotUIView)
//        UIStackView.addArrangedSubview(TableView)
//        UIStackView.layoutIfNeeded()
//
//        var cnt = 0
        print(inputValue)
      
        for vls in inputValue {
            switch vls.key {
            case "j":
                self.j = vls.value as! Double
            case "l_l":
                self.lifterHeight = vls.value as! Double
            case "w_l":
                self.lifterWidth = vls.value as! Double
            case "Ai":
                self.ai = vls.value as! Double
            case "jb":
                self.jb = vls.value as! Double
            case "bethaLifter":
                self.bethaLifter = vls.value as! Double
            case "phi":
                self.phi = vls.value as! Double
            case "name":
                self.name = vls.value as! String
            case "f80":
                self.f80 = vls.value as! Double
            case "db":
                self.db = vls.value as! Double
            case "oreDensity":
                self.oreDensity = vls.value as! Double
            case "linerPlate":
                self.linerPlate = vls.value as! Double
            case "dShell":
                self.dShell = vls.value as! Double
            case "Wi":
                self.Wi = vls.value as! Double
            case "percentSolids":
                self.percentSolids = vls.value as! Double
            case "lBelly":
                self.lBelly = vls.value as! Double
            case "lCenterLine":
                self.lCenterLine = vls.value as! Double
            case "slurryTemp":
                self.slurrytemp = vls.value as! Double
            case "ph":
                self.ph = vls.value as! Double
            case "m":
                self.m = vls.value as! Double
            case "discharge":
                if(vls.value as! String == "Overflow"){
                    self.dischargeIsGrate = false
                }
                else {
                    self.dischargeIsGrate = true
                }
            default:
                print("Input Error: ",  vls.key)
            }
//            cnt += 1
        }
        
        //Send Input to Plot View
        let puv = self.view.subviews[0] as! PlotUIView
        puv.isUserInteractionEnabled = true
        
        
        //Instantiating Mill
        let D = dShell - 2*linerPlate
        let L = lBelly + 2.28*j*(1-j)*(lCenterLine - lBelly)
        let crtSpeed = sqrt(g/(D/2))
        let rstSpeed = pow ((1 - j + 0.000001), -0.25)
        
        //Froude number
        let Fr = pow(phi, 2)
        
        let jOre = j - jb
        let chargeDensity = (jb*steelDensity + jOre*oreDensity)/(j+0.0001)
        let slurryDensity = (oreDensity*percentSolids + (100-percentSolids)*waterDensity)/100
        
        let mill = Mill(name: name, phi: phi/100, d: D, L: L, dTrommel: 0.25*D, j: j/100, jb: jb/100, lifterHeight: lifterHeight, muS: muS, bethaLifter: bethaLifter*(.pi/180), bethaBall: bethaBall*(.pi/180), dischargeIsGrate: dischargeIsGrate, f80: f80, db: db, ristowSpeed: rstSpeed)
        //Instantiating Charge
        let charge = Charge(porosity: porosity, rhoC: chargeDensity, rhoS: slurryDensity)

        
        //lifter
        let liftPoly = mill.shell(R: mill.R-mill.lifterHeight)
        let shellPoly = mill.shell(R: mill.R)
        let diffPoly = shellPoly.difference(liftPoly)
        let diffCrd = geoRef.geometryPoints(str: (diffPoly?.WKT!)!)
        
        //Plot Slurry
        let slurryPoly = mill.slurry(R: mill.R, dTrommel: mill.dTrommel, shellPoly: shellPoly, dischargeIsGrate: mill.dischargeIsGrate)
        
        let empty = geoRef.emptyPoly()
        var mcivorPoly = empty
        var fallPoly = empty
        var centrifugePoly = empty
        var chargePoly = empty
        var chargeEnMassPoly = empty
        
        if mill.j == 1 {
            //            print("j==1")
            let mcCrd = geoRef.getCoordinate(R: mill.R)
            mcivorPoly = geoRef.createPolygon(coord: mcCrd)
            fallPoly = empty
            centrifugePoly = empty
        }
        else if mill.phi >= mill.ristowSpeed {
            //            print("phi > ristowSpeed")
            mcivorPoly = empty
            fallPoly = empty
            centrifugePoly = charge.createCentrifugePoly(mill: mill)
        }
        else if mill.phi > 1 {
            //            print("phi > 1")
            let mcivor = charge.mcivor(mill: mill)
            mcivorPoly = mcivor.0
            fallPoly = mcivor.1
            centrifugePoly = charge.createCentrifugePoly(mill: mill)
        }
        else if mill.phi < 0.3 {
            //            print("phi < 0.3")
            mcivorPoly = empty
            fallPoly = empty
            centrifugePoly = empty
        }
        else {
            //            print("else!")
            let mcivor = charge.mcivor(mill: mill)
            mcivorPoly = mcivor.0
            fallPoly = mcivor.1
            centrifugePoly = empty
        }
        if mill.j == 0 {
            
            mcivorPoly = empty
            fallPoly = empty
            centrifugePoly = empty
        }
        
        chargePoly = (centrifugePoly).union(mcivorPoly)!
        let chargePnts = geoRef.geometryPoints(str: chargePoly.WKT!)
        let chargeArea = geoRef.polygonArea(points: chargePnts)
        
        let shellArea = (.pi)*pow(mill.R, 2)
        //        print(shellArea)
        if chargeArea/shellArea > mill.j {
            //            print("Charge area/shell area> j")
            //thin out the charge
            func thinObjective(j: Double) -> (Double) -> Double {
                func f(r: Double) -> Double {
                    let exCrd = geoRef.getCoordinate(R: r)
                    let exclusionPoly = geoRef.createPolygon(coord: exCrd)
                    
                    let thinPoly = chargePoly.difference(exclusionPoly)
                    let thinPnts = geoRef.geometryPoints(str: thinPoly!.WKT!)
                    let thinArea = geoRef.polygonArea(points: thinPnts)
                    
                    //                    print("thinObjective")
                    //                    print(thinArea/(shellArea)-mill.j)
                    return thinArea/(shellArea)-mill.j
                }
                return f
            }
            let fcn = thinObjective(j: mill.j)
            let exR = mathRef.bisection(fcn, a: 0, b: mill.R, TOL: TOL, NMAX: NMAX)
            //            print(fcn, exR)
            
            let exCrd = geoRef.getCoordinate(R: exR)
            let exPoly = geoRef.createPolygon(coord: exCrd)
            
            chargePoly = chargePoly.difference(exPoly)!
            mcivorPoly = mcivorPoly.difference(exPoly)!
            centrifugePoly = centrifugePoly.difference(exPoly)!
        }
            
        else {
            //fill up the charge
            //find the starting angle of the stable charge that corresponds to the right fill level
            //            print("else")
            func fillObjective(j: Double) -> (Double) -> Double {
                func f(Rpoly: Double) -> Double {
                    let mssPoly = charge.createEnMassPoly(mill: mill, Rpoly: Rpoly)
                    let proposedChargePoly = (mssPoly).union(chargePoly)
                    
                    let proposedPolyPnts = geoRef.geometryPoints(str: proposedChargePoly!.WKT!)
                    let proposedPolyArea = geoRef.polygonArea(points: proposedPolyPnts)
                    return proposedPolyArea/shellArea-mill.j
                }
                
                return f
            }
            if mill.phi < 0.1 {
                //                print("print phi < 0.1")
                let yCh = mill.JtoH(J: mill.j, R: mill.R)-mill.R
                
                let xCharge = [-1.1*mill.R, -1.1*mill.R,  1.1*mill.R,  1.1*mill.R]
                let yCharge = [yCh, -1.1*mill.R, -1.1*mill.R,  yCh]
                
                var points = [Coordinate]()
                for i in 0..<xCharge.count {
                    points.append(Coordinate(x: xCharge[i], y: yCharge[i]))
                }
                
                let poly = geoRef.createPolygon(coord: points)
                chargeEnMassPoly = (poly).intersection(shellPoly)!
                
                //Rotate the ChargeEnMass polygon
                let rotationAngle = mathRef.thetaStability(mill: mill)*180/(.pi)
                chargeEnMassPoly = geoRef.rotatePolygon(geometry: chargeEnMassPoly, alpha: rotationAngle)
            }
                
            else {
                //                print("else else")
                let fcn = fillObjective(j: mill.j)
                let Rfill = mathRef.bisection(fcn, a: mill.R/pow(mill.phi, 2) - mill.R, b: mill.R/pow(mill.phi, 2) + mill.R, TOL: TOL, NMAX: NMAX)
                chargeEnMassPoly = charge.createEnMassPoly(mill: mill, Rpoly: Rfill)
            }
            chargePoly = (chargePoly).union(chargeEnMassPoly)!
        }

        
        puv.mill = mill
        puv.charge = charge
        puv.slurryPoly =  slurryPoly
        puv.mcivorPoly = mcivorPoly
        puv.fallPoly = fallPoly
        puv.centrifugePoly = centrifugePoly
        puv.chargePoly = chargePoly
        puv.chargeEnMassPoly = chargeEnMassPoly
        puv.diffCrd = diffCrd
        
        //Power
        let pwr = power.calcPower(mill: mill, charge: charge, chargePoly: chargePoly)
        self.pwrRslt = String((pwr.0/10).rounded()/100)                               //convert W to kW and round it up
        
        //Wear Rate
        let wearBond = wearRate.Bond(Ai: self.ai)
        let wearBen = wearRate.Benavente(Ai: self.ai, f80: self.f80*10000, PH: self.ph, dBall: self.db)
        let wearGuzman = wearRate.Guzman(Ai: self.ai, f80: self.f80*10000, PH: self.ph, dBall: self.db)
        let wearMR = wearRate.MartinsRadziszewski(Ai: 0.29, dBall: 63.5, F80: 1000, ph: 7.8, h: 63.5, Sol: 56.08, SiO2: 1121.52, rain: 2.612, tmprt: 23)
        print("Default Value for MR Wear Rate!")
        
        self.bondValue = (wearBond.0*10000).rounded()/10000
        self.benValue = (wearBen.0*10000).rounded()/10000
        self.guzValue = (wearGuzman.0*10000).rounded()/10000
        self.mrValue = (wearMR.0*10000).rounded()/10000
      
        self.crticialSpeed = sqrt(self.g/(D/2))
        
        //Ball refill diameters
        let azzaroni = ballTopSize.Azzaroni(f80: self.f80*10000, wi: self.Wi, phi: self.phi/100,d: D,rho: self.oreDensity,omegaC: self.crticialSpeed)
        let bond = ballTopSize.Bond(f80: self.f80*10000, wi: self.Wi, phi: self.phi/100, d: D, rho: self.oreDensity)
        print("Bond uses OreDensity for Rho")
        let nipp = ballTopSize.Nipping(topSize: self.f80*10000, mu: self.muS)
        let allChal = ballTopSize.AllisChalmers(f80: self.f80*10000, phi: self.phi/100, rho: self.oreDensity, wi: self.Wi, d: D)
        let sag = ballTopSize.SAG(topSize: self.f80*1000000, rhoOre: self.oreDensity, e: self.e, rhoMedia: self.steelDensity)
        
        self.dbAzz = (azzaroni*10000).rounded()/10000
        self.dbBond = (bond*10000).rounded()/10000
        self.dbNipp = (nipp*10000).rounded()/10000
        self.dballChal = (allChal*10000).rounded()/10000
        self.dbSag = (sag*10000).rounded()/10000
        
        
        tableData = [cellData(opened: false, title: "φ:", caption: "Mill speed in percent critical", unit: "%", singleValue: String(self.phi), values: []),
                          cellData(opened: false, title: "J:", caption: "Mill fill", unit: "%", singleValue: String(self.j), values: []),
                          cellData(opened: false, title: "Power:", caption: "Power of the Mill", unit: "kW", singleValue: pwrRslt, values: []),
                          cellData(opened: false, title: "▸Wear", caption: "Wear Rate", unit: "kg/kWh", singleValue: "", values: [("Bond", self.bondValue), ("Benavente", self.benValue), ("Guzman", self.guzValue), ("MartinsRadziszewski", self.mrValue)]),
                          cellData(opened: false, title: "▸Db", caption: "Ball refill diameteres", unit: "mm", singleValue: "", values: [("Azzaroni", self.dbAzz), ("Bond", self.dbBond), ("Nipp", self.dbNipp), ("Allis-Chalmers", self.dballChal), ("SAG", self.dbSag)])]

//        TableView.reloadData()
    }
    
    @IBAction func pressedDetailButton(_ sender: Any) {
        infoView.center = self.view.subviews[0].center
        view.addSubview(infoView)
    }
    
    @IBAction func closeInfoPopup(_ sender: UIButton) {
        infoView.removeFromSuperview()
    }
  
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Actions - Share Button Action
    @IBAction func exportButtonPressed(_ sender: Any) {
        //Logging
        //NSLog(@"share action");
        
        //Take Screenshot
//        UIGraphicsBeginImageContext(view.frame.size)
//        view.layer.render(in: UIGraphicsGetCurrentContext()!)
//        let srcImg = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 270, height: 340), false, 0)
        self.view.drawHierarchy(in: CGRect(x: -70, y: -150, width: view.bounds.size.width, height: view.bounds.size.height), afterScreenUpdates: true)
        let srcImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let pdfVC = self.storyboard?.instantiateViewController(withIdentifier: "pdfViewController") as! pdfViewController
    
        pdfVC.plotImage = srcImg!

        pdfVC.millName = self.name
        pdfVC.phi = String(self.phi)
        pdfVC.j = String(self.j)
        pdfVC.power = String(self.pwrRslt)
       
        pdfVC.bondValue = String(self.bondValue)
        pdfVC.benValue = String(self.benValue)
        pdfVC.guzValue = String(self.guzValue)
        pdfVC.mrValue = String(self.mrValue)
        
        pdfVC.dbAzz = String(self.dbAzz)
        pdfVC.dbBond = String(self.dbBond)
        pdfVC.dbNipp = String(self.dbNipp)
        pdfVC.dballChal = String(self.dballChal)
        pdfVC.dbSag = String(self.dbSag)
        
        pdfVC.inputValue = self.inputValue
        
        // Take user to SecondViewController
        _ = navigationController?.pushViewController(pdfVC, animated: true)
    }
    
    //MARK: Actions - Restart Button Action
    @IBAction func restartButtonPressed(_ sender: Any) {
        
        //Instantiate secondViewController
        let CalcFormViewController = self.storyboard?.instantiateViewController(withIdentifier: "CalcFormViewController") as! CalcFormViewController
        
        CalcFormViewController.storedValue = inputValue
        CalcFormViewController.restartedForm = true
        
        //Takeuser to SecondViewController
        _ = navigationController?.pushViewController(CalcFormViewController, animated: true)
    }
    
    convenience init() {
        self.init()
        initialize()
    }

    
    private func initialize() {
        let exportButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: .exportButtonPressed)
        navigationItem.rightBarButtonItem = exportButton
        
        let restartButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: .restartButtonPressed)
        navigationItem.leftBarButtonItem = restartButton
        
        view.backgroundColor = .white
    }

}

// MARK: - Selectors
extension Selector {
    fileprivate static let exportButtonPressed = #selector(PlotViewController.exportButtonPressed(_:))
}

extension Selector {
    fileprivate static let restartButtonPressed = #selector(PlotViewController.restartButtonPressed(_:))
}
