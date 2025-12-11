//
//  SignupViewModel.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation
internal import Combine

@MainActor
final class SignupViewModel: ObservableObject {

    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let authService: AuthServiceProtocol
    private let router = AppRouter.shared

    init(authService: AuthServiceProtocol = DIContainer.shared.authService) {
        self.authService = authService
    }

    func signup() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "All fields are required"
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.signup(email: email, password: password)

            // after signup → logged in
            router.isLoggedIn = true

        } catch {
            errorMessage = "Signup failed: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

