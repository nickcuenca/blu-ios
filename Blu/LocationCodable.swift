//
//  LocationCodable.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/29/25.
//

// LocationCodable.swift
import Foundation
import CoreLocation

struct CodableCoordinate: Codable {
    var latitude: Double
    var longitude: Double

    // Computed property to convert to CLLocationCoordinate2D
    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // ✅ This initializer must exist
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    // Optional initializer to create from CLLocationCoordinate2D
    init(from coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}
