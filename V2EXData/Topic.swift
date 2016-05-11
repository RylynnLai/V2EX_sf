//
//  Topic.swift
//  V2EX
//
//  Created by LLZ on 16/5/5.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import Foundation
import CoreData

private let dataManager:RLDataManager = { return RLDataManager.sharedManager }()

@objc(Topic)
class Topic: NSManagedObject {
    //MARK: -增
    class func createTopicsArray(fromKeyValuesArray keyValuesArray: AnyObject) -> [Topic] {
        var topics = [Topic]()
        
        guard let arr = keyValuesArray as? [AnyObject] else { return topics}
        
        arr.forEach { (keyValues) in
            if let topic = createTopic(fromKeyValues: keyValues) {
                topics.append(topic)
            }
        }
        return topics
    }
    class func createTopic(fromKeyValues keyValues: AnyObject) -> Topic? {
        if let id = keyValues["id"] as? NSNumber{
            guard let t = TopicByID(id) else {//检查数据库中有没有数据
                return dataManager.create("Topic", fromKeyValues: keyValues) as? Topic
            }
            //拿到数据库中的模型,并更新模型
            let topic = t.mj_setKeyValues(keyValues, context: RLDataManager.sharedManager.managedObjectContext)
            //保存
            dataManager.saveContext()
            return topic
        }
        return .None
    }
    //MARK: -查
    //获取指定ID的帖子
    class func TopicByID(ID: NSNumber?) -> Topic? {
        if let value = ID  {
            let predicate = NSPredicate(format: "id == %@", argumentArray:[value])
            let topics = RLDataManager.sharedManager.objectArrayByPredicate("Topic", predicate:predicate) as! [Topic]
            guard let topic = topics.first else {return .None}
            return topic
        }
        return .None
    }
    
    //MARK: -MJExtension
    //截取Node和Member属性,防止重复插入数据
    override func mj_newValueFromOldValue(oldValue: AnyObject!, property: MJProperty!) -> AnyObject! {
        if property.name as String  == "node" {
            if let keyValues = oldValue as? NSDictionary {
                guard let n = Node.NodeByName(keyValues["name"] as? String) else {
                    return oldValue
                }
                return n
            }
        } else if property.name as String == "member" {
            if let keyValues = oldValue as? NSDictionary {
                guard let m = Member.MemberByUsername(keyValues["username"] as? String) else {
                    return oldValue
                }
                return m
            }
        }
        return oldValue
    }
}
