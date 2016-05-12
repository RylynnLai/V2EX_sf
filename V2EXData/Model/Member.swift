//
//  Member.swift
//  V2EX
//
//  Created by LLZ on 16/5/5.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import Foundation
import CoreData

@objc(Member)
class Member: NSManagedObject {
    //MARK: -增
    class func createMembersArray(fromKeyValuesArray keyValuesArray: AnyObject) -> [Member] {
        var members = [Member]()
        
        guard let arr = keyValuesArray as? [AnyObject] else { return members}
        
        arr.forEach { (keyValues) in
            if let member = createMember(fromKeyValues: keyValues) {
                members.append(member)
            }
        }
        return members
    }
    
    class func createMember(fromKeyValues keyValues: AnyObject) -> Member? {
        if let member = RLDataManager.sharedManager.create("Member", fromKeyValues: keyValues, withIdentifier: "username") as? Member {
            return member
        }
        return .None
    }
    //MARK: -查
    //获取指定ID的用户
    class func MemberByUsername(username: String?) -> Member? {
        if let value = username  {
            let predicate = NSPredicate(format: "username == %@", argumentArray:[value])
            let members = RLDataManager.sharedManager.objectArrayByPredicate("Member", predicate: predicate) as! [Member]
            guard let member = members.first else {return .None}
            return member
        }
        return .None
    }
}
