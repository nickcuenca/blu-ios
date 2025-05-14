import FirebaseAuth
import FirebaseFirestore

struct FriendService {

    static let db = Firestore.firestore()
    static var currentUID: String { Auth.auth().currentUser?.uid ?? "" }

    // MARK: – Send a friend request
    static func sendFriendRequest(to receiverID: String) async throws {
        try await db.collection("friendRequests").addDocument(data: [
            "from": currentUID,
            "to": receiverID,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ])
    }

    // MARK: – Accept a friend request
    static func acceptFriendRequest(from senderID: String) async throws {
        // Find the matching pending request
        let snap = try await db.collection("friendRequests")
            .whereField("from", isEqualTo: senderID)
            .whereField("to", isEqualTo: currentUID)
            .whereField("status", isEqualTo: "pending")
            .limit(to: 1)
            .getDocuments()

        guard let doc = snap.documents.first else { return }
        let reqID = doc.documentID

        let pairID = [senderID, currentUID].sorted().joined(separator: "—")

        let batch = db.batch()

        // Update request status
        batch.updateData(["status": "accepted"], forDocument: db.collection("friendRequests").document(reqID))

        // Create symmetric friendship doc
        batch.setData([
            "users": [senderID, currentUID],
            "createdAt": FieldValue.serverTimestamp()
        ], forDocument: db.collection("friends").document(pairID))

        try await batch.commit()
    }

    // MARK: – Decline a friend request
    static func declineFriendRequest(from senderID: String) async throws {
        // Find the matching pending request
        let snap = try await db.collection("friendRequests")
            .whereField("from", isEqualTo: senderID)
            .whereField("to", isEqualTo: currentUID)
            .whereField("status", isEqualTo: "pending")
            .limit(to: 1)
            .getDocuments()

        guard let doc = snap.documents.first else { return }

        try await db.collection("friendRequests")
            .document(doc.documentID)
            .updateData(["status": "rejected"])
    }

    // MARK: – Friend list previews (used in UI)
    static func fetchFriendPreviews() async throws -> [UserPreview] {
        let snap = try await db.collection("friends")
            .whereField("users", arrayContains: currentUID)
            .getDocuments()

        var previews: [UserPreview] = []

        for doc in snap.documents {
            let users = doc["users"] as? [String] ?? []
            guard let friendUID = users.first(where: { $0 != currentUID }) else { continue }

            let friendDoc = try await db.collection("users").document(friendUID).getDocument()
            guard let data = friendDoc.data() else { continue }

            previews.append(UserPreview(
                id: friendUID,
                username: data["displayName"] as? String ?? "Unknown",
                handle: data["handle"] as? String ?? ""
            ))
        }

        return previews
    }
}

// MARK: – Extra helpers used by FriendsProfileView & PendingRequestsView
extension FriendService {

    /// Permanently delete the friendship pair document
    static func removeFriend(uid: String) async throws {
        let pairID = [currentUID, uid].sorted().joined(separator: "—")
        try await db.collection("friends").document(pairID).delete()
    }

    /// All pending requests incoming to the current user
    static func fetchIncomingRequests() async throws -> [FriendRequest] {
        let snap = try await db.collection("friendRequests")
            .whereField("to", isEqualTo: currentUID)
            .whereField("status", isEqualTo: "pending")
            .getDocuments()
        return try snap.documents.compactMap { try $0.data(as: FriendRequest.self) }
    }
}
