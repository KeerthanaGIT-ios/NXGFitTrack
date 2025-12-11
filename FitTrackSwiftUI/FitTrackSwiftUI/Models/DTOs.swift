//
//  DTOs.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
}

struct ProfileDTO: Codable {
    var name: String
    var weightKg: Double
    var heightCm: Double
}

