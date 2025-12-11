//
//  Session+CoreDataProperties.swift
//  FitTrackSwiftUI
//
//  Created by Keetzz on 10/12/25.
//
//

public import Foundation
public import CoreData


public typealias SessionCoreDataPropertiesSet = NSSet

extension Session {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Session")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var endedAt: Date?
    @NSManaged public var synced: Bool
    @NSManaged public var workoutTitle: String?
    @NSManaged public var sets: NSSet?

}

// MARK: Generated accessors for sets
extension Session {

    @objc(addSetsObject:)
    @NSManaged public func addToSets(_ value: SetEntry)

    @objc(removeSetsObject:)
    @NSManaged public func removeFromSets(_ value: SetEntry)

    @objc(addSets:)
    @NSManaged public func addToSets(_ values: NSSet)

    @objc(removeSets:)
    @NSManaged public func removeFromSets(_ values: NSSet)

}

extension Session : Identifiable {

}
