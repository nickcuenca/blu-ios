//
//  RegistrationView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/27/25.
//

import SwiftUI

struct RegistrationView: View {
    @AppStorage("username") var username: String = ""         // Display name
    @AppStorage("userHandle") var userHandle: String = ""     // Unique handle

    @State private var inputName = ""
    @State private var inputHandle = ""

    var body: some View {
        VStack(spacing: 32) {
            Text("Welcome to Blü 👋")
                .font(.largeTitle)
                .bold()
                .padding(.top)

            VStack(alignment: .leading, spacing: 12) {
                Text("What's your name?")
                    .font(.headline)

                TextField("Enter your full name", text: $inputName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 12) {
                Text("Choose a username")
                    .font(.headline)

                TextField("@yourhandle", text: $inputHandle)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)

            Button(action: {
                username = inputName
                userHandle = inputHandle.lowercased()
            }) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(inputIsValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .disabled(!inputIsValid)
        }
        .padding()
    }

    var inputIsValid: Bool {
        !inputName.isEmpty &&
        !inputHandle.isEmpty &&
        !inputHandle.contains(" ")
    }
}
