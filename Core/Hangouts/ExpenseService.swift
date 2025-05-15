//
//  Core/Hangouts/ExpenseService.swift
//

import FirebaseAuth
import FirebaseFirestore

enum ExpenseService {

    private static let db  = Firestore.firestore()
    private static let me  = Auth.auth().currentUser!.uid

    /// Add a single expense doc under `/hangouts/{hid}/expenses/`.
    static func addExpense(hangoutID   : String,
                           title       : String,
                           amount      : Double,
                           paidBy      : String = me,
                           participants: [String]) async throws {

        try await db.collection("hangouts")
                    .document(hangoutID)
                    .collection("expenses")
                    .addDocument(data: [
                        "title"       : title,
                        "amount"      : amount,
                        "paidBy"      : paidBy,
                        "participants": participants,
                        "createdAt"   : FieldValue.serverTimestamp()
                    ])
    }
}
