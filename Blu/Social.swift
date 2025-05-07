import SwiftUI
import FirebaseFirestore

struct FeedItem: Identifiable {
    var id: String
    var username: String
    var location: String
    var timestamp: Date
    var caption: String?
    var memoryThumbnailURLs: [String]
}

struct UserPreview: Identifiable, Hashable {
    var id: String
    var username: String
    var handle: String
}

struct SocialFeedView: View {
    @AppStorage("username") var currentUsername: String = ""
    @AppStorage("userID") var currentUserID: String = ""

    @State private var feedItems: [FeedItem] = []
    @State private var searchText: String = ""
    @State private var userResults: [BluUser] = []
    @State private var currentFriends: [String] = []
    @State private var selectedUserPreview: UserPreview? = nil

    var body: some View {
        NavigationStack {
            VStack {
                // MARK: - Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Search users by name, handle, or email", text: $searchText)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                    .onChange(of: searchText) { _, newValue in
                        if !newValue.isEmpty {
                            searchUsers()
                        } else {
                            userResults = []
                        }
                    }

                // MARK: - Conditional Views
                if !userResults.isEmpty {
                    List {
                        ForEach(userResults, id: \.id) { user in
                            HStack {
                                // Profile Image
                                AsyncImage(url: URL(string: user.profileImageURL ?? "")) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    case .failure:
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }

                                // Username + Handle
                                VStack(alignment: .leading) {
                                    Text(user.username).font(.headline)
                                    Text("@\(user.handle)").font(.subheadline).foregroundColor(.gray)
                                }
                                .onTapGesture {
                                    let preview = UserPreview(
                                        id: user.id ?? "",
                                        username: user.username,
                                        handle: user.handle
                                    )
                                    navigateToFriendProfile(preview)
                                }

                                Spacer()

                                if currentFriends.contains(user.id ?? "") {
                                    Label("Added", systemImage: "checkmark")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                } else {
                                    Button("Add") {
                                        addFriend(userID: user.id ?? "")
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .padding(.leading, 4)
                                }
                            }
                            .contentShape(Rectangle())
                        }

                    }
                    .listStyle(PlainListStyle())
                } else {
                    List(feedItems.sorted(by: { $0.timestamp > $1.timestamp })) { item in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("\(item.username) recently checked into")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(item.location)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }

                            if let caption = item.caption, !caption.isEmpty {
                                Text(caption)
                                    .font(.body)
                            }

                            if !item.memoryThumbnailURLs.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(item.memoryThumbnailURLs, id: \.self) { urlString in
                                            AsyncImage(url: URL(string: urlString)) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 100, height: 100)
                                                        .clipped()
                                                        .cornerRadius(8)
                                                case .failure:
                                                    Image(systemName: "photo")
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Text(item.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .onAppear {
                fetchFeed()
                fetchCurrentFriends()
            }
            // MARK: - Navigation to Friend Profile
            .navigationDestination(isPresented: Binding<Bool>(
                get: { selectedUserPreview != nil },
                set: { if !$0 { selectedUserPreview = nil } }
            )) {
                if let preview = selectedUserPreview {
                    FriendProfileView(friend: preview)
                }
            }
        }
    }

    // MARK: - Navigation Helper

    func navigateToFriendProfile(_ preview: UserPreview) {
        selectedUserPreview = preview
    }

    // MARK: - Firestore Methods

    func fetchFeed() {
        let db = Firestore.firestore()
        db.collection("feed")
            .whereField("isPublic", isEqualTo: true)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else { return }

                let newItems = docs.compactMap { doc -> FeedItem? in
                    let data = doc.data()
                    return FeedItem(
                        id: doc.documentID,
                        username: data["username"] as? String ?? "Unknown",
                        location: data["location"] as? String ?? "",
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                        caption: data["caption"] as? String,
                        memoryThumbnailURLs: data["memoryThumbnailURLs"] as? [String] ?? []
                    )
                }

                DispatchQueue.main.async {
                    self.feedItems = newItems
                }
            }
    }

    func fetchCurrentFriends() {
        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else { return }
            self.currentFriends = data["friends"] as? [String] ?? []
        }
    }

    func searchUsers() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents, error == nil else { return }

            let matches = docs.compactMap { doc -> BluUser? in
                let data = doc.data()
                let id = doc.documentID
                let username = data["username"] as? String ?? ""
                let handle = data["handle"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let friends = data["friends"] as? [String] ?? []
                let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()

                let searchLower = searchText.lowercased()
                let matchesSearch = username.lowercased().contains(searchLower)
                    || handle.lowercased().contains(searchLower)
                    || email.lowercased().contains(searchLower)

                guard matchesSearch,
                      id != currentUserID else {
                    return nil
                }

                let profileImageURL = data["profileImageURL"] as? String

                return BluUser(
                    id: id,
                    username: username,
                    handle: handle,
                    email: email,
                    friends: friends,
                    createdAt: createdAt,
                    profileImageURL: profileImageURL
                )

            }

            DispatchQueue.main.async {
                self.userResults = matches
            }
        }
    }

    func addFriend(userID: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserID)

        userRef.updateData([
            "friends": FieldValue.arrayUnion([userID])
        ]) { error in
            if let error = error {
                print("❌ Failed to add friend: \(error)")
                return
            }
            print("✅ Friend added")
            currentFriends.append(userID) // ✅ View will re-render with "Added"
        }
    }
}
