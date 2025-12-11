//
//  SyncQueueService.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation
internal import CoreData

final class SyncQueueService {

    private let context = PersistenceController.shared.viewContext

    func enqueue(endpoint: String, json: String) {
        let item = SyncQueueItem(context: context)
        item.id = UUID()
        item.endpoint = endpoint
        item.payload = json
        item.createdAt = Date()
        item.attempts = 0
        
        try? context.save()
    }

    func fetchQueue() -> [SyncQueueItem] {
        let request = SyncQueueItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        return (try? context.fetch(request)) ?? []
    }

    func remove(_ item: SyncQueueItem) {
        context.delete(item)
        try? context.save()
    }

    func incrementAttempts(_ item: SyncQueueItem) {
        item.attempts += 1
        try? context.save()
    }
}
