//
//  GoogleSignInView.swift
//  Blu
//
//  Created by Ethan Maldonado on 5/2/25
//

import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInView: View {
    @AppStorage("username") var username: String = ""
    @AppStorage("userEmail") var userEmail: String = ""

    @State private var isSigningIn = false
    @State private var signInComplete = false

    var body: some View {
        VStack(spacing: 20) {
            Image("Blu_Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)

            Text("Welcome to Blu")
                .font(.title)

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
        .fullScreenCover(isPresented: $signInComplete) {
            RegistrationViewV2()
        }
    }

    func signInWithGoogle() {
        isSigningIn = true

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            isSigningIn = false
            return
        }

        // NOTE: We no longer pass config explicitly — it reads from GoogleService-Info.plist
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                self.isSigningIn = false
                return
            }

            guard let result = signInResult else {
                print("Google Sign-In: No result returned")
                self.isSigningIn = false
                return
            }

            let user = result.user
            let idToken = user.idToken?.tokenString
            let accessToken = user.accessToken.tokenString

            guard let idToken = idToken else {
                print("Google Sign-In: Missing ID token")
                self.isSigningIn = false
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                self.isSigningIn = false
                if let error = error {
                    print("Firebase Auth error: \(error.localizedDescription)")
                    return
                }

                self.username = authResult?.user.displayName ?? ""
                self.userEmail = authResult?.user.email ?? ""
                self.signInComplete = true
            }
        }
    }
}
