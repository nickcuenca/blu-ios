// CurrentUserStore.swift

import FirebaseAuth
import Combine

@MainActor
final class CurrentUserStore: ObservableObject {
    static let shared = CurrentUserStore()
    private init() {}

    @Published var profile: UserProfile?
    @Published var isLoggedIn = Auth.auth().currentUser != nil

    func load() async {
        do {
            profile = try await AuthService.shared.fetchCurrentUser()
            isLoggedIn = true
        } catch {
            print("❌ Failed to load user: \(error)")
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            profile = nil
            isLoggedIn = false
        } catch {
            print("❌ Sign out failed: \(error)")
        }
    }
}
