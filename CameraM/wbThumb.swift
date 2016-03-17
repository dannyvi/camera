//
//  wbThumb.swift
//  CameraM
//
//  Created by DannyV on 16/3/17.
//  Copyright © 2016年 YuDan. All rights reserved.
//

import UIKit

class wbThumb: customThumb {
    override func drawInContext(ctx: CGContext) {
        if let slider = self.cSlider {
            
            let thumbFrame = self.bounds.insetBy(dx: 2.0, dy: 2.0)
            let cornerRadius = self.bounds.height  / 2.0
            let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
            
            if self.highlighted {
                CGContextSetFillColorWithColor(ctx, UIColor(red: 0.9, green: 1.0, blue: 0.3, alpha: 0.2).CGColor)
            } else { CGContextSetFillColorWithColor(ctx, slider.thumbTintColor.CGColor) }
            
            CGContextAddPath(ctx, thumbPath.CGPath)
            CGContextFillPath(ctx)
            
            
            let path = CGPathCreateMutable()
            CGPathAddRect(path,nil,CGRectMake(0, 0,self.bounds.size.width,self.bounds.size.height))
            let redTextAttributes: [ String: AnyObject] = [ NSForegroundColorAttributeName : UIColor.redColor(), NSFontAttributeName : UIFont(name: "Georgia", size: 12)! ]
            let words = NSAttributedString(string: "ISO", attributes: redTextAttributes)
            
            let framesetter = CTFramesetterCreateWithAttributedString(words)
            let fontframe = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, words.length), path, nil)
            CGContextSetTextMatrix(ctx, CGAffineTransformIdentity)
            CGContextTranslateCTM(ctx, 0, self.bounds.size.height)
            CGContextScaleCTM(ctx, 1.0, -1.0);
            CTFrameDraw(fontframe, ctx)
            
            
        }
    }
}
