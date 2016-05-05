//
//  Member+CoreDataProperties.swift
//  V2EX
//
//  Created by LLZ on 16/5/5.
//  Copyright © 2016年 LLZ. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Member {

    @NSManaged var avatar_large: String?
    @NSManaged var avatar_mini: String?
    @NSManaged var avatar_normal: String?
    @NSManaged var id: String?
    @NSManaged var tagline: String?
    @NSManaged var username: String?

}
