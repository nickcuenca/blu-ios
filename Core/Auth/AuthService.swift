// Core/Auth/AuthService.swift
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthService: ObservableObject {

    static let shared = AuthService()
    private init() {}

    private let db = Firestore.firestore()

    // MARK: – Public API
    func register(email: String,
                  password: String,
                  displayName: String,
                  photoURL: URL? = nil) async throws {

        let authResult = try await Auth.auth().createUser(withEmail: email,
                                                          password: password)
        let uid = authResult.user.uid

        try await createUserProfileDoc(
            uid: uid,
            email: email,
            displayName: displayName,
            photoURL: photoURL?.absoluteString
        )
    }

    func signIn(email: String, password: String) async throws {
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    // MARK: – Private helpers
    private func createUserProfileDoc(uid: String,
                                      email: String,
                                      displayName: String,
                                      photoURL: String?) async throws {

        let doc: [String: Any] = [
            "displayName": displayName,
            "email": email,
            "photoURL": photoURL ?? "",
            "joinedAt": FieldValue.serverTimestamp(),
            "stats": [
                "friends": 0,
                "hangouts": 0,
                "balanceOwed": 0.0
            ],
            "payment": [
                "venmo": "",
                "paypal": ""
            ]
        ]

        try await db.collection("users").document(uid).setData(doc, merge: false)
    }
    
    func ensureUserProfile(for user: FirebaseAuth.User) async throws {
        let ref = db.collection("users").document(user.uid)
        if try await ref.getDocument().exists { return }

        try await createUserProfileDoc(
            uid: user.uid,
            email: user.email ?? "",
            displayName: user.displayName ?? "",
            photoURL: user.photoURL?.absoluteString
        )
    }

}
