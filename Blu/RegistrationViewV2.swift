//  RegistrationViewV2.swift
//  Blu
//  Created by Nicolas Cuenca on 3/28/25.

import SwiftUI
import PhotosUI
import FirebaseFirestore

struct RegistrationViewV2: View {
    @AppStorage("username") var username: String = ""
    @AppStorage("userEmail") var userEmail: String = ""
    @AppStorage("userHandle") var userHandle: String = ""
    @AppStorage("userPassword") var userPassword: String = ""
    @AppStorage("venmoUsername") var venmoUsername: String = ""
    @AppStorage("cashAppTag") var cashAppTag: String = ""
    @AppStorage("zelleInfo") var zelleInfo: String = ""
    @AppStorage("userProfileImageData") var userProfileImageData: Data?

    @State private var nameInput = ""
    @State private var emailInput = ""
    @State private var handleInput = ""
    @State private var passwordInput = ""
    @State private var venmoInput = ""
    @State private var cashAppInput = ""
    @State private var zelleInput = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil
    @State private var step = 0

    var body: some View {
        VStack(spacing: 30) {
            if step > 0 && step < 6 {
                Button(action: { step -= 1 }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            switch step {
            case 0:
                Text("What should we call you?")
                    .font(.title)
                TextField("Enter your name", text: $nameInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button("Next") { step += 1 }
                    .disabled(nameInput.isEmpty)

            case 1:
                Text("Choose a username")
                    .font(.title)
                TextField("Enter a username", text: $handleInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button("Next") { step += 1 }
                    .disabled(handleInput.isEmpty)

            case 2:
                Text("Create a password")
                    .font(.title)
                SecureField("Enter password", text: $passwordInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button("Next") { step += 1 }
                    .disabled(passwordInput.isEmpty)

            case 3:
                Text("What’s your email?")
                    .font(.title)
                TextField("Enter your email", text: $emailInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button("Next") { step += 1 }
                    .disabled(emailInput.isEmpty)

            case 4:
                Text("Payment Handles (Optional)")
                    .font(.title3)
                VStack(spacing: 10) {
                    TextField("Venmo Username", text: $venmoInput)
                    TextField("Cash App Tag", text: $cashAppInput)
                    TextField("Zelle Email/Phone", text: $zelleInput)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                Button("Next") { step += 1 }

            case 5:
                Text("Add a profile picture (optional)")
                    .font(.headline)

                if let image = profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 150, height: 150)
                        .overlay(Text("No Image").font(.caption))
                }

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Text("Choose Photo")
                        .foregroundColor(.blue)
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            profileImage = uiImage
                            userProfileImageData = data
                        }
                    }
                }

                Button("Finish") {
                    username = nameInput
                    userHandle = handleInput
                    userPassword = passwordInput
                    userEmail = emailInput
                    venmoUsername = venmoInput
                    cashAppTag = cashAppInput
                    zelleInfo = zelleInput
                    step += 1

                    let db = Firestore.firestore()
                    let userID = UUID().uuidString

                    let userData: [String: Any] = [
                        "username": userID,
                        "handle": nameInput,
                        "email": emailInput,
                        "friends": [],
                        "createdAt": Timestamp(date: Date())
                    ]

                    db.collection("users").document(userID).setData(userData) { error in
                        if let error = error {
                            print("Error saving user: \(error)")
                        } else {
                            print("User saved to Firestore!")
                        }
                    }

                    step += 1
                }

            default:
                Text("You're all set, \(username)!")
                    .font(.title2)
                    .padding()
                Text("Launching Blü...")
                    .foregroundColor(.gray)
                ProgressView()
            }
        }
        .padding()
        .animation(.easeInOut, value: step)
    }
}

struct RegistrationViewV2_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationViewV2()
    }
}
