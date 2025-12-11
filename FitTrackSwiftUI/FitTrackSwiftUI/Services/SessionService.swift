//
//  SessionService.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation
internal import CoreData

protocol SessionServiceProtocol {
    func startSession(from template: WorkoutTemplateDTO) -> Session
    func addSet(to session: Session, exerciseName: String)
    func updateSet(_ set: SetEntry, reps: Int, weight: Double)
    func toggleComplete(_ set: SetEntry)
    func endSession(_ session: Session)
}

final class SessionService: SessionServiceProtocol {

    private let context = PersistenceController.shared.viewContext

    func startSession(from template: WorkoutTemplateDTO) -> Session {
        let session = Session(context: context)
        session.id = UUID()
        session.createdAt = Date()
        session.synced = false
        session.workoutTitle = template.title

        // create default sets per exercise
        template.exercises.forEach { ex in
            for i in 0..<ex.defaultSets {
                let set = SetEntry(context: context)
                set.id = UUID()
                set.exerciseName = ex.name
                set.reps = Int16(ex.defaultReps)
                set.weightKg = 0
                set.orderIndex = Int16(i)
                set.isCompleted = false

                set.session = session
            }
        }

        try? context.save()
        return session
    }

    func addSet(to session: Session, exerciseName: String) {
        let set = SetEntry(context: context)
        set.id = UUID()
        set.exerciseName = exerciseName
        set.reps = 10
        set.weightKg = 0
        set.isCompleted = false
        set.orderIndex = Int16((session.sets?.count ?? 0))
        set.session = session
        try? context.save()
    }

    func updateSet(_ set: SetEntry, reps: Int, weight: Double) {
        set.reps = Int16(reps)
        set.weightKg = weight
        try? context.save()
    }

    func toggleComplete(_ set: SetEntry) {
        set.isCompleted.toggle()
        try? context.save()
    }

    
    func endSession(_ session: Session) {
        session.endedAt = Date()
        session.synced = false
        try? context.save()

        // -------- STEP 8.8 SYNC QUEUE ----------
        let dto = SessionDTO.from(session)

        guard let jsonData = try? JSONEncoder().encode(dto),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }

        let op = SyncOperation(endpoint: "/sessions", payload: jsonString)

        guard let opData = try? JSONEncoder().encode(op),
              let opString = String(data: opData, encoding: .utf8) else {
            return
        }

        DIContainer.shared.syncQueueService.enqueue(endpoint: "/sessions", json: opString)
        // -----------------------------------------
    }

}
