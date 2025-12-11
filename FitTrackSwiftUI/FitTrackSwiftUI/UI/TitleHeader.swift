//
//  TitleHeader.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation
import SwiftUI

struct TitleHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(AppFont.title)
            .padding(.vertical, 8)
    }
}
