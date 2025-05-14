// Core/Stores/CurrentUserStore.swift
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class CurrentUserStore: ObservableObject {

    @Published private(set) var profile: UserProfile?

    static let shared = CurrentUserStore()
    private init() {}

    private var listener: ListenerRegistration?

    // Call after login
    func startListening() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        listener = Firestore.firestore()
            .collection("users")
            .document(uid)
            .addSnapshotListener { [weak self] snap, error in
                guard let self,
                      let snap,
                      let data = try? snap.data(as: UserProfile.self) else { return }
                self.profile = data
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        profile  = nil
    }
}
