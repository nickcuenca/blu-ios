//
//  FriendsProfileView.swift
//  Blu
//
//  Updated for pair‑doc friends – May 2025
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct FriendProfileView: View {
    let friend: UserPreview          // uid + displayName (+ optional handle)

    @AppStorage("userID") private var currentUID: String = ""

    @State private var profileImage: UIImage?
    @State private var isFriend      = false
    @State private var isLoading     = true
    @State private var showError     = false

    var body: some View {
        VStack(spacing: 20) {
            // MARK: – Avatar
            Image(uiImage: profileImage ?? UIImage(named: "defaultProfile")!)
                .resizable().scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 1))

            // MARK: – Name / Handle
            VStack(spacing: 4) {
                Text(friend.username).font(.title2).bold()
                if !friend.handle.isEmpty {
                    Text("@\(friend.handle)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            // MARK: – Add / Remove
            if friend.id != currentUID {
                Button(action: isFriend ? removeFriend : sendRequest) {
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
        .task { await loadState() }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        }
    }

    // MARK: – Async helpers
    @MainActor
    private func loadState() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await fetchProfileImage() }
            group.addTask { await checkIfFriend() }
        }
        isLoading = false
    }

    @MainActor
    private func checkIfFriend() async {
        guard !currentUID.isEmpty else { return }
        let pairID = [currentUID, friend.id].sorted().joined(separator: "—")
        let exists = (try? await Firestore.firestore()
            .collection("friends").document(pairID).getDocument())?.exists ?? false
        isFriend = exists
    }

    private func sendRequest() {
        Task {
            do {
                try await FriendService.sendFriendRequest(to: friend.id)
            } catch { showError = true }
        }
    }

    private func removeFriend() {
        Task {
            do {
                try await FriendService.removeFriend(uid: friend.id)
                isFriend = false
            } catch { showError = true }
        }
    }

    private func fetchProfileImage() async {
        let snap = try? await Firestore.firestore()
            .collection("users").document(friend.id).getDocument()

        guard
            let urlString = snap?.data()?["photoURL"] as? String,
            let url       = URL(string: urlString),
            let (data, _) = try? await URLSession.shared.data(from: url),
            let image     = UIImage(data: data)
        else { return }

        await MainActor.run { profileImage = image }
    }
}
