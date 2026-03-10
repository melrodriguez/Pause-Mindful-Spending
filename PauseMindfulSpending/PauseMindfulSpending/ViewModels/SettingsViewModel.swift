import SwiftUI
import FirebaseFirestore

final class SettingsViewModel: ObservableObject {
    @Published var userProfile: UserProfile
    @Published var userSettings: UserSettings
    
    private let firestoreService = FireStoreService()
    let uid: String
    
    init(uid: String, userProfile: UserProfile, userSettings: UserSettings) {
        self.uid = uid
        self.userProfile = userProfile
        self.userSettings = userSettings
    }
    
    var displayName: String {
        userProfile.displayName
    }
    
    var email: String {
        userProfile.email
    }
    
    var photoUrl: String? {
        userProfile.photoUrl
    }
    
    var hapticsEnabled: Bool {
        userSettings.isHapticsEnabled
    }
    
    var singleCardView: Bool {
        userSettings.wishlistLayout == .single
    }
    
    func updateHaptics(_ value: Bool) {
        userSettings.isHapticsEnabled = value
        sync(["isHapticsEnabled": value])
    }
    
    func updateWishlistLayout(singleCard: Bool) {
        let layout: WishlistLayout = singleCard ? .single : .grid
        userSettings.wishlistLayout = layout
        sync(["wishlistLayout": layout.rawValue])
    }
    
    private func sync(_ fields: [String: Any]) {
        var updatedFields = fields
        updatedFields["updatedAt"] = FieldValue.serverTimestamp()
        
        firestoreService.updateSettings(
            uid: uid,
            settingId: userSettings.id,
            fieldsToUpdate: updatedFields
        )
    }
}
