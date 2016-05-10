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
