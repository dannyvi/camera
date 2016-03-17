//
//  customThumb.swift
//  CameraM
//
//  Created by DannyV on 16/3/17.
//  Copyright © 2016年 YuDan. All rights reserved.
//

import UIKit
import QuartzCore

class customThumb: CALayer {
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    weak var cSlider: customVerticalSlider?
}
