//
//  Topic.swift
//  V2EX
//
//  Created by LLZ on 16/5/4.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import Foundation
import CoreData


class Topic: NSManagedObject {
    
    @NSManaged var content: String?
    @NSManaged var content_rendered: String?
    @NSManaged var created: NSNumber?
    @NSManaged var createdTime: String?
    @NSManaged var id: NSNumber?
    @NSManaged var last_modified: NSNumber?
    @NSManaged var last_touched: NSNumber?
    @NSManaged var replies: NSNumber?
    @NSManaged var title: String?
    @NSManaged var url: String?

}
