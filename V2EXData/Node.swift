//
//  Node.swift
//  V2EX
//
//  Created by LLZ on 16/5/5.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import Foundation
import CoreData

private let dataManager:RLDataManager = { return RLDataManager.sharedManager }()

@objc(Node)
class Node: NSManagedObject {
    //MARK: -增
    class func createNodesArray(fromKeyValuesArray keyValuesArray: AnyObject) -> [Node] {
        var nodes = [Node]()
        
        guard let arr = keyValuesArray as? [AnyObject] else { return nodes}
        
        arr.forEach { (keyValues) in
            if let node = createNode(fromKeyValues: keyValues) {
                nodes.append(node)
            }
        }
        return nodes
    }
    class func createNode(fromKeyValues keyValues: AnyObject) -> Node? {
        if let name = keyValues["name"] as? String{
            guard let t = NodeByName(name) else {//检查数据库中有没有数据
                return dataManager.create("Node", fromKeyValues: keyValues) as? Node
            }
            //拿到数据库中的模型,并更新模型
            let node = t.mj_setKeyValues(keyValues, context: RLDataManager.sharedManager.managedObjectContext)
            //保存
            dataManager.saveContext()
            return node
        }
        return .None
    }
    //MARK: -查
    //获取指定ID的用户
    class func NodeByName(name: String?) -> Node? {
        if let value = name {
            let predicate = NSPredicate(format: "name == %@", argumentArray:[value])
            let nodes = RLDataManager.sharedManager.objectArrayByPredicate("Node", predicate: predicate) as! [Node]
            guard let node = nodes.first else {return .None}
            return node
        }
        return .None
    }
}
