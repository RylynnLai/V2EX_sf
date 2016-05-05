//
//  RLDataManager+Topic.swift
//  V2EX
//
//  Created by LLZ on 16/5/4.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import CoreData

extension RLDataManager {
    //MARK: -增
    //字典数组 -> 模型数组 并存进数据库
    func createTopicsArray(fromKeyValuesArray keyValuesArray: AnyObject) -> [Topic] {
        var topics = [Topic]()
        guard let arr = keyValuesArray as? [NSDictionary] else { return topics }
        
        arr.forEach { (keyValues) in
            if let topic = createTopic(fromKeyValues: keyValues) {
                topics.append(topic)
            }
        }
        return topics
    }
    //字典 -> 模型 并存进数据库
    func createTopic(fromKeyValues keyValues: AnyObject) -> Topic? {
        if let id = keyValues["id"] as? NSNumber{
            guard let t = TopicByID(id) else {//检查数据库中有没有数据
                //获取entity
                guard let entity = NSEntityDescription.entityForName("Topic", inManagedObjectContext: managedObjectContext) else {
                    debugPrint("No entity.")
                    return .None
                }
                //插入一个entity
                guard let t = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext) as? Topic else {
                    debugPrint("Failed to insert")
                    return .None
                }
                //在新创建的模型上更新模型
                let topic = t.mj_setKeyValues(keyValues, context: managedObjectContext)
                //保存
                saveContext()
                return topic
            }
            //拿到数据库中的模型,并更新模型
            let topic = t.mj_setKeyValues(keyValues, context: managedObjectContext)
            //保存
            saveContext()
            return topic
        }
        return .None
    }
    //MARK: -删
    func deleteTopic(topic: Topic) {
        managedObjectContext.deleteObject(topic)
        //删除后要保存下,不然会没有效果
        saveContext()
    }
    //MARK: -查
    //获取指定ID的帖子
    func TopicByID(ID: NSNumber) -> Topic? {
        let predicate = NSPredicate(format: "id == \(ID)")
        let topics = objectArrayByPredicate("Topic", predicate:predicate) as! [Topic]
        guard let topic = topics.first else {return .None}
        return topic
    }
}