//  HangoutSession.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/29/25.

import Foundation
import CoreLocation
import MapKit
import FirebaseFirestore

struct HangoutSession: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore auto-generated ID
    var title: String
    var date: Date
    var location: CLLocationCoordinate2D
    var participants: [String]
    var expenses: [Expense] = []
    var checkpoints: [Checkpoint] = []

    enum CodingKeys: String, CodingKey {
        case id, title, date, location, participants, expenses, checkpoints
    }

    init(id: String? = nil, title: String, date: Date, location: CLLocationCoordinate2D, participants: [String], expenses: [Expense] = [], checkpoints: [Checkpoint] = []) {
        self.id = id
        self.title = title
        self.date = date
        self.location = location
        self.participants = participants
        self.expenses = expenses
        self.checkpoints = checkpoints
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.date = try container.decode(Date.self, forKey: .date)
        self.location = try container.decode(CLLocationCoordinate2D.self, forKey: .location)
        self.participants = try container.decode([String].self, forKey: .participants)
        self.expenses = try container.decodeIfPresent([Expense].self, forKey: .expenses) ?? []
        self.checkpoints = try container.decodeIfPresent([Checkpoint].self, forKey: .checkpoints) ?? []
    }
}

// Codable support for Firestore location data
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
