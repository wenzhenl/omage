//
//  SimpleImageProcessor.swift
//  Omage
//
//  Created by Wenzheng Li on 10/30/15.
//  Copyright © 2015 Wenzheng Li. All rights reserved.
//  Read documentation about Quartz 2D to further understand

import Foundation
class SimpleImageProcessor {
    
    static func createARGBBitmapContext(imageRef : CGImageRef) -> CGContextRef! {
        let pixelWidth = CGImageGetWidth(imageRef);
        let pixelHeight = CGImageGetHeight(imageRef);
        let bitmapBytesPerRow = (pixelWidth * 4)
        let bitmapByteCount = (bitmapBytesPerRow * pixelHeight)
        
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()!
        
        let bitmapData:UnsafeMutablePointer<Void> = malloc(bitmapByteCount)
        if bitmapData == nil {
            return nil
        }
        
//        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        let context:CGContextRef = CGBitmapContextCreate(bitmapData, pixelWidth, pixelHeight, 8, bitmapBytesPerRow, colorSpace, CGImageAlphaInfo.PremultipliedFirst.rawValue)! //| CGBitmapInfo.ByteOrder32Big.rawValue)!
        return context
    }
    
    static func makeTransparent(imageRef : CGImageRef, isBlack: Bool) -> UIImage? {
        let context = self.createARGBBitmapContext(imageRef)
        let width:Int  = Int(CGImageGetWidth(imageRef))
        let height:Int = Int(CGImageGetHeight(imageRef))
        let rect = CGRectMake(0, 0, CGFloat(width), CGFloat(height))
        
        CGContextDrawImage(context, rect, imageRef)
        
        let data: UnsafeMutablePointer<Void> = CGBitmapContextGetData(context)
        let dataType = UnsafeMutablePointer<UInt8>(data)
        
        var red, green, blue:UInt8
        var base, offset:Int
        
        for y in 0...(height - 1) {
            
            base = y * height * 4
            for x in 0...(width - 1) {
                
                offset = base + x * 4
                
//                alpha = dataType[offset]
                red   = dataType[offset + 1]
                green = dataType[offset + 2]
                blue  = dataType[offset + 3]

//                print(alpha,red,green,blue)
                if red > 200 && green > 200 && blue > 200 {
//                    print(red)
                    dataType[offset + 1] = 0
                    dataType[offset + 2] = 0
                    dataType[offset + 3] = 0
                    dataType[offset] = 0
                } else {
                    if !isBlack {
                        dataType[offset + 1] = 255
                        dataType[offset + 2] = 255
                        dataType[offset + 3] = 255
                        dataType[offset] = 255
                    }
                }
            }
        }
        
        let imageRef = CGBitmapContextCreateImage(context)
        
        let newImage = UIImage(CGImage: imageRef!)
        
        free(data)
        return newImage
    }
}