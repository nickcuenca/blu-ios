//  TabBarView.swift
//  Blu

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0
    @State private var previousTab = 0
    @State private var showCreationToast = false
    @State private var showModal = false
    @State private var sessions: [HangoutSession] = []

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeView(sessions: $sessions)
                }
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)

                ExploreView(sessions: $sessions)
                    .tabItem {
                        Image(systemName: "safari")
                        Text("Explore")
                    }
                    .tag(1)

                Text("") // Placeholder for modal
                    .tabItem {
                        Image(systemName: "plus.circle")
                        Text("New")
                    }
                    .tag(2)

                SocialFeedView()
                    .tabItem {
                        Image(systemName: "person.2")
                        Text("Social")
                    }
                    .tag(3)

                ProfileViewEnhanced()
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("Profile")
                    }
                    .tag(4)
            }
            .onChange(of: selectedTab) { _, newTab in
                if newTab == 2 {
                    selectedTab = previousTab
                    showModal = true
                } else {
                    previousTab = newTab
                }
            }

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
        }
        .sheet(isPresented: $showModal) {
            NewCreationModal(sessions: $sessions, onSessionCreated: {
                showCreationToast = true
            })
        }
    }
}
