import SwiftUI

struct PendingRequestsView: View {
    @State private var pending: [UserPreview] = []
    @State private var isLoading = true

    var body: some View {
        List {
            if pending.isEmpty && !isLoading {
                Text("No pending requests.")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(pending) { user in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(user.username).bold()
                            Text("@\(user.handle)").font(.caption).foregroundColor(.gray)
                        }
                        Spacer()
                        Button("Accept") {
                            Task {
                                try? await FriendService.acceptFriendRequest(from: user.id)
                                await loadRequests()
                            }
                        }
                        .buttonStyle(.bordered)

                        Button("Decline") {
                            Task {
                                try? await FriendService.declineFriendRequest(from: user.id)
                                await loadRequests()
                            }
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Friend Requests")
        .onAppear { Task { await loadRequests() } }
    }

    @MainActor
    private func loadRequests() async {
        isLoading = true
        if let requests = try? await FriendService.fetchIncomingRequests() {
            pending = requests
        }
        isLoading = false
    }
}
