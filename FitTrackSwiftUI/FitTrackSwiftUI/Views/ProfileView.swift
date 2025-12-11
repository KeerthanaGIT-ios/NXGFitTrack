//
//  ProfileView.swift
//  FitTrackApp
//
//  Created by Keetzz on 09/12/25.
//

import Foundation
import SwiftUI

struct ProfileView: View {

    @StateObject private var vm = ProfileViewModel()

    var body: some View {
        ScrollView {

            VStack(alignment: .leading, spacing: 16) {

                Text("Profile")
                    .font(.largeTitle)
                    .bold()

                Group {
                    Text("Name")
                    TextField("Your name", text: $vm.name)
                        .textFieldStyle(.roundedBorder)
                }

                Group {
                    Text("Weight (kg)")
                    TextField("Weight", text: $vm.weight)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }

                Group {
                    Text("Height (cm)")
                    TextField("Height", text: $vm.height)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }

                if let err = vm.errorMessage {
                    Text(err).foregroundColor(.red)
                }

                if let success = vm.successMessage {
                    Text(success).foregroundColor(.green)
                }

                Button {
                    Task { await vm.save() }
                } label: {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.vertical)
                 Spacer()
                Button {
                    vm.logout()
                } label: {
                    Text("Logout")
                        .frame(maxWidth: .infinity)
                        .font(Font.subheadline)
                        .padding()
//                        .background(Color.red)
                        .foregroundColor(.red)
                        .cornerRadius(8)
                }
//                .buttonStyle(DangerButtonStyle())
                .padding(.vertical)

            }
            .padding()
        }
        .onAppear {
            Task { await vm.loadProfile() }
        }
    }
}
