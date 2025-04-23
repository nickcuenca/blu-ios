//
//  Expense.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/29/25.
//

import Foundation
import CoreLocation

struct Expense: Identifiable, Codable, Hashable, Equatable {
    let id: UUID
    var title: String
    var amount: Double
    var paidBy: String
    var splitType: SplitType
    var participants: [String]
    var itemizedBreakdown: [String: Double]?

    // Init if not present
    init(id: UUID = UUID(), title: String, amount: Double, paidBy: String, splitType: SplitType, participants: [String], itemizedBreakdown: [String: Double]? = nil) {
        self.id = id
        self.title = title
        self.amount = amount
        self.paidBy = paidBy
        self.splitType = splitType
        self.participants = participants
        self.itemizedBreakdown = itemizedBreakdown
    }
}
