//  ExploreView.swift
//  Blu

import SwiftUI
import MapKit

struct ExploreView: View {
    @Binding var sessions: [HangoutSession]

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

            // Optional: Add button for future pin drops
            Button(action: {
                // Placeholder: You can later add functionality to drop a pin or navigate to new hangout creation
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

// Preview
struct ExploreView_Previews: PreviewProvider {
    @State static var dummySessions: [HangoutSession] = [
        HangoutSession(
            id: UUID(),
            title: "BBQ at Sunset",
            date: Date().addingTimeInterval(3600),
            location: CLLocationCoordinate2D(latitude: 34.07, longitude: -118.44),
            participants: ["Nick", "Max"],
            expenses: [],
            checkpoints: []
        )
    ]

    static var previews: some View {
        ExploreView(sessions: $dummySessions)
    }
}
