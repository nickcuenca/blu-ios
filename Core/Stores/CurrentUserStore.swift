// Core/Stores/CurrentUserStore.swift
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class CurrentUserStore: ObservableObject {

    // MARK: - Published state
    @Published private(set) var profile: UserProfile?
    @Published private(set) var pendingRequests: [FriendRequest] = []
    @Published private(set) var hangouts: [HangoutSession]   = []

    // MARK: - Singleton
    static let shared = CurrentUserStore()
    private init() {}

    private var listeners: [ListenerRegistration] = []

    // MARK: - Lifecycle
    func startListening() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        stopListening()                                             // hot-reload safety

        // ① Profile doc
        listeners.append(
            Firestore.firestore()
                .collection("users")
                .document(uid)
                .addSnapshotListener { [weak self] snap, _ in
                    self?.profile = try? snap?.data(as: UserProfile.self)
                }
        )

        // ② Incoming friend-requests
        listeners.append(
            Firestore.firestore()
                .collection("friendRequests")
                .whereField("to", isEqualTo: uid)
                .whereField("status", isEqualTo: "pending")
                .addSnapshotListener { [weak self] snap, _ in
                    self?.pendingRequests = snap?.documents.compactMap {
                        try? $0.data(as: FriendRequest.self)
                    } ?? []
                }
        )

        // ③ Hang-out sessions involving current user
        listeners.append(
            Firestore.firestore()
                .collection("hangoutSessions")
                .whereField("participants", arrayContains: uid)
                .addSnapshotListener { [weak self] snap, _ in
                    self?.hangouts = snap?.documents.compactMap {
                        try? $0.data(as: HangoutSession.self)
                    } ?? []
                }
        )
    }

    func stopListening() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
        profile = nil
        pendingRequests = []
        hangouts = []
    }
}
