//
//  RLTopicsHelper.swift
//  V2EX
//
//  Created by LLZ on 16/3/29.
//  Copyright © 2016年 ucs. All rights reserved.
//

import UIKit
import Alamofire


class RLTopicsHelper: NSObject {
    static let shareTopicsHelper = RLTopicsHelper()//单例
    private override init() {}//防止外部用init（）或者（）来初始化这个单例
    
    var currentPageIdx:Int = 1//当前加载到的页码,从1开始,20条话题一页(由服务器决定)
    
    //根据话题ID获取数据
    func topicWithTopicID(ID:NSNumber, completion:(topic:Topic?) -> Void) {
        let path = "/api/topics/show.json?id=\(ID)"
        
        Alamofire.request(.GET, mainURLStr + path).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error 获取话题失败: \(response.result.error)")
                completion(topic: .None)
                return
            }
            if let responseJSON = response.result.value as? [AnyObject]{
                let topic = RLDataManager.sharedManager.createTopic(fromKeyValues: responseJSON.first!)
                completion(topic: topic)
            }
        }
    }
    //获取话题列表(从html转换过来)
    func topicsWithCompletion(completion:(topics:[Topic]?) -> Void, option:RLPageSelected) {
        var topics = [Topic]()
        if option == .RecentTopics {
            if currentPageIdx == 1 {
                topics.removeAll()
            }
            let path = "/recent?p=\(currentPageIdx)"
            RLNetWorkManager.defaultNetWorkManager.requestHTMLWithPath(path, callBack: { [weak self] (resArr) in
                if let strongSelf = self {
                    let tempArr = strongSelf.parserHTMLStrs(resArr)
                    for topic in tempArr {
                        topics.append(topic)
                    }
                    completion(topics: topics)
                }
            })
            
            Alamofire.request(TopicsRouter.RecentTopics(currentPageIdx)).responseString(completionHandler: { (response) in
                guard response.result.isSuccess else {
                    print("Error 获取话题失败: \(response.result.error)")
                    completion(topics: .None)
                    return
                }
                print(response.result.value)
                var range:NSRange = NSRange()
                var substring:NSString = ""
                var topics = [NSDictionary]()
                
                
                if let value = response.result.value {
                    // Conditional cast from 'String' to 'NSString' always succeeds
                    var HTMLStr = value as NSString
                    while true {//解析
                        range = (HTMLStr.rangeOfString("<td width=\"48\" valign=\"top\" align=\"center\">"))//起点
                        if range.location == NSNotFound { break }//跳出
                        HTMLStr = HTMLStr.substringFromIndex(NSMaxRange(range))//截取起点后面的字符串
                        range = HTMLStr.rangeOfString("</tr>")//终点
                        substring = HTMLStr.substringToIndex(range.location)//解析结果
                   
                        
                        let topicDic = NSMutableDictionary()
                        let memberDic = NSMutableDictionary()
                        let nodeDic = NSMutableDictionary()
                        
                        var rangeStart = substring.rangeOfString("<img src=\"")
                        var tempStr = substring.substringFromIndex(rangeStart.location + rangeStart.length)
                        var rangEnd = tempStr.rangeOfString("\" class=\"avatar\"")
                        memberDic.setValue(tempStr.substringToIndex(rangEnd.location), forKey: "avatar_normal")
                        
                        rangeStart = (tempStr as NSString).rangeOfString("class=\"item_title\"><a href=\"/t/")
                        tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
                        rangEnd = (tempStr as NSString).rangeOfString("#")
                        topicDic.setValue(Int((tempStr as NSString).substringToIndex(rangEnd.location)), forKey: "id")
                        
                        rangeStart = (tempStr as NSString).rangeOfString("reply")
                        tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
                        rangEnd = (tempStr as NSString).rangeOfString("\">")
                        topicDic.setValue((tempStr as NSString).substringToIndex(rangEnd.location), forKey: "replies")
                        
                        rangeStart = (tempStr as NSString).rangeOfString("\">")
                        tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
                        rangEnd = (tempStr as NSString).rangeOfString("</a>")
                        topicDic.setValue((tempStr as NSString).substringToIndex(rangEnd.location), forKey: "title")
                        
                        rangeStart = (tempStr as NSString).rangeOfString("class=\"node\" href=\"/go/")
                        tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
                        rangEnd = (tempStr as NSString).rangeOfString("\">")
                        nodeDic.setValue((tempStr as NSString).substringToIndex(rangEnd.location), forKey: "name")
                        
                        rangeStart = (tempStr as NSString).rangeOfString("\">")
                        tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
                        rangEnd = (tempStr as NSString).rangeOfString("</a>")
                        nodeDic.setValue((tempStr as NSString).substringToIndex(rangEnd.location), forKey: "title")
                        
                        rangeStart = (tempStr as NSString).rangeOfString("href=\"/member/")
                        tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
                        rangEnd = (tempStr as NSString).rangeOfString("\">")
                        memberDic.setValue((tempStr as NSString).substringToIndex(rangEnd.location), forKey: "username")
                        
                        rangeStart = (tempStr as NSString).rangeOfString("</strong> &nbsp;•&nbsp;")
                        if rangeStart.location == NSNotFound {continue}
                        tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
                        rangEnd = (tempStr as NSString).rangeOfString("&nbsp;•&nbsp;")
                        if rangEnd.location == NSNotFound {rangEnd = (tempStr as NSString).rangeOfString("</span>")}
                        topicDic.setValue((tempStr as NSString).substringToIndex(rangEnd.location), forKey: "createdTime")
                        
                        topicDic.setValue(memberDic, forKey: "member")
                        topicDic.setValue(nodeDic, forKey: "node")
                        topics.append(topicDic)
                        
                        
                    }
                }
            })
        } else if option == .PopTopics {
            let path = "/api/topics/hot.json"
            RLNetWorkManager.defaultNetWorkManager.requestWithPath(path, success: { (response) in
                topics = RLDataManager.sharedManager.createTopicsArray(fromKeyValuesArray: response)
                completion(topics: topics)
                
                }, failure: {})
        }
    }
    //根据话题ID获得评论
    func topicRepliesWithTopicID(ID:String, completion:(replies:NSArray) -> Void) {
     let path = "/api/replies/show.json?topic_id=\(ID)"
        RLNetWorkManager.defaultNetWorkManager.requestWithPath(path, success: { (response) in
            let repliesItem = RLTopicReply.mj_objectArrayWithKeyValuesArray(response)
            completion(replies: repliesItem)
            }, failure:{})
    }

    //MARK: -other
    //解析HTML,获取标题等简单数据
    func parserHTMLStrs(resArr:NSArray) -> [Topic] {
        var topics = [NSDictionary]()
        
        for str in resArr {
            let topicDic = NSMutableDictionary()
            let memberDic = NSMutableDictionary()
            let nodeDic = NSMutableDictionary()
            
            var rangeStart = (str as! NSString).rangeOfString("<img src=\"")
            var tempStr = (str as! NSString).substringFromIndex(rangeStart.location + rangeStart.length)
            var rangEnd = (tempStr as NSString).rangeOfString("\" class=\"avatar\"")
//            topic.member.avatar_normal = (tempStr as NSString).substringToIndex(rangEnd.location)
            memberDic.setValue((tempStr as NSString).substringToIndex(rangEnd.location), forKey: "avatar_normal")
            
            rangeStart = (tempStr as NSString).rangeOfString("class=\"item_title\"><a href=\"/t/")
            tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = (tempStr as NSString).rangeOfString("#")
//            topic.ID = Int((tempStr as NSString).substringToIndex(rangEnd.location))
            topicDic.setValue(Int((tempStr as NSString).substringToIndex(rangEnd.location)), forKey: "id")
            
            rangeStart = (tempStr as NSString).rangeOfString("reply")
            tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = (tempStr as NSString).rangeOfString("\">")
//            topic.replies = (tempStr as NSString).substringToIndex(rangEnd.location)
            topicDic.setValue((tempStr as NSString).substringToIndex(rangEnd.location), forKey: "replies")
            
            rangeStart = (tempStr as NSString).rangeOfString("\">")
            tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = (tempStr as NSString).rangeOfString("</a>")
//            topic.title = (tempStr as NSString).substringToIndex(rangEnd.location)
            topicDic.setValue((tempStr as NSString).substringToIndex(rangEnd.location), forKey: "title")
            
            rangeStart = (tempStr as NSString).rangeOfString("class=\"node\" href=\"/go/")
            tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = (tempStr as NSString).rangeOfString("\">")
//            topic.node.name = (tempStr as NSString).substringToIndex(rangEnd.location)
            nodeDic.setValue((tempStr as NSString).substringToIndex(rangEnd.location), forKey: "name")
            
            rangeStart = (tempStr as NSString).rangeOfString("\">")
            tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = (tempStr as NSString).rangeOfString("</a>")
//            topic.node.title = (tempStr as NSString).substringToIndex(rangEnd.location)
            nodeDic.setValue((tempStr as NSString).substringToIndex(rangEnd.location), forKey: "title")
            
            rangeStart = (tempStr as NSString).rangeOfString("href=\"/member/")
            tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = (tempStr as NSString).rangeOfString("\">")
//            topic.member.username = (tempStr as NSString).substringToIndex(rangEnd.location)
            memberDic.setValue((tempStr as NSString).substringToIndex(rangEnd.location), forKey: "username")
            
            rangeStart = (tempStr as NSString).rangeOfString("</strong> &nbsp;•&nbsp;")
            if rangeStart.location == NSNotFound {continue}
            tempStr = (tempStr as NSString).substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = (tempStr as NSString).rangeOfString("&nbsp;•&nbsp;")
            if rangEnd.location == NSNotFound {rangEnd = (tempStr as NSString).rangeOfString("</span>")}
//            topic.createdTime = (tempStr as NSString).substringToIndex(rangEnd.location)
            topicDic.setValue((tempStr as NSString).substringToIndex(rangEnd.location), forKey: "createdTime")
            
            topicDic.setValue(memberDic, forKey: "member")
            topicDic.setValue(nodeDic, forKey: "node")
            topics.append(topicDic)
        }
        return RLDataManager.sharedManager.createTopicsArray(fromKeyValuesArray: topics)
    }
}
