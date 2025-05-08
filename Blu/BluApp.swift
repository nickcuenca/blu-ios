import SwiftUI
import Firebase
import GoogleSignIn

@main
struct BluApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        FirebaseApp.configure() // <-- Ensure Firebase is initialized

        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        } else {
            print("❌ Missing or invalid GoogleService-Info.plist")
        }
    }

    var body: some Scene {
        WindowGroup {
            LauncherView()
        }
    }
}
