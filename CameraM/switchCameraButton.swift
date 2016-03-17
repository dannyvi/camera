//
//  switchCameraButton.swift
//  CameraM
//
//  Created by DannyV on 16/3/17.
//  Copyright © 2016年 YuDan. All rights reserved.
//


import UIKit

@IBDesignable class switchCameraButton: UIButton {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    override func drawRect(rect: CGRect) {
        let context : CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetLineCap(context, CGLineCap.Butt)
        CGContextSetLineWidth(context, 2.0)
        if self.state == UIControlState.Normal {
            CGContextSetRGBStrokeColor(context, 0.9, 0.9, 0.9, 0.6)
        }
        else {
            CGContextSetRGBFillColor(context, 0.2, 0.2, 0.2, 0.6)
        }
        
        CGContextAddArc(context, 20, 20, 6, CGFloat( M_PI * 0.7),CGFloat( M_PI * 1.5),  0)
        CGContextAddLineToPoint(context, 19, 16)
        CGContextStrokePath(context)
        CGContextAddArc(context, 20, 20, 6, CGFloat( M_PI * 1.7),CGFloat( M_PI * 0.5),  0)
        CGContextAddLineToPoint(context, 21, 24)
        CGContextStrokePath(context)
        
        CGContextSetLineWidth(context, 1.0)
        
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, 5, 13)
        CGContextAddLineToPoint(context, 10, 13)
        CGContextAddLineToPoint(context, 13, 10)
        
        CGContextAddLineToPoint(context, 27, 10)
        CGContextAddLineToPoint(context, 30, 13)
        CGContextAddLineToPoint(context, 35, 13)
        CGContextAddLineToPoint(context, 35, 30)
        CGContextAddLineToPoint(context, 5, 30)
        CGContextClosePath(context)
        CGContextStrokePath(context)
        
        
    }
    
}
