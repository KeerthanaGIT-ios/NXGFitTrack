//
//  NetworkClient.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation

protocol NetworkClient {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func request(_ endpoint: APIEndpoint) async throws -> Data
}

