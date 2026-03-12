import SwiftUI
import FirebaseFirestore

final class WishlistViewModel: ObservableObject {
    
    @Published var userProfile: UserProfile
    
    private let firestoreService = FireStoreService()
    let uid: String
    
    init(uid: String, userProfile: UserProfile) {
        self.uid = uid
        self.userProfile = userProfile
    }

    var displayName: String {
        userProfile.displayName
    }
}
