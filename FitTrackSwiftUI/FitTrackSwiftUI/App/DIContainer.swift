//
//  DIContainer.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation

final class DIContainer {
    static let shared = DIContainer()

    // MARK: - Services
    var networkClient: NetworkClient
    var authService: AuthServiceProtocol
    var profileService: ProfileServiceProtocol
    var sessionService: SessionServiceProtocol
    var workoutsService: WorkoutsServiceProtocol
    var syncService: SyncService
    var syncQueueService: SyncQueueService

    // Toggle this flag to switch between pure in-app mock and real HTTP backend.
    // - useMockNetwork = true  → everything served from MockNetworkClient (no real HTTP)
    // - useMockNetwork = false → real HTTP via URLSessionNetworkClient
    private let useMockNetwork: Bool = true

    private init() {
        let client: NetworkClient

        if useMockNetwork {
            client = MockNetworkClient()
        } else {
            client = URLSessionNetworkClient()
        }

        self.networkClient = client
        self.authService = AuthService(client: client)
        self.profileService = ProfileService(client: client)
        self.workoutsService = WorkoutsService(client: client)
        self.sessionService = SessionService()
        self.syncService = SyncService(network: client)
        self.syncQueueService = SyncQueueService()
    }
}
