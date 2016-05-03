//
//  RLTopicsTool.swift
//  V2EX
//
//  Created by LLZ on 16/3/29.
//  Copyright © 2016年 ucs. All rights reserved.
//

import UIKit

class RLTopicsTool: NSObject {
    static let shareTopicsTool = RLTopicsTool()//单例
    private override init() {}//防止外部用init（）或者（）来初始化这个单例
    
    var currentPageIdx:Int = 1//当前加载到的页码,从1开始,20条话题一页(由服务器决定)
    
    private lazy var topics:NSMutableArray = {[]}()
    
    //根据话题ID获取数据
    func topicWithTopicID(ID:String, completion:(topic:RLTopic) -> Void) {
        let path = "/api/topics/show.json?id=\(ID)"
        RLNetWorkManager.defaultNetWorkManager.requestWithPath(path, success: { (response) in
            let topics = RLTopic.mj_objectArrayWithKeyValuesArray(response)
            _ = self.test(response)
            
            completion(topic: topics.firstObject as! RLTopic)
            } , failure:{})
    }
    //获取话题列表(从html转换过来)
    func topicsWithCompletion(completion:(topics:NSArray) -> Void, option:RLPageSelected) {
        if option == .RecentTopics {
            if currentPageIdx == 1 {
                topics.removeAllObjects()
            }
            let path = "/recent?p=\(currentPageIdx)"
            RLNetWorkManager.defaultNetWorkManager.requestHTMLWithPath(path, callBack: { [weak self] (resArr) in
                if let strongSelf = self {
                    let tempArr = RLTopic.parserHTMLStrs(resArr)
                    for topic in tempArr {
                        strongSelf.topics.addObject(topic)
                    }
                    completion(topics: strongSelf.topics)
                }
            })
        } else if option == .PopTopics {
            let path = "/api/topics/hot.json"
            RLNetWorkManager.defaultNetWorkManager.requestWithPath(path, success: { [weak self] (response) in
                if let strongSelf = self {
                    strongSelf.topics = RLTopic.mj_objectArrayWithKeyValuesArray(response)
                    completion(topics: strongSelf.topics)
                }
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
    
    func test(keyValuesArray:AnyObject) {
        //获取管理的数据上下文 对象
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = app.managedObjectContext

        //创建TopicEntity对象并赋值
        let s = TopicEntity.mj_objectArrayWithKeyValuesArray(keyValuesArray, context: context)
        
        print(s)
        //保存
        do{
            try context.save()
        }catch let error as NSError{
            print("不能保存：\(error.localizedDescription)")
        }
    }
}
