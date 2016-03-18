//
//  ViewController.swift
//  CameraM
//
//  Created by DannyV on 16/3/11.
//  Copyright © 2016年 YuDan. All rights reserved.
//


import UIKit
import AVFoundation
import Photos
import GLKit
import QuartzCore

class ViewController: UIViewController , AVCaptureVideoDataOutputSampleBufferDelegate , AVCaptureMetadataOutputObjectsDelegate ,  UINavigationControllerDelegate{
    var tempCounter: Int = 0
    var tips = "需要授权： 设置->隐私->照片 相机"
    
    var winback: UIWindow!
    var controlback: UnrotViewController!
    
    var captureSession: AVCaptureSession!
    var frontCaptureDevice: AVCaptureDevice!
    var backCaptureDevice:  AVCaptureDevice!
    var currentCaptureDevice:      AVCaptureDevice!
    var previewView: AVCaptureVideoPreviewLayer!
    var currentDeviceInput: AVCaptureDeviceInput!
    
    var glContext: EAGLContext!
    var glView: GLKView!
    var ciContext: CIContext!
    var glMask: UIView!
    
    var queuePreview: dispatch_queue_t!
    var queueCaptureTask: dispatch_queue_t!
    var stillImageOutput: AVCaptureStillImageOutput!
    var dataOutput: AVCaptureVideoDataOutput!
    
    @IBOutlet var toolbarView: UIView!
    @IBOutlet var infoContainer: UIView!
    @IBOutlet var ISOLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var tintLabel: UILabel!
    @IBOutlet var flashButtonInstance: flashButton!
    @IBOutlet var switchCameraButtonInstance: switchCameraButton!
    @IBOutlet var frameModeButtonInstance: frameModeButton!
    @IBOutlet var showLibButtonInstance: UIButton!
    
    var ISOAdjustButtonInstance: customVerticalSlider! //updownButton!
    var durationAdjustButtonInstance: customVerticalSlider! //updownButton!
    var tempAdjustButtonInstance: customVerticalSlider!
    var tintAdjustButtonInstance: customVerticalSlider!
    var focusViewInstance: focusView!
    var exposureViewInstance: exposureView!
    var doubleTouch = false
    var authorizationCamera: AVAuthorizationStatus!
    var authorizationPhotos: PHAuthorizationStatus!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.init_all()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func init_all() {
        let delegate = UIApplication.sharedApplication().delegate!
        delegate.window!!.backgroundColor = UIColor.clearColor()
        delegate.window!!.clipsToBounds = true
        delegate.window!!.windowLevel = 1.0
        self.winback = UIWindow(frame: delegate.window!!.bounds)//UIScreen.mainScreen().bounds)
        self.controlback = UnrotViewController()
        self.winback.rootViewController = self.controlback
        self.winback.makeKeyAndVisible()
        
        self.infoContainer.layer.cornerRadius = 5
        self.focusViewInstance = focusView(frame: CGRectMake(0, 0, 45, 45))
        self.view.addSubview(self.focusViewInstance)
        self.focusViewInstance.hidden = true
        self.exposureViewInstance = exposureView(frame: CGRectMake(0, 0, 45, 45))
        self.view.addSubview(self.exposureViewInstance)
        self.exposureViewInstance.hidden = true
        let ISOthum = ISOThumb()
        self.ISOAdjustButtonInstance = customVerticalSlider(thumb: ISOthum) //updownButton(text: "ISO")
        self.ISOAdjustButtonInstance.minValue = 0.0
        self.ISOAdjustButtonInstance.maxValue = 800.0
        self.ISOAdjustButtonInstance.currentValue = 400.0
        self.ISOAdjustButtonInstance.hidden = true
        self.view.addSubview(self.ISOAdjustButtonInstance)
        
        let durationthum = durationThumb()
        self.durationAdjustButtonInstance =  customVerticalSlider(thumb: durationthum)  //updownButton(text: "Dur")
        self.durationAdjustButtonInstance.minValue = 0.0
        self.durationAdjustButtonInstance.maxValue = 1.0
        self.durationAdjustButtonInstance.currentValue = 0.5
        self.durationAdjustButtonInstance.hidden = true
        self.view.addSubview(self.durationAdjustButtonInstance)
        
        let tempthum = tempThumb()
        self.tempAdjustButtonInstance = customVerticalSlider(thumb: tempthum)
        self.tempAdjustButtonInstance.minValue = 2400.0
        self.tempAdjustButtonInstance.maxValue = 9000.0
        self.tempAdjustButtonInstance.currentValue = ( 2400 + 9000 ) / 2
        self.tempAdjustButtonInstance.hidden = true
        self.view.addSubview(self.tempAdjustButtonInstance)
        
        let tintthum = tintThumb()
        self.tintAdjustButtonInstance = customVerticalSlider(thumb: tintthum)
        self.tintAdjustButtonInstance.minValue = -200
        self.tintAdjustButtonInstance.maxValue = 200
        self.tintAdjustButtonInstance.currentValue = 0
        self.tintAdjustButtonInstance.hidden = true
        self.view.addSubview(self.tintAdjustButtonInstance)
        
        self.queuePreview = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL)
        self.queueCaptureTask = dispatch_queue_create("CaptureTaskQueue", DISPATCH_QUEUE_SERIAL)
        
