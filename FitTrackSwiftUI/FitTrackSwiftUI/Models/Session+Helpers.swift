//
//  Session+Helpers.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation

extension Session {
    var setsArray: [SetEntry] {
        let set = sets as? Set<SetEntry> ?? []
        return set.sorted { $0.orderIndex < $1.orderIndex }
    }
}
