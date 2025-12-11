//
//  APIEndpoint.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation

enum APIEndpoint {
    case signup(email: String, password: String)
    case login(email: String, password: String)
    case getProfile
    case updateProfile(ProfileDTO)
    case workouts
    case workout(id: String)
    case postSession(SessionDTO)




    var url: URL { URL(string: "https://mock.fittrack.api")! }

    var urlRequest: URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = "POST" 
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainManager.shared.getAccessToken() {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        switch self {
        case .signup(let email, let password):
            req.url = url.appendingPathComponent("/signup")
            req.httpMethod = "POST"
            req.httpBody = try? JSONEncoder().encode(["email": email, "password": password])

        case .login(let email, let password):
            req.url = url.appendingPathComponent("/login")
            req.httpMethod = "POST"
            req.httpBody = try? JSONEncoder().encode(["email": email, "password": password])

        case .getProfile:
            req.url = url.appendingPathComponent("/user/profile")
            req.httpMethod = "GET"

        case .updateProfile(let dto):
            req.url = url.appendingPathComponent("/user/profile")
            req.httpMethod = "PUT"
            req.httpBody = try? JSONEncoder().encode(dto)
        case .workouts:
            req.url = url.appendingPathComponent("/workouts")
            req.httpMethod = "GET"

        case .workout(let id):
            req.url = url.appendingPathComponent("/workouts/\(id)")
            req.httpMethod = "GET"
        case .postSession(let dto):
            req.url = url.appendingPathComponent("/sessions")
            req.httpMethod = "POST"
            req.httpBody = try? JSONEncoder().encode(dto)


            
        default:
              break
        }

//        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return req
    }
}

