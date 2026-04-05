import SwiftUI
import FirebaseFirestore

final class WishlistViewModel: ObservableObject {
    private let repo = DashboardRepository()
    
    @Published var userProfile: UserProfile
    @Published var items: [Item] = []
    @Published var categories: [Category] = []

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
    
    func startItemListener() {
        listener = db.collection("users")
            .document(uid)
            .collection("items")
            .whereField("status", isEqualTo: "wishlist")
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
    
    func filterByStatus(status: String) {
        listener?.remove()
        
        let query = db.collection("users")
            .document(uid)
            .collection("items")
            .whereField("status", isEqualTo: status)
        
        listener = query.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error getting items: \(error)")
                return
            }
            
            self.items = snapshot?.documents.compactMap { document in
                try? document.data(as: Item.self)
            } ?? []
        }
        
        print("\(status)")
        print(items)
        print("Filtered by Status")
    }
    
    func filterByCategory(categoryId: String) {
        listener?.remove()
        
        var query = db.collection("users")
            .document(uid)
            .collection("items")
            .whereField("status", isEqualTo: "wishlist")
        
        query = query.whereField("categoryId", isEqualTo: categoryId)
        
        listener = query.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error getting items: \(error)")
                return
            }
            
            self.items = snapshot?.documents.compactMap { document in
                try? document.data(as: Item.self)
            } ?? []
        }
        
        print(items)
        print(categoryId)
        print("Filtered by Category")
    }
    
    func loadCategories() {
        db.collection("users")
            .document(uid)
            .collection("categories")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting items: \(error)")
                    return
                }
                
                self.categories = snapshot?.documents.compactMap { document in
                    try? document.data(as: Category.self)
                } ?? []
            }
    }
}
