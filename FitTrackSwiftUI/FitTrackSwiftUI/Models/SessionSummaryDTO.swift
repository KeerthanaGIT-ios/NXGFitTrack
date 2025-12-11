//
//  SessionSummaryDTO.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation

struct SessionSummaryDTO: Identifiable {
    let id: UUID
    let date: Date
    let workoutTitle: String
    let totalVolume: Double
}
