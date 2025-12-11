//
//  SessionDTO.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation

struct SessionDTO: Codable {
    let id: UUID
    let createdAt: Date
    let endedAt: Date
    let workoutTitle: String
    let sets: [SetDTO]

    static func from(_ session: Session) -> SessionDTO {
        SessionDTO(
            id: session.id ?? UUID(),
            createdAt: session.createdAt ?? Date(),
            endedAt: session.endedAt ?? Date(),
            workoutTitle: session.workoutTitle ?? "",
            sets: session.setsArray.map { SetDTO.from($0) }
        )
    }
}

struct SetDTO: Codable {
    let exerciseName: String
    let reps: Int
    let weightKg: Double
    let isCompleted: Bool
    let orderIndex: Int

    static func from(_ set: SetEntry) -> SetDTO {
        SetDTO(
            exerciseName: set.exerciseName ?? "",
            reps: Int(set.reps),
            weightKg: set.weightKg,
            isCompleted: set.isCompleted,
            orderIndex: Int(set.orderIndex)
        )
    }
}
