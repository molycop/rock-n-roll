//
//  ViewController.swift
//  GW
//
//  Created by Elnaz Taqizadeh on 2017-07-12.
//  Copyright © 2017 Elnaz Taqizadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BWWalkthroughViewControllerDelegate {

    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var shineView: ThreePointGradientView!
    
    
    @IBAction func showWalkthroughButtonPressed(_ sender: Any) {
        // Get view controllers and build the walkthrough
        let stb = UIStoryboard(name: "Main", bundle: nil)
        let walkthrough = stb.instantiateViewController(withIdentifier: "Walk0") as! BWWalkthroughViewController
        let page_one = stb.instantiateViewController(withIdentifier: "Walk1") as UIViewController
        let page_two = stb.instantiateViewController(withIdentifier: "Walk2") as UIViewController
        let page_three = stb.instantiateViewController(withIdentifier: "Walk3") as UIViewController
        let page_four = stb.instantiateViewController(withIdentifier: "Walk4") as UIViewController
        let page_five = stb.instantiateViewController(withIdentifier: "Walk5") as UIViewController
        let page_six = stb.instantiateViewController(withIdentifier: "Walk6") as UIViewController
        
        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.add(viewController:page_one)
        walkthrough.add(viewController:page_two)
        walkthrough.add(viewController:page_three)
        walkthrough.add(viewController:page_four)
        walkthrough.add(viewController:page_five)
        walkthrough.add(viewController:page_six)
        
        self.present(walkthrough, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLoadingScreen()
    }

    func showLoadingScreen() {
        loadingView.bounds.size.width = view.bounds.width
        loadingView.bounds.size.height = view.bounds.height
        loadingView.center = view.center
        loadingView.alpha = 1
        view.addSubview(loadingView)
        UIView.animate(withDuration: 4, animations: {self.loadingView.alpha = 0}) { (success) in
        }
    }
    
//    UIView.animate(withDuration: 1, delay: 0.2, options: [], animations: {
//    self.shineView.transform = CGAffineTransform(translationX: 0, y: -800)
//    }, completion: { (success) in
//    })
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCalcFormViewController" {
            _ = segue.destination as! CalcFormViewController
        }
    }
    
    func walkthroughCloseButtonPressed() {
        self.dismiss(animated: true, completion: nil )
    }
}

