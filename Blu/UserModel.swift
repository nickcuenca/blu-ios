//
//  UserModel.swift
//  Blu
//
//  Created by Nicolas Cuenca on 4/29/25.
//

import Foundation

struct BluUser: Identifiable {
    var id: String? = nil
    var username: String
    var handle: String
    var email: String
    var friends: [String]
    var createdAt: Date
}
