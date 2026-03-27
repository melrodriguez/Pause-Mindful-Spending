import SwiftUI
import FirebaseFirestore

final class WishlistViewModel: ObservableObject {
    @Published var userProfile: UserProfile
    @Published var items: [Item] = []
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    let uid: String
    
    init(uid: String, userProfile: UserProfile) {
        self.uid = uid
        self.userProfile = userProfile
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    deinit {
        stopListening()
    }

    var displayName: String {
        userProfile.displayName
    }
    
    func getItems() {
        listener = db.collection("users")
            .document(uid)
            .collection("items")
            .whereField("status", isEqualTo: "wishlist")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error getting items: \(error)")
                    return
                }
                
                self.items = snapshot?.documents.compactMap { document in
                    try? document.data(as: Item.self)
                } ?? []
            }
    }
    
}
