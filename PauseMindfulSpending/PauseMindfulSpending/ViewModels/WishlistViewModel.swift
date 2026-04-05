import SwiftUI
import FirebaseFirestore

final class WishlistViewModel: ObservableObject {
    private let repo = DashboardRepository()
    
    @Published var userProfile: UserProfile
    @Published var items: [Item] = []
    @Published var categories: [String] = []
    
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
    
    func startItemListener(fieldType: String, fieldValue: String) {
        listener = db.collection("users")
            .document(uid)
            .collection("items")
            .whereField(fieldType, isEqualTo: fieldValue)
            .order(by: "createdAt", descending: true)
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
    
    func loadCategories() {
        repo.fetchCategoryNames(uid: uid) { [weak self] categories in
            self?.categories = categories
        }
    }
}
