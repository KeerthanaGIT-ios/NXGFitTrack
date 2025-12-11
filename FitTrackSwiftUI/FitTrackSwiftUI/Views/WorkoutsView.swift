//
//  WorkoutsView.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import SwiftUI

struct WorkoutsView: View {

    @StateObject private var vm = WorkoutsViewModel()

    var body: some View {
        NavigationStack {
            List(vm.workouts) { workout in
                NavigationLink {
                    WorkoutDetailView(workout: workout)
                } label: {
                    VStack(alignment: .leading) {
                        Text(workout.title)
                            .font(.headline)
                        Text(workout.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Workouts")
            .task {
                await vm.load()
            }
        }
    }
}
