import FirebaseAuth
import FirebaseFirestore

struct FriendService {

    private static let db  = Firestore.firestore()
    private static var me: String { Auth.auth().currentUser?.uid ?? "" }

    // MARK: - Helpers
    private static func pairID(_ other: String) -> String {
        [me, other].sorted().joined(separator: "-")                 // e.g. "abc-xyz"
    }
    private static func requestID(to other: String) -> String {
        "\(me)_\(other)"                                            // e.g. "abc_xyz"
    }

    // MARK: - Send
    static func sendFriendRequest(to receiverID: String) async throws {
        try await db.collection("friendRequests")
            .document(requestID(to: receiverID))
            .setData([
                "from": me,
                "to":   receiverID,
                "status": "pending",
                "sentAt": FieldValue.serverTimestamp()
            ])
    }

    // MARK: - Accept
    static func acceptFriendRequest(from sender: String) async throws {
        let batch = db.batch()

        // update request status
        let reqRef = db.collection("friendRequests").document("\(sender)_\(me)")
        batch.updateData(["status": "accepted"], forDocument: reqRef)

        // create friends pair-doc
        let pairRef = db.collection("friends").document(pairID(sender))
        batch.setData([
            "users": [sender, me],
            "createdAt": FieldValue.serverTimestamp()
        ], forDocument: pairRef)

        try await batch.commit()
    }

    // MARK: - Decline
    static func declineFriendRequest(from sender: String) async throws {
        try await db.collection("friendRequests")
            .document("\(sender)_\(me)")
            .updateData(["status": "rejected"])
    }

    // MARK: - Remove friend
    static func removeFriend(uid: String) async throws {
        try await db.collection("friends").document(pairID(uid)).delete()
    }

    // MARK: - Friend previews
    static func fetchFriendPreviews() async throws -> [UserPreview] {
        let snap = try await db.collection("friends")
            .whereField("users", arrayContains: me)
            .getDocuments()

        var previews: [UserPreview] = []
        for doc in snap.documents {
            guard
                let users = doc["users"] as? [String],
                let friendUID = users.first(where: { $0 != me })
            else { continue }

            let friendDoc = try await db.collection("users").document(friendUID).getDocument()
            guard let data = friendDoc.data() else { continue }

            previews.append(
                UserPreview(
                    id: friendUID,
                    username: data["displayName"] as? String ?? "Unknown",
                    handle:   data["handle"]      as? String ?? ""
                )
            )
        }
        return previews
    }

    // MARK: - Pending inbound requests (utility)
    static func fetchIncomingRequests() async throws -> [FriendRequest] {
        let snap = try await db.collection("friendRequests")
            .whereField("to", isEqualTo: me)
            .whereField("status", isEqualTo: "pending")
            .getDocuments()
        return try snap.documents.compactMap { try $0.data(as: FriendRequest.self) }
    }
}
