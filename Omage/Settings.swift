//
//  Constants.swift
//  Alyssa
//
//  Created by Wenzheng Li on 10/20/15.
//  Copyright © 2015 Wenzheng Li. All rights reserved.
//

import Foundation
import UIKit

class Settings {
    
    // MARK - parameters for gestures
    static let GestureScaleForMovingHandwritting = CGFloat(2.0)
    
    // MARK - parameters for color
    static let avaiableHandwrittingColors =
    [   UIColor(red: 1.0, green: 153.0/255.0, blue: 51/255.0, alpha: 1.0),
        UIColor(red: 0, green: 0, blue: 0, alpha: 1.0),
        UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        UIColor(red: 0.0078, green: 0.517647, blue: 0.5098039, alpha: 1.0),
        UIColor(red: 0, green: 0.4, blue: 0.6, alpha: 1.0),
        UIColor(red: 1.0, green: 0.4, blue: 0, alpha: 1.0)
    ]
    
    // MARK - color for header
    static let ColorForHeader = UIColor(red: 13.0/255.0, green: 82.0/255.0, blue: 145.0/255.0, alpha: 1.0)
}
