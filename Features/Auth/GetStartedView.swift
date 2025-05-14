// GetStartedView.swift
import SwiftUI
import FirebaseAuth

struct GetStartedView: View {
    enum Screen {
        case intro, login, signUp, app
    }

    @State private var current: Screen = .intro

    var body: some View {
        NavigationStack {
            Group {
                switch current {
                case .intro:
                    VStack(spacing: 32) {
                        Image("Blu_Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140)

                        Button("Log in") {
                            current = .login
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Create a new account") {
                            current = .signUp
                        }
                        .buttonStyle(.bordered)
                    }

                case .login:
                    LoginView(switchTo: $current)

                case .signUp:
                    SignUpView(switchTo: $current)

                case .app:
                    TabBarView()
                }
            }
            .task {
                if Auth.auth().currentUser != nil {
                    await CurrentUserStore.shared.load()
                    current = .app
                }
            }
        }
    }
}
