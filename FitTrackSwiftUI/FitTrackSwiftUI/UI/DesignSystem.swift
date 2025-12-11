//
//  DesignSystem.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation
import SwiftUI

enum AppColor {
    static let primary = Color.blue
    static let danger = Color.red
    static let success = Color.green
    static let background = Color(UIColor.systemGroupedBackground)
}

enum AppFont {
    static let title = Font.system(.title2, design: .rounded).bold()
    static let headline = Font.system(.headline, design: .rounded)
    static let body = Font.system(.body, design: .rounded)
}
