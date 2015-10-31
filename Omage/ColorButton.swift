//
//  ColorButton.swift
//  Omage
//
//  Created by Wenzheng Li on 10/31/15.
//  Copyright © 2015 Wenzheng Li. All rights reserved.
//
import UIKit

@IBDesignable
class ColorButton: UIButton {
    
    override func drawRect(rect: CGRect) {
        
        let innerFilledCircle = UIBezierPath(arcCenter: CGPoint(x: self.bounds.midX, y: self.bounds.midY), radius: self.bounds.height/2 * Settings.RatioInnerCircleAndHeightForCameraButton, startAngle: 0, endAngle: 360, clockwise: true)
        
        let color = UIColor(red: 0.27, green: 0.67, blue: 0.08, alpha: 0.9)
        color.setFill()
        innerFilledCircle.fill()
        
        
        let outerCircle = UIBezierPath(arcCenter: CGPoint(x: self.bounds.midX, y: self.bounds.midY), radius: self.bounds.height/2 * Settings.RatioOuterCircleAndHeightForCameraButton, startAngle: 0, endAngle: 360, clockwise: true)
        color.setStroke()
        outerCircle.lineWidth = 3
        outerCircle.stroke()
    }
}
