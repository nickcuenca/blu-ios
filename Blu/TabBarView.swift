//  TabBarView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/28/25.

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0
    @State private var previousTab = 0
    @State private var showCreationToast = false
    @State private var showModal = false
    @State private var sessions: [HangoutSession] = []

    var body: some View {
        NavigationStack {
            ZStack {
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

                    // Fake tab to trigger modal
                    Text("")
                        .tabItem {
                            Image(systemName: "plus.circle")
                            Text("New")
                        }.tag(2)

                    SocialFeedView()
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
                .onChange(of: selectedTab) { newTab in
                    if newTab == 2 {
                        selectedTab = previousTab
                        showModal = true
                    } else {
                        previousTab = newTab
                    }
                }

                // Toast
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
}

struct CreateSessionViewWrapper: View {
    @Binding var sessions: [HangoutSession]
    var onSessionCreated: () -> Void = {}

    var body: some View {
        CreateHangoutViewWithLocation(sessions: $sessions, onHangoutCreated: onSessionCreated)
    }
}

struct NewCreationModal: View {
    @Environment(\.dismiss) var dismiss
    @Binding var sessions: [HangoutSession]
    var onSessionCreated: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Button {
                    dismiss()
                    // Delay to prevent modal conflicts
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        // Navigate to Quick Add
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let root = windowScene.windows.first?.rootViewController {
                            root.present(
                                UIHostingController(
                                    rootView: AddExpenseView(participants: [], onAdd: { _ in}
                                                            )
                                ),
                                animated: true
                            )
                        }
                    }
                } label: {
                    Label("Quick Add Expense", systemImage: "plus.circle")
                }

                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let root = windowScene.windows.first?.rootViewController {
                            root.present(
                                UIHostingController(rootView: CreateHangoutViewWithLocation(sessions: $sessions, onHangoutCreated: onSessionCreated)),
                                animated: true
                            )
                        }
                    }
                } label: {
                    Label("Create Hangout", systemImage: "calendar.badge.plus")
                }
            }
            .navigationTitle("What would you like to add?")
        }
    }
}
