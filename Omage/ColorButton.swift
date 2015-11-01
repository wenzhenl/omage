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
        let colors = [UIColor(red: 0.0078, green: 0.517647, blue: 0.5098039, alpha: 0.8),
                      UIColor(red: 0, green: 0.4, blue: 0.6, alpha: 0.8),
                      UIColor(red: 1.0, green: 0.4, blue: 0, alpha: 0.8)]
    
        let origin = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        
        let radius = self.bounds.height/2 * Settings.RatioOuterCircleAndHeightForColorButton
        for i in 0..<3 {
            let sector = UIBezierPath()
            sector.addArcWithCenter(origin, radius: radius, startAngle: CGFloat(Double(i) * 2.0 * M_PI / 3.0)  + CGFloat(M_PI / 6.0), endAngle: CGFloat( Double(i+1) * 2.0 * M_PI / 3.0)  + CGFloat(M_PI / 6.0), clockwise: true)
            sector.closePath()
            colors[i].setFill()
            sector.fill()
        }
    }
}
