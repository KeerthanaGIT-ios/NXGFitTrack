//
//  SetEntry+CoreDataProperties.swift
//  FitTrackSwiftUI
//
//  Created by Keetzz on 10/12/25.
//
//

public import Foundation
public import CoreData


public typealias SetEntryCoreDataPropertiesSet = NSSet

extension SetEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SetEntry> {
        return NSFetchRequest<SetEntry>(entityName: "SetEntry")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var exerciseName: String?
    @NSManaged public var reps: Int16
    @NSManaged public var weightKg: Double
    @NSManaged public var note: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var orderIndex: Int16
    @NSManaged public var session: Session?

}

extension SetEntry : Identifiable {

}
