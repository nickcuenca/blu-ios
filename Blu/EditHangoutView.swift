//
//  EditHangoutView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/29/25.
//

//  EditHangoutView.swift
//  Blu

import SwiftUI
import MapKit

struct EditHangoutView: View {
    @Binding var hangout: HangoutSession
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
                hangout.title = title
                hangout.date = selectedDate
                if let coord = selectedCoordinate {
                    hangout.location = coord
                }
                dismiss()
            })
            .onAppear {
                title = hangout.title
                selectedDate = hangout.date
                selectedCoordinate = hangout.location
                region.center = hangout.location
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
}
