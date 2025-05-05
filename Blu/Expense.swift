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
    var timestamp: Date = Date()
    var createdBy: String

    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        paidBy: String,
        splitType: SplitType,
        participants: [String],
        itemizedBreakdown: [String: Double]? = nil,
        createdBy: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.paidBy = paidBy
        self.splitType = splitType
        self.participants = participants
        self.itemizedBreakdown = itemizedBreakdown
        self.createdBy = createdBy
        self.timestamp = timestamp
    }
}

extension Expense {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.paidBy = try container.decode(String.self, forKey: .paidBy)
        self.splitType = try container.decode(SplitType.self, forKey: .splitType)
        self.participants = try container.decode([String].self, forKey: .participants)
        self.itemizedBreakdown = try container.decodeIfPresent([String: Double].self, forKey: .itemizedBreakdown)
        self.createdBy = try container.decode(String.self, forKey: .createdBy)
        self.timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date()
    }
}
