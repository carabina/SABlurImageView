//
//  UIImage+BlurEffect.swift
//  SABlurImageView
//
//  Created by 鈴木大貴 on 2015/03/27.
//  Copyright (c) 2015年 鈴木大貴. All rights reserved.
//

import UIKit
import QuartzCore
import Accelerate

extension UIImage {
    class func blurEffect(cgImage: CGImageRef) -> UIImage! {
        return UIImage(CGImage: cgImage)
    }
    
    func blurEffect(boxSize: Float) -> UIImage! {
        return UIImage(CGImage: bluredCGImage(boxSize))
    }
    
    func bluredCGImage(boxSize: Float) -> CGImageRef! {
        return CGImage.blurEffect(boxSize, scale: Float(scale))
    }
}

extension CGImage {
    func blurEffect(boxSize: Float, scale: Float) -> CGImageRef! {
        
        let boxSize = (boxSize - (boxSize % 2) + 1) * scale
        
        let inProvider = CGImageGetDataProvider(self)
        
        let height = CGImageGetHeight(self)
        let width = CGImageGetWidth(self)
        let rowBytes = CGImageGetBytesPerRow(self)
        
        let inBitmapData = CGDataProviderCopyData(inProvider)
        let inData = UnsafeMutablePointer<Void>(CFDataGetBytePtr(inBitmapData))
        var inBuffer = vImage_Buffer(data: inData, height: height, width: width, rowBytes: rowBytes)
        
        let outData = malloc(CGImageGetBytesPerRow(self) * CGImageGetHeight(self))
        var outBuffer = vImage_Buffer(data: outData, height: height, width: width, rowBytes: rowBytes)
        
        let error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, UInt32(boxSize), UInt32(boxSize), nil, vImage_Flags(kvImageEdgeExtend))
        
        var colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(self))
        let imageRef = CGBitmapContextCreateImage(context)
        
        free(outData)
        
        return imageRef
    }
}