import SwiftUI
import FirebaseFirestore

final class WishlistViewModel: ObservableObject {
    @Published var isLoading = false
    
    @Published var userProfile: UserProfile
    @Published var items: [Item] = []
    
    private let firestoreService = FireStoreService()
    let uid: String
    
    init(uid: String, userProfile: UserProfile) {
        self.uid = uid
        self.userProfile = userProfile
    }

    var displayName: String {
        userProfile.displayName
    }
    
    func loadItems() {
        if items.isEmpty {
            isLoading = true
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
                if self.isLoading {
                    self.isLoading = false
                }
                self.items = loadedItems
            }
        }
    }
}
