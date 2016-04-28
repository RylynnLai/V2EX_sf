//
//  UIView+Extension.swift
//  V2EX
//
//  Created by ucs on 16/1/14.
//  Copyright © 2016年 ucs. All rights reserved.
//

import UIKit

public extension UIView {
    // MARK: - 快速获取x, y ,width, height
    public var rl_x : CGFloat
        {
        get{
            return self.frame.origin.x
        }
        set{
            self.frame.origin.x = newValue
        }
    }
    public var rl_y : CGFloat
        {
        get{
            return self.frame.origin.y
        }
        set{
            self.frame.origin.y = newValue
        }
    }
    public var rl_width : CGFloat
        {
        get{
            return self.frame.size.width
        }
        set{
            self.frame.size.width = newValue
        }
    }
    public var rl_height : CGFloat
        {
        get{
            return self.frame.size.height
        }
        set{
            self.frame.size.height = newValue
        }
    }
    // MARK: - 从xib加载view
    //这里的class修饰词作用是修饰类方法
    public class func instantiateFromNib() -> AnyObject? {
        return NSBundle.mainBundle().loadNibNamed(String(self), owner: nil, options: nil).first
    }

}


