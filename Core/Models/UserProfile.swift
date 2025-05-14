// Core/Models/UserProfile.swift
import Foundation

struct UserProfile: Codable, Identifiable {
    let id: String                      // == Firebase UID
    var displayName: String
    var email: String
    var photoURL: String?
    var joinedAt: Date?
    var stats: Stats
    var payment: Payment

    struct Stats: Codable {
        var friends: Int
        var hangouts: Int
        var balanceOwed: Double
    }

    struct Payment: Codable {
        var venmo: String
        var paypal: String
    }
}
