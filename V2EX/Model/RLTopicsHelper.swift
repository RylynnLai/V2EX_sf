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
    private var topics = [Topic]()
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
        if option == .RecentTopics {
            if currentPageIdx == 1 {
                topics.removeAll()
            }

            Alamofire.request(TopicsRouter.RecentTopics(currentPageIdx)).responseString(completionHandler: { [weak self] (response) in
                guard response.result.isSuccess else {
                    print("Error 获取最新话题失败: \(response.result.error)")
                    completion(topics: .None)
                    return
                }

                if let HTMLStr = response.result.value,
                   let strongSelf = self {
                    // Conditional cast from 'String' to 'NSString' always succeeds
                    let KeyValuesArray = strongSelf.parserHTMLString(HTMLStr as NSString)
                    let newTopics = RLDataManager.sharedManager.createTopicsArray(fromKeyValuesArray: KeyValuesArray)
                    strongSelf.topics += newTopics
                    completion(topics: strongSelf.topics)
                }
            })
        } else if option == .PopTopics {
            Alamofire.request(TopicsRouter.PopTopics).responseJSON(completionHandler: { (response) in
                guard response.result.isSuccess else {
                    print("Error 获取最热话题失败: \(response.result.error)")
                    completion(topics: .None)
                    return
                }
                
                if let responseJSON = response.result.value as? [AnyObject] {
                    let topics = RLDataManager.sharedManager.createTopicsArray(fromKeyValuesArray: responseJSON)
                    completion(topics: topics)
                }
            })
        }
    }
    //根据话题ID获得评论
    func topicRepliesWithTopicID(ID:String, completion:(replies:NSArray) -> Void) {
        let path = "/api/replies/show.json?topic_id=\(ID)"
        Alamofire.request(.GET, mainURLStr + path).responseJSON { (response) in
            
        }
        RLNetWorkManager.defaultNetWorkManager.requestWithPath(path, success: { (response) in
            let repliesItem = RLTopicReply.mj_objectArrayWithKeyValuesArray(response)
            completion(replies: repliesItem)
            }, failure:{})
    }

    //MARK: -other
    //解析HTML,返回话题字典
    func parserHTMLString(str:NSString) -> [NSDictionary] {
        var range:NSRange
        var rangeStart:NSRange
        var rangEnd:NSRange
        
        var HTMLStr = str
        var substring:NSString
        var tempStr:NSString
        
        var topics = [NSDictionary]()
        
        while true {//解析
            range = HTMLStr.rangeOfString("<td width=\"48\" valign=\"top\" align=\"center\">")//起点
            if range.location == NSNotFound { break }//跳出
            HTMLStr = HTMLStr.substringFromIndex(NSMaxRange(range))//截取起点后面的字符串
            range = HTMLStr.rangeOfString("</tr>")//终点
            substring = HTMLStr.substringToIndex(range.location)//解析结果
            
            let topicDic = NSMutableDictionary()
            let memberDic = NSMutableDictionary()
            let nodeDic = NSMutableDictionary()
            
            rangeStart = substring.rangeOfString("<img src=\"")
            tempStr = substring.substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = tempStr.rangeOfString("\" class=\"avatar\"")
            memberDic.setValue(tempStr.substringToIndex(rangEnd.location), forKey: "avatar_normal")
            
            rangeStart = tempStr.rangeOfString("class=\"item_title\"><a href=\"/t/")
            tempStr = tempStr.substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = tempStr.rangeOfString("#")
            topicDic.setValue(Int(tempStr.substringToIndex(rangEnd.location)), forKey: "id")
            
            rangeStart = tempStr.rangeOfString("reply")
            tempStr = tempStr.substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = tempStr.rangeOfString("\">")
            topicDic.setValue(tempStr.substringToIndex(rangEnd.location), forKey: "replies")
            
            rangeStart = tempStr.rangeOfString("\">")
            tempStr = tempStr.substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = tempStr.rangeOfString("</a>")
            topicDic.setValue(tempStr.substringToIndex(rangEnd.location), forKey: "title")
            
            rangeStart = tempStr.rangeOfString("class=\"node\" href=\"/go/")
            tempStr = tempStr.substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = tempStr.rangeOfString("\">")
            nodeDic.setValue(tempStr.substringToIndex(rangEnd.location), forKey: "name")
            
            rangeStart = tempStr.rangeOfString("\">")
            tempStr = tempStr.substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = tempStr.rangeOfString("</a>")
            nodeDic.setValue(tempStr.substringToIndex(rangEnd.location), forKey: "title")
            
            rangeStart = tempStr.rangeOfString("href=\"/member/")
            tempStr = tempStr.substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = tempStr.rangeOfString("\">")
            memberDic.setValue(tempStr.substringToIndex(rangEnd.location), forKey: "username")
            
            rangeStart = tempStr.rangeOfString("</strong> &nbsp;•&nbsp;")
            if rangeStart.location == NSNotFound {continue}
            tempStr = tempStr.substringFromIndex(rangeStart.location + rangeStart.length)
            rangEnd = tempStr.rangeOfString("&nbsp;•&nbsp;")
            if rangEnd.location == NSNotFound {rangEnd = (tempStr as NSString).rangeOfString("</span>")}
            topicDic.setValue(tempStr.substringToIndex(rangEnd.location), forKey: "createdTime")
            
            topicDic.setValue(memberDic, forKey: "member")
            topicDic.setValue(nodeDic, forKey: "node")
            topics.append(topicDic)
        }
        return topics
    }
}
