//
//  AppRouter.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation
internal import Combine

class AppRouter: ObservableObject {
    @Published var isLoggedIn: Bool = false

    static let shared = AppRouter()
    
    init() {
        // Check if user is already logged in (has valid token)
        isLoggedIn = KeychainManager.shared.hasValidToken
    }
}

