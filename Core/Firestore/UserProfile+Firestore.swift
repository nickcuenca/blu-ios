import FirebaseFirestore

extension UserProfile {
    init?(snapshot: DocumentSnapshot) {
        guard let src = snapshot.data() else { return nil }

        self.id       = snapshot.documentID
        self.name     = src["name"]     as? String ?? ""
        self.username = src["username"] as? String ?? ""
        self.email    = src["email"]    as? String ?? ""

        if let ts = src["createdAt"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else if let date = src["createdAt"] as? Date {
            self.createdAt = date
        } else {
            self.createdAt = nil
        }

        // Payment map (optional)
        self.payment = src["payment"] as? [String:String] ?? [:]
    }
}
