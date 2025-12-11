//
//  ErrorBanner.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation
import SwiftUI

struct ErrorBanner: View {
    let message: String
    var body: some View {
        Text(message)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red.opacity(0.9))
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.horizontal)
    }
}
