//
//  Node+CoreDataProperties.swift
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

extension Node {

    @NSManaged var avatar_large: String?
    @NSManaged var avatar_mini: String?
    @NSManaged var avatar_normal: String?
    @NSManaged var created: NSNumber?
    @NSManaged var footer: String?
    @NSManaged var header: String?
    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var stars: NSNumber?
    @NSManaged var tagline: String?
    @NSManaged var title: String?
    @NSManaged var title_alternative: String?
    @NSManaged var topics: NSNumber?
    @NSManaged var url: String?
    @NSManaged var username: String?
    @NSManaged var topic: NSSet?

}
