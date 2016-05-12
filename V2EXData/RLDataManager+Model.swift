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
        if let id = keyValues[identifier] {
            //检查数据库有没有存在的
            let predicate = NSPredicate(format: "\(identifier) == %@", argumentArray:[id!])
            let objectArray = objectArrayByPredicate(entityName, predicate:predicate)
            guard let object = objectArray.first as? NSManagedObject else {
                //数据库没有则创建并插入
                let object = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: managedObjectContext)
                //在新创建的模型上更新模型
                let managedObject = object.mj_setKeyValues(keyValues, context: managedObjectContext)
                //保存
                saveContext()
                return managedObject
            }
            
            //拿到数据库中的模型,并更新模型
            let managedObject = object.mj_setKeyValues(keyValues, context: managedObjectContext)
            //保存
            saveContext()
            return managedObject
        }
        return .None
    }
    
    //删
    func delete(object: NSManagedObject) {
        managedObjectContext.deleteObject(object)
        //删除后要保存下,不然会没有效果
        saveContext()
    }
    //根据查询条件查询数据库
    func objectArrayByPredicate(entityName:String, predicate: NSPredicate?) -> [AnyObject] {
        var items = [AnyObject]()
        
        //创建一个查询获取请求
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: entityName)
        
        //设置查询条件
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        
        //查询操作
        guard let results = try? managedObjectContext.executeFetchRequest(fetchRequest) else { return items }
        
        results.filter { !$0.deleted }.forEach { items.append($0) }
        
        return items
    }

}