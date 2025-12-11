//
//  MetricsCalculator.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation

struct MetricsCalculator {

    static func calculateVolume(for session: Session) -> Double {
        session.setsArray.reduce(0) { result, set in
            result + (Double(set.reps) * set.weightKg)
        }
    }

    static func personalBest(from sessions: [Session]) -> [PersonalBestDTO] {

        var bests: [String: Double] = [:]

        for session in sessions {
            for set in session.setsArray {
                let score = Double(set.reps) * set.weightKg
                bests[set.exerciseName ?? ""] = max(bests[set.exerciseName ?? ""] ?? 0, score)
            }
        }

        return bests.map { PersonalBestDTO(exercise: $0.key, best: $0.value) }
    }
}

struct PersonalBestDTO: Identifiable {
    let id = UUID()
    let exercise: String
    let best: Double
}
