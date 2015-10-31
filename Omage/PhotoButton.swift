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
        let color = UIColor(red: 0.88, green: 0.40, blue: 0.49, alpha: 0.8)
        color.setFill()
        let border = self.bounds.height * (1 - Settings.RatioOuterRectAndHeightForPhotoButton)
        let outerRect = UIBezierPath(roundedRect: CGRect(x: self.bounds.minX + border, y: self.bounds.minY + border, width: self.bounds.width - 2 * border, height: self.bounds.height - 2 * border), cornerRadius: Settings.CornerRadiusForPhotoButton)
        outerRect.fill()
        
        UIColor.whiteColor().setFill()
        let innerBorder = self.bounds.height * (1 - Settings.RatioInnerRectAndHeightForPhotoButton)
        let innerRect = UIBezierPath(roundedRect: CGRect(x: self.bounds.minX + innerBorder, y: self.bounds.minY + innerBorder, width: self.bounds.width - 2 * innerBorder, height: self.bounds.height - 2 * innerBorder), cornerRadius: Settings.CornerRadiusForPhotoButton)
        innerRect.fill()
    }

}
