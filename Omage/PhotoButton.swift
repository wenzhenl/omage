//
//  PhotoButton.swift
//  Omage
//
//  Created by Wenzheng Li on 10/30/15.
//  Copyright © 2015 Wenzheng Li. All rights reserved.
//

import UIKit

@IBDesignable
class PhotoButton: UIButton {
    override func drawRect(rect: CGRect) {
        let color = UIColor(red: 0.88, green: 0.40, blue: 0.49, alpha: 1)
        color.set()
        let border = self.bounds.height * (1 - Settings.RatioOuterRectAndHeightForPhotoButton)
        let outerRect = UIBezierPath(roundedRect: CGRect(x: self.bounds.minX + border, y: self.bounds.minY + border, width: self.bounds.width - 2 * border, height: self.bounds.height - 2 * border), cornerRadius: Settings.CornerRadiusForPhotoButton)
        
        let innerBorder = self.bounds.height * (1 - Settings.RatioInnerRectAndHeightForPhotoButton)
        let topLeft = CGPoint(x: self.bounds.minX + innerBorder, y: self.bounds.minY + innerBorder)
        let topRight = CGPoint(x: self.bounds.maxX - innerBorder, y: self.bounds.minY + innerBorder)
        let bottomRight = CGPoint(x: self.bounds.maxX - innerBorder, y: self.bounds.maxY - innerBorder)
        let bottomLeft = CGPoint(x: self.bounds.minX + innerBorder, y: self.bounds.maxY - innerBorder)
        
        let anchorPoint1 = CGPoint(x: self.bounds.midX - 0.1 * self.bounds.width, y: self.bounds.minY + 0.3 * self.bounds.height)
        let anchorPoint2 = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let anchorPoint3 = CGPoint(x: self.bounds.midX + 0.1 * self.bounds.width, y: self.bounds.minY + innerBorder + 0.15 * self.bounds.height)
        let anchorPoint4 = CGPoint(x: self.bounds.maxX - innerBorder - 0.1 * self.bounds.width, y: self.bounds.minY + innerBorder + 0.4 * self.bounds.height)
        
        let midBottomLeft = CGPoint(x: self.bounds.minX + (border + innerBorder) / 2.0, y: self.bounds.maxY - (border + innerBorder) / 2.0)
        let midBottomRight = CGPoint(x: self.bounds.maxX - (border + innerBorder) / 2.0, y: self.bounds.maxY - (border + innerBorder) / 2.0)
        outerRect.moveToPoint(topLeft)
        outerRect.addLineToPoint(topRight)
        outerRect.addLineToPoint(bottomRight)
        outerRect.addLineToPoint(bottomLeft)
        outerRect.closePath()
        outerRect.usesEvenOddFillRule = true
        
        let innerHill = UIBezierPath()
        innerHill.moveToPoint(midBottomLeft)
        innerHill.addLineToPoint(anchorPoint1)
        innerHill.addLineToPoint(anchorPoint2)
        innerHill.addLineToPoint(anchorPoint3)
        innerHill.addLineToPoint(anchorPoint4)
        innerHill.addLineToPoint(midBottomRight)
        innerHill.closePath()
        innerHill.lineWidth = 3
        innerHill.stroke()
        
        outerRect.fill()
    }

}
