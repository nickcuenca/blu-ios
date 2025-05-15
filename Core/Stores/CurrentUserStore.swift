//
//  Core/Stores/CurrentUserStore.swift
//

import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class CurrentUserStore: ObservableObject {

    // Published state ---------------------------------------------------------
    @Published private(set) var profile          : UserProfile?
    @Published private(set) var pendingRequests  : [FriendRequest] = []
    @Published private(set) var upcomingHangouts : [Hangout]       = []
    @Published private(set) var pairBalances     : [String: Double] = [:]  // uid ➜ net $

    // Singleton ---------------------------------------------------------------
    static let shared = CurrentUserStore()
    private init() {}

    private var listeners: [ListenerRegistration] = []
    private var cancellables = Set<AnyCancellable>()

    // Lifecycle ----------------------------------------------------------------
    func startListening() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        stopListening()                                           // hot-reload safety

        let db = Firestore.firestore()

        // ① live profile
        listeners.append(
            db.collection("users")
              .document(uid)
              .addSnapshotListener { [weak self] snap, _ in
                  self?.profile = try? snap?.data(as: UserProfile.self)
              }
        )

        // ② incoming friend-requests
        listeners.append(
            db.collection("friendRequests")
              .whereField("to", isEqualTo: uid)
              .whereField("status", isEqualTo: "pending")
              .addSnapshotListener { [weak self] snap, _ in
                  self?.pendingRequests = snap?.documents.compactMap {
                      try? $0.data(as: FriendRequest.self)
                  } ?? []
              }
        )

        // ③ pair-doc balances
        listeners.append(
            db.collection("friends")
              .whereField("users", arrayContains: uid)
              .addSnapshotListener { [weak self] snap, _ in
                  guard let self else { return }
                  var dict: [String: Double] = [:]
                  snap?.documents.forEach { doc in
                      let users = doc.get("users") as? [String] ?? []
                      guard let friendID = users.first(where: { $0 != uid }) else { return }
                      if let balances = doc.get("balances") as? [String: Double],
                         let myBal = balances[uid] {
                          dict[friendID] = myBal
                      }
                  }
                  self.pairBalances = dict
              }
        )

        // ④ upcoming hang-outs (via Combine helper)
        HangoutService.streamUpcoming(for: uid)
            .replaceError(with: [])
            .sink { [weak self] in self?.upcomingHangouts = $0 }
            .store(in: &cancellables)
    }

    func stopListening() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
        cancellables.removeAll()
        profile = nil
        pendingRequests = []
        upcomingHangouts = []
        pairBalances = [:]
    }
}
