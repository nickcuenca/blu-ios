// SignUpView.swift
import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @Binding var switchTo: GetStartedView.Screen
    @Environment(\.dismiss) private var dismiss

    @AppStorage("userID") private var userID: String = ""

    @State private var name = ""
    @State private var username = ""
    @State private var email = ""
    @State private var pw1 = ""
    @State private var pw2 = ""
    @State private var venmo = ""
    @State private var paypal = ""
    @State private var error: String?
    @State private var busy = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                groupField("Full name", $name)
                groupField("Username", $username, .default)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                groupField("Email", $email, .emailAddress)
                SecureField("Password (min 6)", text: $pw1)
                    .textFieldStyle(.roundedBorder)
                SecureField("Confirm password", text: $pw2)
                    .textFieldStyle(.roundedBorder)

                Text("Payment handles").font(.headline).padding(.top)
                groupField("Venmo (optional)", $venmo)
                groupField("PayPal (optional)", $paypal)

                if let error {
                    Text(error).foregroundStyle(.red)
                }

                Button(busy ? "Creating…" : "Create account") {
                    create()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!valid || busy)
            }
            .padding()
        }
        .navigationTitle("Sign up")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") { switchTo = .intro }
            }
        }
    }

    private func groupField(_ prompt: String,
                            _ binding: Binding<String>,
                            _ keyboard: UIKeyboardType = .default) -> some View {
        TextField(prompt, text: binding)
            .keyboardType(keyboard)
            .autocapitalization(.none)
            .textFieldStyle(.roundedBorder)
    }

    private var valid: Bool {
        !name.isEmpty &&
        !username.isEmpty &&
        !email.isEmpty &&
        pw1.count >= 6 &&
        pw1 == pw2
    }

    private func create() {
        busy = true
        error = nil
        Task {
            do {
                try await AuthService.shared.register(
                    name: name,
                    username: username,
                    email: email,
                    password: pw1,
                    payment: ["venmo": venmo, "paypal": paypal]
                )
                if let uid = Auth.auth().currentUser?.uid {
                    userID = uid
                }
                await CurrentUserStore.shared.load()
                switchTo = .app
            } catch {
                self.error = error.localizedDescription
            }
            busy = false
        }
    }
}
