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

    override init(
        entity: NSEntityDescription,
        insertIntoManagedObjectContext context: NSManagedObjectContext?
        ) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self = nil
    }
    
    //MARK: -查
    //获取指定ID的用户
    class func MemberByID(ID: NSNumber) -> Member? {
        let predicate = NSPredicate(format: "id == \(ID)")
        let members = RLDataManager.sharedManager.objectArrayByPredicate("Member", predicate: predicate) as! [Member]
        guard let member = members.first else {return .None}
        return member
    }
}
