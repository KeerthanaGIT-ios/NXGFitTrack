//
//  SessionViewModel.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation
internal import CoreData
internal import Combine

@MainActor
final class SessionViewModel: ObservableObject {

    @Published var session: Session
    @Published var setsByExercise: [String: [SetEntry]] = [:]

    private let service: SessionServiceProtocol

    init(session: Session,
         service: SessionServiceProtocol = DIContainer.shared.sessionService) {

        self.session = session
        self.service = service

        groupSets()
    }

    func groupSets() {
        let sets = session.setsArray 
        setsByExercise = Dictionary(grouping: sets, by: { $0.exerciseName ?? "" })
    }

    func addSet(for exercise: String) {
        service.addSet(to: session, exerciseName: exercise)
        groupSets()
    }

    func updateSet(_ set: SetEntry, reps: Int, weight: Double) {
        service.updateSet(set, reps: reps, weight: weight)
        groupSets()
    }

    func toggleComplete(_ set: SetEntry) {
        service.toggleComplete(set)
        groupSets()
    }

    func endSession() {
        service.endSession(session)
    }
}
