import SwiftUI
import FirebaseFirestore

struct AddFriendsView: View {
    @State private var username = ""
    @State private var results: [UserPreview] = []
    @AppStorage("userID") private var currentUserID: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .onSubmit { Task { await search() } }

                List {
                    ForEach(results) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.username).bold()
                                Text("@\(user.handle)").font(.caption).foregroundColor(.gray)
                            }
                            Spacer()
                            Button("Send Request") {
                                Task {
                                    try? await FriendService.sendFriendRequest(to: user.id)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
            }
            .navigationTitle("Add Friends")
        }
    }

    @MainActor
    private func search() async {
        let db = Firestore.firestore()
        let snap = try? await db.collection("users")
            .whereField("username", isEqualTo: username.lowercased())
            .getDocuments()

        guard let docs = snap?.documents else { return }

        results = docs.compactMap { doc in
            let id = doc.documentID
            guard id != currentUserID else { return nil }
            let data = doc.data()
            return UserPreview(
                id: id,
                username: data["username"] as? String ?? "Unknown",
                handle: data["handle"] as? String ?? ""
            )
        }
    }
}
