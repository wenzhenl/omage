//
//  SimpleImageProcessor.swift
//  Omage
//
//  Created by Wenzheng Li on 10/30/15.
//  Copyright © 2015 Wenzheng Li. All rights reserved.
//  Read documentation about Quartz 2D to further understand

import UIKit

class ImageCutoutFilter {
    
    static func createARGBBitmapContext(imageRef: CGImageRef) -> CGContextRef? {
        
        let width = CGImageGetWidth(imageRef)
        let height = CGImageGetHeight(imageRef)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let rawdata: UnsafeMutablePointer<Void> = malloc(bytesPerRow * height)
        if rawdata == nil {
            print("cannot malloc memory")
            return nil
        }
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        let context = CGBitmapContextCreate(rawdata, width, height, bitsPerComponent, bytesPerRow, colorSpace,
            CGBitmapInfo.ByteOrder32Big.rawValue | bitmapInfo.rawValue)
        
        return context
    }
    
    static func createARGBBitmapContextWithSize(size: CGSize) -> CGContextRef? {
        
        let width = Int(size.width)
        let height = Int(size.height)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let rawdata: UnsafeMutablePointer<Void> = malloc(bytesPerRow * height)
        if rawdata == nil {
            print("cannot malloc memory")
            return nil
        }
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        let context = CGBitmapContextCreate(rawdata, width, height, bitsPerComponent, bytesPerRow, colorSpace,
            CGBitmapInfo.ByteOrder32Big.rawValue | bitmapInfo.rawValue)
        
        return context
    }

