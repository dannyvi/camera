//
//  flashButton.swift
//  CameraM
//
//  Created by DannyV on 16/3/17.
//  Copyright © 2016年 YuDan. All rights reserved.
//


import UIKit

@IBDesignable class flashButton: UIButton {
    
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
        //CGContextSetRGBStrokeColor(context, 0.9, 0.9, 0.9, 0.6)
        if self.state == UIControlState.Normal {
            CGContextSetRGBFillColor(context, 0.9, 0.9, 0.9, 0.6)
        }
        else if self.state == UIControlState.Selected {
            CGContextSetRGBFillColor(context, 1.0, 0.8, 0.3, 0.6)
        }
        else {
            CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.1)
        }
        
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, 18, 10)
        CGContextAddLineToPoint(context, 13, 22)
        CGContextAddLineToPoint(context, 20, 22)
        
        CGContextAddLineToPoint(context, 20, 30)
        CGContextAddLineToPoint(context, 22, 30)
        CGContextAddLineToPoint(context, 27, 18)
        CGContextAddLineToPoint(context, 20, 18)
        CGContextAddLineToPoint(context, 20, 10)
        CGContextClosePath(context)
        CGContextFillPath(context)
    }
    
}
