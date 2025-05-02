//
//  LauncherView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/28/25.
//

import SwiftUI
import FirebaseAuth

struct LauncherView: View {
    @AppStorage("username") var username: String = ""
    @State private var isLoading = true
    @State private var needsGoogleSignIn = false

    var body: some View {
        Group {
            if isLoading {
                VStack {
                    Image("Blu_Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .ignoresSafeArea()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if Auth.auth().currentUser == nil {
                            needsGoogleSignIn = true
                        }
                        isLoading = false
                    }
                }
            } else if needsGoogleSignIn {
                GoogleSignInView()
            } else {
                TabBarView()
            }
        }
    }
}
