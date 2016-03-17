//
//  customTrack.swift
//  CameraM
//
//  Created by DannyV on 16/3/17.
//  Copyright © 2016年 YuDan. All rights reserved.
//


import UIKit
import QuartzCore

class customTrack: CALayer {
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    weak var cSlider: customVerticalSlider?
    
    override func drawInContext(ctx: CGContext) {
        if let slider = cSlider {
            if self.highlighted {
                let trackFrame = self.bounds.insetBy(dx: 0.0, dy: 2.0)
                let cornerRadius = self.bounds.height  / 2.0
                let trackPath = UIBezierPath(roundedRect: trackFrame, cornerRadius: cornerRadius)
                let thumbFrame = slider.thumbLayer.frame
                let thumbPath = UIBezierPath(roundedRect: thumbFrame.insetBy(dx: -3.0, dy: -3.0), cornerRadius: 0.0)
                
                CGContextSetFillColorWithColor(ctx, slider.trackTintColor.CGColor)
                CGContextAddPath(ctx, trackPath.CGPath)
                
                CGContextAddPath(ctx, thumbPath.CGPath)
                
                CGContextEOFillPath(ctx)
                
            }
        }
    }
}