        self.captureSession = AVCaptureSession()
        self.currentCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        self.captureSession.beginConfiguration()
        self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        do {
            self.currentDeviceInput = try AVCaptureDeviceInput(device: currentCaptureDevice)
            if self.captureSession.canAddInput(self.currentDeviceInput) {
                self.captureSession.addInput(self.currentDeviceInput)
            }
        } catch {}
        self.captureSession.commitConfiguration()
        dispatch_async(self.queuePreview, { () -> Void in
            self.captureSession.startRunning()
        })
        
        self.previewView = AVCaptureVideoPreviewLayer(session: self.captureSession) as AVCaptureVideoPreviewLayer
        self.previewView.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.previewView.frame = getFrame(bySize: self.winback.bounds.size, mode: self.frameModeButtonInstance.mode)
        //self.controlback.view.layer.insertSublayer(self.previewView, atIndex: 0)
        
        glContext = EAGLContext(API: .OpenGLES2) //
        
        glView = GLKView()
        glView.frame = getFrame(bySize: self.winback.bounds.size, mode: self.frameModeButtonInstance.mode)
        glView.context = glContext
        self.glMask = UIView()
        self.glMask.frame =  getFrame(bySize: self.glView.bounds.size, mode: self.frameModeButtonInstance.mode)
        self.glMask.backgroundColor = UIColor.whiteColor()
        glView.maskView = self.glMask
        ciContext = CIContext(EAGLContext: glContext)
        
