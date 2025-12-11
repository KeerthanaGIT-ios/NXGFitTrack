//
//  SyncOperation.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation

struct SyncOperation: Codable {
    let endpoint: String  
    let payload: String    // JSON string
}
