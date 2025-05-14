import FirebaseAuth
import FirebaseFirestore

enum AuthError: LocalizedError {
    case usernameTaken
    case noAuthenticatedUser

    var errorDescription: String? {
        switch self {
        case .usernameTaken:      "Sorry, that username is already in use."
        case .noAuthenticatedUser:"No authenticated user."
        }
    }
}

@MainActor
final class AuthService {
    static let shared = AuthService()
    private init() {}

    private let usersRef = Firestore.firestore().collection("users")

    // ────────── Queries ──────────
    func usernameExists(_ username: String) async throws -> Bool {
        let snap = try await usersRef
            .whereField("username", isEqualTo: username.lowercased())
            .limit(to: 1)
            .getDocuments()
        return !snap.documents.isEmpty
    }

    func fetchCurrentUser() async throws -> UserProfile {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw AuthError.noAuthenticatedUser
        }
        let snap = try await usersRef.document(uid).getDocument()

        guard let profile = UserProfile(snapshot: snap) else {
            throw AuthError.noAuthenticatedUser
        }
        return profile
    }
    // ────────── Account creation ──────────
    func register(name: String,
                  username: String,
                  email: String,
                  password: String,
                  payment: [String:String]) async throws {

        // 1. username free?
        if try await usernameExists(username) { throw AuthError.usernameTaken }

        // 2. create Auth user
        let authResult = try await Auth.auth().createUser(withEmail: email,
                                                          password: password)
        let uid = authResult.user.uid

        // 3. write Firestore profile
        let data: [String:Any] = [
            "name":     name,
            "username": username.lowercased(),
            "email":    email,
            "payment":  payment,
            "createdAt": Date()
        ]
        try await usersRef.document(uid).setData(data)
    }
}
