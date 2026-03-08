import Foundation
import FirebaseFirestore

enum WishlistLayout: String, Codable {
    case grid
    case single
}

struct UserSettings: Identifiable, Codable {
    let id: String
    var isNightMode: Bool
    var isHapticsEnabled: Bool
    var wishlistLayout: WishlistLayout
    var updatedAt: Date?
    
    init(
        id: String,
        isNightMode: Bool = false,
        isHapticsEnabled: Bool = false,
        wishlistLayout: WishlistLayout = .grid,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.isNightMode = isNightMode
        self.isHapticsEnabled = isHapticsEnabled
        self.wishlistLayout = wishlistLayout
        self.updatedAt = updatedAt
    }
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.isNightMode = data["isNightMode"] as? Bool ?? false
        self.isHapticsEnabled = data["isHapticsEnabled"] as? Bool ?? false
        
        let rawLayout = data["wishlistLayout"] as? String ?? "grid"
        self.wishlistLayout = WishlistLayout(rawValue: rawLayout) ?? .grid
        
        if let updated = data["updatedAt"] as? Timestamp {
            self.updatedAt = updated.dateValue()
        } else {
            self.updatedAt = nil
        }
    }
    
    var asDictionary: [String: Any] {
        [
            "isNightMode": isNightMode,
            "isHapticsEnabled": isHapticsEnabled,
            "wishlistLayout": wishlistLayout.rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ]
    }
}
