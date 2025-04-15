//  HangoutSession.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/29/25.

import Foundation
import CoreLocation
import MapKit

struct HangoutSession: Identifiable, Codable {
    let id: UUID
    var title: String
    var date: Date
    var location: CLLocationCoordinate2D  // 🌍 Location of hangout
    var participants: [String]
    var expenses: [Expense]
    var checkpoints: [Checkpoint] = []
}

// ✅ Codable conformance for CLLocationCoordinate2D
extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
}
