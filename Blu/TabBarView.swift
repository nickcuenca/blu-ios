//  TabBarView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/28/25.

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0
    @State private var showCreationToast = false
    @State private var sessions: [HangoutSession] = []

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                HomeView(sessions: $sessions)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }.tag(0)

                ExploreView(sessions: $sessions)
                    .tabItem {
                        Image(systemName: "safari")
                        Text("Explore")
                    }.tag(1)

                CreateSessionViewWrapper(sessions: $sessions, onSessionCreated: {
                    showCreationToast = true
                })
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("New")
                }.tag(2)

                SocialView()
                    .tabItem {
                        Image(systemName: "person.2")
                        Text("Social")
                    }.tag(3)

                ProfileViewEnhanced()
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("Profile")
                    }.tag(4)
            }
            .overlay(
                VStack {
                    Spacer()
                    if showCreationToast {
                        Text("✅ Session Created!")
                            .padding()
                            .background(Color.green.opacity(0.95))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showCreationToast = false
                                    }
                                }
                            }
                            .padding(.bottom, 50)
                    }
                }
            )
        }
    }
}

struct CreateSessionViewWrapper: View {
    @Binding var sessions: [HangoutSession]
    var onSessionCreated: () -> Void = {}

    var body: some View {
        CreateHangoutViewWithLocation(sessions: $sessions, onHangoutCreated: onSessionCreated)
    }
}


struct SocialView: View {
    var body: some View {
        Text("Social Coming Soon")
            .font(.title2)
            .padding()
    }
}
