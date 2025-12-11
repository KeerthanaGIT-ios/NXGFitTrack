//
//  SyncQueueItem+CoreDataProperties.swift
//  FitTrackSwiftUI
//
//  Created by Keetzz on 10/12/25.
//
//

public import Foundation
public import CoreData


public typealias SyncQueueItemCoreDataPropertiesSet = NSSet

extension SyncQueueItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SyncQueueItem> {
        return NSFetchRequest<SyncQueueItem>(entityName: "SyncQueueItem")
    }

    @NSManaged public var attempts: Int16
    @NSManaged public var createdAt: Date?
    @NSManaged public var endpoint: String?
    @NSManaged public var id: UUID?
    @NSManaged public var payload: String?

}

extension SyncQueueItem : Identifiable {

}
