//
//  URLSessionNetworkClient.swift
//  FitTrackSwiftUI
//
//  Created by Agent on 10/12/25.
//

import Foundation

/// Concrete NetworkClient implementation backed by URLSession.
///
/// This is used when you want to talk to a real HTTP backend (e.g. mockapi.io).
final class URLSessionNetworkClient: NetworkClient {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let (data, response) = try await session.data(for: endpoint.urlRequest)
        try Self.validate(response: response, data: data)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func request(_ endpoint: APIEndpoint) async throws -> Data {
        let (data, response) = try await session.data(for: endpoint.urlRequest)
        try Self.validate(response: response, data: data)
        return data
    }

    // MARK: - Helpers

    private static func validate(response: URLResponse?, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200..<300).contains(http.statusCode) else {
            // Simple error wrapper – you can enhance this later
            let body = String(data: data, encoding: .utf8) ?? "<no body>"
            throw NetworkError.httpError(status: http.statusCode, body: body)
        }
    }
}

enum NetworkError: Error {
    case httpError(status: Int, body: String)
}
