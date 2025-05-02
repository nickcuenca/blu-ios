import FirebaseStorage
import FirebaseFirestore
import Foundation

func logToFeed(moment: Moment, checkpoint: Checkpoint) {
    guard let userID = UserDefaults.standard.string(forKey: "userID") else {
        print("❌ Missing user ID")
        return
    }

    guard let imageData = moment.imageData else {
        print("❌ No image data in moment")
        return
    }

    let username = UserDefaults.standard.string(forKey: "username") ?? "Unknown"

    let storageRef = Storage.storage().reference()
    let imageID = UUID().uuidString
    let imageRef = storageRef.child("feedImages/\(imageID).jpg")

    imageRef.putData(imageData, metadata: nil) { metadata, error in
        if let error = error {
            print("❌ Image upload failed: \(error.localizedDescription)")
            return
        }

        imageRef.downloadURL { url, error in
            if let error = error {
                print("❌ Failed to get download URL: \(error.localizedDescription)")
                return
            }

            guard let downloadURL = url else {
                print("❌ URL unexpectedly nil")
                return
            }

            let feedEntry: [String: Any] = [
                "username": username,
                "location": checkpoint.title,
                "timestamp": Timestamp(date: Date()),
                "caption": moment.caption ?? "",
                "memoryThumbnailURLs": [downloadURL.absoluteString],
                "isPublic": true
            ]

            let db = Firestore.firestore()

            // Write to user's personal feed (optional if you want private logs)
            db.collection("users").document(userID).collection("feed").addDocument(data: feedEntry) { error in
                if let error = error {
                    print("❌ User feed write failed: \(error.localizedDescription)")
                } else {
                    print("✅ Feed logged for \(username)")
                }
            }

            // ✅ Also write to global feed for everyone to see
            db.collection("feed").addDocument(data: feedEntry) { error in
                if let error = error {
                    print("❌ Global feed write failed: \(error.localizedDescription)")
                } else {
                    print("✅ Feed also saved to global feed")
                }
            }
        }
    }
}
