import SwiftUI
import Firebase
import GoogleSignIn  

@main
struct BluApp: App {
    init() {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: FirebaseApp.app()?.options.clientID ?? "")
    }

    var body: some Scene {
        WindowGroup {
            LauncherView()
        }
    }
}
