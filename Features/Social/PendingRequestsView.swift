import SwiftUI

struct PendingRequestsView: View {
    @State private var requests: [FriendRequest] = []
    @State private var isLoading                 = true

    var body: some View {
        List {
            if requests.isEmpty && !isLoading {
                Text("No pending requests.")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(requests, id: \.id) { req in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(req.from)           // displayName lookup could be added
                                .bold()
                            Text(req.id)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button("Accept") {
                            Task {
                                try? await FriendService.acceptFriendRequest(from: req.from)
                                await reload()
                            }
                        }
                        .buttonStyle(.bordered)

                        Button("Decline") {
                            Task {
                                try? await FriendService.declineFriendRequest(from: req.from)
                                await reload()
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
            }
        }
        .navigationTitle("Friend Requests")
        .task { await reload() }
    }

    @MainActor private func reload() async {
        isLoading = true
        requests  = (try? await FriendService.fetchIncomingRequests()) ?? []
        isLoading = false
    }
}
