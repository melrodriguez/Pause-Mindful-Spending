import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AppSessionViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var userSettings: UserSettings?
    @Published var isLoading = false
    @Published var isAuthenticated = false
    
    private let firestoreService = FireStoreService()
    
    init() {
        listenToAuthState()
    }
        
    // This listener waits for user to be authenticated (logged in)
    private func listenToAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let user = user {
                    self.isAuthenticated = true
                    self.loadSessionData(uid: user.uid)
                } else {
                    self.isAuthenticated = false
                    self.userProfile = nil
                    self.userSettings = nil
                }
            }
        }
    }
    
    // Temporary logout function for debugging
    func logout() {
        try? Auth.auth().signOut()
    }
    
    func loadSessionData(uid: String) {
        guard !uid.isEmpty else { return }
        guard !isLoading else { return }
        
        isLoading = true
        
        firestoreService.fetchUser(uid: uid) { [weak self] data in
            guard let self = self else { return }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            let profile = UserProfile(id: uid, data: data)
            
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
                parentId: uid,
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
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Authenticated user not found.")
            return
        }
        
        firestoreService.updateSettings(
            uid: uid,
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
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Authenticated user not found.")
            return
        }

        firestoreService.updateSettings(
            uid: uid,
            settingId: settings.id,
            fieldsToUpdate: [
                "isHapticsEnabled": value,
                "updatedAt": FieldValue.serverTimestamp()
            ]
        )
    }
    
    func updateWishlistLayout(_ value: WishlistLayout) {
        guard var settings = userSettings else { return }
        
        settings.wishlistLayout = value
        userSettings = settings
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Authenticated user not found.")
            return
        }

        firestoreService.updateSettings(
            uid: uid,
            settingId: settings.id,
            fieldsToUpdate: [
                "wishlistLayout": value.rawValue,
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
