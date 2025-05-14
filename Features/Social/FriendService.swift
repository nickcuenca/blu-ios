import FirebaseAuth
import FirebaseFirestore

struct FriendService {

    static var currentUserID: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    static func sendFriendRequest(to receiverID: String) async throws {
        let db = Firestore.firestore()
        let senderRef = db.collection("users").document(currentUserID)
        let receiverRef = db.collection("users").document(receiverID)

        try await senderRef.updateData([
            "outgoingRequests": FieldValue.arrayUnion([receiverID])
        ])

        try await receiverRef.updateData([
            "incomingRequests": FieldValue.arrayUnion([currentUserID])
        ])
    }

    static func acceptFriendRequest(from senderID: String) async throws {
        let db = Firestore.firestore()
        let receiverID = currentUserID
        let receiverRef = db.collection("users").document(receiverID)
        let senderRef = db.collection("users").document(senderID)

        try await receiverRef.updateData([
            "friends": FieldValue.arrayUnion([senderID]),
            "incomingRequests": FieldValue.arrayRemove([senderID])
        ])

        try await senderRef.updateData([
            "friends": FieldValue.arrayUnion([receiverID]),
            "outgoingRequests": FieldValue.arrayRemove([receiverID])
        ])
    }

    static func declineFriendRequest(from senderID: String) async throws {
        let db = Firestore.firestore()
        let receiverID = currentUserID
        let receiverRef = db.collection("users").document(receiverID)
        let senderRef = db.collection("users").document(senderID)

        try await receiverRef.updateData([
            "incomingRequests": FieldValue.arrayRemove([senderID])
        ])

        try await senderRef.updateData([
            "outgoingRequests": FieldValue.arrayRemove([receiverID])
        ])
    }

    static func fetchIncomingRequests() async throws -> [UserPreview] {
        let db = Firestore.firestore()
        let currentRef = db.collection("users").document(currentUserID)
        let userDoc = try await currentRef.getDocument()
        let incoming = userDoc["incomingRequests"] as? [String] ?? []

        var previews: [UserPreview] = []

        for id in incoming {
            let doc = try await db.collection("users").document(id).getDocument()
            guard let data = doc.data() else { continue }

            let preview = UserPreview(
                id: id,
                username: data["username"] as? String ?? "Unknown",
                handle: data["handle"] as? String ?? ""
            )
            previews.append(preview)
        }

        return previews
    }
}
