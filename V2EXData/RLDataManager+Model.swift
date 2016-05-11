//
//  RLDataManager+Model.swift
//  V2EX
//
//  Created by rylynn lai on 16/5/11.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import Foundation
extension RLDataManager {
    //MARK: -增
    //字典 -> 模型 并存进数据库
    func create(entityName:String, fromKeyValues keyValues: AnyObject, withIdentifier identifier:String) -> NSManagedObject? {
        if let id = keyValues[identifier] as AnyObject {
            let predicate = NSPredicate(format: "\(entityName) == %@", argumentArray:[id])
            let topics = RLDataManager.sharedManager.objectArrayByPredicate("Topic", predicate:predicate) as! [Topic]

            
            
            
            guard let t = TopicByID(id) else {//检查数据库中有没有数据
                return dataManager.create("Topic", fromKeyValues: keyValues) as? Topic
            }
            //拿到数据库中的模型,并更新模型
            let topic = t.mj_setKeyValues(keyValues, context: RLDataManager.sharedManager.managedObjectContext)
            //保存
            dataManager.saveContext()
            return topic
        }
        
        
        if let value = ID  {
            let predicate = NSPredicate(format: "id == %@", argumentArray:[value])
            let topics = RLDataManager.sharedManager.objectArrayByPredicate("Topic", predicate:predicate) as! [Topic]
            guard let topic = topics.first else {return .None}
            return topic
        }
        
        
        
        
        //创建并插入
        let t = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: managedObjectContext)
        
        //在新创建的模型上更新模型
        let item = t.mj_setKeyValues(keyValues, context: managedObjectContext)
        //保存
        saveContext()
        return item
    }
    
    //删
    func delete(object: NSManagedObject) {
        managedObjectContext.deleteObject(object)
        //删除后要保存下,不然会没有效果
        saveContext()
    }
    //根据查询条件查询数据库
    func objectArrayByPredicate(entityName:String, predicate: NSPredicate) -> [AnyObject] {
        var items = [AnyObject]()
        
        //创建一个查询获取请求
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: entityName)
        
        //设置查询条件
        fetchRequest.predicate = predicate
        
        //查询操作
        guard let results = try? managedObjectContext.executeFetchRequest(fetchRequest) else { return items }
        
        results.filter { !$0.deleted }.forEach { items.append($0) }
        
        return items
    }

}