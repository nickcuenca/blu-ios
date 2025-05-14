//
//  CreateHangoutViewWithLocation.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/29/25.
//

import SwiftUI
import MapKit

struct CreateHangoutViewWithLocation: View {
    @Binding var sessions: [HangoutSession]
    var onHangoutCreated: (() -> Void)? = nil
    var preselectedCoordinate: CLLocationCoordinate2D? = nil

    @Environment(\.dismiss) var dismiss
    @AppStorage("username") var username: String = ""

    @State private var title = ""
    @State private var selectedDate = Date()
    @State private var selectedParticipants: [String] = []
    @State private var showMapPicker = false
    @State private var selectedCoordinate: CLLocationCoordinate2D? = nil
    @State private var pendingCoordinate: CLLocationCoordinate2D? = nil
    @State private var isPlacingPin = false
    @State private var showConfirmButton = false

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.07, longitude: -118.44),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    let allPeople = ["Nick", "Max", "Armeen", "John", "Lisa"]

    var body: some View {
        NavigationView {
            Form {
                // Hangout Info
                Section(header: Text("Hangout Info")) {
                    TextField("Enter hangout title", text: $title)
                    DatePicker("Select Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                }

                // Location
                Section(header: Text("Location")) {
                    Button(action: {
                        showMapPicker = true
                        isPlacingPin = true
                    }) {
                        HStack {
                            Image(systemName: "mappin.circle")
                            Text(selectedCoordinate == nil ? "Pick a location" : "Location selected")
                        }
                    }
                }

                // Participants
                Section(header: Text("Select Participants")) {
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

                // Create Button
                Button("Create Hangout") {
                    var finalParticipants = selectedParticipants
                    if !finalParticipants.contains(username) {
                        finalParticipants.append(username)
                    }

                    guard let coordinate = selectedCoordinate else { return }

                    let generatedId = UUID().uuidString
                    let newSession = HangoutSession(
                        id: generatedId,
                        title: title,
                        date: selectedDate,
                        location: coordinate,
                        participants: finalParticipants,
                        expenses: []
                    )

                    sessions.append(newSession)
                    onHangoutCreated?()
                    dismiss()
                }
                .disabled(title.isEmpty || selectedParticipants.isEmpty || selectedCoordinate == nil)
            }
            .navigationTitle("New Hangout")
            .sheet(isPresented: $showMapPicker) {
                ZStack(alignment: .bottom) {
                    MapPickerView(
                        region: $region,
                        isPlacingPin: $isPlacingPin,
                        selectedCoordinate: $selectedCoordinate,
                        showConfirmButton: $showConfirmButton,
                        pendingCoordinate: $pendingCoordinate
                    )

                    if showConfirmButton, let pending = pendingCoordinate {
                        Button("Confirm Location") {
                            selectedCoordinate = pending
                            pendingCoordinate = nil
                            showConfirmButton = false
                            showMapPicker = false
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                    }
                }
            }
            .onAppear {
                if !selectedParticipants.contains(username) {
                    selectedParticipants.append(username)
                }

                if let preselected = preselectedCoordinate, selectedCoordinate == nil {
                    selectedCoordinate = preselected
                }
            }
        }
    }
}
