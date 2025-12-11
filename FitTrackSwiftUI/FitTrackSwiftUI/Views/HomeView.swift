//
//  HomeView.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
       
        TabView {
            WorkoutsView()
                .tabItem { Label("Workouts", systemImage: "figure.strengthtraining.traditional") }

            HistoryView()
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }

            MetricsView()
                .tabItem { Label("Metrics", systemImage: "chart.line.uptrend.xyaxis") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle") }
        }


    }
}

