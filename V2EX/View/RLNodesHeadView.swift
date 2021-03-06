//
//  RLNodesHeadView.swift
//  V2EX
//
//  Created by LLZ on 16/3/15.
//  Copyright © 2016年 ucs. All rights reserved.
//

import UIKit

class RLNodesHeadView: UIView {

    
    @IBOutlet weak var _titleLable: UILabel!
    @IBOutlet weak var _iconImgV: UIImageView!
    @IBOutlet weak var _startsNumLable: UILabel!
    @IBOutlet weak var _topicsNumLable: UILabel!
    @IBOutlet weak var _descriptionLable: UILabel!
    
    
    // MARk:setter方法
    var nodeModel:Node? {
        didSet{
            //标题
            _titleLable.text = nodeModel!.title;
            //icon 
            _iconImgV.sd_setImageWithURL(NSURL(string: "https:\(nodeModel!.avatar_normal ?? "")"), placeholderImage: UIImage.init(named: "icon_rayps_64@2x"))
            //话题数
            _topicsNumLable.text = nodeModel?.topics?.stringValue
            //星
            if nodeModel!.stars != nil {
                _startsNumLable.text = "★\(nodeModel!.stars!)"
            }
            //描述
            _descriptionLable.text = nodeModel?.header
        }
        
    }
    override func layoutSubviews() {
        //更新高度
        self.mj_h = _descriptionLable.frame.maxY + 10
    }
}
