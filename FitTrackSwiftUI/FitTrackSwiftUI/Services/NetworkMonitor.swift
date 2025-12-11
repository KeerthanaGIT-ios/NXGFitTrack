//
//  NetworkMonitor.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation
import Network
internal import Combine

final class NetworkMonitor: ObservableObject {

    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected: Bool = true

    private init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = (path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
}
