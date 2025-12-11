//
//  WorkoutDTOs.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation

struct ExerciseDTO: Codable, Identifiable {
    let id: String
    let name: String
    let muscleGroup: String
    let defaultSets: Int
    let defaultReps: Int
    let equipment: String
}

struct WorkoutTemplateDTO: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let exercises: [ExerciseDTO]
}

