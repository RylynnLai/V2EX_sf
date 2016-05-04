//
//  RLDataManager+Topic.swift
//  V2EX
//
//  Created by LLZ on 16/5/4.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import CoreData

extension RLDataManager {
    func createTopic(fromDictionary dictionary: AnyObject) -> Topic? {
        guard let entity = NSEntityDescription.entityForName("Topic", inManagedObjectContext: managedObjectContext) else {
            debugPrint("No entity.")
            return nil
        }
        guard let t = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext) as? Topic else {
            debugPrint("Failed to insert")
            return nil
        }
        //转成模型
        let topic = t.mj_setKeyValues(dictionary, context: managedObjectContext)
        //保存
        do {
            try
                managedObjectContext.save()
                saveContext()
                return topic
        } catch let error as NSError {
            debugPrint("Could not save Topic \(error), \(error.userInfo)")
        }
        return .None
    }
    
    
    
    //获取指定ID的帖子
    func TopicByIDString(ID: NSNumber) -> Topic? {
        let predicate = NSPredicate(format: "id == \(ID)")
        let topics = TopicByPredicate(predicate)
        guard let topic = topics.first else {return .None}
        return topic
    }
    
    //根据查询条件查询数据库
    func TopicByPredicate(predicate: NSPredicate) -> [Topic] {
        var topics = [Topic]()
      
        //创建一个查询获取请求
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Topic")
        
        //设置查询条件
        fetchRequest.predicate = predicate
        
        //查询操作
        guard let results = try? managedObjectContext.executeFetchRequest(fetchRequest) as! [Topic] else { return topics }
        
        results.filter { !$0.deleted }.forEach { topics.append($0) }
        
        return topics
    }
    
    
}