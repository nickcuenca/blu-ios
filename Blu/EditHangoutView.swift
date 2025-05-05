//
//  EditHangoutView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/29/25.
//

import SwiftUI
import MapKit
import FirebaseFirestore

struct EditHangoutView: View {
    var sessionId: String
    var isEditing: Bool = true

    @Environment(\.dismiss) var dismiss

    @State private var title: String = ""
    @State private var selectedDate: Date = Date()
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.07, longitude: -118.44),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var pendingCoordinate: CLLocationCoordinate2D? = nil
    @State private var selectedCoordinate: CLLocationCoordinate2D? = nil
    @State private var isPlacingPin: Bool = false
    @State private var showMapPicker: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Hangout Info")) {
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                }

                Section(header: Text("Location")) {
                    Button(action: {
                        showMapPicker = true
                        isPlacingPin = true
                    }) {
                        HStack {
                            Image(systemName: "mappin.circle")
                            Text(selectedCoordinate == nil ? "Select a location" : "Location selected")
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Hangout" : "New Hangout")
            .navigationBarItems(trailing: Button("Save") {
                saveChangesToFirestore()
            })
            .onAppear {
                loadExistingSessionData()
            }
            .sheet(isPresented: $showMapPicker) {
                ZStack(alignment: .bottom) {
                    MapPickerView(
                        region: $region,
                        isPlacingPin: $isPlacingPin,
                        selectedCoordinate: $pendingCoordinate,
                        showConfirmButton: .constant(true),
                        pendingCoordinate: $pendingCoordinate
                    )

                    if pendingCoordinate != nil {
                        Button("Confirm Location") {
                            selectedCoordinate = pendingCoordinate
                            pendingCoordinate = nil
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
        }
    }

    // MARK: - Firestore Logic

    func loadExistingSessionData() {
        let db = Firestore.firestore()
        db.collection("hangoutSessions").document(sessionId).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.title = data["title"] as? String ?? ""
                self.selectedDate = (data["date"] as? Timestamp)?.dateValue() ?? Date()

                if let loc = data["location"] as? [String: Double],
                   let lat = loc["latitude"],
                   let lon = loc["longitude"] {
                    self.selectedCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    self.region.center = self.selectedCoordinate!
                }
            } else {
                print("❌ Failed to load session: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func saveChangesToFirestore() {
        let db = Firestore.firestore()
        var updates: [String: Any] = [
            "title": title,
            "date": Timestamp(date: selectedDate)
        ]

        if let coord = selectedCoordinate {
            updates["location"] = [
                "latitude": coord.latitude,
                "longitude": coord.longitude
            ]
        }

        db.collection("hangoutSessions").document(sessionId).updateData(updates) { error in
            if let error = error {
                print("❌ Failed to update hangout: \(error)")
            } else {
                print("✅ Hangout updated.")
                dismiss()
            }
        }
    }
}
