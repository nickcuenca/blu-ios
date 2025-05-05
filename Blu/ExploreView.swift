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
    @Binding var sessions: [HangoutSession]  // ✅ Accept external binding
    @State private var sessionIds: [String: String] = [:]
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.0689, longitude: -118.4452), // Default: UCLA
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(coordinateRegion: $region, annotationItems: sessions) { session in
                MapAnnotation(coordinate: session.location) {
                    VStack(spacing: 4) {
                        Image(systemName: session.date > Date() ? "calendar.circle.fill" : "clock.fill")
                            .font(.title)
                            .foregroundColor(session.date > Date() ? .green : .gray)

                        Text(session.title)
                            .font(.caption2)
                            .padding(4)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(6)
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)

            Button(action: {
                // Optional: Add logic for future action
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
        .navigationTitle("Explore")
    }
}
