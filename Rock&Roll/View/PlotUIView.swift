//
//  PlotUIView.swift
//  GW
//
//  Created by Elnaz Taqizadeh on 2017-08-21.
//  Copyright © 2017 Elnaz Taqizadeh. All rights reserved.
//

import UIKit
import GEOSwift

let TOL = 0.000001
let NMAX = 100

class PlotUIView: UIView {
    
    let mathRef = MathRef()
    let geoRef = GeoRef()
    
    var mill: Mill!
    var charge: Charge!
    var slurryPoly: Geometry!
    var mcivorPoly: Geometry!
    var fallPoly: Geometry!
    var centrifugePoly: Geometry!
    var chargePoly: Geometry!
    var chargeEnMassPoly: Geometry!
    var diffCrd: [Coordinate]!
    
    
    //Create Text Field
    func CreateTextField(myText: String, font: UIFont, frame: CGRect, isHeader: Bool){
        
        let txtField = UITextField(frame: frame)
        self.addSubview(txtField)
        txtField.text = myText
        txtField.font = font
        txtField.isUserInteractionEnabled = false
        txtField.autocorrectionType = UITextAutocorrectionType.no
        txtField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        
        if(isHeader){
            txtField.textAlignment = .center
        }
    }
    

    
    //Draw Polygon
    func drawPolygon(points: Array<Coordinate>, rect: CGRect,ctx: CGContext, scale: Double, red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat, outline: CGFloat) {
        
        let polyPath = CGMutablePath()
        let hght = rect.height
        
        let x0: CGFloat = CGFloat(points[0].x*scale)
        let y0: CGFloat = CGFloat(points[0].y*scale)

        
//        polyPath.move(to: CGPoint(x: x0+rect.midX, y: -y0+rect.midY))
        polyPath.move(to: CGPoint(x: x0+rect.midX, y: -y0+hght/1.7))
        for i in 1..<points.count {
            let x: CGFloat = CGFloat(points[i].x*scale)
            let y: CGFloat = CGFloat(points[i].y*scale)
            
            polyPath.addLine(to: CGPoint(x: x+rect.midX, y: -y+hght/1.7))
//            polyPath.move(to: CGPoint(x: -x+rect.midX, y: -y+rect.midY))
            
        }
        polyPath.closeSubpath()
        
        ctx.strokePath()
        ctx.addPath(polyPath)
        ctx.setFillColor(red: red, green: green, blue: blue, alpha: alpha)
        ctx.fillPath()
        
        polyPath.copy()
        ctx.addPath(polyPath)
        
        if(outline > 0.0){
            ctx.setLineWidth(outline)
        }
        
        else{
            ctx.setLineWidth(0.0)
        }
        ctx.setStrokeColor(UIColor.darkGray.cgColor)
        ctx.strokePath()
    }
    

    //Draw
    override func draw(_ rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        let scale = Double(rect.maxX)/(1.8*mill.D)
      
        //Header Print on Screen
        let headerTxt = "Charge configuration " + mill.name
        let headerFont = UIFont(name: "Helvetica", size: 19)
        let headerFrame = CGRect(x: 0, y: 17, width: rect.maxX, height: 30)
        CreateTextField(myText: headerTxt, font: headerFont!, frame: headerFrame, isHeader: true)

        
        if !((slurryPoly.WKT)?.isEqual(geoRef.emptyPoly().WKT))!{
            let coord = geoRef.geometryPoints(str: slurryPoly.WKT!)
            drawPolygon(points: coord, rect: rect, ctx: context, scale: scale, red:0.76, green:0.87, blue:1.00, alpha:0.5, outline: 0.0)
        }
        
        //Plot Trommel
        if !mill.dischargeIsGrate {
            let coord = geoRef.getCoordinate(R: mill.dTrommel/2)
            drawPolygon(points: coord, rect: rect, ctx: context, scale: scale, red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0, outline: 0.6)
        }
        
        //Plot the centrifuge charge
        //centrifuge radius, if that is the case
        if !((centrifugePoly.WKT)?.isEqual(geoRef.emptyPoly().WKT))!{
            let coord = geoRef.geometryPoints(str: centrifugePoly.WKT!)
            drawPolygon(points: coord, rect: rect, ctx: context, scale: scale, red:0.95, green:0.35, blue:0.09, alpha:0.5, outline: 0.0)
        }
        
        //Plot the McivorPoly
        if !((mcivorPoly.WKT)?.isEqual(geoRef.emptyPoly().WKT))!{
            let coord = geoRef.geometryPoints(str: mcivorPoly.WKT!)
            drawPolygon(points: coord, rect: rect, ctx: context, scale: scale, red:0.58, green:0.04, blue:0.19, alpha:0.5, outline: 0.0)
        }

        //Plot the Fall Poly
        if !((fallPoly.WKT)?.isEqual(geoRef.emptyPoly().WKT))!{
            let coord = geoRef.geometryPoints(str: fallPoly.WKT!)
            drawPolygon(points: coord, rect: rect, ctx: context, scale: scale, red: 0.02, green: 0.46, blue: 0.43, alpha: 0.5, outline: 0.0)
        }

        if !((chargeEnMassPoly.WKT)?.isEqual(geoRef.emptyPoly().WKT))!{
            let coord = geoRef.geometryPoints(str: chargeEnMassPoly.WKT!)
            drawPolygon(points: coord, rect: rect, ctx: context, scale: scale, red:0.95, green:0.35, blue:0.09, alpha:0.5, outline: 0.0)
        }

                
        //Draw Shell Poly
        drawPolygon(points: diffCrd, rect: rect, ctx: context, scale: scale, red: 0.0, green: 0.0, blue: 0.1, alpha: 0.05, outline: 0.0)
   }
}
