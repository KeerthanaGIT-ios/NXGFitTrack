//
//  LoginView.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import SwiftUI

struct LoginView: View {

    @StateObject private var vm = LoginViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                TitleHeader(title: "FitTrack")

                VStack(spacing: 16) {
                    TextField("Email", text: $vm.email)
                        .textFieldStyle(.roundedBorder)

                    SecureField("Password", text: $vm.password)
                        .textFieldStyle(.roundedBorder)

                    if let error = vm.errorMessage {
                        ErrorBanner(message: error)
                    }

                    Button("Log In") {
                        Task { await vm.login() }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
                .background(.white)
                .cornerRadius(12)
                .shadow(radius: 3)
                .padding(.horizontal)

                Spacer()

                NavigationLink("Create an account") {
                    SignupView()
                }

                Spacer()
            }
            .background(AppColor.background.ignoresSafeArea())
        }
    }
}

