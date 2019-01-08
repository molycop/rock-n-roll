//
//  pdfViewController.swift
//  Rock&Roll
//
//  Created by Elnaz Taqizadeh on 2018-10-22.
//

import UIKit
import WebKit
import TPPDF

class pdfViewController: UIViewController, UINavigationControllerDelegate {
    var plotImage = UIImage()
    var url: URL?
    
    var inputValue: [String: Any?] = [:]
    
    var millName = ""
    var phi = ""
    var j = ""
    var power = ""
    
    var dbAzz = ""
    var dbBond = ""
    var dbNipp = ""
    var dballChal = ""
    var dbSag = ""
    
    var bondValue = ""
    var benValue = ""
    var guzValue = ""
    var mrValue = ""
    
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateResultPdf()
    }
    
    func generateResultPdf() {
        /* ---- Execution Metrics ---- */
        var startTime = Date()
        /* ---- Execution Metrics ---- */
        
        let document = PDFDocument(format: .a4)
        
        // Set document meta data
        document.info.title = "R&R Report"
        document.info.subject = "Rock & Roll Report Pdf"
        //document.info.ownerPassword = "Password123"
        
        // Set spacing of header and footer
        document.layout.space.header = 1
//        document.layout.space.footer = 1
        
        // Add an image and scale it down. Image will not be drawn scaled, instead it will be scaled down and compressed to save file size.
        // Also you can define a quality in percent between 0.0 and 1.0 which is the JPEG compression quality. This is applied if the option `compress` is set.
        let logoImage = PDFImage(image: UIImage(named: "app_report_background.jpg")!)
        document.addImage(image: logoImage)
    
        
        let titleStr = "Charge configuration " + self.millName + "\n\n"
        
        let titleTable = PDFTable()
        do {
            try titleTable.generateCells(
                data: [[titleStr]], alignments: [[.center]])
        } catch PDFError.tableContentInvalid(let value) {
            print("This type of object is not supported as table content: " + String(describing: (type(of: value))))
        } catch {
            print("Error while creating table: " + error.localizedDescription)
        }
        titleTable.widths = [0.998]
        
        
        let titleStyle = PDFTableStyleDefaults.simple
        let metsoBrightGreen = UIColor(red: 0.5137, green: 0.7882, blue: 0.3451, alpha: 1.0)
        
        titleStyle.footerStyle = PDFTableCellStyle(
            colors: (
                fill: metsoBrightGreen,
                text: UIColor.white
            ),
            borders: PDFTableCellBorders(left: PDFLineStyle.init(type: .dotted, color: UIColor.white),
                                         top: PDFLineStyle.init(type: .dotted, color: UIColor.white),
                                         right: PDFLineStyle.init(type: .dotted, color: UIColor.white),
                                         bottom: PDFLineStyle.init(type: .dotted, color: UIColor.white)),
            
            font: UIFont.systemFont(ofSize: 10)
        )
        
        titleStyle.footerCount = 12
        
        //table outline boarder
        titleStyle.outline = PDFLineStyle.none
        titleTable.style = titleStyle
        
        do {
            // Style each cell individually
            let colors = (fill: metsoBrightGreen, text: UIColor.white)
//            let lineStyle = PDFLineStyle(type: .none, color: UIColor.white, width: 1)
//            let lineStyle = PDFLineStyle.none
            let borders = PDFTableCellBorders(left: PDFLineStyle.init(type: .dotted, color: UIColor.white),
                                              top: PDFLineStyle.init(type: .dotted, color: UIColor.white),
                                              right: PDFLineStyle.init(type: .dotted, color: UIColor.white),
                                              bottom: PDFLineStyle.init(type: .dotted, color: UIColor.white))
            let font = UIFont.boldSystemFont(ofSize: 24)
            try titleTable.setCellStyle(row: 0, column: 0, style: PDFTableCellStyle(colors: colors, borders: borders, font: font))
        } catch PDFError.tableIndexOutOfBounds(let index, let length){
            // In case the index is out of bounds
            print("Requested cell is out of bounds! \(index) / \(length)")
        } catch {
            // General error handling in case something goes wrong.
            print("Error while setting cell style: " + error.localizedDescription)
        }
        document.addTable(table: titleTable)
        
        // Add some spacing below title
        document.addSpace(space: 1.0)
        
        
        // Set document font and document color. This will be used only for simple text until it is reset.
        document.setFont(font: UIFont.systemFont(ofSize: 8.0))
        document.setTextColor(color: UIColor.black)
        
        
        let section = PDFSection(columnWidths: [0.40, 0.715])
        section.columns[0].addImage(.center, image: PDFImage(image: self.plotImage, size: CGSize(width: 200, height: 260)))
        
       //Create a table
        let table = PDFTable()
        do {
            try table.generateCells(
                data:
                [
                    ["Mill speed", String(self.phi + " %")],
                    ["Mill fill", String(self.j + " %")],
                    ["Mill power", String(self.power + " kW")],
//                    ["Wear Rate", nil],
                    [nil, "Wear Rate"],
                    ["Bond", String(self.bondValue + " kg/kWh")],
                    ["Benavente", String(self.benValue + " kg/kWh")],
                    ["Guzman", String(self.guzValue + " kg/kWh")],
                    ["Martins Radziszewski", String(self.mrValue + " kg/kWh")],
//                    ["Media makeup size", nil],
                    [nil, "Media makeup size"],
                    ["Azzaroni", String(self.dbAzz + " mm")],
                    ["Bond", String(self.dbBond + " mm")],
                    ["Nipp", String(self.dbNipp + " mm")],
                    ["Allis Chalmers", String(self.dballChal + " mm")],
                    ["SAG", String(self.dbSag + " mm")]
                    ],
                alignments:
                [
                    [.right, .left],
                    [.right, .left],
                    [.right, .left],
                    [.right, .center],
                    [.right, .left],
                    [.right, .left],
                    [.right, .left],
                    [.right, .left],
                    [.right, .center],
                    [.right, .left],
                    [.right, .left],
                    [.right, .left],
                    [.right, .left],
                    [.right, .left]
                ])
        } catch PDFError.tableContentInvalid(let value) {
            print("This type of object is not supported as table content: " + String(describing: (type(of: value))))
        } catch {
            print("Error while creating table: " + error.localizedDescription)
        }
        table.widths = [0.430, 0.415]
        
        let tableStyle = PDFTableStyleDefaults.simple
        do {
            // Style each cell individually
            let leftColor = (fill: UIColor.white, text: UIColor.darkGray)
            //let clearLineStyle = PDFLineStyle(type: .none, color: UIColor.white, width: 1)
            let clearLineStyle = PDFLineStyle.none
            let borders = PDFTableCellBorders(left: clearLineStyle, top: clearLineStyle, right: clearLineStyle, bottom: clearLineStyle)
            let font = UIFont.systemFont(ofSize: 11)

            for i in 0...14{
                try table.setCellStyle(row: i, column: 0, style: PDFTableCellStyle(colors: leftColor, borders: borders, font: font))
            }
        } catch PDFError.tableIndexOutOfBounds(let index, let length){
            // In case the index is out of bounds
            print("Requested cell is out of bounds! \(index) / \(length)")
        } catch {
            // General error handling in case something goes wrong.
            print("Error while setting cell style: " + error.localizedDescription)
        }
        
        do {
            // Style each cell individually
            let metsoGreen = UIColor(red: 0, green: 0.3686, blue: 0.3412, alpha: 1.0)
            let lightGray = UIColor(red: 0.9176, green: 0.9176, blue: 0.9176, alpha: 1.0)
            let rightColor = (fill: lightGray, text: metsoGreen)
            let clearLineStyle = PDFLineStyle.none
            let borders = PDFTableCellBorders(left: clearLineStyle, top: clearLineStyle, right: clearLineStyle, bottom: clearLineStyle)
            let font = UIFont.systemFont(ofSize: 11)

            for i in 0...14{
                try table.setCellStyle(row: i, column: 1, style: PDFTableCellStyle(colors: rightColor, borders: borders, font: font))
            }
        } catch PDFError.tableIndexOutOfBounds(let index, let length){
            print("Requested cell is out of bounds! \(index) / \(length)")
        } catch {
            print("Error while setting cell style: " + error.localizedDescription)
        }
        
        //Wear Rate and Media Makeup Size Title
        let sbColor = (fill: UIColor.white, text: UIColor.darkGray)
        let sbClearLineStyle = PDFLineStyle.none
        let sbBorders = PDFTableCellBorders(left: sbClearLineStyle, top: sbClearLineStyle, right: sbClearLineStyle, bottom: sbClearLineStyle)
        let sbFont = UIFont.boldSystemFont(ofSize: 11)
        
        do {
            for j in 0...1 {
                try table.setCellStyle(row: 3, column: j, style: PDFTableCellStyle(colors: sbColor, borders: sbBorders, font: sbFont))
            }
        } catch PDFError.tableIndexOutOfBounds(let index, let length){
            print("Requested cell is out of bounds! \(index) / \(length)")
        } catch {
            print("Error while setting cell style: " + error.localizedDescription)
        }
        
        do {
            for j in 0...1 {
                try table.setCellStyle(row: 8, column: j, style: PDFTableCellStyle(colors: sbColor, borders: sbBorders, font: sbFont))
            }
        } catch PDFError.tableIndexOutOfBounds(let index, let length){
            print("Requested cell is out of bounds! \(index) / \(length)")
        } catch {
            print("Error while setting cell style: " + error.localizedDescription)
        }
        
        
        // Set table padding and margin
        table.padding = 4.0
        table.margin = 5.0

        //TABLE OUTLINE
        tableStyle.outline = PDFLineStyle.none
        table.style = tableStyle
        
        section.columns[1].addTable(table: table)
        document.addSection(section)
    
        document.addSpace(space: 5.0)
        
        document.addText(text: "©2018 Metso Corporation. All rights reserved.")
        document.addText(text: "Disclaimer text goes here... qui te dolo et autemqui atio cullabo. Sam que offici optaquia adio excerro blamust, sin nos as nate nem ut dus sit ad utem veri rerupta tinvent rerspel enderci endaerese volese inctecestio. Udanihi llabore sequodis non experor emquos velitatur, sectempos arumet inverumet fugit et velestotas magnitia sit que nonem.")
        
        
        // Insert page break
        // document.createNewPage()
        
        /* ---- Execution Metrics ---- */
        print("Preparation took: " + stringFromTimeInterval(interval: Date().timeIntervalSince(startTime)))
        startTime = Date()
        /* ---- Execution Metrics ---- */
        
        // Convert document to JSON String for debugging
        let _ = document.toJSON(options: JSONSerialization.WritingOptions.prettyPrinted) ?? "nil"
        //        print(json)
        do {
            // Generate PDF file and save it in a temporary file. This returns the file URL to the temporary file
            //set debug: false for removing dash borders
            self.url = try PDFGenerator.generateURL(document: document, filename: "RnRresult.pdf", progress: {
                (progressValue: CGFloat) in
                print("progress: ", progressValue)
            }, debug: false)
            
            // Load PDF into a webview from the temporary file
            self.webView.load(URLRequest(url: self.url!))
        } catch {
            print("Error while generating PDF: " + error.localizedDescription)
        }
        
        /* ---- Execution Metrics ---- */
        print("Generation took: " + stringFromTimeInterval(interval: Date().timeIntervalSince(startTime)))
        startTime = Date()
        /* ---- Execution Metrics ---- */
    }
    
    /**
     Used for debugging execution time.
     Converts time interval in seconds to String.
     */
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let ns = (interval * 10e8).truncatingRemainder(dividingBy: 10e5)
        let ms = (interval * 10e2).rounded(.towardZero)
        let seconds = interval.rounded(.towardZero)
        let minutes = (interval / 60).rounded(.towardZero)
        let hours = (interval / 3600).rounded(.towardZero)
        
        var result = [String]()
        if hours > 1 {
            result.append(String(format: "%.0f", hours) + "h")
        }
        if minutes > 1 {
            result.append(String(format: "%.0f", minutes) + "m")
        }
        if seconds > 1 {
            result.append(String(format: "%.0f", seconds) + "s")
        }
        if ms > 1 {
            result.append(String(format: "%.0f", ms) + "ms")
        }
        if ns > 0.001 {
            result.append(String(format: "%.3f", ns) + "ns")
        }
        return result.joined(separator: " ")
    }
    
    @IBAction func shareButtonDidPressed(_ sender: Any) {
        do {
            let data = try Data(contentsOf: self.url!)

            try data.write(to: self.url as! URL)

            let activitycontroller = UIActivityViewController(activityItems: [self.url], applicationActivities: nil)
            if activitycontroller.responds(to: #selector(getter: activitycontroller.completionWithItemsHandler))
            {
                activitycontroller.completionWithItemsHandler = {(type, isCompleted, items, error) in
                    if isCompleted
                    {
                        print("completed")
                    }
                }
            }
//
//            activitycontroller.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
//            activitycontroller.popoverPresentationController?.sourceView = self.view
//            self.present(activitycontroller, animated: true, completion: nil)
//
        }
        catch {
            print("Error while exporting Pdf!")
        }
//   }
        
        let activityVC = UIActivityViewController(activityItems: [self.url!], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    //MARK: Actions - Restart Button Action
    @IBAction func backButtonDidPressed(_ sender: Any) {
        
        //Instantiate secondViewController
        let plotVC = self.storyboard?.instantiateViewController(withIdentifier: "PlotViewController") as! PlotViewController
        
        plotVC.inputValue = self.inputValue
        
        //Takeuser to SecondViewController
        _ = navigationController?.pushViewController(plotVC, animated: true)
    }
    
    convenience init() {
        self.init()
        initialize()
    }
    
    
    private func initialize() {
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: .shareButtonDidPressed)
        navigationItem.rightBarButtonItem = shareButton
        
        let backButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: .backButtonDidPressed)
        navigationItem.leftBarButtonItem = backButton
        
        view.backgroundColor = .white
    }
    
}

// MARK: - Selectors
extension Selector {
    fileprivate static let shareButtonDidPressed = #selector(pdfViewController.shareButtonDidPressed(_:))
}
extension Selector {
    fileprivate static let backButtonDidPressed = #selector(pdfViewController.backButtonDidPressed(_:))
}
