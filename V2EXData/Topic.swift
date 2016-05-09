//
//  Topic.swift
//  V2EX
//
//  Created by LLZ on 16/5/5.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import Foundation
import CoreData


class Topic: NSManagedObject {
    override func mj_newValueFromOldValue(oldValue: AnyObject!, property: MJProperty!) -> AnyObject! {
        if property.name == "node" {
            if let keyValues = oldValue as? [String: String] {
                guard let n = Node.NodeByName(keyValues["name"]!) else {
                    return oldValue
                }
                return n
            }
        } else if property.name == "member" {
            if let keyValues = oldValue as? [String: String] {
                guard let m = Member.MemberByUsername(keyValues["username"]!) else {
                    return oldValue
                }
                return m
            }
        }
        return oldValue
    }
}
