//
//  RLNode.swift
//  V2EX
//
//  Created by LLZ on 16/3/31.
//  Copyright © 2016年 ucs. All rights reserved.
//

import UIKit

class RLNode: NSObject {
    var ID:String?
    var name:String?//用于发起请求获取话题列表
    var title:String?//实际显示名字
    var title_alternative:String?
    var url:String?
    var topics:String?
    var stars:String?
    var header:String?
    var footer:String?
    var created:String?
    var avatar_mini:String?
    var avatar_normal:String?
    var avatar_large:String?
    
    override class func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
        return ["ID":"id"]
    }
}
