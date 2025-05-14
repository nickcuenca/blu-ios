//
//  HangoutService.swift
//  Blu
//
//  Created by Ethan on 14 May 2025.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import CoreLocation

/// Centralised CRUD + realtime stream for v2 `/hangoutSessions`
///
///  Collection shape
///  └─ hangoutSessions/{sessionId}
///       • owner            String  (uid)
///       • title            String
///       • date             Timestamp
///       • location         { latitude: Double, longitude: Double }
///       • participants     [String]             // ≤100 UIDs
///       • createdAt        Timestamp
///       ├─ checkpoints/{checkpointId}
///       └─ expenses/{expenseId}
///
enum HangoutService {

    // MARK: – Firestore helpers
    private static var db: Firestore { Firestore.firestore() }
    private static var currentUID: String { Auth.auth().currentUser!.uid }

    // MARK: – Create
    static func createSession(title: String,
                              date: Date,
                              location: CLLocationCoordinate2D,
                              participants: [String]) async throws -> String {

        var allParticipants = participants
        if allParticipants.contains(currentUID) == false {              // ensure owner included
            allParticipants.append(currentUID)
        }

        let ref = try await db.collection("hangoutSessions").addDocument(data: [
            "owner": currentUID,
            "title": title,
            "date": Timestamp(date: date),
            "location": [ "latitude": location.latitude,
                          "longitude": location.longitude ],
            "participants": allParticipants,
            "createdAt": FieldValue.serverTimestamp()
        ])

        return ref.documentID
    }

    // MARK: – Stream a single session
    static func streamSession(id: String) -> AnyPublisher<HangoutSession, Error> {
        Future { promise in
            db.collection("hangoutSessions").document(id)
                .addSnapshotListener { snap, err in
                    if let err { promise(.failure(err)); return }
                    guard
                        let snap,
                        let data = snap.data()
                    else { return }

                    // decode scalar fields
                    let title       = data["title"]       as? String ?? "Untitled"
                    let ts          = data["date"]        as? Timestamp ?? Timestamp()
                    _ = data["owner"] as? String ?? ""
                    let parts       = data["participants"] as? [String] ?? []
                    let locDict     = data["location"]    as? [String: Double] ?? [:]
                    let coord       = CLLocationCoordinate2D(
                                        latitude: locDict["latitude"] ?? 0,
                                        longitude: locDict["longitude"] ?? 0)

                    // checkpoints + expenses are streamed separately (optional)
                    let session = HangoutSession(
                        id: snap.documentID,
                        title: title,
                        date: ts.dateValue(),
                        location: coord,
                        participants: parts,
                        expenses: [],
                        checkpoints: []
                    )

                    promise(.success(session))
                }
        }
        .eraseToAnyPublisher()
    }

    // MARK: – Add checkpoint
    static func addCheckpoint(to sessionID: String,
                              checkpoint: Checkpoint) async throws {

        let ref = db.collection("hangoutSessions")
            .document(sessionID)
            .collection("checkpoints")
            .document(checkpoint.id.uuidString)

        _ = try await ref.setData(from: checkpoint)
    }

    // MARK: – Add expense
    static func addExpense(to sessionID: String,
                           expense: Expense) async throws {

        let ref = db.collection("hangoutSessions")
            .document(sessionID)
            .collection("expenses")
            .document(expense.id.uuidString)

        _ = try await ref.setData(from: expense)
    }

    // MARK: – Delete expense / checkpoint
    static func deleteCheckpoint(sessionID: String, checkpointID: UUID) async throws {
        try await db.collection("hangoutSessions")
            .document(sessionID)
            .collection("checkpoints")
            .document(checkpointID.uuidString)
            .delete()
    }

    static func deleteExpense(sessionID: String, expenseID: UUID) async throws {
        try await db.collection("hangoutSessions")
            .document(sessionID)
            .collection("expenses")
            .document(expenseID.uuidString)
            .delete()
    }
}
