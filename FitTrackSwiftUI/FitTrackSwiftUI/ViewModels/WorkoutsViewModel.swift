//
//  WorkoutsViewModel.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation
internal import Combine

@MainActor
final class WorkoutsViewModel: ObservableObject {

    @Published var workouts: [WorkoutTemplateDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: WorkoutsServiceProtocol

    init(service: WorkoutsServiceProtocol = DIContainer.shared.workoutsService) {
        self.service = service
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            workouts = try await service.fetchWorkouts()
        } catch {
            errorMessage = "Failed to load workouts"
        }

        isLoading = false
    }
}

