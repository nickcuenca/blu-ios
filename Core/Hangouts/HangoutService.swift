//
//  Core/Hangouts/HangoutService.swift
//

import Combine
import CoreLocation
import FirebaseAuth
import FirebaseFirestore

// MARK: - Firestore models ----------------------------------------------------

struct Hangout: Identifiable, Codable {
    @DocumentID var id: String?
    var name       : String
    var location   : String?
    var dateTime   : Timestamp
    var ownerUID   : String
    var participants: [String]
    var createdAt  : Timestamp
}

// MARK: - Service -------------------------------------------------------------

enum HangoutService {

    // Firestore handles
    private static var db : Firestore { Firestore.firestore() }
    private static var me : String    { Auth.auth().currentUser!.uid }

    /// Create a new hang-out session and return the new document ID.
    static func create(name      : String,
                       location  : CLLocationCoordinate2D?,
                       date      : Date,
                       invitees  : [String]) async throws -> String {

        var participants = invitees
        if participants.contains(me) == false { participants.append(me) }

        let ref = try await db.collection("hangouts").addDocument(data: [
            "name"        : name,
            "location"    : location.map {
                 GeoPoint(latitude: $0.latitude, longitude: $0.longitude)
            } as Any,
            "dateTime"    : Timestamp(date: date),
            "ownerUID"    : me,
            "participants": participants,
            "createdAt"   : FieldValue.serverTimestamp()
        ])

        return ref.documentID
    }

    /// Live stream of upcoming hang-outs *I’m in*.
    static func streamUpcoming(for uid: String) -> AnyPublisher<[Hangout], Error> {
        db.collection("hangouts")
          .whereField("participants", arrayContains: uid)
          .whereField("dateTime", isGreaterThan: Timestamp(date: .now))
          .order(by: "dateTime")
          .snapshotPublisher(as: Hangout.self)
    }
}
