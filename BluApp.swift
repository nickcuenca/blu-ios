// BluApp.swift

import SwiftUI
import GoogleSignIn

@main
struct BluApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var userStore = CurrentUserStore.shared

    var body: some Scene {
        WindowGroup {
            if userStore.isLoggedIn {
                TabBarView() // Main app UI
            } else {
                GetStartedView()
            }
        }
    }
}
