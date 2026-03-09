import Foundation
import FirebaseFirestore

struct UserProfile: Identifiable, Codable {
    let id: String
    var displayName: String
    var email: String
    var createdAt: Date?
    var lastLoginAt: Date?
    var photoUrl: String?
    var categoryIds: [String]
    var eventIds: [String]
    var settingsId: String?
    var impulseResisted: Int
    
    init(
        id: String,
        displayName: String = "",
        email: String = "",
        createdAt: Date? = nil,
        lastLoginAt: Date? = nil,
        photoUrl: String? = nil,
        categoryIds: [String] = [],
        eventIds: [String] = [],
        settingsId: String? = nil,
        impulseResisted: Int = 0
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
        self.photoUrl = photoUrl
        self.categoryIds = categoryIds
        self.eventIds = eventIds
        self.settingsId = settingsId
        self.impulseResisted = impulseResisted
    }
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.displayName = data["displayName"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.photoUrl = data["photoUrl"] as? String
        self.categoryIds = data["categoryIds"] as? [String] ?? []
        self.eventIds = data["eventIds"] as? [String] ?? []
        self.settingsId = data["settingsId"] as? String
        self.impulseResisted = data["impulseResisted"] as? Int ?? 0
        
        if let created = data["createdAt"] as? Timestamp {
            self.createdAt = created.dateValue()
        } else {
            self.createdAt = nil
        }
        
        if let lastLogin = data["lastLoginAt"] as? Timestamp {
            self.lastLoginAt = lastLogin.dateValue()
        } else {
            self.lastLoginAt = nil
        }
    }
}
