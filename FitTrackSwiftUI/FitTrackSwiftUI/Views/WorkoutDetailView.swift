//
//  WorkoutDetailView.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation
import SwiftUI
internal import CoreData

struct WorkoutDetailView: View {

    let workout: WorkoutTemplateDTO
    @State private var activeSession: Session?


    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text(workout.title)
                        .font(.largeTitle)
                        .bold()
                    
                    Text(workout.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text("Exercises")
                        .font(.title2)
                        .bold()
                    
                    ForEach(workout.exercises) { ex in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ex.name).font(.headline)
                            Text(ex.muscleGroup).font(.subheadline).foregroundColor(.secondary)
                            Text("Default: \(ex.defaultSets)x\(ex.defaultReps)")
                                .font(.caption)
                        }
                        .padding(.vertical, 6)
                    }
                    
                    Divider()
                    
                    Button {
                        print("Start Workout tapped")
                        let service = DIContainer.shared.sessionService
                        let session = service.startSession(from: workout)
                        
                        // Refresh the context to ensure relationships are loaded
                        let context = PersistenceController.shared.viewContext
                        context.refresh(session, mergeChanges: true)
                        
                        // Set session - this will trigger the fullScreenCover
                        activeSession = session
                    } label: {
                        Text("Start Workout")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                    .fullScreenCover(item: $activeSession) { session in
                        NavigationStack {
                            SessionView(vm: SessionViewModel(session: session))
                                .navigationTitle("Workout Session")
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                    
                }
                .padding()
            }
        }
    }
}
