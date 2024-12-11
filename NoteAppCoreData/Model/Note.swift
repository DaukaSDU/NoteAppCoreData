//
//  Note.swift
//  NoteAppCoreData
//
//  Created by Daulet Omar on 12.12.2024.
//

import CoreData

@objc(Note)
class Note: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var title: String
    @NSManaged var desc: String
    @NSManaged var deletedDate: Date?
    @NSManaged var updatedAt: Date?
    @NSManaged var createdAt: Date?

    convenience init(id: NSNumber, title: String, desc: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)!
        self.init(entity: entity, insertInto: context)
        self.id = id
        self.title = title
        self.desc = desc
    }
}
