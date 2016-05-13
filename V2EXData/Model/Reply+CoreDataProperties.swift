//
//  Reply+CoreDataProperties.swift
//  
//
//  Created by LLZ on 16/5/13.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Reply {

    @NSManaged var id: NSNumber?
    @NSManaged var created: NSNumber?
    @NSManaged var content_rendered: String?
    @NSManaged var content: String?
    @NSManaged var thanks: NSNumber?
    @NSManaged var last_modified: NSNumber?
    @NSManaged var member: Member?
    @NSManaged var topic: Topic?

}
