//
//  MetricsView.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation
import SwiftUI
import Charts

struct MetricsView: View {

    @StateObject private var vm = HistoryViewModel() 

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                Text("Training Volume")
                    .font(.title2)
                    .bold()

                Chart(vm.summaries) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Volume", item.totalVolume)
                    )
                }
                .frame(height: 200)

                Divider()

                Text("Personal Bests")
                    .font(.title2)
                    .bold()

                Chart(vm.personalBests) { pb in
                    BarMark(
                        x: .value("Exercise", pb.exercise),
                        y: .value("Best", pb.best)
                    )
                }
                .frame(height: 250)

            }
            .padding()
        }
        .onAppear { vm.load() }
    }
}
