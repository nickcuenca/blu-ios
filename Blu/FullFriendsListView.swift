//
//  FullFriendsListView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 5/7/25.
//

import SwiftUI

struct FullFriendsListView: View {
    let friends: [UserPreview]

    var body: some View {
        List {
            if friends.isEmpty {
                Text("You don’t have any friends yet.")
                    .foregroundColor(.gray)
                    .italic()
                    .padding()
            } else {
                ForEach(friends, id: \.id) { friend in
                    NavigationLink(destination: FriendProfileView(friend: friend)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(friend.username.isEmpty ? "Unnamed Friend" : friend.username)
                                .font(.headline)
                            Text("@\(friend.handle)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("All Friends")
    }
}
