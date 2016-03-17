//
//  customVerticalSlider.swift
//  CameraM
//
//  Created by DannyV on 16/3/17.
//  Copyright © 2016年 YuDan. All rights reserved.
//


import UIKit
import QuartzCore

class customVerticalSlider: UIControl {
    //weak var cSlider:
    var minValue: Double = 0.0 {
        didSet{
            self.updateLayerFrames()
        }
    }
    
    var maxValue: Double = 1.0 {
        didSet {
            self.updateLayerFrames()
        }
    }
    
    var currentValue: Double = 0.5 {
        didSet {
            self.updateLayerFrames()
        }
    }
    
    var previousLocation = CGPoint()
    
    var trackTintColor: UIColor = UIColor(white: 0.9, alpha: 0.2) {
        didSet {
            self.trackLayer.setNeedsDisplay()
        }
    }
    
    var thumbTintColor: UIColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.6) {
        didSet {
            self.thumbLayer.setNeedsDisplay()
        }
    }
    
    var thumbWidth: CGFloat {
        return CGFloat(self.bounds.width)
    }
    
    let trackLayer = customTrack()
    var thumbLayer = customThumb()
    
    override var frame: CGRect {
        didSet {
            self.updateLayerFrames()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    
    init(frame: CGRect , thumb: customThumb) {
        super.init(frame: frame)
        self.thumbLayer = thumb
        self.thumbLayer.cSlider = self
        self.trackLayer.cSlider = self
        //self.trackLayer.addSublayer(self.thumbLayer)
        //self.trackLayer.mask = self.thumbLayer
        //self.trackLayer.masksToBounds = false
        
        self.layer.addSublayer(self.trackLayer)
        self.layer.addSublayer(self.thumbLayer)
        self.updateLayerFrames()
    }
    
    init(thumb: customThumb) {
        super.init(frame: CGRectMake(0, 0, 30, 100))
        self.thumbLayer = thumb
        self.thumbLayer.cSlider = self
        self.trackLayer.cSlider = self
        self.layer.addSublayer(self.trackLayer)
        self.layer.addSublayer(self.thumbLayer)
        self.updateLayerFrames()
    }
    
    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.trackLayer.frame = self.bounds.insetBy(dx: (self.bounds.width - 2.0) / 2.0 , dy: 0.0 )
        self.trackLayer.setNeedsDisplay()
        
        let thumbCenter = CGFloat(self.positionForValue(self.currentValue))
        //print(self.thumbLayer.frame)
        self.thumbLayer.frame = CGRect(x: 0.0, y: thumbCenter - self.thumbWidth / 2.0 , width: self.thumbWidth , height: self.thumbWidth)
        self.thumbLayer.setNeedsDisplay()
        CATransaction.commit()
        //self.thumbLayer.frame = CGRect(x:
    }
    
    func positionForValue(value: Double) -> Double {
        return Double(self.bounds.height - self.thumbWidth) * (self.maxValue  - value) / (self.maxValue - self.minValue) + Double(self.thumbWidth / 2.0)
    }
    
    func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        previousLocation = touch.locationInView(self)
        
        if self.thumbLayer.frame.contains(previousLocation) {
            self.thumbLayer.highlighted = true
            self.trackLayer.highlighted = true
        }
        return self.thumbLayer.highlighted
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        
        let deltaLocation = Double( self.previousLocation.y - location.y)
        let deltaValue    = (self.maxValue - self.minValue) * deltaLocation / Double(self.bounds.height - self.bounds.width) / 5.0
        
        self.previousLocation = location
        
        if self.thumbLayer.highlighted {
            self.currentValue += deltaValue
            self.currentValue =  self.boundValue(currentValue, toLowerValue: self.minValue, upperValue: self.maxValue)
        }
        
        sendActionsForControlEvents(.ValueChanged)
        
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        self.thumbLayer.highlighted = false
        self.trackLayer.highlighted = false
    }
    
}
