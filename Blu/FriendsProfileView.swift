//
//  FriendsProfileView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 5/7/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct FriendProfileView: View {
    let friend: UserPreview

    @AppStorage("userID") var currentUserID: String = ""
    @AppStorage("username") var currentUsername: String = ""

    @State private var profileImage: UIImage? = nil
    @State private var isFriend: Bool = false
    @State private var isLoading = true
    @State private var showError = false

    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Profile Image
            Image(uiImage: profileImage ?? UIImage(named: "defaultProfile") ?? UIImage(systemName: "person.circle.fill")!)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 1))

            // MARK: - Name / Handle
            VStack(spacing: 4) {
                Text(friend.username).font(.title2).bold()
                Text("@\(friend.handle)").font(.subheadline).foregroundColor(.gray)
            }

            // MARK: - Add/Remove Button
            if friend.id != currentUserID {
                Button(action: {
                    isFriend ? removeFriend() : addFriend()
                }) {
                    Text(isFriend ? "Remove Friend" : "Add Friend")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isFriend ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Profile")
        .onAppear {
            fetchProfileImage()
            checkIfFriend()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Something went wrong.")
        }
    }

    // MARK: - Firebase Logic

    func checkIfFriend() {
        guard !currentUserID.isEmpty else { return }
        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                let friends = data["friends"] as? [String] ?? []
                self.isFriend = friends.contains(friend.id)
            } else {
                showError = true
            }
            isLoading = false
        }
    }

    func addFriend() {
        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).updateData([
            "friends": FieldValue.arrayUnion([friend.id])
        ]) { error in
            if let error = error {
                print("❌ Add friend failed: \(error)")
                showError = true
            } else {
                self.isFriend = true
            }
        }
    }

    func removeFriend() {
        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).updateData([
            "friends": FieldValue.arrayRemove([friend.id])
        ]) { error in
            if let error = error {
                print("❌ Remove friend failed: \(error)")
                showError = true
            } else {
                self.isFriend = false
            }
        }
    }

    func fetchProfileImage() {
        let db = Firestore.firestore()
        db.collection("users").document(friend.id).getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let urlString = data["profileImageURL"] as? String,
                  let url = URL(string: urlString) else {
                return
            }

            // Download image data from the URL
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, let image = UIImage(data: data) else {
                    return
                }

                DispatchQueue.main.async {
                    self.profileImage = image
                }
            }.resume()
        }
    }

}
