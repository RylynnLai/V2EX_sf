//
//  TopicEntity.swift
//  V2EX
//
//  Created by LLZ on 16/5/3.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import Foundation
import CoreData


class TopicEntity: NSManagedObject {
    
     var content: String?
     var content_rendered: String?
     var created: String?
     var createdTime: String?
     var id: String?
     var last_modified: String?
     var last_touched: String?
     var replies: String?
     var title: String?
     var url: String?

}
