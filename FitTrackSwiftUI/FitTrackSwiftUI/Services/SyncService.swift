//
//  SyncService.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation

final class SyncService {

    private let queueService = SyncQueueService()
    private let network: NetworkClient
    private var timer: Timer?

    init(network: NetworkClient = DIContainer.shared.networkClient) {
        self.network = network
        startProcessor()
    }

    private func startProcessor() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            Task { await self.processQueue() }
        }
    }

    
    @MainActor
    func processQueue() async {
        guard NetworkMonitor.shared.isConnected else { return }

        let items = queueService.fetchQueue()

        for item in items {
            // 1. Ensure payload exists
            guard let payloadString = item.payload,
                  let opData = payloadString.data(using: .utf8) else {
                queueService.remove(item)
                continue
            }

            do {
                // 2. Decode SyncOperation (contains endpoint + payload)
                let op = try JSONDecoder().decode(SyncOperation.self, from: opData)

                // 3. Decode SessionDTO from op.payload
                guard let sessionData = op.payload.data(using: .utf8) else {
                    queueService.remove(item)
                    continue
                }

                let dto = try JSONDecoder().decode(SessionDTO.self, from: sessionData)

                // 4. Send to backend
                _ = try await network.request(.postSession(dto)) as Data

                // 5. On success: remove from queue
                queueService.remove(item)

            } catch {
                // 6. On failure: increment attempts, maybe drop if too many
                queueService.incrementAttempts(item)

                if item.attempts > 5 {
                    queueService.remove(item) // give up after 5 tries
                }
            }
        }
    }

}
