//
//  Checkpoint.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/29/25.
//

import Foundation
import CoreLocation

struct Checkpoint: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var time: Date?
    var location: CodableCoordinate
    var expenses: [Expense]
    var moments: [Moment]

    init(id: UUID = UUID(), title: String, time: Date? = nil, location: CLLocationCoordinate2D, expenses: [Expense] = [], moments: [Moment] = []) {
        self.id = id
        self.title = title
        self.time = time
        self.location = CodableCoordinate(from: location)
        self.expenses = expenses
        self.moments = moments
    }

    // Optional convenience initializer using CodableCoordinate directly
    init(id: UUID = UUID(), title: String, time: Date? = nil, codableLocation: CodableCoordinate, expenses: [Expense] = [], moments: [Moment] = []) {
        self.id = id
        self.title = title
        self.time = time
        self.location = codableLocation
        self.expenses = expenses
        self.moments = moments
    }
}

extension Checkpoint {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.time = try container.decodeIfPresent(Date.self, forKey: .time)
        self.location = try container.decode(CodableCoordinate.self, forKey: .location)
        self.expenses = try container.decodeIfPresent([Expense].self, forKey: .expenses) ?? []
        self.moments = try container.decodeIfPresent([Moment].self, forKey: .moments) ?? []
    }
}
