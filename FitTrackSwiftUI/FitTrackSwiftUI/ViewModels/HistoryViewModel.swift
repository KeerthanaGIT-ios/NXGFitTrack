//
//  HistoryViewModel.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation
internal import CoreData
internal import Combine

@MainActor
final class HistoryViewModel: ObservableObject {

    @Published var sessions: [Session] = []
    @Published var summaries: [SessionSummaryDTO] = []
    @Published var personalBests: [PersonalBestDTO] = []
    @Published var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @Published var endDate: Date = Date()

    private let context = PersistenceController.shared.viewContext

    func load() {
        let req = Session.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        // Apply date range filter
        req.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt <= %@", 
                                    startDate as NSDate, 
                                    endDate as NSDate)

        sessions = (try? context.fetch(req)) ?? []

        summaries = sessions.map { session in
            SessionSummaryDTO(
                id: session.id ?? UUID(),
                date: session.createdAt ?? Date(),
                workoutTitle: session.workoutTitle ?? "",
                totalVolume: MetricsCalculator.calculateVolume(for: session)
            )
        }

        personalBests = MetricsCalculator.personalBest(from: sessions)
    }
}
