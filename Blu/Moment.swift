//
//  Moment.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/29/25.
//

import Foundation

struct Moment: Identifiable, Codable {
    let id: UUID
    var caption: String
    var imageData: Data?

    init(id: UUID = UUID(), caption: String = "", imageData: Data? = nil) {
        self.id = id
        self.caption = caption
        self.imageData = imageData
    }
}


