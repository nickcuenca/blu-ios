import Foundation

struct UserProfile: Codable, Identifiable {
    var id: String?                 // ← plain property; no @DocumentID
    var name: String
    var username: String
    var email: String
    var payment: [String:String]
    var createdAt: Date?
}
