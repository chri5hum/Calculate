
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Chris Hum on 2018-10-25.
//  Copyright © 2018 Chris Hum. All rights reserved.

//model
//done - calculator used evaluate func over and over
//done - accumulator used to set
//done - evaluate - loop through list of expression literals

//bug list:


import Foundation
//supposed to be ui independent, so dont import uikit

class CalculatorBrain {
    
    
    private var accumulator = 0.0 {
        didSet {didResetAccumulator = true}
    }
    
    private var internalProgram = [AnyObject]() //array with double or string (thus must be anyObject)
    fileprivate var expression = [ExpressionLiteral]()
    
    //    var description = ""
    private var isPartialResult = false //bascially determines whether to use "=" or "..." in description, replace with pending in
    private var afterUnary = false; //replace this with didResetAccumulator
    
    //func evaluate
    //result is the numerical result
    //pending true if waiting on equal sign
    //description based on expression array
    
    
    //function with optional parameter, default value nil
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double, pending: Bool, description: String) { //store the dictionary in the view controller
        //start with internal program - later change this to an array of expression literals
        let brain = CalculatorBrain()
        
        //do some order of operations here
        for expressionLiteral in expression { //cant take from anyobject for some reason
            switch expressionLiteral {
            case .operand(let operand):
                switch operand {
                case .variable(let variableName):
                    brain.accumulator = variables?[variableName] ?? 0
                    brain.setOperand(variableName: variableName)
                    
                case .value(let operandValue):
                    brain.setOperand(operand: operandValue)
                }
                
            case .operation(let operation):
                //order of operations here???
                brain.performOperation(symbol: operation)
            }
        }
        return (brain.accumulator, brain.pending != nil, brain.describe())
    }
    
    private func describe() -> String {
        var descriptionString = ""
        for expressionLiteral in expression {
            switch expressionLiteral {
            case.operand(let operand):
                switch operand {
                case .variable(let variableName):
                    descriptionString.append(variableName)
                case .value(let operandValue): descriptionString.append(String(intOrDouble(number: operandValue)))
                }
            case .operation(let operation):
                guard let operationString = operations[operation] else {break}
                switch operationString {
                    
                case .UnaryOperation:
                    descriptionString = operation + "(" + descriptionString + ")"
                case .Equals:
                    //do nothing
                    break
                default:
                    descriptionString.append(operation)
                }
            }
        }
        return descriptionString
    }
    
    //should be a better way to do this
    private func intOrDouble(number: Double) -> String {
        if (floor(number) == ceil(number)){
            return String(Int(number))
        } else {
            return String(number)
        }
    }
    
    func clear() {
        accumulator = 0
        pending = nil
        expression.removeAll()
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        expression.append(.operand(.value(operand)))
    }
    
    func setOperand(variableName: String){
        expression.append(.operand(.variable(variableName)))
    }
    
    func undo() { //change this
        if expression.count > 0 {
            expression.removeLast()
        }
    }
    
    fileprivate enum ExpressionLiteral {
        case operation(String)
        case operand(Operand)
        
        enum Operand {
            case variable(String)
            case value(Double)
        }
    }
    
    fileprivate var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(Double.pi),
        "e" : Operation.Constant(M_E), //M_E,
        "√" : Operation.UnaryOperation(sqrt), //sqrt
        "cos": Operation.UnaryOperation(cos), //cos
        "±": Operation.UnaryOperation({ -$0 }),
        "ln": Operation.UnaryOperation(log),
        //                "×": Operation.BinaryOperation({ (op1: Double , op2: Double) -> Double in
        //                    return op1*op2}),
        //called a closure, basically the same as a function, but curly braces around the arguments and return
        //after type inferencing
        "×": Operation.BinaryOperation({$0 * $1}),
        "÷": Operation.BinaryOperation({$0 / $1}),
        "+": Operation.BinaryOperation({$0 + $1}),
        "−": Operation.BinaryOperation({$0 - $1}),
        "=": Operation.Equals,
        
        ]
    fileprivate enum Operation {
        //in swift, enums are like classes (can have methods, cannot store vars, cannot inherit)
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double)-> Double)
        case Equals
    }
    private var didResetAccumulator = true
    
    func performOperation(symbol: String) {
        guard let operation = operations[symbol]  else { return }
        switch operation {
        case .Constant(let value):
            //            expression.append(.operation(symbol))
            accumulator = value
            
        case .UnaryOperation(let function):
            //            expression.append(.operation(symbol))
            accumulator = function(accumulator)
            
        case .BinaryOperation(let function):
            //            expression.append(.operation(symbol))
            executePendingBinaryOperation()
            pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator) //when click plus, instance of struct created, first operand stored
            
        case .Equals:
            executePendingBinaryOperation()
        }
        //        if(didResetAccumulator) {
        expression.append(.operation(symbol))
        
        
        
        
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private func executePendingBinaryOperation() {
        if (pending != nil) {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get{
            return expression as CalculatorBrain.PropertyList
            //returning a pointer, not a copy (bc its a value type)
        }
        set {
            clear()
            expression = newValue as! [ExpressionLiteral]
            //            if let arrayOfOps = newValue as? [AnyObject] {
            //                for op in arrayOfOps {
            //                    if let operand = op as? Double {
            //                        setOperand(operand: operand)
            //                    } else if let operation = op as? String {
            //                        performOperation(symbol: operation)
            //                    }
            //                }
            //            }
            
        }
    }
    
    
    var result: Double {
        get{
            return evaluate().result
        }
        //read only, no setter
    }
    
    var descriptionString: String {
        get {
            if (evaluate().pending){
                return evaluate().description + "..."
            } else if(evaluate().pending == false){
                if(expression.count > 0) {
                    return evaluate().description + "="
                } else { return "" }
            } else {
                return evaluate().description
            }
        }
    }
    
}
