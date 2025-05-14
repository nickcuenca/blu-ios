import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SocialFeedView: View {
    @State private var friends: [UserPreview] = []
    @State private var isLoading = true
    @AppStorage("userID") private var currentUserID: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Your Friends")) {
                    if isLoading {
                        ProgressView()
                    } else if friends.isEmpty {
                        Text("You haven't added any friends yet.")
                            .italic()
                            .foregroundColor(.gray)
                    } else {
                        ForEach(friends) { friend in
                            NavigationLink(destination: FriendProfileView(friend: friend)) {
                                VStack(alignment: .leading) {
                                    Text(friend.username)
                                        .font(.headline)
                                    Text("@\(friend.handle)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }

                Section {
                    NavigationLink("Add Friends") {
                        AddFriendsView()
                    }

                    NavigationLink("Pending Friend Requests") {
                        PendingRequestsView()
                    }
                }
            }
            .navigationTitle("Social")
            .onAppear {
                Task {
                    await loadFriends()
                }
            }
        }
    }

    @MainActor
    private func loadFriends() async {
        isLoading = true
        let db = Firestore.firestore()
        do {
            let doc = try await db.collection("users").document(currentUserID).getDocument()
            guard let friendIDs = doc["friends"] as? [String] else {
                friends = []
                isLoading = false
                return
            }

            var fetched: [UserPreview] = []

            for id in friendIDs {
                let userDoc = try await db.collection("users").document(id).getDocument()
                guard let data = userDoc.data() else { continue }
                let preview = UserPreview(
                    id: id,
                    username: data["username"] as? String ?? "Unknown",
                    handle: data["handle"] as? String ?? ""
                )
                fetched.append(preview)
            }

            friends = fetched
        } catch {
            print("❌ Failed to fetch friends: \(error)")
            friends = []
        }
        isLoading = false
    }
}
