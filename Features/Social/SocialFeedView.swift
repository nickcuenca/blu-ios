import SwiftUI

struct SocialFeedView: View {
    @State private var friends: [UserPreview] = []
    @State private var isLoading = true

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
                                Text(friend.username)                 // displayName
                                    .font(.headline)
                            }
                        }
                    }
                }

                Section {
                    NavigationLink("Add Friends") { AddFriendsView() }
                    NavigationLink("Pending Friend Requests") { PendingRequestsView() }
                }
            }
            .navigationTitle("Social")
            .task { await loadFriends() }          // Swift 5.9 .task modifier
        }
    }

    @MainActor
    private func loadFriends() async {
        isLoading = true
        do {
            friends = try await FriendService.fetchFriendPreviews()
        } catch {
            print("❌ fetchFriendPreviews:", error)
            friends = []
        }
        isLoading = false
    }
}
