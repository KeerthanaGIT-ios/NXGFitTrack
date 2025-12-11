//
//  ProfileService.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation

protocol ProfileServiceProtocol {
    func fetchProfile() async throws -> ProfileDTO
    func updateProfile(_ profile: ProfileDTO) async throws
}

final class ProfileService: ProfileServiceProtocol {

    private let client: NetworkClient

    init(client: NetworkClient) {
        self.client = client
    }

    func fetchProfile() async throws -> ProfileDTO {
        let dto: ProfileDTO = try await client.request(.getProfile)
        return dto
    }

    func updateProfile(_ profile: ProfileDTO) async throws {
        _ = try await client.request(.updateProfile(profile)) as Data
    }
}

