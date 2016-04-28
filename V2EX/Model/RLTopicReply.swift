//
//  RLTopicReply.swift
//  V2EX
//
//  Created by LLZ on 16/4/1.
//  Copyright © 2016年 ucs. All rights reserved.
//

import UIKit

class RLTopicReply: NSObject {
    var ID:String?
    var thanks:String?
    var content:String?
    var content_rendered:String?
    var member:RLMember?
    var created:String?
    var last_modified:String?
    
    override static func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
        return ["ID":"id"]
    }
}
