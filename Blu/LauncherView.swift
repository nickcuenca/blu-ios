//
//  LauncherView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/28/25.
//

import SwiftUI

struct LauncherView: View {
    @AppStorage("username") var username: String = ""
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                VStack {
                    Image("Blu_Logo") // must match asset name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .ignoresSafeArea()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isLoading = false
                    }
                }
            } else {
                if username.isEmpty {
                    RegistrationViewV2()
                } else {
                    TabBarView()
                }
            }
        }
    }
}
