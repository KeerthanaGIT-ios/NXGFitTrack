//
//  ProfileViewModel.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation
internal import Combine

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var name = ""
    @Published var weight = ""
    @Published var height = ""

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let service: ProfileServiceProtocol
    private let authService: AuthServiceProtocol
    private let router = AppRouter.shared

    init(service: ProfileServiceProtocol = DIContainer.shared.profileService,
         authService: AuthServiceProtocol = DIContainer.shared.authService) {
        self.service = service
        self.authService = authService
    }

    func loadProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            let dto = try await service.fetchProfile()
            name = dto.name
            weight = String(Int(dto.weightKg))
            height = String(Int(dto.heightCm))
        } catch {
            errorMessage = "Failed to load profile"
        }

        isLoading = false
    }

    func save() async {
        guard let weightVal = Double(weight),
              let heightVal = Double(height) else {
            errorMessage = "Invalid numeric values"
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        let dto = ProfileDTO(name: name, weightKg: weightVal, heightCm: heightVal)

        do {
            try await service.updateProfile(dto)
            successMessage = "Saved!"
        } catch {
            errorMessage = "Save failed"
        }

        isLoading = false
    }
    
    func logout() {
        authService.logout()
        router.isLoggedIn = false
    }
}
