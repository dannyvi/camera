//
//  ISOThumb.swift
//  CameraM
//
//  Created by DannyV on 16/3/17.
//  Copyright © 2016年 YuDan. All rights reserved.
//


import UIKit

class ISOThumb: customThumb {
    override func drawInContext(ctx: CGContext) {
        if let slider = self.cSlider {
            
            let thumbFrame = self.bounds.insetBy(dx: 10.0, dy: 10.0)
            let cornerRadius = self.bounds.height  / 2.0
            let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
            
            if self.highlighted {
                CGContextSetFillColorWithColor(ctx, UIColor(red: 0.9, green: 1.0, blue: 0.3, alpha: 0.6).CGColor)
                CGContextSetRGBStrokeColor(ctx, 0.9, 1.0, 0.3, 0.6)
            } else {
                CGContextSetFillColorWithColor(ctx, slider.thumbTintColor.CGColor)
                CGContextSetStrokeColorWithColor(ctx, slider.thumbTintColor.CGColor)
                //CGContextSetRGBStrokeColor(ctx, 0.8, 0.8, 0.8, 0.9)
            }
            
            CGContextAddPath(ctx, thumbPath.CGPath)
            CGContextFillPath(ctx)
            
            CGContextSetLineCap(ctx, CGLineCap.Round)
            CGContextSetLineWidth(ctx, 1.0)
            
            CGContextBeginPath(ctx)
            CGContextMoveToPoint(ctx, 22, 15)
            CGContextAddLineToPoint(ctx, 28, 15)
            CGContextStrokePath(ctx)
            
            CGContextBeginPath(ctx)
            CGContextMoveToPoint(ctx, 15 + 7 / 1.4142 , 15 - 7 / 1.4142)
            CGContextAddLineToPoint(ctx, 15 + 13 / 1.4142 , 15 - 13 / 1.4142)
            CGContextStrokePath(ctx)
            
            CGContextBeginPath(ctx)
            CGContextMoveToPoint(ctx, 15 , 8)
            CGContextAddLineToPoint(ctx, 15 , 2)
            CGContextStrokePath(ctx)
            
            CGContextBeginPath(ctx)
            CGContextMoveToPoint(ctx, 15 - 7 / 1.4142 , 15 - 7 / 1.4142 )
            CGContextAddLineToPoint(ctx, 15 - 13 / 1.4142 , 15 - 13 / 1.4142)
            CGContextStrokePath(ctx)
            
            CGContextBeginPath(ctx)
            CGContextMoveToPoint(ctx, 8 , 15)
            CGContextAddLineToPoint(ctx, 2 , 15)
            CGContextStrokePath(ctx)
            
            CGContextBeginPath(ctx)
            CGContextMoveToPoint(ctx, 15 - 7 / 1.4142, 15 + 7 / 1.4142)
            CGContextAddLineToPoint(ctx, 15 - 13 / 1.4142 , 15 + 13 / 1.4142)
            CGContextStrokePath(ctx)
            
            CGContextBeginPath(ctx)
            CGContextMoveToPoint(ctx, 15 , 22)
            CGContextAddLineToPoint(ctx, 15 , 28)
            CGContextStrokePath(ctx)
            
            CGContextBeginPath(ctx)
            CGContextMoveToPoint(ctx, 15 + 7 / 1.4142 , 15 + 7 / 1.4142)
            CGContextAddLineToPoint(ctx, 15 + 13 / 1.4142 , 15 + 13 / 1.4142)
            CGContextStrokePath(ctx)
            
        }
    }
}
