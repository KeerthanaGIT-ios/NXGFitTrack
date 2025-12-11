//
//  HistoryView.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation
import SwiftUI

struct HistoryView: View {

    @StateObject private var vm = HistoryViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                // Date Range Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date Range")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack {
                        DatePicker("From", selection: $vm.startDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .onChange(of: vm.startDate) { _, _ in vm.load() }
                        
                        DatePicker("To", selection: $vm.endDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .onChange(of: vm.endDate) { _, _ in vm.load() }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                
                List(vm.summaries) { summary in
                    VStack(alignment: .leading) {
                        Text(summary.workoutTitle)
                            .font(.headline)

                        Text(summary.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("Volume: \(Int(summary.totalVolume))")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("History")
            .onAppear { vm.load() }
        }
    }
}
