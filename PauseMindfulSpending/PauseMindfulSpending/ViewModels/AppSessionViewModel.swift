import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AppSessionViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var userSettings: UserSettings?
    @Published var isLoading = false
    
    private let firestoreService = FireStoreService()
    
    var currentUID: String {
        // temp - hardcode user for testing
        Auth.auth().currentUser?.uid ?? "KldBIFHuI45un0BgIet2"
    }
    
    func loadSessionData() {
        guard !currentUID.isEmpty else { return }
        guard !isLoading else { return }
        
        isLoading = true
        
        firestoreService.fetchUser(uid: currentUID) { [weak self] data in
            guard let self = self else { return }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            let profile = UserProfile(id: self.currentUID, data: data)
            
            DispatchQueue.main.async {
                self.userProfile = profile
            }
            
            guard let settingsId = profile.settingsId, !settingsId.isEmpty else {
                DispatchQueue.main.async {
                    self.userSettings = nil
                    self.isLoading = false
                }
                return
            }
            
            self.firestoreService.fetchDocumentFromSubcollection(
                parentCollection: "users",
                parentId: self.currentUID,
                subCollection: "settings",
                subId: settingsId
            ) { settingsData in
                DispatchQueue.main.async {
                    if let settingsData = settingsData {
                        self.userSettings = UserSettings(id: settingsId, data: settingsData)
                    } else {
                        self.userSettings = nil
                    }
                    
                    self.isLoading = false
                }
            }
        }
    }
    
    func updateNightMode(_ value: Bool) {
        guard var settings = userSettings else { return }
        
        settings.isNightMode = value
        userSettings = settings
        
        firestoreService.updateSettings(
            uid: currentUID,
            settingId: settings.id,
            fieldsToUpdate: [
                "isNightMode": value,
                "updatedAt": FieldValue.serverTimestamp()
            ]
        )
    }
    
    func updateHaptics(_ value: Bool) {
        guard var settings = userSettings else { return }

        settings.isHapticsEnabled = value
        userSettings = settings

        firestoreService.updateSettings(
            uid: currentUID,
            settingId: settings.id,
            fieldsToUpdate: [
                "isHapticsEnabled": value,
                "updatedAt": FieldValue.serverTimestamp()
            ]
        )
    }
    
    func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard userSettings?.isHapticsEnabled == true else { return }
        
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
