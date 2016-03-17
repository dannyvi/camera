//
//  durationThumb.swift
//  CameraM
//
//  Created by DannyV on 16/3/17.
//  Copyright © 2016年 YuDan. All rights reserved.
//

import UIKit

class durationThumb: customThumb {
    
    override func drawInContext(ctx: CGContext) {
        if let slider = self.cSlider {
            
            let thumbFrame = self.bounds.insetBy(dx: 5.0, dy: 5.0)

            let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: 2.0)

            if self.highlighted {
                CGContextSetFillColorWithColor(ctx, UIColor(red: 0.9, green: 1.0, blue: 0.3, alpha: 0.6).CGColor)
                CGContextSetRGBStrokeColor(ctx, 0.9, 1.0, 0.3, 0.6)
            } else {
                CGContextSetFillColorWithColor(ctx, slider.thumbTintColor.CGColor)
                CGContextSetStrokeColorWithColor(ctx, slider.thumbTintColor.CGColor)
            }
            
            CGContextSetLineCap(ctx, CGLineCap.Round)
            CGContextSetLineWidth(ctx, 2.0)
            
            CGContextAddPath(ctx, thumbPath.CGPath)
            CGContextStrokePath(ctx)

            
        }
    }
}
