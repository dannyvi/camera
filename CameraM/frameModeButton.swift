//
//  frameModeButton.swift
//  CameraM
//
//  Created by DannyV on 16/3/17.
//  Copyright © 2016年 YuDan. All rights reserved.
//


import UIKit

enum frameMode {
    case Rect
    case Square
}

@IBDesignable class frameModeButton: UIButton {
    var mode:frameMode = frameMode.Rect
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    override func drawRect(rect: CGRect) {
        var rectangle: CGRect
        switch self.mode {
        case .Rect:
            rectangle = CGRectMake(6, 2, 28, 36)
        case .Square:
            rectangle = CGRectMake(6, 6, 28, 28)
        }
        
        let context : CGContextRef = UIGraphicsGetCurrentContext()!
        
        CGContextSetLineWidth(context, 3.0)
        CGContextSetRGBStrokeColor(context, 1.0 ,0.6, 0.2, 0.5)
        
        CGContextSetRGBFillColor(context, 0.9, 0.9, 0.9, 0.2)
        CGContextStrokeRectWithWidth(context, rectangle, 1.0)
        
        CGContextFillRect(context, rectangle)
    }
    
    
}
