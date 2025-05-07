import SwiftUI
import Firebase
import GoogleSignIn

@main
struct BluApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: FirebaseApp.app()?.options.clientID ?? ""
        )
    }

    var body: some Scene {
        WindowGroup {
            LauncherView()
        }
    }
}
