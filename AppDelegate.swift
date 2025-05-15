import UIKit
import Firebase
import GoogleSignIn
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {

    // MARK: - UIApplicationDelegate
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        FirebaseApp.configure()

        // 🔗 Configure Google-Sign-In
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        } else {
            assertionFailure("❌ Missing or invalid GoogleService-Info.plist")
        }

        // 🔌  Use local Firestore emulator in DEBUG builds
        #if DEBUG
        let settings = Firestore.firestore().settings
        settings.host = "127.0.0.1:8080"
        settings.isSSLEnabled = false
        settings.cacheSettings = MemoryCacheSettings()
        Firestore.firestore().settings = settings
        #endif

        return true
    }
}
