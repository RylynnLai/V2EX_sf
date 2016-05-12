//
//  Node.swift
//  V2EX
//
//  Created by LLZ on 16/5/5.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import Foundation
import CoreData

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
        if let node = RLDataManager.sharedManager.create("Node", fromKeyValues: keyValues, withIdentifier: "name") as? Node {
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
    
    class func allNodes() -> [Node] {
        let nodes = RLDataManager.sharedManager.objectArrayByPredicate("Node", predicate: nil) as! [Node]
        return nodes
    }
}
