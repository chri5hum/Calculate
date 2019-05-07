//
//  GraphView.swift
//  Calculator
//
//  Created by Chris Hum on 2019-02-09.
//  Copyright © 2019 Chris Hum. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    @IBInspectable
    var scale: CGFloat = 0.90 { didSet { setNeedsDisplay() } }
    //    @IBInspectable
    //    var origin: CGPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)    { didSet { setNeedsDisplay() }}
    
    @IBInspectable var color: UIColor = UIColor.blue        { didSet { setNeedsDisplay() }}
    @IBInspectable var axesColor: UIColor = UIColor.black   { didSet { setNeedsDisplay() }}
    @IBInspectable var lineWidth: CGFloat = 2.0 { didSet { setNeedsDisplay() }}
    
    var savedProgram: CalculatorBrain.PropertyList?
    private var brain = CalculatorBrain()
    
    private var graphDictionary: Dictionary<String, Double> = [
        "M" : 0
    ]
    
    
    override func draw(_ rect: CGRect) {
        
        let pointsPerUnit: CGFloat = 50
        let localContentScaleFactor = 100
        let origin = CGPoint(x:bounds.midX, y:bounds.midY)
        
        //test circle
        /*
         let radius = min(bounds.size.width, bounds.size.height)/2
         let center = CGPoint(x:bounds.midX, y:bounds.midY)
         
         let circle = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0.0, endAngle: CGFloat(2*Double.pi), clockwise: true)
         color.set()
         circle.stroke()
         */
        //
        
        
        let axesDrawer = AxesDrawer()
        //        axesDrawer.drawBasicCircle(bounds: bounds, origin: origin)
        axesDrawer.drawAxesInRect(bounds: bounds, origin: origin, pointsPerUnit: pointsPerUnit)
        
        if(savedProgram != nil) {
            drawFx(bounds: bounds, origin: origin, pointsPerUnit: pointsPerUnit, savedProgram: savedProgram);
        }
        
    }
    
    func drawFx(bounds: CGRect, origin: CGPoint, pointsPerUnit: CGFloat, savedProgram: CalculatorBrain.PropertyList?) { //make this function
        brain.program = savedProgram!
        let path = UIBezierPath()
        //        graphDictionary.keys.forEach {graphDictionary[$0] = 0.0}  //changes all values to 0
        //evaluate, changing variable values in for loop
        var x = bounds.minX
        var y: CGFloat
        graphDictionary.keys.forEach {graphDictionary[$0] = Double(x-207.0)}  //changes all values to 0
        
        y = CGFloat(brain.evaluate(using: graphDictionary).result)
        if(!y.isNaN) { path.move(to: CGPoint(x: x, y: y)) }
        while(x < bounds.maxX) {
            graphDictionary.keys.forEach {graphDictionary[$0] = Double((x-207.0)/pointsPerUnit)}
            y = origin.y - CGFloat(brain.evaluate(using: graphDictionary).result) * pointsPerUnit
            if(!y.isNaN) {
                path.addLine(to: CGPoint(x: x, y: y))
                path.move(to: CGPoint(x: x, y: y)) //for single sided functions (ln, sqrt)
            }
//                        path.addLine(to: CGPoint(x: origin.x, y: origin.y)) //debugging when drawn out of the picture
                        print(x)
                        print(CGFloat(brain.evaluate(using: graphDictionary).result))
            x += 1 //increment
        }
        path.stroke()
        
        
        
    }
    //        let path = UIBezierPath()
    //graph y = x - straight line
    //        path.move(to: CGPoint(x:bounds.midX, y: bounds.midY))
    //        path.addLine(to: CGPoint(x:bounds.maxX, y: bounds.maxY))
    
    //graph y = x^2
    //        path.move(to: CGPoint
    //        path.stroke()
}



/*
 // Only override draw() if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 override func draw(_ rect: CGRect) {
 // Drawing code
 }
 */
