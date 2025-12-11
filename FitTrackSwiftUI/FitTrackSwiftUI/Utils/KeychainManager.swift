//
//  KeychainManager.swift
//  FitTrackApp
//
//  Created by Keetzz on 10/12/25.
//

import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()
    
    private let service = "com.fittrack.tokens"
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    private init() {}
    
    // MARK: - Save Token
    func saveAccessToken(_ token: String) throws {
        try save(token, forKey: accessTokenKey)
    }
    
    func saveRefreshToken(_ token: String) throws {
        try save(token, forKey: refreshTokenKey)
    }
    
    func saveTokens(accessToken: String, refreshToken: String) throws {
        try saveAccessToken(accessToken)
        try saveRefreshToken(refreshToken)
    }
    
    private func save(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.dataConversionFailed
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    // MARK: - Retrieve Token
    func getAccessToken() -> String? {
        return get(forKey: accessTokenKey)
    }
    
    func getRefreshToken() -> String? {
        return get(forKey: refreshTokenKey)
    }
    
    private func get(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    // MARK: - Delete Tokens
    func deleteAccessToken() {
        delete(forKey: accessTokenKey)
    }
    
    func deleteRefreshToken() {
        delete(forKey: refreshTokenKey)
    }
    
    func deleteAllTokens() {
        deleteAccessToken()
        deleteRefreshToken()
    }
    
    private func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - Check if logged in
    var hasValidToken: Bool {
        return getAccessToken() != nil
    }
}

enum KeychainError: Error, LocalizedError {
    case dataConversionFailed
    case saveFailed(OSStatus)
    case retrievalFailed(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .dataConversionFailed:
            return "Failed to convert token to data"
        case .saveFailed(let status):
            return "Failed to save token to Keychain: \(status)"
        case .retrievalFailed(let status):
            return "Failed to retrieve token from Keychain: \(status)"
        }
    }
}

