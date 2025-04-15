//
//  Checkpoint.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/29/25.
//


import Foundation
import CoreLocation

struct Checkpoint: Identifiable, Codable {
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
