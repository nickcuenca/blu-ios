//
//  Moment.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/29/25.
//

import Foundation

struct Moment: Identifiable, Codable, Hashable, Equatable {
    let id: String               // Firestore-friendly UUID
    var caption: String
    var imageURL: String?       // ✅ Must match Firestore key exactly
    var createdBy: String
    var timestamp: Date

    init(
        id: String = UUID().uuidString,
        caption: String,
        imageURL: String? = nil,
        createdBy: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.caption = caption
        self.imageURL = imageURL
        self.createdBy = createdBy
        self.timestamp = timestamp
    }

    // Custom decoder to gracefully handle missing fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.caption = try container.decode(String.self, forKey: .caption)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        self.createdBy = try container.decode(String.self, forKey: .createdBy)
        self.timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date()
    }
}
