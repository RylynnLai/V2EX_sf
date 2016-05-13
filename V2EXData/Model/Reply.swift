//
//  Reply.swift
//  
//
//  Created by LLZ on 16/5/13.
//
//

import Foundation
import CoreData

@objc(Reply)
class Reply: NSManagedObject {
    //MARK: -增
    class func createRepliesArray(fromKeyValuesArray keyValuesArray: AnyObject) -> [Reply] {
        var replies = [Reply]()
        
        guard let arr = keyValuesArray as? [AnyObject] else { return replies}
        
        arr.forEach { (keyValues) in
            if let reply = createReply(fromKeyValues: keyValues) {
                replies.append(reply)
            }
        }
        return replies
    }
    
    class func createReply(fromKeyValues keyValues: AnyObject) -> Reply? {
        if let reply = RLDataManager.sharedManager.create("Reply", fromKeyValues: keyValues, withIdentifier: "id") as? Reply {
            return reply
        }
        return .None
    }
    //MARK: -查
    //获取指定ID的用户
    class func ReplyByID(ID: NSNumber?) -> Reply? {
        if let value = ID  {
            let predicate = NSPredicate(format: "id == %@", argumentArray:[value])
            let replyies = RLDataManager.sharedManager.objectArrayByPredicate("Reply", predicate: predicate) as! [Reply]
            guard let reply = replyies.first else {return .None}
            return reply
        }
        return .None
    }
    //MARK: -MJExtension
    //截取Node和Member属性,防止重复插入数据
    override func mj_newValueFromOldValue(oldValue: AnyObject!, property: MJProperty!) -> AnyObject! {
        if property.name as String  == "node" {
            if let keyValues = oldValue as? NSDictionary {
                guard let n = Node.NodeByName(keyValues["name"] as? String) else {
                    return oldValue
                }
                return n
            }
        } else if property.name as String == "member" {
            if let keyValues = oldValue as? NSDictionary {
                guard let m = Member.MemberByUsername(keyValues["username"] as? String) else {
                    return oldValue
                }
                return m
            }
        }
        return oldValue
    }
}
