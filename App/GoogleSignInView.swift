//
//  GoogleSignInView.swift
//  Blu
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct GoogleSignInView: View {
    @State private var isSigningIn     = false
    @State private var signInCompleted = false

    var body: some View {
        VStack(spacing: 20) {
            Image("Blu_Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)

            Text("Welcome to Blu").font(.title)

            Button(action: signInWithGoogle) {
                HStack {
                    Image(systemName: "globe")
                    Text(isSigningIn ? "Signing in..." : "Sign in with Google")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(isSigningIn)
        }
        .padding()
        .fullScreenCover(isPresented: $signInCompleted) {
            RegistrationViewV2()
        }
    }

    // MARK: – Google sign‑in
    private func signInWithGoogle() {
        isSigningIn = true

        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let root  = scene.windows.first?.rootViewController
        else { isSigningIn = false; return }

        GIDSignIn.sharedInstance.signIn(withPresenting: root) { result, error in
            guard let result, error == nil else {
                print("Google sign‑in error:", error?.localizedDescription ?? "")
                isSigningIn = false
                return
            }

            let user         = result.user
            let idToken      = user.idToken?.tokenString ?? ""
            let accessToken  = user.accessToken.tokenString
            let credential   = GoogleAuthProvider.credential(withIDToken: idToken,
                                                             accessToken: accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                isSigningIn = false
                guard let fbUser = authResult?.user, error == nil else {
                    print("Firebase auth error:", error?.localizedDescription ?? "")
                    return
                }

                Task {
                    // ensure the profile doc exists with v2 schema
                    try? await AuthService.shared.ensureUserProfile(for: fbUser)
                    await MainActor.run { signInCompleted = true }
                }
            }
        }
    }
}
