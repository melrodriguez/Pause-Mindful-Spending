import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AppSessionViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var userSettings: UserSettings?
    @Published var timerItems: [TimerItem] = []
    @Published var items: [Item] = []
    
    @Published var isLoading = false
    @Published var isAuthenticated = false
    
    private let firestoreService = FireStoreService()
    private let userManager = UserManager()
    
    init() {
        listenToAuthState()
    }

    private func listenToAuthState() {
        userManager.addAuthStateListener { [weak self] uid in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let uid = uid {
                    self.isAuthenticated = true
                    self.loadSessionData(uid: uid)
                } else {
                    self.isAuthenticated = false
                    self.userProfile = nil
                    self.userSettings = nil
                }
            }
        }
    }

    func logout() {
        userManager.logout()
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
            // print(uid)
            // print(data)
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
                    self.loadTimerItems()
                    self.loadItems()
                }
            }
        }
    }
    
    func updateNightMode(_ value: Bool) {
        guard var settings = userSettings else { return }
        
        settings.isNightMode = value
        userSettings = settings
        
        guard let uid = userManager.getCurrentUserId() else {
            print("Authenticated user not found")
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
        
        guard let uid = userManager.getCurrentUserId() else {
            print("Authenticated user not found")
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
        
        guard let uid = userManager.getCurrentUserId() else {
            print("Authenticated user not found")
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
    
    func loadTimerItems() {
        guard let uid = userManager.getCurrentUserId() else {
            print("Authenticated user not found")
            return
        }
        
        self.firestoreService.fetchItemsForList(uid: uid) { results in
            var loadedTimers: [TimerItem] = []
            let group = DispatchGroup()
            
            for data in results {
                guard
                    let _ = data["itemId"] as? String,
                    let timerId = data["timerId"] as? String,
                    let itemName = data["name"] as? String
                else { continue }
                
                group.enter()
                
                self.firestoreService.fetchTimer(uid: uid, timerId: timerId) { document in
                    defer { group.leave() }
                    guard
                        let document = document,
                        let timestamp = document["endDate"] as? Timestamp
                    else { return }
                    
                    let endDate = timestamp.dateValue()
                    let duration = max(0, endDate.timeIntervalSince(Date()))
                    let imageUrl = data["imageUrl"] as? String
                    
                    let timer = TimerItem(
                        id: timerId,
                        itemName: itemName,
                        startTime: Date(),
                        duration: duration,
                        imageUrl: imageUrl
                    )
                    
                    loadedTimers.append(timer)
                }
                
            }
            
            group.notify(queue: .main) {
                self.timerItems = loadedTimers
            }
        }
    }
    
    func loadItems() {
        guard let uid = userManager.getCurrentUserId() else {
            print("Authenticated user not found")
            return
        }
        
        self.firestoreService.fetchItemsForList(uid: uid) { results in
            var loadedItems: [Item] = []
            
            for data in results {
                guard
                    let itemId = data["itemId"] as? String,
                    let timerId = data["timerId"] as? String,
                    let itemName = data["name"] as? String
                else { continue }
                
                let categoryId = data["categoryId"] as? String
                let photoUrl = data["photoUrl"] as? String

                let item = Item(
                    id: itemId,
                    name: itemName,
                    timerId: timerId,
                    categoryId: categoryId,
                    imageUrl: photoUrl
                )
                
                loadedItems.append(item)
            }
            
            DispatchQueue.main.async {
                self.items = loadedItems
            }
        }
    }
}
