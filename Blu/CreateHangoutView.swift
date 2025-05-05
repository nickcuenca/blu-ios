//
//  CreateHangoutView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/27/25.
//

import SwiftUI
import CoreLocation

struct CreateHangoutView: View {
    @Binding var sessions: [HangoutSession]
    var onHangoutCreated: (() -> Void)? = nil

    @Environment(\.dismiss) var dismiss
    @AppStorage("username") var username: String = ""

    @State private var title = ""
    @State private var selectedDate = Date()
    @State private var selectedParticipants: [String] = []

    let allPeople = ["Nick", "Max", "Armeen", "John", "Lisa"]

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Hangout Info
                Section(header: Text("Hangout Info")) {
                    TextField("Enter hangout name", text: $title)
                }

                // MARK: - Date Selection
                Section(header: Text("Select Date & Time")) {
                    VStack(alignment: .leading, spacing: 4) {
                        // Use `.wheel` style to see the old spinning wheel
                        DatePicker(
                            "Choose Date",
                            selection: $selectedDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.wheel)
                    }
                }

                // MARK: - Participants
                Section(header: Text("Select Participants")) {
                    // Put the current user at the top:
                    let sortedPeople = [username] + allPeople.filter { $0 != username }

                    ForEach(sortedPeople, id: \.self) { person in
                        let isCurrentUser = person == username
                        let displayName = isCurrentUser ? "\(person) (You)" : person

                        HStack {
                            Text(displayName)
                            Spacer()
                            if selectedParticipants.contains(person) {
                                Image(systemName: "checkmark")
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Don't allow removing "You" from the list
                            if !isCurrentUser {
                                if selectedParticipants.contains(person) {
                                    selectedParticipants.removeAll { $0 == person }
                                } else {
                                    selectedParticipants.append(person)
                                }
                            }
                        }
                        .foregroundColor(isCurrentUser ? .gray : .primary)
                    }
                }

                // MARK: - Create Button
                Button("Create Hangout") {
                    var finalParticipants = selectedParticipants
                    if !finalParticipants.contains(username) {
                        finalParticipants.append(username)
                    }

                    let newSession = HangoutSession(
                        id: UUID().uuidString,
                        title: title,
                        date: selectedDate,
                        location: CLLocationCoordinate2D(latitude: 0, longitude: 0), // Placeholder
                        participants: finalParticipants,
                        expenses: []
                    )

                    sessions.append(newSession)
                    onHangoutCreated?()
                    dismiss()
                }
                .disabled(title.isEmpty || selectedParticipants.isEmpty)
            }
            .navigationTitle("New Hangout")
            .onAppear {
                // Make sure the current user is always included
                if !selectedParticipants.contains(username) {
                    selectedParticipants.append(username)
                }
            }
        }
    }
}
