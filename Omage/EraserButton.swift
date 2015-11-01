//
//  EraserButton.swift
//  Omage
//
//  Created by Wenzheng Li on 10/31/15.
//  Copyright © 2015 Wenzheng Li. All rights reserved.
//

import UIKit

@IBDesignable
class EraserButton: UIButton {
    override func drawRect(rect: CGRect) {
        let color = UIColor(red: 0.88, green: 0.40, blue: 0.49, alpha: 1.0)
        color.set()
        let border = self.bounds.height * (1 - Settings.RatioOuterRectAndHeightForEraserButton)
    
        let outline = UIBezierPath()
        let outTopLeft = CGPoint(x: self.bounds.minX, y: self.bounds.minY + border)
        let outTopRight = CGPoint(x: self.bounds.maxX, y: self.bounds.minY + border)
        let outBottomRight = CGPoint(x: self.bounds.maxX, y: self.bounds.maxY - border)
        let outBottomLeft = CGPoint(x: self.bounds.minX + 0.3 * self.bounds.width, y: self.bounds.maxY - border)
        let outMidLeft = CGPoint(x: self.bounds.minX, y: self.bounds.midY)
        
        outline.moveToPoint(outTopLeft)
        outline.addLineToPoint(outTopRight)
        outline.addLineToPoint(outBottomRight)
        outline.addLineToPoint(outBottomLeft)
        outline.addLineToPoint(outMidLeft)
        outline.closePath()
        outline.fill()
        
    
    }
    
}
