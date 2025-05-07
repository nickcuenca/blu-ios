//
//  ExploreView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/29/25.
//

import SwiftUI
import MapKit
import FirebaseFirestore

struct ExploreView: View {
    @Binding var sessions: [HangoutSession]
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 34.0689, longitude: -118.4452),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(position: $position) {
                ForEach(sessions) { session in
                    Annotation(session.title, coordinate: session.location) {
                        Label {
                            Text(session.title)
                                .font(.caption2)
                                .padding(6)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(6)
                        } icon: {
                            Image(systemName: session.date > Date() ? "calendar.circle.fill" : "clock.fill")
                                .foregroundColor(session.date > Date() ? .green : .gray)
                                .font(.title3)
                        }
                    }
                }
            }
            .mapStyle(.standard)
            .edgesIgnoringSafeArea(.all)

            Button(action: {
                // Future logic for adding new hangout
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                    .padding(12)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding()
        }
        // Removed: .navigationTitle("Explore")
    }
}
