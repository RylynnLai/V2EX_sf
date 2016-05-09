//
//  RLNodeBtn.swift
//  V2EX
//
//  Created by ucs on 16/1/13.
//  Copyright © 2016年 ucs. All rights reserved.
//


import UIKit


class RLNodeBtn: UIButton {
    var nodeModel:Node?
    var isZoomAnimating:Bool

    override init(frame: CGRect) {
        isZoomAnimating = false
        super.init(frame: frame)
        
        setTitleColor(UIColor.darkGrayColor(), forState:.Normal)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.minimumScaleFactor = 0.5
        self.titleLabel?.numberOfLines = 2
        self.titleLabel?.textAlignment = .Center
        
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.layer.anchorPoint = CGPointMake(0.5, 0.5)
        self.imageView?.contentMode = .ScaleAspectFit
        setBackgroundImage(UIImage.init(named: "nodeIcon\(arc4random_uniform(8) + 1)"), forState: .Normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}