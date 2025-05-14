// LoginView.swift
import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var switchTo: GetStartedView.Screen
    @Environment(\.dismiss) private var dismiss

    @AppStorage("userID") private var userID: String = ""

    @State private var email = ""
    @State private var password = ""
    @State private var error: String?
    @State private var busy = false

    var body: some View {
        Form {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            SecureField("Password", text: $password)

            if let error {
                Text(error).foregroundStyle(.red)
            }

            Button(busy ? "Logging in…" : "Log in") {
                login()
            }
            .disabled(busy || email.isEmpty || password.count < 6)
        }
        .navigationTitle("Log in")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") { switchTo = .intro }
            }
        }
    }

    private func login() {
        busy = true
        error = nil
        Task {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
                if let uid = Auth.auth().currentUser?.uid {
                    userID = uid
                }
                CurrentUserStore.shared.startListening()
                switchTo = .app
            } catch {
                self.error = error.localizedDescription
            }
            busy = false
        }
    }
}
