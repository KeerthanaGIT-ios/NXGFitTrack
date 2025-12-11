//
//  WorkoutsService.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation

protocol WorkoutsServiceProtocol {
    func fetchWorkouts() async throws -> [WorkoutTemplateDTO]
}

final class WorkoutsService: WorkoutsServiceProtocol {

    private let client: NetworkClient

    init(client: NetworkClient) {
        self.client = client
    }

    func fetchWorkouts() async throws -> [WorkoutTemplateDTO] {
        try await client.request(.workouts)
    }
}

