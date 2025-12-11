//
//  FitTrackSwiftUIApp.swift
//  FitTrackSwiftUI
//
//  Created by Keetzz on 10/12/25.
//

import SwiftUI

@main
struct FitTrackSwiftUIApp: App {
  
    @StateObject private var router = AppRouter.shared

    var body: some Scene {
        WindowGroup {
            if router.isLoggedIn {
                HomeView()
            } else {
                LoginView()
            }
        }
    }
}