    static func createBitmapRawdataFromRef(refImage: UIImage?) -> UnsafeMutablePointer<UInt8>? {
        if let refImage = refImage {
            let imageRef = refImage.CGImage
            if let context = createARGBBitmapContext(imageRef!) {
                let width = CGImageGetWidth(imageRef)
                let height = CGImageGetHeight(imageRef)
                
                // draw image on the context
                CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), imageRef)
                let rawdata = UnsafeMutablePointer<UInt8>(CGBitmapContextGetData(context))
                return rawdata
            }
        }
        return nil
    }
    
    static func cutImageOutOriginalColor(image: UIImage?) -> UIImage? {
        if let image = image {
            var imageRef = image.CGImage
            
            // create the ref image by converting the image to grey version with Gaussion blur and Otuz threshold
            let refImage = OpenCV.magicallyExtractChar(image)
            
            // create the working context
            if let context = createARGBBitmapContext(imageRef!) {
                
                let width = CGImageGetWidth(imageRef)
                let height = CGImageGetHeight(imageRef)
                
                // draw image on the context
                CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), imageRef)
                let rawdata = UnsafeMutablePointer<UInt8>(CGBitmapContextGetData(context))
                
                if let refRawdata = createBitmapRawdataFromRef(refImage) {
                    if width != CGImageGetWidth(refImage!.CGImage) {
                        print("serious error, the image and its ref must be consistent")
                        return nil
                    }
                    
                    if height != CGImageGetHeight(refImage!.CGImage) {
                        print("serious error, the image and its ref must be consistent")
                        return nil
                    }
                    
                    // make all white pixels transparent
                    // keep other pixels their original color
                    var byteIndex = 0
                    for _ in 0 ..< width * height {
                        let componentForClearColor: UInt8 = 0
                        let red: UInt8 = refRawdata[byteIndex+1]
                        let green: UInt8 = refRawdata[byteIndex+2]
                        let blue: UInt8 = refRawdata[byteIndex+3]
                        if red > 200 && green > 200 && blue > 200 {
                            rawdata[byteIndex] = componentForClearColor
                            rawdata[byteIndex+1] = componentForClearColor
                            rawdata[byteIndex+2] = componentForClearColor
                            rawdata[byteIndex+3] = componentForClearColor
                        }
                        byteIndex += 4
                    }
                    free(refRawdata)
                }
                
                imageRef = CGBitmapContextCreateImage(context)
                free(rawdata)
                return UIImage(CGImage: imageRef!)
            }
        }
        return nil
    }
    
    static func cutImageOutOriginalColorInverted(image: UIImage?) -> UIImage? {
        if let image = image {
            var imageRef = image.CGImage
            
            // create the ref image by converting the image to grey version with Gaussion blur and Otuz threshold
            let refImage = OpenCV.magicallyExtractChar(image)
            
            // create the working context
            if let context = createARGBBitmapContext(imageRef!) {
                
                let width = CGImageGetWidth(imageRef)
                let height = CGImageGetHeight(imageRef)
                
                // draw image on the context
                CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), imageRef)
                let rawdata = UnsafeMutablePointer<UInt8>(CGBitmapContextGetData(context))
                
                if let refRawdata = createBitmapRawdataFromRef(refImage) {
                    if width != CGImageGetWidth(refImage!.CGImage) {
                        print("serious error, the image and its ref must be consistent")
                        return nil
                    }
                    
                    if height != CGImageGetHeight(refImage!.CGImage) {
                        print("serious error, the image and its ref must be consistent")
                        return nil
                    }
                    
                    // make all white pixels transparent
                    // keep other pixels their original color
                    var byteIndex = 0
                    for _ in 0 ..< width * height {
                        let componentForClearColor: UInt8 = 0
                        let red: UInt8 = refRawdata[byteIndex+1]
                        let green: UInt8 = refRawdata[byteIndex+2]
                        let blue: UInt8 = refRawdata[byteIndex+3]
                        if red < 100 && green < 100 && blue < 100 {
                            rawdata[byteIndex] = componentForClearColor
                            rawdata[byteIndex+1] = componentForClearColor
                            rawdata[byteIndex+2] = componentForClearColor
                            rawdata[byteIndex+3] = componentForClearColor
                        }
                        byteIndex += 4
                    }
                    free(refRawdata)
                }
                
                imageRef = CGBitmapContextCreateImage(context)
                free(rawdata)
                return UIImage(CGImage: imageRef!)
            }
        }
        return nil
    }

    static func cutImageOutWithColor(refImage: UIImage?, color: UIColor?) -> UIImage? {
        
        if color != nil {
            if CGColorGetNumberOfComponents(color!.CGColor) != 4 {
                print("Cannot handle non-RGBA color")
                return refImage
            }
        }
        
        if var image = refImage {
            // create the ref image by converting the image to grey version with Gaussion blur and Otuz threshold
            image = OpenCV.magicallyExtractChar(image)
            
            var imageRef = image.CGImage
            
            // create the working context
            if let context = createARGBBitmapContext(imageRef!) {
                
                let width = CGImageGetWidth(imageRef)
                let height = CGImageGetHeight(imageRef)
                
                // draw image on the context
                CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), imageRef)
                let rawdata = UnsafeMutablePointer<UInt8>(CGBitmapContextGetData(context))
                
                // make all white pixels transparent
                // keep other pixels based on designated color
                var byteIndex = 0
                
                let componentForClearColor: UInt8 = 0
                
                for _ in 0 ..< width * height {
//                    let alpha: UInt8 = rawdata[byteIndex]
                    let red: UInt8 = rawdata[byteIndex+1]
                    let green: UInt8 = rawdata[byteIndex+2]
                    let blue: UInt8 = rawdata[byteIndex+3]
                    
                    if red > 200 && green > 200 && blue > 200 {
                        rawdata[byteIndex] = componentForClearColor
                        rawdata[byteIndex+1] = componentForClearColor
                        rawdata[byteIndex+2] = componentForClearColor
                        rawdata[byteIndex+3] = componentForClearColor
                    } else {
                        if let color = color {
                            // color should be in RGBA format
                            let colorData = CGColorGetComponents(color.CGColor)
                            rawdata[byteIndex] = UInt8(colorData[3] * 255) // alpha
                            rawdata[byteIndex+1] = UInt8(colorData[0] * 255) // red
                            rawdata[byteIndex+2] = UInt8(colorData[1] * 255) // green
                            rawdata[byteIndex+3] = UInt8(colorData[2] * 255) // blue
                        }
                    }
                    byteIndex += 4
                }
                
                imageRef = CGBitmapContextCreateImage(context)
                free(rawdata)
                return UIImage(CGImage: imageRef!)
            }
        }
        return nil
    }
    
    static func cutImageOutWithColorInverted(refImage: UIImage?, color: UIColor?) -> UIImage? {
        
        if color != nil {
            if CGColorGetNumberOfComponents(color!.CGColor) != 4 {
                print("Cannot handle non-RGBA color")
                return refImage
            }
        }
        
        if var image = refImage {
            // create the ref image by converting the image to grey version with Gaussion blur and Otuz threshold
            image = OpenCV.magicallyExtractChar(image)
            
            var imageRef = image.CGImage
            
            // create the working context
            if let context = createARGBBitmapContext(imageRef!) {
                
                let width = CGImageGetWidth(imageRef)
                let height = CGImageGetHeight(imageRef)
                
                // draw image on the context
                CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), imageRef)
                let rawdata = UnsafeMutablePointer<UInt8>(CGBitmapContextGetData(context))
                
                // make all white pixels transparent
                // keep other pixels based on designated color
                var byteIndex = 0
                
                let componentForClearColor: UInt8 = 0
                
                for _ in 0 ..< width * height {
                    //                    let alpha: UInt8 = rawdata[byteIndex]
                    let red: UInt8 = rawdata[byteIndex+1]
                    let green: UInt8 = rawdata[byteIndex+2]
                    let blue: UInt8 = rawdata[byteIndex+3]
                    
                    if red < 100 && green < 100 && blue < 100 {
                        rawdata[byteIndex] = componentForClearColor
                        rawdata[byteIndex+1] = componentForClearColor
                        rawdata[byteIndex+2] = componentForClearColor
                        rawdata[byteIndex+3] = componentForClearColor
                    } else {
                        if let color = color {
                            // color should be in RGBA format
                            let colorData = CGColorGetComponents(color.CGColor)
                            rawdata[byteIndex] = UInt8(colorData[3] * 255) // alpha
                            rawdata[byteIndex+1] = UInt8(colorData[0] * 255) // red
                            rawdata[byteIndex+2] = UInt8(colorData[1] * 255) // green
                            rawdata[byteIndex+3] = UInt8(colorData[2] * 255) // blue
                        }
                    }
                    byteIndex += 4
                }
                
                imageRef = CGBitmapContextCreateImage(context)
                free(rawdata)
                return UIImage(CGImage: imageRef!)
            }
        }
        return nil
    }

    static func changeImageFromOldColorToNewColor(refImage: UIImage?, oldColor: UIColor?, newColor: UIColor?) -> UIImage? {
    
        if let image = refImage {
            
            var imageRef = image.CGImage
            
            // create the working context
            if let context = createARGBBitmapContext(imageRef!) {
                
                let width = CGImageGetWidth(imageRef)
                let height = CGImageGetHeight(imageRef)
                
                // draw image on the context
                CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), imageRef)
                let rawdata = UnsafeMutablePointer<UInt8>(CGBitmapContextGetData(context))
                
                // make all white pixels transparent
                // keep other pixels based on designated color
                var byteIndex = 0
                
                for _ in 0 ..< width * height {
                    
                    if let newColor = newColor {
                        if let oldColor = oldColor {
                            // color should be in RGBA format
                            let oldColorData = CGColorGetComponents(oldColor.CGColor)
                            let newColorData = CGColorGetComponents(newColor.CGColor)
                            if rawdata[byteIndex+1] == UInt8(oldColorData[0] * 255) && rawdata[byteIndex+2] == UInt8(oldColorData[1] * 255) && rawdata[byteIndex+3] == UInt8(oldColorData[2] * 255) {
                            
                                rawdata[byteIndex+1] = UInt8(newColorData[0] * 255) // red
                                rawdata[byteIndex+2] = UInt8(newColorData[1] * 255) // green
                                rawdata[byteIndex+3] = UInt8(newColorData[2] * 255) // blue
                            }
                        }
                    }
                    
                    byteIndex += 4
                }
                
                imageRef = CGBitmapContextCreateImage(context)
                free(rawdata)
                return UIImage(CGImage: imageRef!)
            }
        }
        return nil
    }
    
    static func cutImageOut(refImage: UIImage?) -> UIImage? {
        
        if let image = refImage {
            
            var imageRef = image.CGImage
            
            // create the working context
            if let context = createARGBBitmapContext(imageRef!) {
                
                let width = CGImageGetWidth(imageRef)
                let height = CGImageGetHeight(imageRef)
                
                // draw image on the context
                CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), imageRef)
                let rawdata = UnsafeMutablePointer<UInt8>(CGBitmapContextGetData(context))
                
                // make all white pixels transparent
                // keep other pixels based on designated color
                var byteIndex = 0
                
                let componentForClearColor: UInt8 = 0
                
                for _ in 0 ..< width * height {
                    //                    let alpha: UInt8 = rawdata[byteIndex]
                    let red: UInt8 = rawdata[byteIndex+1]
                    let green: UInt8 = rawdata[byteIndex+2]
                    let blue: UInt8 = rawdata[byteIndex+3]
                    
                    if red == 255 && green == 255 && blue == 255 {
                        rawdata[byteIndex] = componentForClearColor
                        rawdata[byteIndex+1] = componentForClearColor
                        rawdata[byteIndex+2] = componentForClearColor
                        rawdata[byteIndex+3] = componentForClearColor
                    }
                    byteIndex += 4
                }
                
                imageRef = CGBitmapContextCreateImage(context)
                free(rawdata)
                return UIImage(CGImage: imageRef!)
            }
        }
        return nil
    }

    static func convertSnapshotToImage(image: UIImage?) -> UIImage? {
        if image == nil {
            return nil
        }
        var imageRef = image!.CGImage
        if let context = createARGBBitmapContext(imageRef!) {
            let width = CGImageGetWidth(imageRef)
            let height = CGImageGetHeight(imageRef)
            
            // draw image on the context
            CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), imageRef)
            imageRef = CGBitmapContextCreateImage(context)
            return UIImage(CGImage: imageRef!)
        }
        return nil
    }
}