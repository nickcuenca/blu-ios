// BluApp.swift
import SwiftUI
import GoogleSignIn
import FirebaseAuth

@main
struct BluApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var userStore = CurrentUserStore.shared

    var body: some Scene {
        WindowGroup {
            if userStore.profile != nil {  // was userStore.isLoggedIn
                TabBarView()
            } else {
                GetStartedView()
            }
        }
    }
}
