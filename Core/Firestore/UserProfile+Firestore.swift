import FirebaseFirestore
import Foundation

extension UserProfile {

    /// Initialise from a Firestore `DocumentSnapshot` – v2 schema
    init?(snapshot: DocumentSnapshot) {
        guard let src = snapshot.data() else { return nil }

        self.id           = snapshot.documentID
        self.displayName  = src["displayName"] as? String ?? ""
        self.email        = src["email"]       as? String ?? ""
        self.photoURL     = src["photoURL"]    as? String
        self.joinedAt     = (src["joinedAt"] as? Timestamp)?.dateValue()

        // stats may be missing on very old accounts → default zeroes
        if let stats = src["stats"] as? [String: Any] {
            self.stats = .init(
                friends:     stats["friends"]     as? Int    ?? 0,
                hangouts:    stats["hangouts"]    as? Int    ?? 0,
                balanceOwed: stats["balanceOwed"] as? Double ?? 0
            )
        } else {
            self.stats = .init(friends: 0, hangouts: 0, balanceOwed: 0)
        }

        if let pay = src["payment"] as? [String: String] {
            self.payment = .init(
                venmo:  pay["venmo"]  ?? "",
                paypal: pay["paypal"] ?? ""
            )
        } else {
            self.payment = .init(venmo: "", paypal: "")
        }
    }
}
