//
//  pageViewController.swift
//  CameraM
//
//  Created by DannyV on 16/3/17.
//  Copyright © 2016年 YuDan. All rights reserved.
//

import UIKit
import Photos

class pageViewController: UIViewController , UINavigationControllerDelegate ,UIPageViewControllerDataSource , PHPhotoLibraryChangeObserver   {
    
    @IBOutlet var toolScroll: UIScrollView!
    @IBOutlet var maskView: UIView!
    
    var thumbView: UIView!
    var thumbViewImages: [UIImageView]! = []
    
    var allPhotos: PHFetchResult!
    var cachingManager: PHCachingImageManager!
    
    var pageViewController: UIPageViewController!
    
    var back: Int = 0
    var forward: Int = 0
    
    override func awakeFromNib() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: true) ]
        self.allPhotos = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: allPhotosOptions)
        self.cachingManager = PHCachingImageManager()
        var assets: [PHAsset] = []
        self.allPhotos.enumerateObjectsUsingBlock{(object,idx,_) in
            if let asset = object as? PHAsset {
                assets.append(asset)
            }
        }
        self.cachingManager.startCachingImagesForAssets(assets, targetSize: CGSizeMake(50,50), contentMode: PHImageContentMode.AspectFit, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("pageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        let contentController = self.viewControllerAtIndex(self.allPhotos.count - 1)
        let viewControllers = [contentController!]
        self.pageViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)

        self.addChildViewController(self.pageViewController)
        //self.view.addSubview(self.pageViewController.view)
        self.view.insertSubview(self.pageViewController.view, atIndex: 0)

        self.pageViewController.didMoveToParentViewController(self)
        
        let singleTouch = UITapGestureRecognizer(target: self, action: Selector("switchBars:"))
        singleTouch.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTouch)
        
        self.initToolScroll()
        self.updateToolScroll()
        let singleTouch2 = UITapGestureRecognizer(target: self, action: Selector("selectPic:"))
        singleTouch2.numberOfTapsRequired = 1
        self.toolScroll.addGestureRecognizer(singleTouch2)
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    func photoLibraryDidChange(changeInfo: PHChange) {
        //dispatch_async(dispatch_get_main_queue()) {
        /* let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: true) ]
        self.allPhotos = PHAsset.fetchAssetsWithOptions(allPhotosOptions)*/
        /*self.cachingManager = PHCachingImageManager()
        var assets: [PHAsset] = []
        self.allPhotos.enumerateObjectsUsingBlock{(object,idx,_) in
        if let asset = object as? PHAsset {
        assets.append(asset)
        }
        }
        self.cachingManager.startCachingImagesForAssets(assets, targetSize: CGSizeMake(50,50), contentMode: PHImageContentMode.AspectFit, options: nil)*/
        //self.updateToolScroll()
        //}
    }
    
    func switchBars(sender: UITapGestureRecognizer) {
        if let v = self.navigationController?.navigationBar.hidden {
            self.navigationController?.navigationBarHidden = !v
            self.toolScroll.hidden = !v
            self.maskView.hidden = !v
        }
    }
    
    @IBAction func deletePic(sender: UIBarButtonItem) {
        if let viewControllers = self.pageViewController.viewControllers {
            let viewController = viewControllers[0] as! contentViewController
            let opindex = viewController.pageIndex

            let asset = self.allPhotos[opindex] as! PHAsset

            PHPhotoLibrary.sharedPhotoLibrary().performChanges({() -> Void in
                PHAssetChangeRequest.deleteAssets([asset])
                }, completionHandler: { (success: Bool , error: NSError?) -> Void in
                    if success {
                        dispatch_async(dispatch_get_main_queue()) {
                            let allPhotosOptions = PHFetchOptions()
                            allPhotosOptions.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: true) ]
                            self.allPhotos = PHAsset.fetchAssetsWithOptions(allPhotosOptions)

                            var index : Int
                            if ( opindex < self.allPhotos.count - 1 ) {
                                index = opindex
                            } else { index = self.allPhotos.count - 1 }

                            if let contentController = self.viewControllerAtIndex(index) {
                                let viewControllers = [contentController]
                                self.pageViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
                            }
                            self.thumbViewImages[opindex].removeFromSuperview()
                            self.thumbViewImages.removeAtIndex(opindex)
                            
                            dispatch_after(dispatch_time_t(0.3), dispatch_get_main_queue()) {
                                if opindex < self.allPhotos.count {
                                    for i in opindex...(self.allPhotos.count - 1) {
                                        self.thumbViewImages[i].frame =  CGRectMake( 5 + CGFloat(i * 55) , 0, 50, 50)
                                    } }
                                self.thumbView.frame = CGRectMake(0 , 0 , 55 * CGFloat(self.allPhotos.count) + CGFloat(5) , 50)
                                self.toolScroll.contentSize = self.thumbView.frame.size

                            }
                        }}
                    
            })
        }
    }
    
    func selectPic(sender: UITapGestureRecognizer) {
        let index = Int((sender.locationInView(self.toolScroll).x - 5) / 55)
        if let viewControllers = self.pageViewController.viewControllers {
            let viewController = viewControllers[0] as! contentViewController
            if index == viewController.pageIndex { return }
        }
        if let contentController = viewControllerAtIndex(index) {
            let viewControllers = [contentController]
            self.pageViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
    }
    
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let viewController = viewController as! contentViewController
        var index = viewController.pageIndex
        forward++
        if (index) >= self.allPhotos.count {
            return nil
        } else { index += 1 }
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let viewController = viewController as! contentViewController
        var index = viewController.pageIndex
        back++
        if index < 0 {
            return nil
        } else { index -= 1 }
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(indexx: Int) -> UIViewController? {
        if indexx >= self.allPhotos.count || indexx < 0 {
            return nil
        }
        let contentInstance = self.storyboard!.instantiateViewControllerWithIdentifier("contentViewController") as! contentViewController
        contentInstance.pageIndex = indexx
        
        
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
        imageRequestOptions.networkAccessAllowed = false
        
        if let asset = self.allPhotos[indexx] as? PHAsset {

            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: self.targetSize(), contentMode: PHImageContentMode.AspectFit, options: imageRequestOptions, resultHandler: {(result: UIImage? , info: [NSObject: AnyObject]?) -> Void in
                if ((result == nil)) {return }
                if let r = result { contentInstance.setPic(r) }
            })
        }
        return contentInstance
    }
    
    func targetSize() -> CGSize {
        let scale: CGFloat = UIScreen.mainScreen().scale
        return CGSizeMake(CGRectGetWidth(self.view.bounds) * scale, CGRectGetHeight(self.view.bounds) * scale)
    }
    
    func initToolScroll() {
        let number = CGFloat(self.allPhotos.count)
        self.thumbView = UIView(frame: CGRectMake(0 , 0 , 55 * number + CGFloat(5) , 50))
        self.thumbView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9)
        self.toolScroll.addSubview(self.thumbView)
    }
    
    func updateToolScroll() {
        let number = CGFloat(self.allPhotos.count)
        self.thumbView.removeFromSuperview()
        self.thumbView = UIView(frame: CGRectMake(0 , 0 , 55 * number + CGFloat(5) , 50))
        self.toolScroll.addSubview(self.thumbView)

        
        self.toolScroll.contentSize = self.thumbView.frame.size
        self.toolScroll.contentOffset = CGPointMake(self.thumbView.frame.size.width - self.view.frame.size.width , 0)
        
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
        imageRequestOptions.networkAccessAllowed = false
        for i in 0...(self.allPhotos.count - 1)  {
            if let asset = self.allPhotos[i] as? PHAsset {
                let imageview = UIImageView(frame: CGRectMake( 5 + CGFloat(i * 55) , 0, 50, 50))
                imageview.contentMode = UIViewContentMode.ScaleAspectFit
                self.thumbViewImages.append(imageview)
                self.thumbView.addSubview(imageview)

                self.cachingManager.requestImageForAsset(asset, targetSize: CGSizeMake(50,50) , contentMode: PHImageContentMode.AspectFit, options: imageRequestOptions, resultHandler: {(result: UIImage? , info: [NSObject: AnyObject]?) -> Void in
                    if ((result == nil)) {return }
                    imageview.image = result

                })
            }
        }

    }
}
