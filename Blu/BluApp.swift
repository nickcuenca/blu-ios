import SwiftUI
import Firebase

@main
struct BluApp: App {
    init() {
        FirebaseApp.configure()
        UserDefaults.standard.set("D9A762EC-C6E3-4BC9-AC87-1B967DA95F06", forKey: "userID")
    }

    var body: some Scene {
        WindowGroup {
            LauncherView()
        }
    }
}
