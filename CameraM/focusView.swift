//
//  focusView.swift
//  CameraM
//
//  Created by DannyV on 16/3/17.
//  Copyright © 2016年 YuDan. All rights reserved.
//

import UIKit

class focusView: UIView {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func drawRect(rect: CGRect) {
        let context : CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetLineCap(context, CGLineCap.Square)
        CGContextSetLineWidth(context, 3.0)
        CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 0.9)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, 18, 18)
        CGContextAddLineToPoint(context, 18, 26)
        CGContextAddLineToPoint(context, 26, 26)
        CGContextAddLineToPoint(context, 26, 18)
        CGContextClosePath(context)
        CGContextStrokePath(context)
        
        CGContextSetLineWidth(context, 1.0)
        
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, 20, 1)
        CGContextAddLineToPoint(context, 24, 1)
        CGContextStrokePath(context)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, 20, 43)
        CGContextAddLineToPoint(context, 24, 43)
        CGContextStrokePath(context)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, 1, 20)
        CGContextAddLineToPoint(context, 1, 24)
        CGContextStrokePath(context)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, 43, 20)
        CGContextAddLineToPoint(context, 43, 24)
        CGContextStrokePath(context)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, 22, 2)
        CGContextAddLineToPoint(context, 22, 6)
        CGContextStrokePath(context)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, 2, 22)
        CGContextAddLineToPoint(context, 6, 22)
        CGContextStrokePath(context)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, 22, 38)
        CGContextAddLineToPoint(context, 22, 42)
        CGContextStrokePath(context)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, 38, 22)
        CGContextAddLineToPoint(context, 42, 22)
        CGContextStrokePath(context)
        //super.drawRect(rect)
    }
    
}
