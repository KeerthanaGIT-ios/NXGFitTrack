//
//  LoginViewModel.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation
internal import Combine

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let authService: AuthServiceProtocol
    private let router = AppRouter.shared


    init(authService: AuthServiceProtocol = DIContainer.shared.authService) {
        self.authService = authService
    }

    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.login(email: email, password: password)
            print("Login successful")

            // Navigate later to Home tab
            router.isLoggedIn = true


        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

