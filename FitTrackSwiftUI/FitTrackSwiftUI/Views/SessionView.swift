//
//  SessionView.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation
import SwiftUI

struct SessionView: View {

    @ObservedObject var vm: SessionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                // Title
                Text(vm.session.workoutTitle ?? "Workout")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom)

                if vm.setsByExercise.isEmpty {
                    Text("No exercises in this workout")
                        .foregroundColor(.secondary)
                        .padding()
                }

                ForEach(vm.setsByExercise.keys.sorted(), id: \.self) { exercise in
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise)
                            .font(AppFont.headline)

                        ForEach(vm.setsByExercise[exercise] ?? []) { set in
                            HStack {
                                Button {
                                    vm.toggleComplete(set)
                                } label: {
                                    Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(set.isCompleted ? .green : .gray)
                                }

                                Stepper("Reps: \(set.reps)", value: Binding(
                                    get: { Int(set.reps) },
                                    set: { vm.updateSet(set, reps: $0, weight: set.weightKg) }
                                ))

                                Stepper("Kg: \(Int(set.weightKg))", value: Binding(
                                    get: { Int(set.weightKg) },
                                    set: { vm.updateSet(set, reps: Int(set.reps), weight: Double($0)) }
                                ))
                            }
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 1)
                        }

                        Button("Add Set") {
                            vm.addSet(for: exercise)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }

                // End Session Button
                Button("End Session") {
                    vm.endSession()
                    dismiss()
                }
                .buttonStyle(DangerButtonStyle())
                .padding(.top, 20)

            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}
