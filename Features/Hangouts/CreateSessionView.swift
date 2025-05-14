//
//  CreateSessionView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/29/25.
//

import SwiftUI
import CoreLocation
import FirebaseFirestore

struct CreateSessionView: View {
    @AppStorage("username") var username: String = ""
    @State private var title = ""
    @State private var selectedParticipants: [String] = []
    @Environment(\.dismiss) var dismiss

    let allPeople = ["Nick", "Max", "Armeen", "John", "Lisa"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Session Info")) {
                    TextField("Title", text: $title)
                }

                Section(header: Text("Select Participants")) {
                    let sortedPeople = [username] + allPeople.filter { $0 != username }
                    ForEach(sortedPeople, id: \.self) { person in
                        Toggle(isOn: Binding(
                            get: { selectedParticipants.contains(person) },
                            set: { isSelected in
                                if isSelected {
                                    selectedParticipants.append(person)
                                } else {
                                    selectedParticipants.removeAll { $0 == person }
                                }
                            })) {
                                Text(person)
                            }
                    }
                }

                Section {
                    Button("Create Hangout") {
                        var finalParticipants = selectedParticipants
                        if !finalParticipants.contains(username) {
                            finalParticipants.append(username)
                        }

                        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
                        let sessionId = UUID().uuidString
                        let db = Firestore.firestore()

                        let sessionData: [String: Any] = [
                            "title": title,
                            "date": Timestamp(date: Date()),
                            "participants": finalParticipants,
                            "location": [
                                "latitude": coordinate.latitude,
                                "longitude": coordinate.longitude
                            ],
                            "createdBy": username
                        ]

                        db.collection("hangoutSessions").document(sessionId).setData(sessionData) { error in
                            if let error = error {
                                print("❌ Failed to create session: \(error)")
                            } else {
                                print("✅ Session created with ID: \(sessionId)")
                                dismiss()
                            }
                        }
                    }
                    .disabled(title.isEmpty || selectedParticipants.isEmpty)
                }
            }
            .navigationTitle("New Hangout")
        }
    }
}
