//
//  exposureView.swift
//  CameraM
//
//  Created by DannyV on 16/3/17.
//  Copyright © 2016年 YuDan. All rights reserved.
//


import UIKit

class exposureView: UIView {
    
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
        CGContextAddArc(context, 22, 22, 12, 0, CGFloat( M_PI * 2), 0)
        CGContextStrokePath(context)
        
        CGContextSetLineWidth(context, 1.0)
        
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, 4, 1)
        CGContextAddLineToPoint(context, 1, 1)
        CGContextAddLineToPoint(context, 1, 4)
        CGContextStrokePath(context)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, 39, 1)
        CGContextAddLineToPoint(context, 43, 1)
        CGContextAddLineToPoint(context, 43, 4)
        CGContextStrokePath(context)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, 1, 39)
        CGContextAddLineToPoint(context, 1, 43)
        CGContextAddLineToPoint(context, 4, 43)
        CGContextStrokePath(context)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, 39, 43)
        CGContextAddLineToPoint(context, 43, 43)
        CGContextAddLineToPoint(context, 43, 39)
        CGContextStrokePath(context)
        
    }
    
}
