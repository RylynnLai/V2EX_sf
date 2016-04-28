//
//  RLTopic.swift
//  V2EX
//
//  Created by LLZ on 16/3/31.
//  Copyright © 2016年 ucs. All rights reserved.
//

import UIKit

class RLTopic: NSObject {
    var ID:String?
    var title:String?
    var url:String?
    var content:String?
    var content_rendered:String?
    var replies:String?
    lazy var member:RLMember = {return RLMember.init()}()
    lazy var node:RLNode = {return RLNode()}()
    var created:String?
    var createdTime:String?
    var last_modified:String?
    var last_touched:String?
    
    
    override static func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
        return ["ID":"id"]
    }
    //解析HTML,获取标题等简单数据
    internal class func parserHTMLStrs(resArr:NSArray) -> NSMutableArray {
        let topics = NSMutableArray.init(capacity: resArr.count)
        
        for str in resArr {
            let topic = RLTopic.init()
            
            var rangeStart = (str as! NSString).rangeOfString("<img src=\"")
            var tempStr = (str as! NSString).substringFromIndex(rangeStart.location + rangeStart.length)
            var rangEnd = (tempStr as NSString).rangeOfString("\" class=\"avatar\"")
            topic.member.avatar_normal = (tempStr as NSString).substringToIndex(rangEnd.location)
            
            rangeStart = (tempStr as NSString).rangeOfString("class=\"item_title\"><a href=\"/t/")
            tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = (tempStr as NSString).rangeOfString("#")
            topic.ID = (tempStr as NSString).substringToIndex(rangEnd.location)
            
            rangeStart = (tempStr as NSString).rangeOfString("reply")
            tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = (tempStr as NSString).rangeOfString("\">")
            topic.replies = (tempStr as NSString).substringToIndex(rangEnd.location)
            
            rangeStart = (tempStr as NSString).rangeOfString("\">")
            tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = (tempStr as NSString).rangeOfString("</a>")
            topic.title = (tempStr as NSString).substringToIndex(rangEnd.location)
            
            rangeStart = (tempStr as NSString).rangeOfString("class=\"node\" href=\"/go/")
            tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = (tempStr as NSString).rangeOfString("\">")
            topic.node.name = (tempStr as NSString).substringToIndex(rangEnd.location)
            
            rangeStart = (tempStr as NSString).rangeOfString("\">")
            tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = (tempStr as NSString).rangeOfString("</a>")
            topic.node.title = (tempStr as NSString).substringToIndex(rangEnd.location)
            
            rangeStart = (tempStr as NSString).rangeOfString("href=\"/member/")
            tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = (tempStr as NSString).rangeOfString("\">")
            topic.member.username = (tempStr as NSString).substringToIndex(rangEnd.location)
            
            rangeStart = (tempStr as NSString).rangeOfString("</strong> &nbsp;•&nbsp;")
            if rangeStart.location == NSNotFound {continue}
            tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = (tempStr as NSString).rangeOfString("&nbsp;•&nbsp;")
            if rangEnd.location == NSNotFound {rangEnd = (tempStr as NSString).rangeOfString("</span>")}
            topic.createdTime = (tempStr as NSString).substringToIndex(rangEnd.location)
            
            topics.addObject(topic)
        }
        return topics
    }
    
}
