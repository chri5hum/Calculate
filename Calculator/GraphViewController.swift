//
//  GraphViewController.swift
//  Calculator
//
//  Created by Chris Hum on 2019-02-09.
//  Copyright © 2019 Chris Hum. All rights reserved.
//

import UIKit


class GraphViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //        navigationItem.title = brain.evaluate
    }
    
    //gesture recognizers
    
    
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    
    var program: CalculatorBrain.PropertyList? {
        get{
            return savedProgram //should be smth that just calls itself
        }
        set {
            savedProgram = newValue
            updateUI()
        }
    }
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            //add gesture recognizers here:
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: #selector(GraphView.changeScale)))
            updateUI()
        }
    }
    
    
    
    private func updateUI() {
        if graphView != nil {
            graphView.savedProgram = savedProgram
        }
    }
    
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
