//
//  MockNetworkClient.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation

final class MockNetworkClient: NetworkClient {

    private var storedProfile = ProfileDTO(name: "Demo User", weightKg: 68, heightCm: 170)

    func request<T>(_ endpoint: APIEndpoint) async throws -> T where T : Decodable {
        switch endpoint {
        case .login(let email, _):
            let token = TokenResponse(accessToken: "mock_access_\(email)", refreshToken: "mock_refresh")
            return token as! T

        case .signup(let email, _):
            let token = TokenResponse(accessToken: "mock_access_\(email)", refreshToken: "mock_refresh")
            return token as! T

        case .getProfile:
            // Return the current stored profile.
            return storedProfile as! T

        case .updateProfile(let dto):
            // Update stored profile so subsequent GETs reflect the change.
            storedProfile = dto
            return Data() as! T
        case .workouts:
            let list = [
                WorkoutTemplateDTO(
                    id: "w1",
                    title: "Full Body Beginner",
                    description: "A basic full-body routine",
                    exercises: [
                        ExerciseDTO(id: "e1", name: "Push Ups", muscleGroup: "Chest", defaultSets: 3, defaultReps: 10, equipment: "Bodyweight"),
                        ExerciseDTO(id: "e2", name: "Squats", muscleGroup: "Legs", defaultSets: 3, defaultReps: 12, equipment: "Bodyweight"),
                        ExerciseDTO(id: "e3", name: "Plank", muscleGroup: "Core", defaultSets: 3, defaultReps: 30, equipment: "None")
                    ]
                ),
                WorkoutTemplateDTO(
                    id: "w2",
                    title: "Upper Body Strength",
                    description: "Chest, shoulders & arms",
                    exercises: [
                        ExerciseDTO(id: "e4", name: "Bench Press", muscleGroup: "Chest", defaultSets: 4, defaultReps: 8, equipment: "Barbell"),
                        ExerciseDTO(id: "e5", name: "Dumbbell Shoulder Press", muscleGroup: "Shoulders", defaultSets: 4, defaultReps: 10, equipment: "Dumbbells")
                    ]
                )
            ]
            return list as! T

        case .workout(let id):
            let template = WorkoutTemplateDTO(
                id: id,
                title: "Mock Workout \(id)",
                description: "Mock detail",
                exercises: []
            )
            return template as! T
        case .postSession:
            // simulate success
            return Data() as! T



        default:
            throw NSError(domain: "Mock", code: 404)
        }
    }

    func request(_ endpoint: APIEndpoint) async throws -> Data {
        return Data()
    }
}

