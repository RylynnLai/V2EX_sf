//
//  RLMember.swift
//  V2EX
//
//  Created by LLZ on 16/3/31.
//  Copyright © 2016年 ucs. All rights reserved.
//

import UIKit

class RLMember: NSObject {
    var ID:String?
    var username:String?
    var tagline:String?
    var avatar_mini:String?
    var avatar_normal:String?
    var avatar_large:String?
    
    
    override static func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
        return ["ID":"id"]
    }
}
