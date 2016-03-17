//
//  tintThumb.swift
//  CameraM
//
//  Created by DannyV on 16/3/17.
//  Copyright © 2016年 YuDan. All rights reserved.
//

import UIKit

class tintThumb: customThumb {
    override func drawInContext(ctx: CGContext) {
        if let _ = self.cSlider {
            
            if self.highlighted {
                CGContextSetFillColorWithColor(ctx, UIColor(red: 1.0, green: 0.0, blue: 0.4, alpha: 0.8).CGColor)
                CGContextMoveToPoint(ctx, 15, 15);
                CGContextAddArc(ctx, 15, 15, 10,  CGFloat(0.0 * M_PI / 180.0), CGFloat(-180.0 * M_PI / 180.0), 1);
                CGContextClosePath(ctx);
                CGContextDrawPath(ctx, CGPathDrawingMode.Fill)
                
                CGContextSetFillColorWithColor(ctx, UIColor(red: 0.0, green: 1.0, blue: 0.2, alpha: 0.8).CGColor)
                CGContextMoveToPoint(ctx, 15, 15);
                CGContextAddArc(ctx, 15, 15, 10,  CGFloat(-180 * M_PI / 180.0), CGFloat(0.0 * M_PI / 180.0), 1);
                CGContextClosePath(ctx);
                CGContextDrawPath(ctx, CGPathDrawingMode.Fill)
                
            } else {
                CGContextSetFillColorWithColor(ctx, UIColor(red: 1.0, green: 0.0, blue: 0.4, alpha: 0.4).CGColor)
                CGContextMoveToPoint(ctx, 15, 15);
                CGContextAddArc(ctx, 15, 15, 10,  CGFloat(0.0 * M_PI / 180.0), CGFloat(-180.0 * M_PI / 180.0), 1);
                CGContextClosePath(ctx);
                CGContextDrawPath(ctx, CGPathDrawingMode.Fill)
                
                CGContextSetFillColorWithColor(ctx, UIColor(red: 0.0, green: 1.0, blue: 0.2, alpha: 0.4).CGColor)
                CGContextMoveToPoint(ctx, 15, 15);
                CGContextAddArc(ctx, 15, 15, 10,  CGFloat(-180 * M_PI / 180.0), CGFloat(0.0 * M_PI / 180.0), 1);
                CGContextClosePath(ctx);
                CGContextDrawPath(ctx, CGPathDrawingMode.Fill)
            }
            
        }
    }
}