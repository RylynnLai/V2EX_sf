//
//  RLDataManager.swift
//  V2EX
//
//  Created by LLZ on 16/5/4.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import UIKit
import CoreData


class RLDataManager {

    static let sharedManager = RLDataManager()
    
    private lazy var _oldDataDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let url = urls[urls.count-1]
        return url
    }()
    
    lazy var dataDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.LexTang.VPNOn" in the application's documents Application Support directory.
        return NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.VPNOn")!
    }()
    
    // MARK: - Core Data stack
    // 获取程序数据存放文档的路径
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.rylynn.V2EX" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    // 托管对象模型
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("V2EX", withExtension: "momd")!//获取V2EX.xcdatamodeld文件的路径
        return NSManagedObjectModel(contentsOfURL: modelURL)!// 通过momd文件对应的模型初始化托管对象模型
    }()
    //持久性存储区
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator:NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)// 通过托管对象模型初始化持久化存储区
        
        self.migrateToVersion2(coordinator!)
        
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")// 获取存储的数据库路径
        var failureReason = "There was an error creating or loading the application's saved data."
        
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: NSNumber(bool: true),
            NSInferMappingModelAutomaticallyOption: NSNumber(bool: true),
            "journal_mode": "WAL"
        ]
        
        guard let store = coordinator!.persistentStoreForURL(url) else{
        
            do {
                try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
            } catch let error as NSError {
                coordinator = nil
                NSLog("Unresolved error \(error), \(error.userInfo)")
                exit(1)
            } catch {
                fatalError()
            }
            return coordinator
        }
        
        return coordinator
    }()
    // 托管上下文对象
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator// 设置托管对象上下文管理的持久存储区
        return managedObjectContext
    }()
    
    // MARK: - Migration
    
    func migrateToVersion2(coordinator: NSPersistentStoreCoordinator) {
        let srcURL = self._oldDataDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        let dstURL = self.dataDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        
        if !NSFileManager.defaultManager().fileExistsAtPath(srcURL.path!) {
            return
        }
        
        if NSFileManager.defaultManager().fileExistsAtPath(dstURL.path!) {
            return
        }
        
        let options = NSDictionary(
            objects: [NSNumber(bool: true), NSNumber(bool: true), "WAL"],
            forKeys: [NSMigratePersistentStoresAutomaticallyOption, NSInferMappingModelAutomaticallyOption, "journal_mode"])
        
        var srcError: NSError?
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: srcURL, options: options as! [NSObject : AnyObject] as [NSObject : AnyObject])
        } catch let error as NSError {
            srcError = error
            debugPrint("Failed to add src store: \(srcError)")
            return
        }
        
        guard let oldStore = coordinator.persistentStoreForURL(srcURL) else { return }
        do {
            try coordinator.migratePersistentStore(oldStore, toURL: dstURL, options: options as? [NSObject : AnyObject], withType: NSSQLiteStoreType)
            do {
                try NSFileManager.defaultManager().removeItemAtPath(srcURL.path!)
            } catch _ {
            }
        } catch let error as NSError {
            debugPrint("Failed to migrate CoreData: \(error)")
        }
    }
    
    // MARK: - Core Data support
    // 保存上下文
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    //MARK: -增
    //字典 -> 模型 并存进数据库
    func create(entityName:String, fromKeyValues keyValues: AnyObject) -> NSManagedObject? {
        //获取entity
        guard let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext) else {
            debugPrint("No entity.")
            return .None
        }
        //插入一个entity
        guard let t = NSManagedObject.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext) as? Topic else {
            debugPrint("Failed to insert.")
            return .None
        }
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