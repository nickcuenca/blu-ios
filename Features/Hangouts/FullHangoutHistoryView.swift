//
//  FullHangoutHistoryView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 5/7/25.
//

import SwiftUI
import FirebaseFirestore

struct FullHangoutHistoryView: View {
    let userID: String
    @State private var pastHangouts: [HangoutSession] = []

    var body: some View {
        List {
            if pastHangouts.isEmpty {
                Text("No past hangouts found.")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(pastHangouts) { hangout in
                    NavigationLink(destination: HangoutDetailView(hangout: hangout)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(hangout.title)
                                .font(.headline)
                            Text(hangout.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Past Hangouts")
        .task { await fetchPastHangouts() }
    }

    @MainActor
    private func fetchPastHangouts() async {
        let db = Firestore.firestore()
        do {
            let snapshot = try await db.collection("hangouts")
                .whereField("participants", arrayContains: userID)
                .whereField("date", isLessThan: Timestamp(date: Date()))
                .order(by: "date", descending: true)
                .getDocuments()

            pastHangouts = snapshot.documents.compactMap {
                try? $0.data(as: HangoutSession.self)
            }
        } catch {
            print("❌ Failed to fetch past hangouts: \(error)")
        }
    }
}
