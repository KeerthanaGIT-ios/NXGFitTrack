//
//  SignupView.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import SwiftUI

struct SignupView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = SignupViewModel()

    var body: some View {
        VStack(spacing: 20) {

            Text("Create Account")
                .font(.largeTitle)
                .bold()
                .padding(.top, 40)

            TextField("Email", text: $vm.email)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.none)
                .padding(.horizontal)

            SecureField("Password", text: $vm.password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            SecureField("Confirm Password", text: $vm.confirmPassword)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            if let error = vm.errorMessage {
//                Text(error)
//                    .foregroundColor(.red)
                ErrorBanner(message: error)
            }

            Button {
                Task { await vm.signup() }
            } label: {
                if vm.isLoading {
//                    ProgressView()
                    LoadingOverlay()
                } else {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

