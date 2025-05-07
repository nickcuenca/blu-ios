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

struct SocialFeedView: View {
    @State private var feedItems: [FeedItem] = []

    var body: some View {
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
        // Removed NavigationView and .navigationTitle("Friends Feed")
        .onAppear {
            fetchFeed()
        }
    }

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
}