        self.controlback.view.addSubview(glView)
        
        
        dispatch_async(self.queueCaptureTask, {() -> Void in
            self.setupCaptureSession()
        })
        self.addObservers()
        self.prepareButtons()
        self.refreshPhotoLibImage()
    }
    
    func setupCaptureSession() {
        let availableCameraDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in availableCameraDevices as! [AVCaptureDevice] {
            if device.position == .Back {
                self.backCaptureDevice = device
            }
            else if device.position == .Front {
                self.frontCaptureDevice = device
                //self.frontCaptureDevice.h
            }
        }
        if ((self.backCaptureDevice == nil ) || (self.frontCaptureDevice == nil)) {
            self.switchCameraButtonInstance.enabled = false
        }
        if self.currentCaptureDevice.hasFlash  {
            self.flashButtonInstance.enabled = true
        } else {
            self.flashButtonInstance.enabled = false
        }
        self.captureSession.beginConfiguration()
        self.resetDeviceConfig()
        
        
        
        self.dataOutput = AVCaptureVideoDataOutput()
        //[kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA]
        
        self.dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as NSString : NSNumber(unsignedInt: kCVPixelFormatType_32BGRA)]
        self.dataOutput.alwaysDiscardsLateVideoFrames = true
        self.dataOutput.setSampleBufferDelegate(self, queue: dispatch_queue_create("sample buffer delegate", DISPATCH_QUEUE_SERIAL))
        
        if self.captureSession.canAddOutput(dataOutput) {
            self.captureSession.addOutput(dataOutput)
        }
        self.dataOutput.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = AVCaptureVideoOrientation.Portrait
        
        self.stillImageOutput  = AVCaptureStillImageOutput()
        //let outputSetting = [
        //self.stillImageOutput.outputSettings
        if self.captureSession.canAddOutput(self.stillImageOutput) {
            self.captureSession.addOutput(self.stillImageOutput)
        }
        self.captureSession.commitConfiguration()
    }
    
    func resetDeviceConfig() {
        do {
            try self.currentCaptureDevice.lockForConfiguration()
            if self.currentCaptureDevice.isFocusModeSupported(AVCaptureFocusMode.ContinuousAutoFocus) {
                self.currentCaptureDevice.focusMode = .ContinuousAutoFocus
            }
            if self.currentCaptureDevice.isExposureModeSupported(AVCaptureExposureMode.ContinuousAutoExposure) {
                self.currentCaptureDevice.exposureMode = .ContinuousAutoExposure
            }
            if self.currentCaptureDevice.isWhiteBalanceModeSupported(AVCaptureWhiteBalanceMode.ContinuousAutoWhiteBalance){
                self.currentCaptureDevice.whiteBalanceMode = .ContinuousAutoWhiteBalance
            }
            self.currentCaptureDevice.unlockForConfiguration()
        } catch _ {
        }
        self.focusViewInstance.hidden = true
        self.exposureViewInstance.hidden = true
        self.ISOAdjustButtonInstance.hidden = true
        self.durationAdjustButtonInstance.hidden = true
        self.tempAdjustButtonInstance.hidden = true
        self.tintAdjustButtonInstance.hidden = true
    }
    
    func getFrame(bySize size: CGSize, mode:frameMode) -> CGRect {
        var rect:CGRect!
        switch mode {
        case .Rect:
            rect = CGRect(origin: CGPointZero, size: size)
        case .Square:
            let w = size.width , h = size.height ;
            let width = min(w,h)
            let cgsize = CGSize(width: width, height: width)
            var origpoint: CGPoint
            let x = abs(w-h) / 2
            if h > w {
                origpoint = CGPoint(x:0, y:x)
            } else { origpoint = CGPoint(x: x, y:0)}
            rect = CGRect(origin: origpoint, size: cgsize)
        }
        return rect
    }
    
    func refreshPhotoLibImage() {
        //dispatch_async(self.queueCaptureTask) { () -> Void in
        let fetchoptions:PHFetchOptions = PHFetchOptions()
        fetchoptions.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        
        let assets:PHFetchResult = PHAsset.fetchAssetsWithOptions(fetchoptions)
        let asset:PHAsset = assets[0] as! PHAsset
        let options = PHImageRequestOptions()
        options.resizeMode = PHImageRequestOptionsResizeMode.Exact
        
        let scale = UIScreen.mainScreen().scale
        let size = self.showLibButtonInstance.bounds.size
        let thumbTargetSize = CGSizeMake(scale * size.width, scale * size.height)
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: thumbTargetSize, contentMode: PHImageContentMode.AspectFit, options: options, resultHandler: {(result: UIImage?, info:[NSObject : AnyObject]?) -> Void in
            if (result != nil) {
                self.showLibButtonInstance.setImage(result, forState: UIControlState.Normal)
                self.showLibButtonInstance.setNeedsDisplay()
            }
        } )
        //}
    }
    
    func prepareButtons() {
        self.ISOAdjustButtonInstance.addTarget(self, action: "changeISO:", forControlEvents: .ValueChanged)
        self.durationAdjustButtonInstance.addTarget(self, action: "changeDuration:", forControlEvents: .ValueChanged)
        self.tempAdjustButtonInstance.addTarget(self, action: "changeTemp:", forControlEvents: .ValueChanged)
        self.tintAdjustButtonInstance.addTarget(self, action: "changeTint:", forControlEvents: .ValueChanged)
    }
    
    func removeButtons() {
        self.ISOAdjustButtonInstance.removeTarget(self, action: "changeISO:", forControlEvents: .ValueChanged)
        self.durationAdjustButtonInstance.removeTarget(self, action: "changeDuration:", forControlEvents: .ValueChanged)
        self.tempAdjustButtonInstance.removeTarget(self, action: "changeTemp:", forControlEvents: .ValueChanged)
        self.tintAdjustButtonInstance.removeTarget(self, action: "changeTint:", forControlEvents: .ValueChanged)
    }
    
    func addObservers() {
        self.addObserver(self, forKeyPath: "currentCaptureDevice.ISO", options: .New, context: nil)//&ISOcontext)
        self.addObserver(self, forKeyPath: "currentCaptureDevice.exposureDuration", options: .New, context: nil)
        self.addObserver(self, forKeyPath: "currentCaptureDevice.deviceWhiteBalanceGains", options: .New, context: nil)
    }
    
    func removeObservers() {
        self.removeObserver(self, forKeyPath: "currentCaptureDevice.ISO") //, context:&ISOcontext)
        self.removeObserver(self, forKeyPath: "currentCaptureDevice.exposureDuration")
        self.removeObserver(self, forKeyPath: "currentCaptureDevice.deviceWhiteBalanceGains")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if ( keyPath == "currentCaptureDevice.ISO") {
            var newISO = change![NSKeyValueChangeNewKey]?.intValue
            if newISO != nil {
                newISO = (newISO! + 2) / 10 * 10
            }
            self.ISOLabel.text = newISO?.description
            if !self.ISOAdjustButtonInstance.thumbLayer.highlighted {
                self.ISOAdjustButtonInstance.currentValue = Double(newISO!)
            }
        }
        else if (keyPath == "currentCaptureDevice.exposureDuration") {
            let newDurationSeconds = CMTimeGetSeconds(change![NSKeyValueChangeNewKey]!.CMTimeValue) as Double
            if (newDurationSeconds >= 1) {
                self.durationLabel.text = NSString(format: "%.2f", newDurationSeconds) as String
                if !self.durationAdjustButtonInstance.thumbLayer.highlighted {
                    self.durationAdjustButtonInstance.currentValue = 1.0
                }
            }
            else {
                var  durValue = Int(1.0 / newDurationSeconds)
                if durValue > 10000     {    durValue = durValue / 1000 * 1000 }
                else if durValue > 5000 {    durValue = durValue / 100 * 100   }
                else if durValue > 100  {    durValue = durValue / 10 * 10     }
                self.durationLabel.text = NSString(format: "1/%d", durValue) as String
                let dur = 1.0 / newDurationSeconds
                var result: Double = 0.0
                
                if dur < 1 { result = 1.0 }
                else if dur < 2 { result = 0.95 }
                else if dur < 3 { result = 0.9 }
                else if dur < 6 { result = 0.85 }
                else if dur < 15 { result = 0.8 }
                else if dur < 30 { result = 0.75 }
                else if dur < 45 { result = 0.7 }
                else if dur < 60 { result = 0.65 }
                else if dur < 80 { result = 0.6 }
                else if dur < 100 { result = 0.55 }
                else if dur < 125 { result = 0.5 }
                else if dur < 160 { result = 0.45 }
                else if dur < 250 { result = 0.4 }
                else if dur < 500 { result = 0.35 }
                else if dur < 750 { result = 0.3 }
                else if dur < 1000 { result = 0.25 }
                else if dur < 1250 { result = 0.2 }
                else if dur < 2500 { result = 0.15 }
                else if dur < 5000 { result = 0.1 }
                else if dur < 10000 { result = 0.05 }
                else {result = 0.00}
                if !self.durationAdjustButtonInstance.thumbLayer.highlighted {
                    self.durationAdjustButtonInstance.currentValue = result
                }
            }
        }
        else if (keyPath == "currentCaptureDevice.deviceWhiteBalanceGains") {
            var wbGains:AVCaptureWhiteBalanceGains = AVCaptureWhiteBalanceGains()
            change![NSKeyValueChangeNewKey]!.getValue!(&wbGains)
            let tempAndTint = self.currentCaptureDevice.temperatureAndTintValuesForDeviceWhiteBalanceGains(wbGains)
            self.tempLabel.text = NSString(format: "%i", (Int(tempAndTint.temperature) + 10) / 100 * 100) as String
            self.tintLabel.text = NSString(format: "%i", (Int(tempAndTint.tint) + 2) / 10 * 10) as String
            if !self.tempAdjustButtonInstance.thumbLayer.highlighted {
                self.tempAdjustButtonInstance.currentValue = Double(tempAndTint.temperature)
            }
            if !self.tintAdjustButtonInstance.thumbLayer.highlighted {
                self.tintAdjustButtonInstance.currentValue = Double(tempAndTint.tint)
            }
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.ISOAdjustButtonInstance.hidden = true
        self.durationAdjustButtonInstance.hidden = true
        //self.wbAdjustButtonInstance.hidden = true
        self.tempAdjustButtonInstance.hidden = true
        self.tintAdjustButtonInstance.hidden = true
        if (event!.allTouches()?.count == 1) {
            let touch: UITouch! = touches.first! as UITouch
            let touchLocation: CGPoint! = touch.locationInView(self.view)
            let focusViewInstanceframe = self.view.convertRect(focusViewInstance.frame, fromView: self.view)
            let exposureViewInstanceframe = self.view.convertRect(exposureViewInstance.frame, fromView: self.view)
            if (!(CGRectContainsPoint(focusViewInstanceframe, touchLocation)) && !(CGRectContainsPoint(exposureViewInstanceframe, touchLocation))) {
                self.doubleTouch = false
                focusViewInstance.center = touchLocation
                focusViewInstance.hidden = false
                exposureViewInstance.center = touchLocation
                exposureViewInstance.hidden = false
            }
        }
        else if (event!.allTouches()?.count == 2) {
            let twoTouches = (event!.allTouches()! as NSSet).allObjects
            let first:UITouch = twoTouches[0] as! UITouch
            let second:UITouch = twoTouches[1] as! UITouch
            let firstPoint:CGPoint! = first.locationInView(self.view)
            let secondPoint:CGPoint! = second.locationInView(self.view)
            let focusViewInstanceframe = self.view.convertRect(focusViewInstance.frame, fromView: self.view)
            let exposureViewInstanceframe = self.view.convertRect(exposureViewInstance.frame, fromView: self.view)
            if CGRectContainsPoint(focusViewInstanceframe, firstPoint)  {
                focusViewInstance.center = firstPoint
                focusViewInstance.hidden = false
                exposureViewInstance.center = secondPoint
                exposureViewInstance.hidden = false
            }
            else if CGRectContainsPoint(focusViewInstanceframe, secondPoint) {
                focusViewInstance.center = secondPoint
                focusViewInstance.hidden = false
                exposureViewInstance.center = firstPoint
                exposureViewInstance.hidden = false
            }
            else if CGRectContainsPoint(exposureViewInstanceframe, firstPoint) {
                focusViewInstance.center = secondPoint
                focusViewInstance.hidden = false
                exposureViewInstance.center = firstPoint
                exposureViewInstance.hidden = false
            }
            else if CGRectContainsPoint(exposureViewInstanceframe, secondPoint) {
                focusViewInstance.center = firstPoint
                focusViewInstance.hidden = false
                exposureViewInstance.center = secondPoint
                exposureViewInstance.hidden = false
            }
            else {
                focusViewInstance.center = firstPoint
                focusViewInstance.hidden = false
                exposureViewInstance.center = secondPoint
                exposureViewInstance.hidden = false
            }
            if (self.doubleTouch == false) {
                self.doubleTouch = true
            }
        }
        else {
            return
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (event!.allTouches()?.count == 1) {
            if (self.doubleTouch == false) {
                let touch: UITouch! = touches.first! as UITouch  //.anyObject() as! UITouch
                let touchLocation: CGPoint! = touch.locationInView(self.view)
                focusViewInstance.center = touchLocation
                focusViewInstance.hidden = false
                exposureViewInstance.center = touchLocation
                exposureViewInstance.hidden = false
            }
            else {
                let touch: UITouch! = touches.first! as UITouch //.anyObject() as! UITouch
                let touchLocation: CGPoint! = touch.locationInView(self.view)
                let focusViewInstanceframe = self.view.convertRect(focusViewInstance.frame, fromView: self.view)
                let exposureViewInstanceframe = self.view.convertRect(exposureViewInstance.frame, fromView: self.view)
                if CGRectContainsPoint(focusViewInstanceframe, touchLocation) {
                    focusViewInstance.center = touchLocation
                    focusViewInstance.hidden = false
                }
                else if CGRectContainsPoint(exposureViewInstanceframe, touchLocation) {
                    exposureViewInstance.center = touchLocation
                    exposureViewInstance.hidden = false
                }
            }
        }
        else if (event!.allTouches()?.count == 2) {
            let twoTouches = (event!.allTouches()! as NSSet).allObjects
            let first:UITouch = twoTouches[0] as! UITouch
            let second:UITouch = twoTouches[1] as! UITouch
            let firstPoint:CGPoint! = first.locationInView(self.view)
            let secondPoint:CGPoint! = second.locationInView(self.view)
            let focusViewInstanceframe = self.view.convertRect(focusViewInstance.frame, fromView: self.view)
            let exposureViewInstanceframe = self.view.convertRect(exposureViewInstance.frame, fromView: self.view)
            if CGRectContainsPoint(focusViewInstanceframe, firstPoint)  {
                focusViewInstance.center = firstPoint
                focusViewInstance.hidden = false
                exposureViewInstance.center = secondPoint
                exposureViewInstance.hidden = false
            }
            else if CGRectContainsPoint(focusViewInstanceframe, secondPoint) {
                focusViewInstance.center = secondPoint
                focusViewInstance.hidden = false
                exposureViewInstance.center = firstPoint
                exposureViewInstance.hidden = false
            }
            else if CGRectContainsPoint(exposureViewInstanceframe, firstPoint) {
                focusViewInstance.center = secondPoint
                focusViewInstance.hidden = false
                exposureViewInstance.center = firstPoint
                exposureViewInstance.hidden = false
            }
            else if CGRectContainsPoint(exposureViewInstanceframe, secondPoint) {
                focusViewInstance.center = firstPoint
                focusViewInstance.hidden = false
                exposureViewInstance.center = secondPoint
                exposureViewInstance.hidden = false
            }
            else {
                focusViewInstance.center = firstPoint
                focusViewInstance.hidden = false
                exposureViewInstance.center = secondPoint
                exposureViewInstance.hidden = false
            }
        }
        else {
            return
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //dispatch_async(self.queueCaptureTask) {() -> Void in
        let orig = self.previewView.frame.origin
        //let orig = self.view.convertPoint(self.previewView.frame.origin, toView: self.controlback.view)
        let firstPointInPreview = self.view.convertPoint(self.focusViewInstance.center, toView: self.controlback.view)
        let firstPoint = CGPoint(x: firstPointInPreview.x - orig.x, y: firstPointInPreview.y - orig.y)
        let secondPointInPreview = self.view.convertPoint(self.exposureViewInstance.center, toView: self.controlback.view)
        let secondPoint = CGPoint(x: secondPointInPreview.x - orig.x, y: secondPointInPreview.y - orig.y)
        //print("orig: \(orig),\n,p1  : \(self.focusViewInstance.center), \(firstPointInPreview), \(firstPoint)")
        let pv = self.previewView as AVCaptureVideoPreviewLayer
        let P1 = pv.captureDevicePointOfInterestForPoint(firstPoint)
        let P2 = pv.captureDevicePointOfInterestForPoint(secondPoint)
        do {
            try self.currentCaptureDevice.lockForConfiguration()
            if (self.currentCaptureDevice.focusPointOfInterestSupported && self.currentCaptureDevice.isFocusModeSupported(AVCaptureFocusMode.AutoFocus)) {
                self.currentCaptureDevice.focusPointOfInterest = P1
                self.currentCaptureDevice.focusMode = .AutoFocus
            }
            else {
                self.focusViewInstance.hidden = true
                self.focusViewInstance.setNeedsDisplay()
            }
            if (self.currentCaptureDevice.exposurePointOfInterestSupported && self.currentCaptureDevice.isExposureModeSupported(AVCaptureExposureMode.AutoExpose)) {
                self.currentCaptureDevice.exposurePointOfInterest = P2
                self.currentCaptureDevice.exposureMode = .AutoExpose
            }
            else {
                self.exposureViewInstance.hidden = true
                self.exposureViewInstance.setNeedsDisplay()
            }
            self.currentCaptureDevice.unlockForConfiguration()
        } catch _ {
            print("caught some error")
        }
        
        self.locateAdjustButtons()
        //}
    }
    
    func locateAdjustButtons() {
        var location1: CGPoint!
        var location2: CGPoint!
        
        location1 = self.exposureViewInstance.center
        location2 = self.exposureViewInstance.center
        
        if self.view.frame.width - location1.x < 120 {
            
            location1.x -= 150
            location2.x -= 110
        }
        else if location1.x < 120 {
            
            location1.x += 110
            location2.x += 150
        }
        if self.view.frame.height - location1.y < 60 {
            location1.y -= 100
            location2.y -= 100
            if location1.x == location2.x {
                location1.x -= 40
            }
        }
        else if location1.y < 60 {
            location1.y += 100
            location2.y += 100
            if location1.x == location2.x {
                location1.x -= 40
            }
        }
        
        self.ISOAdjustButtonInstance.center = CGPoint(x: location1.x + 40, y: location1.y)
        self.durationAdjustButtonInstance.center = CGPoint(x: location1.x + 80, y: location1.y)
        //self.wbAdjustButtonInstance.center = CGPoint(x: location1.x - 50, y: location1.y)
        self.tempAdjustButtonInstance.center = CGPoint(x: location2.x - 40, y: location2.y)
        self.tintAdjustButtonInstance.center = CGPoint(x: location2.x - 80, y: location2.y)
        self.ISOAdjustButtonInstance.hidden = false
        self.durationAdjustButtonInstance.hidden = false
        //self.wbAdjustButtonInstance.hidden = false
        self.tempAdjustButtonInstance.hidden = false
        self.tintAdjustButtonInstance.hidden = false
    }
    
    func changeISO(sender: AnyObject) {
        let sender = sender as! customVerticalSlider
        func switchISO(current:Float, flags:Bool) -> Float {
            var retvar: Float = 0.0
            if flags == false {
                retvar = current * 1.1892
            }
            else {
                retvar = current * 0.8408
            }
            return retvar
        }
        let activeFormat = self.currentCaptureDevice.activeFormat
        
        
        let ISO = Float(sender.currentValue)
        if ISO < activeFormat.maxISO && ISO > activeFormat.minISO {
            do {
                try self.currentCaptureDevice.lockForConfiguration()
                self.currentCaptureDevice.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO: ISO, completionHandler: nil)
                self.currentCaptureDevice.unlockForConfiguration()
            } catch _ {
            }
        } else {
            if ISO < activeFormat.minISO {
                do {
                    try self.currentCaptureDevice.lockForConfiguration()
                    self.currentCaptureDevice.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO: activeFormat.minISO, completionHandler: nil)
                    self.currentCaptureDevice.unlockForConfiguration()
                } catch _ {
                }
            } else if ISO > activeFormat.maxISO {
                do {
                    try self.currentCaptureDevice.lockForConfiguration()
                    self.currentCaptureDevice.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO: activeFormat.maxISO, completionHandler: nil)
                    self.currentCaptureDevice.unlockForConfiguration()
                } catch _ {
                }
            }
        }
    }
    
    func changeDuration(sender: AnyObject) {
        func switchDuration(current: Double) -> Float64 {
            var retVar: Float64 = 0.0
            if      current > 0.95 { retVar = 1.0 }
            else if 0.9      <   current && current <= 0.95       { retVar = 1 / 2.0 }
            else if 0.85     <   current && current <= 0.9        { retVar = 1 / 3.0 }
            else if 0.8      <   current && current <= 0.85       { retVar = 1 / 6.0 }
            else if 0.75     <   current && current <= 0.8        { retVar = 1 / 15.0 }
            else if 0.7      <   current && current <= 0.75       { retVar = 1 / 30.0 }
            else if 0.65     <   current && current <= 0.7        { retVar = 1 / 45.0 }
            else if 0.6      <   current && current <= 0.65       { retVar = 1 / 60.0 }
            else if 0.55      <  current && current <= 0.6        { retVar = 1 / 80.0 }
            else if 0.5       <  current && current <= 0.55       { retVar = 1 / 100.0 }
            else if 0.45      <  current && current <= 0.5        { retVar = 1 / 125.0 }
            else if 0.4       <  current && current <= 0.45       { retVar = 1 / 160.0 }
            else if 0.35      <  current && current <= 0.4        { retVar = 1 / 250.0 }
            else if 0.3       <  current && current <= 0.35       { retVar = 1 / 500.0 }
            else if 0.25      <  current && current <= 0.3        { retVar = 1 / 750.0 }
            else if 0.2       <  current && current <= 0.25       { retVar = 1 / 1000.0 }
            else if 0.15      <  current && current <= 0.2        { retVar = 1 / 1250.0 }
            else if 0.1       <  current && current <= 0.15       { retVar = 1 / 2500.0 }
            else if 0.05      <  current && current <= 0.1        { retVar = 1 / 5000.0 }
            else {retVar = 1 / 10000.0 }
            return retVar
        }
        
        let sender = sender as! customVerticalSlider   //updownButton
        let activeFormat = self.currentCaptureDevice.activeFormat
        let minExp = CMTimeGetSeconds(activeFormat.minExposureDuration)
        let maxExp = CMTimeGetSeconds(activeFormat.maxExposureDuration)
        let duration = switchDuration(sender.currentValue)
        if duration < maxExp && duration > minExp {
            do {
                try self.currentCaptureDevice.lockForConfiguration()
            } catch _ {
            }
            self.currentCaptureDevice.setExposureModeCustomWithDuration(CMTimeMakeWithSeconds(duration, 1000*1000*1000), ISO: AVCaptureISOCurrent, completionHandler: nil)
            self.currentCaptureDevice.unlockForConfiguration()
        }
    }
    
    func changeTemp(sender: AnyObject) {
        let sender = sender as! customVerticalSlider
        let temp = Float(sender.currentValue)
        
        let wbGains = self.currentCaptureDevice.deviceWhiteBalanceGains
        let tempAndTint = self.currentCaptureDevice.temperatureAndTintValuesForDeviceWhiteBalanceGains(wbGains)
        let tint = tempAndTint.tint
        
        let temperatureAndTint = AVCaptureWhiteBalanceTemperatureAndTintValues(temperature: temp, tint: tint)
        let deviceGains = self.currentCaptureDevice.deviceWhiteBalanceGainsForTemperatureAndTintValues(temperatureAndTint)
        let maxv = self.currentCaptureDevice.maxWhiteBalanceGain
        if (deviceGains.blueGain >= 1.0 && deviceGains.blueGain < maxv && deviceGains.greenGain >= 1.0 && deviceGains.greenGain < maxv && deviceGains.redGain >= 1.0 && deviceGains.redGain < maxv) {
            do {
                try self.currentCaptureDevice.lockForConfiguration()
                self.currentCaptureDevice.setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains(deviceGains, completionHandler: {(time:CMTime) -> Void in})
                self.currentCaptureDevice.unlockForConfiguration()
            } catch _ { }
        }
        //changeWB(temp)
    }
    
    func changeTint(sender: AnyObject) {
        let sender = sender as! customVerticalSlider
        let tint = Float(sender.currentValue)
        
        let wbGains = self.currentCaptureDevice.deviceWhiteBalanceGains
        let tempAndTint = self.currentCaptureDevice.temperatureAndTintValuesForDeviceWhiteBalanceGains(wbGains)
        let temp = tempAndTint.temperature
        
        let temperatureAndTint = AVCaptureWhiteBalanceTemperatureAndTintValues(temperature: temp, tint: tint)
        let deviceGains = self.currentCaptureDevice.deviceWhiteBalanceGainsForTemperatureAndTintValues(temperatureAndTint)
        let maxv = self.currentCaptureDevice.maxWhiteBalanceGain
        if (deviceGains.blueGain >= 1.0 && deviceGains.blueGain < maxv && deviceGains.greenGain >= 1.0 && deviceGains.greenGain < maxv && deviceGains.redGain >= 1.0 && deviceGains.redGain < maxv) {
            do {
                try self.currentCaptureDevice.lockForConfiguration()
                self.currentCaptureDevice.setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains(deviceGains, completionHandler: {(time:CMTime) -> Void in})
                self.currentCaptureDevice.unlockForConfiguration()
            } catch _ { }
        }
    }
    
    @IBAction func infoContainerTouched(sender: UITapGestureRecognizer) {
        self.resetDeviceConfig()
    }
    
    @IBAction func changeFlashMode(sender: flashButton) {
        self.flashButtonInstance.selected = !self.flashButtonInstance.selected
        if (self.flashButtonInstance.selected == true) {
            if self.currentCaptureDevice.hasFlash && self.currentCaptureDevice.isFlashModeSupported(AVCaptureFlashMode.On) {
                do {
                    try self.currentCaptureDevice.lockForConfiguration()
                    self.currentCaptureDevice.flashMode = AVCaptureFlashMode.On
                    self.currentCaptureDevice.unlockForConfiguration()
                } catch {}
            }
        } else {
            if self.currentCaptureDevice.hasFlash && self.currentCaptureDevice.isFlashModeSupported(AVCaptureFlashMode.Off) {
                do {
                    try self.currentCaptureDevice.lockForConfiguration()
                    self.currentCaptureDevice.flashMode = AVCaptureFlashMode.Off
                    self.currentCaptureDevice.unlockForConfiguration()
                } catch {}
            }
        }
    }
    
    @IBAction func switchCamera(sender: switchCameraButton) {
        if ((self.frontCaptureDevice != nil) && (self.backCaptureDevice != nil)) {
            
            if (self.currentCaptureDevice == self.frontCaptureDevice) {
                do {
                    self.removeButtons()
                    self.removeObservers()
                    self.captureSession.beginConfiguration()
                    
                    self.captureSession.removeInput(self.currentDeviceInput)
                    self.currentCaptureDevice = self.backCaptureDevice
                    self.currentDeviceInput = try AVCaptureDeviceInput(device: currentCaptureDevice)
                    if self.captureSession.canAddInput(self.currentDeviceInput) {
                        self.captureSession.addInput(self.currentDeviceInput)
                    }
                    self.dataOutput.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = AVCaptureVideoOrientation.Portrait
                    self.dataOutput.connectionWithMediaType(AVMediaTypeVideo).videoMirrored = false
                    self.captureSession.commitConfiguration()
                    if self.currentCaptureDevice.hasFlash {
                        self.flashButtonInstance.enabled = true
                    } else {
                        self.flashButtonInstance.enabled = false
                    }
                    
                    
                    self.addObservers()
                    self.prepareButtons()
                } catch {}
            }
            else if (self.currentCaptureDevice == self.backCaptureDevice) {
                do {
                    self.removeButtons()
                    self.removeObservers()
                    self.captureSession.beginConfiguration()
                    
                    self.captureSession.removeInput(self.currentDeviceInput)
                    self.currentCaptureDevice = self.frontCaptureDevice
                    self.currentDeviceInput = try AVCaptureDeviceInput(device: currentCaptureDevice)
                    //self.currentDeviceInput.con
                    if self.captureSession.canAddInput(self.currentDeviceInput) {
                        self.captureSession.addInput(self.currentDeviceInput)
                    }
                    self.dataOutput.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = AVCaptureVideoOrientation.Portrait
                    self.dataOutput.connectionWithMediaType(AVMediaTypeVideo).videoMirrored = true
                    self.captureSession.commitConfiguration()
                    if self.currentCaptureDevice.hasFlash {
                        self.flashButtonInstance.enabled = true
                    } else {
                        self.flashButtonInstance.enabled = false
                    }
                    
                    self.addObservers()
                    self.prepareButtons()
                } catch {}
            }
            self.resetDeviceConfig()
        }
    }
    
    @IBAction func changeFrameMode(sender: frameModeButton) {
        let mode = sender.mode
        switch mode {
        case .Rect:
            sender.mode = .Square
        case .Square:
            sender.mode = .Rect
        }
        sender.setNeedsDisplay()
        self.previewView.frame = getFrame(bySize: self.winback.bounds.size, mode: self.frameModeButtonInstance.mode)
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.2)
        self.glMask.frame = getFrame(bySize: self.glView.bounds.size, mode: self.frameModeButtonInstance.mode)
        UIView.commitAnimations()
    }
    
    @IBAction func shotPic(sender: shotButton) {
        //dispatch_async(self.queueCaptureTask) {() -> Void in
        let connection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        connection.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.currentDevice().orientation.rawValue)!
        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(connection)
            { (imageDataSampleBuffer: CMSampleBufferRef!, error: NSError?) -> Void in
                if error == nil {
                    
                    /*if let exifAttachment = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyExifDictionary, nil) {
                    }*/
                    
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    
                    if let image = UIImage(data: imageData) {
                        var uimage:UIImage!
                        if self.frameModeButtonInstance.mode == .Square {
                            let size:CGSize = image.size
                            let frameRect = self.getFrame(bySize: size, mode: .Square)
                            let orig = frameRect.origin
                            let x = max(orig.x,orig.y), y = min(orig.x,orig.y)
                            let rect2 = CGRect(origin: CGPoint(x: x, y: y), size: frameRect.size)
                            if let imageRef = CGImageCreateWithImageInRect(image.CGImage, rect2) {
                                uimage = UIImage(CGImage: imageRef, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation) }
                        } else {
                            if let imageRef = image.CGImage {
                                uimage = UIImage(CGImage: imageRef, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
                            }
                        }
                        if uimage != nil {
                            PHPhotoLibrary.sharedPhotoLibrary().performChanges({() -> Void in
                                PHAssetChangeRequest.creationRequestForAssetFromImage(uimage)},
                                completionHandler: {(success: Bool, error: NSError?) -> Void in
                                    if success { self.refreshPhotoLibImage()}})
                        }
                    }
                }
                else {
                    print("error while capturing still image: \(error)")
                }
                
        }
        //}
        
        self.resetDeviceConfig()
        
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        autoreleasepool {
            if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                
                let image = CIImage(CVPixelBuffer: pixelBuffer)
                
                if glContext != EAGLContext.currentContext() {
                    EAGLContext.setCurrentContext(glContext)
                }
                glView.bindDrawable()
                
                let scale = UIScreen.mainScreen().scale
                let size = self.glView.bounds.size
                let prop = image.extent.height / image.extent.width
                let Ypos = ( size.height - size.width * prop ) / 2
                
                let targetRect = CGRectMake(0,Ypos * scale,scale * size.width, scale * size.width * prop)
                let previewRect = CGRectMake(0, Ypos, size.width, size.width * prop)
                self.previewView.frame = previewRect
                ciContext.drawImage(image, inRect:targetRect, fromRect: image.extent)
                glView.display()
            }
        }
    }
    
    
}

