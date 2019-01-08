//
//  calcFormViewController.swift
//  GW
//
//  Created by Elnaz Taqizadeh on 2017-08-18.
//  Copyright © 2017 Elnaz Taqizadeh. All rights reserved.
//
//ΒΓΔΕΖΗΘΙΚΛΞΠΣΦΨΩαβγδεζηθλμνξπρστφχψω

import UIKit
import Eureka
import os.log

import Crashlytics

class CalcFormViewController: FormViewController {

    
    //MARK: Properties
    @IBOutlet weak var restartButton: UIBarButtonItem!
    @IBOutlet weak var applyButton: UIBarButtonItem!
    var storedValue: [String: Any?] = [:]
    var passedStr: String? = "Hello"
    var restartedForm = false
    
    //MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
   
    //MARK: Actions
    
    @IBAction func applyButtonPressed(_ sender: UIBarButtonItem) {
        let jRow: DecimalRow? = form.rowBy(tag: "j")
        let jbRow: DecimalRow? = form.rowBy(tag: "jb")
        if(!(jRow?.value != nil) && !(jbRow?.value != nil)) {
            let jValue = jRow?.value as! Double
            let jbValue = jbRow?.value as! Double
            if (jValue < jbValue) {
                let alert = UIAlertController(title: "Warning:", message: "Check if Jb ≤ J", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default
                    , handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        let lbelly: DecimalRow? = form.rowBy(tag: "lBelly")
        let centerLine: DecimalRow? = form.rowBy(tag: "lCenterLine")
        
        if(!(lbelly?.value != nil) && !(centerLine?.value != nil)) {
            let lbValue = lbelly?.value as! Double
            let clValue = centerLine?.value as! Double
            
            
            if (clValue < lbValue) {
                let alert = UIAlertController(title: "Warning:", message: " Check if \n mill belly length ≤ mill center line", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default
                    , handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        // Instantiate SecondViewController
        let PlotViewController = self.storyboard?.instantiateViewController(withIdentifier: "PlotViewController") as! PlotViewController

        PlotViewController.inputValue = form.values()
        
        // Take user to SecondViewController
        if form.validate().isEmpty {
            _ = navigationController?.pushViewController(PlotViewController, animated: true)
        }


    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(storedValue)
//        print(passedStr!)

        // Enables the navigation accessory and stops navigation when a disabled row is encountered
        navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)
        
        // Enables smooth scrolling on navigation to off-screen rows
        animateScroll = true
        
        // Leaves 20pt of space between the keyboard and the highlighted row after scrolling to an off screen row
        rowKeyboardSpacing = 20
        
        // Do any additional setup after loading the view, typically from a nib.
        form +++ Section("Fill the follwing rows:")
            <<< TextRow("name") {
                $0.title = "Name"
                $0.value = "Meadowbank"
                $0.placeholder = "Name"
                $0.add(rule: RuleRequired())
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != "Meadowbank" {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
            <<< DecimalRow("phi") {
                $0.title = "φ"
                $0.value = 75
                $0.placeholder = "Mill Speed in Percent Critical"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleGreaterOrEqualThan(min: 0))
                $0.add(rule: RuleSmallerOrEqualThan(max: 10000))
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 75 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }

            }
//            <<< DecimalRow("d") {
//                $0.title = "D  (m)"
//                $0.value = 7.7
//                $0.placeholder = "Mill Diameter"
//                $0.add(rule: RuleRequired())
//                $0.add(rule: RuleGreaterOrEqualThan(min: 0.05))
//                $0.add(rule: RuleSmallerThan(max: 100))
//                }.cellUpdate{cell, row in
//                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
//                    if !row.isValid {
//                        cell.titleLabel?.textColor = .red
//                    }
//            }
//            <<< DecimalRow("l") {
//                $0.title = "L  (m)"
//                $0.value = 3.35
//                $0.placeholder = "Mill Effective Length"
//                $0.add(rule: RuleRequired())
//                $0.add(rule: RuleGreaterOrEqualThan(min: 0))
//                $0.add(rule: RuleSmallerThan(max: 100))
//                }.cellUpdate{cell, row in
//                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
//                    if !row.isValid {
//                        cell.titleLabel?.textColor = .red
//                    }
//            }
            <<< DecimalRow("j") {
                $0.title = "J"
                $0.value = 22.6
                $0.placeholder = "Percent Mill Fill"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleGreaterOrEqualThan(min: 0))
                $0.add(rule: RuleSmallerOrEqualThan(max: 100))
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 22.6 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
            <<< DecimalRow("jb") {
                $0.title = "Jb"
                $0.value = 13.7
                $0.placeholder = "Percent Mill Ball Fill"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleGreaterOrEqualThan(min: 0))
                $0.add(rule: RuleSmallerOrEqualThan(max: 100))
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 13.7 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
            <<< DecimalRow("l_l") {
                $0.title = "Lifter height (m)"
                $0.value = 0.385
                $0.placeholder = "Lifter height"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleGreaterOrEqualThan(min: 0))
                $0.add(rule: RuleSmallerOrEqualThan(max: 2))
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 0.385 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
            <<< DecimalRow("w_l") {
                $0.title = "Lifter width (m)"
                $0.value = 0.231
                $0.placeholder = "Lifter width"
                $0.add(rule: RuleRequired())
//                $0.add(rule: RuleGreaterOrEqualThan(min: 0))
//                $0.add(rule: RuleSmallerOrEqualThan(max: 2))
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 0.231 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
            <<< DecimalRow("bethaLifter") {
                $0.title = "β (Degrees)"
                $0.value = 25
                $0.placeholder = "Lifter angle"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleGreaterOrEqualThan(min: 0))
                $0.add(rule: RuleSmallerOrEqualThan(max: 99))
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 25 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
            <<< DecimalRow("Ai") {
                $0.title = "Ai"
                $0.value = 0.5
                $0.placeholder = "Bond abrasion index"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleGreaterOrEqualThan(min: 0))
                $0.add(rule: RuleSmallerOrEqualThan(max: 1))
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 0.5 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
//            <<< DecimalRow("chargeDensity") {
//                $0.title = "ρc"
//                $0.value = 5.83
//                $0.placeholder = "Charge specific gravity"
//                $0.add(rule: RuleRequired())
//                $0.add(rule: RuleGreaterOrEqualThan(min: 1))
//                $0.add(rule: RuleSmallerOrEqualThan(max: 10))
//                }.cellUpdate{cell, row in
//                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
//                    if !row.isValid {
//                        cell.titleLabel?.textColor = .red
//                    }
//            }
//            <<< DecimalRow("slurryDensity") {
//                $0.title = "ρs"
//                $0.value = 2.45
//                $0.placeholder = "Slurry specific gravity"
//                $0.add(rule: RuleRequired())
//                $0.add(rule: RuleGreaterOrEqualThan(min: 0.5))
//                $0.add(rule: RuleSmallerOrEqualThan(max: 8))
//                }.cellUpdate{cell, row in
//                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
//                    if !row.isValid {
//                        cell.titleLabel?.textColor = .red
//                    }
//            }
            <<< DecimalRow("f80") {
                $0.title = "F80  (m)"
                $0.value = 0.1925
                $0.placeholder = "Feed size"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleGreaterOrEqualThan(min: 0))
                $0.add(rule: RuleSmallerOrEqualThan(max: 1))
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 0.1925 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
            <<< DecimalRow("db") {
                $0.title = "Db  (m)"
                $0.value = 0.1925
                $0.placeholder = "Top up media size"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleGreaterOrEqualThan(min: 0))
                $0.add(rule: RuleSmallerOrEqualThan(max: 0.3))
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 0.1925 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
            <<< DecimalRow("oreDensity") {
                $0.title = "ρore"
                $0.value = 2.93
                $0.placeholder = "ore density"
                $0.add(rule: RuleRequired())
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 2.93 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
//            <<< DecimalRow("steelDensity") {
//                $0.title = "ρsteel"
//                $0.value = 7.8
//                $0.placeholder = "steel density"
//                $0.add(rule: RuleRequired())
//                }.cellUpdate{cell, row in
//                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
//                    if !row.isValid {
//                        cell.titleLabel?.textColor = .red
//                    }
//            }
//            <<< DecimalRow("waterDensity") {
//                $0.title = "ρwater"
//                $0.value = 1.0
//                $0.placeholder = "water density"
//                $0.add(rule: RuleRequired())
//                }.cellUpdate{cell, row in
//                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
//                    if !row.isValid {
//                        cell.titleLabel?.textColor = .red
//                    }
//            }
            <<< DecimalRow("linerPlate") {
                $0.title = "Liner plate (m)"
                $0.value = 0.385
                $0.placeholder = "Liner plate thickness"
                $0.add(rule: RuleRequired())
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 0.385 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
            <<< DecimalRow("dShell") {
                $0.title = "dShell (m)"
                $0.value = 8.470
                $0.placeholder = "shell inner diameter"
                $0.add(rule: RuleRequired())
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 8.470 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
            <<< DecimalRow("Wi") {
                $0.title = "Wi (kWh/ton)"
                $0.value = 10.0
                $0.placeholder = "Bond’s work index"
                $0.add(rule: RuleRequired())
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 10.0 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
            <<< DecimalRow("percentSolids") {
                $0.title = "Percent solids"
                $0.value = 80
                $0.placeholder = "Percent solids"
                $0.add(rule: RuleRequired())
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 80 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
            <<< DecimalRow("lBelly") {
                $0.title = "Belly length (m)"
                $0.value = 3.35
                $0.placeholder = "mill belly length"
                $0.add(rule: RuleRequired())
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 3.35 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
            <<< DecimalRow("lCenterLine") {
                $0.title = "center line length (m)"
                $0.value = 3.35
                $0.placeholder = "mill centerline length"
                $0.add(rule: RuleRequired())
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 3.35 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
            <<< DecimalRow("slurryTemp") {
                $0.title = "Slurry temperature (K)"
                $0.value = 50 + 273.15
                $0.placeholder = "Slurry temperature"
                $0.add(rule: RuleRequired())
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 50 + 273.15 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
            <<< DecimalRow("ph") {
                $0.title = "Slurry PH"
                $0.value = 10
                $0.placeholder = "Slurry PH"
                $0.add(rule: RuleRequired())
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 10 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
            <<< DecimalRow("m") {
                $0.title = "Throughput (tonnes/hr)"
                $0.value = 300
                $0.placeholder = "throughput"
                $0.add(rule: RuleRequired())
                }.cellUpdate{cell, row in
                    cell.textField.font =  .italicSystemFont(ofSize: 16.0)
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    if row.value != 300 {
                        cell.textField.textColor = UIColor(red:0.11, green:0.36, blue:0.16, alpha:1.0)
                    }
            }
            <<< SegmentedRow<String>("discharge") {
                $0.title = "Discharge type"
                //                $0.selectorTitle = "Pick the discharge type"
                $0.value = "Overflow"
                $0.options = ["Overflow","Grates"]
                $0.add(rule: RuleRequired())
                }.cellUpdate{cell, row in
                    if !row.isValid {
                        cell.textLabel?.textColor = .red
                    }
        }
        
        if(restartedForm) {
            form.setValues(storedValue)
            print(storedValue)
            tableView.reloadData()
            
//            print("Restarted Value:")
//            print(form.values())
        }
    }
    
    convenience init() {
        self.init()
        initialize()
    }
    
    private func initialize() {
        let applyButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: .applyButtonPressed)
        navigationItem.rightBarButtonItem = applyButton
        view.backgroundColor = .white
    }
}

// MARK: - Selectors
extension Selector {
    fileprivate static let applyButtonPressed = #selector(CalcFormViewController.applyButtonPressed(_:))
}
