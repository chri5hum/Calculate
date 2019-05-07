//
//  ViewController.swift
//  Calculator
//
//  Created by Chris Hum on 2018-10-15.
//  Copyright © 2018 Chris Hum. All rights reserved.


import UIKit //module

extension Dictionary where Key: Equatable {
    func containsValue(key : Key) -> Bool {
        return self.contains { $0.0 == key }
    }
}


class CalculatorViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        splitViewController?.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet weak var displayDescription: UILabel!
    
    private var userIsInTheMiddleOfTyping = false;
    
    //could add more to this later
    private var variableDictionary: Dictionary<String, Double> = [
        "M" : 0
    ]
    
    
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        
        
        let digit = sender.currentTitle!
        
        
        if (userIsInTheMiddleOfTyping == false || display.text! == "0") {
            display.text = digit
        } else {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        }
        userIsInTheMiddleOfTyping = true
        
        
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
        print("saved")
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            print("restored")
            brain.program = savedProgram!
            //reevaluate
            displayDescriptionValue = brain.descriptionString
            displayValue = brain.result
        }
    }
    
    
    
    private var brain = CalculatorBrain()
    
    @IBAction func undo() {
        if (userIsInTheMiddleOfTyping && display.text!.count > 0) {
            display.text = String(display.text!.dropLast())
        } else {
            brain.undo()
            displayValue = brain.result
            displayDescriptionValue = brain.descriptionString
        }
    }
    
    @IBAction private func assignVariable(_ sender: UIButton) {
        variableDictionary["M"] = displayValue
        displayValue = brain.evaluate(using: variableDictionary).result
        displayDescriptionValue = brain.evaluate(using: variableDictionary) .description
    }
    
    @IBAction func clearButton() {
        brain.clear()
        displayValue = brain.result
        displayDescriptionValue = ""
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if (userIsInTheMiddleOfTyping == true) { //should later make m a digit
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if variableDictionary.containsValue(key: sender.currentTitle!) {
            brain.setOperand(variableName: sender.currentTitle!)
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
        }
        displayValue = brain.evaluate(using:  variableDictionary).result //idk if better way to do this
        displayDescriptionValue = brain.evaluate(using: variableDictionary).description
    }
    
    
    private var displayValue: Double { //theres gotta be a better way to do this than using margin of error
        //curly braces mean computed property
        get {
            return Double(display.text!)!
        }
        set{
            if((newValue-floor(newValue))<0.0000000001){
                display.text = String(Int(newValue))
            } else {
                display.text = String(newValue)
            }
            //            display.text = String(newValue)
            
            //new value is a keyword for the double that someone sets
        }
    }
    
    private var displayDescriptionValue: String {
        get {
            return displayDescription.text!
        }
        set {
            displayDescription.text = brain.descriptionString
        }
    }
    
    
    //do this later, finish the evaluate function
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(!brain.evaluate(using: variableDictionary).pending) {
            var destinationvc = segue.destination
            
            if let navcon = destinationvc as? UINavigationController {
                destinationvc = navcon.visibleViewController ?? destinationvc
            }
            
            if let graphvc = destinationvc as? GraphViewController {
                if let identifier = segue.identifier { //idk wtf is going on, but just put everything inside here
                    //set expression used in graph
                    graphvc.program = brain.program
                    graphvc.navigationItem.title = displayDescriptionValue
                }
                
                
            }
            
            
        }
    }
    
}
