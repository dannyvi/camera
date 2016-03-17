//
//  shotButton.swift
//  CameraM
//
//  Created by DannyV on 16/3/17.
//  Copyright © 2016年 YuDan. All rights reserved.
//

import UIKit

@IBDesignable class shotButton: UIButton {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    override func drawRect(rect: CGRect) {
        let rad = rect.width
        let path = UIBezierPath(ovalInRect: CGRectMake(13, 13, rad-26, rad-26))
        UIColor(white: 0.95, alpha: 0.6).setFill()
        path.fill()
        
        let path2 = UIBezierPath(ovalInRect: CGRectMake(8, 8, rad-16, rad-16))
        path2.lineWidth = 5.0
        UIColor(white: 0.95, alpha: 0.6).setStroke()
        path2.stroke()
    }
}
