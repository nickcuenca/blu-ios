import Combine
import CoreLocation
import FirebaseAuth
import FirebaseFirestore

enum HangoutService {

    // MARK: - Helpers
    private static var db: Firestore { Firestore.firestore() }
    private static var me: String    { Auth.auth().currentUser!.uid }

    // MARK: - Create session
    static func createSession(
        title: String,
        date:  Date,
        location: CLLocationCoordinate2D,
        participants: [String]
    ) async throws -> String {

        var all = participants
        if all.contains(me) == false { all.append(me) }

        let ref = try await db.collection("hangoutSessions").addDocument(data: [
            "owner": me,
            "title": title,
            "startedAt": FieldValue.serverTimestamp(),
            "eventDate": Timestamp(date: date),
            "location": [
                "latitude":  location.latitude,
                "longitude": location.longitude
            ],
            "participants": all
        ])
        return ref.documentID
    }

    // MARK: - Stream single session
    static func streamSession(id: String) -> AnyPublisher<HangoutSession, Error> {
        Future { promise in
            db.collection("hangoutSessions").document(id)
                .addSnapshotListener { snap, err in
                    if let err { promise(.failure(err)); return }
                    guard let snap, let session = try? snap.data(as: HangoutSession.self) else { return }
                    promise(.success(session))
                }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Expenses / checkpoints (unchanged)
    static func addCheckpoint(to session: String, checkpoint: Checkpoint) async throws {
        try await db.collection("hangoutSessions")
            .document(session)
            .collection("checkpoints")
            .document(checkpoint.id.uuidString)
            .setData(from: checkpoint)
    }

    static func addExpense(to session: String, expense: Expense) async throws {
        try await db.collection("hangoutSessions")
            .document(session)
            .collection("expenses")
            .document(expense.id.uuidString)
            .setData(from: expense)
    }

    static func deleteCheckpoint(session: String, id: UUID) async throws {
        try await db.collection("hangoutSessions")
            .document(session)
            .collection("checkpoints")
            .document(id.uuidString)
            .delete()
    }

    static func deleteExpense(session: String, id: UUID) async throws {
        try await db.collection("hangoutSessions")
            .document(session)
            .collection("expenses")
            .document(id.uuidString)
            .delete()
    }
}
