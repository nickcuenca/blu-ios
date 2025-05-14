// Core/Models/FriendRequest.swift
import Foundation

struct FriendRequest: Codable, Identifiable {
    enum Status: String, Codable { case pending, accepted, rejected }

    let id: String
    let from: String    // sender UID
    let to: String      // receiver UID
    var status: Status
    let createdAt: Date
}
