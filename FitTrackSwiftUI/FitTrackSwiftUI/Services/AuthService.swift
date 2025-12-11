//
//  AuthService.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws
    func signup(email: String, password: String) async throws
    func logout()
}

final class AuthService: AuthServiceProtocol {

    private let client: NetworkClient

    init(client: NetworkClient) {
        self.client = client
    }

    func login(email: String, password: String) async throws {
        let response: TokenResponse = try await client.request(.login(email: email, password: password))
        try KeychainManager.shared.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
    }

    func signup(email: String, password: String) async throws {
        let response: TokenResponse = try await client.request(.signup(email: email, password: password))
        try KeychainManager.shared.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
    }
    
    func logout() {
        KeychainManager.shared.deleteAllTokens()
    }
}

