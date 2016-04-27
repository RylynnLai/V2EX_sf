//
//  RLTopicList+UI.swift
//  V2EX
//
//  Created by LLZ on 16/4/26.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import UIKit

extension RLTopicList {
    
    func initUI() {
        let tagView = UIView.init(frame: CGRectMake(0, 0, tagW, 30))
        tagView.layer.cornerRadius = 10
        tagView.layer.masksToBounds = true
        tagView.layer.borderWidth = 1
        tagView.layer.borderColor = V2EXGray.CGColor
        tagView.tintColor = V2EXGray
        tagView.addSubview(recentBtn)
        tagView.addSubview(popBtn)
        self.navigationItem.titleView = tagView
        
        //设置返回按钮
        let backBarButtonItem = UIBarButtonItem.init()
        backBarButtonItem.title = ""
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
}