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
    private var isPressed = false
    
    func flipState() {
        isPressed = !isPressed
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        let color = UIColor(red: 0.1, green: 0.5, blue: 0.6, alpha: 0.8)
        color.set()
        let border = self.bounds.height * (1 - Settings.RatioOuterRectAndHeightForEraserButton)
    
        let outline = UIBezierPath()
        let outTopLeft = CGPoint(x: self.bounds.minX, y: self.bounds.minY + border)
        let outTopRight = CGPoint(x: self.bounds.maxX, y: self.bounds.minY + border)
        let outBottomRight = CGPoint(x: self.bounds.maxX, y: self.bounds.maxY - border)
        let outBottomLeft = CGPoint(x: self.bounds.minX + 0.2 * self.bounds.width, y: self.bounds.maxY - border)
        let outMidLeft = CGPoint(x: self.bounds.minX, y: self.bounds.midY + 5)
        
        let lineWidth = CGFloat(3)
        
        let lTopLeft = CGPoint(x: self.bounds.minX + lineWidth, y: self.bounds.minY + border + lineWidth)
        let lTopRight = CGPoint(x: self.bounds.midX - 0.1 * self.bounds.width, y: self.bounds.minY + border + lineWidth)
        let lBottomRight = CGPoint(x: self.bounds.midX - 0.1 * self.bounds.width, y: self.bounds.maxY - border - lineWidth)
        let lBottomLeft = CGPoint(x: self.bounds.minX + 0.2 * self.bounds.width + 2.0, y: self.bounds.maxY - border - lineWidth)
        let lMidLeft = CGPoint(x: self.bounds.minX + lineWidth, y: self.bounds.midY + 3.0)
        
        let rTopLeft = CGPoint(x: self.bounds.midX - 0.1 * self.bounds.width + lineWidth, y: self.bounds.minY + border + lineWidth)
        let rTopRight = CGPoint(x: self.bounds.maxX - lineWidth, y: self.bounds.minY + border + lineWidth)
        let rBottomRight = CGPoint(x: self.bounds.maxX - lineWidth, y: self.bounds.maxY - border - lineWidth)
        let rBottomLeft = CGPoint(x: self.bounds.midX - 0.1 * self.bounds.width + lineWidth, y: self.bounds.maxY - border - lineWidth)
        
        outline.moveToPoint(outTopLeft)
        outline.addLineToPoint(outTopRight)
        outline.addLineToPoint(outBottomRight)
        outline.addLineToPoint(outBottomLeft)
        outline.addLineToPoint(outMidLeft)
        outline.closePath()
        
        outline.moveToPoint(lTopLeft)
        outline.addLineToPoint(lTopRight)
        outline.addLineToPoint(lBottomRight)
        outline.addLineToPoint(lBottomLeft)
        outline.addLineToPoint(lMidLeft)
        outline.closePath()
        if !isPressed {
            outline.moveToPoint(rTopLeft)
            outline.addLineToPoint(rTopRight)
            outline.addLineToPoint(rBottomRight)
            outline.addLineToPoint(rBottomLeft)
            outline.closePath()
        }
        
        outline.usesEvenOddFillRule = true
        
        outline.fill()
        
    
    }
    
}
