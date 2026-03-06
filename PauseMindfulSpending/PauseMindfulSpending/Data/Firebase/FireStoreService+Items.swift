import FirebaseFirestore

extension FireStoreService {
    func createItem(
        uid: String,
        data: [String: Any],
        durationSeconds: Int,
        completion: @escaping (String?) -> Void
    ) {
        // Creates an item in the items subcollection and will pass the itemId using the
        // completion handler
        
        var updatedData = data
        updatedData["createdAt"] = FieldValue.serverTimestamp()
        updatedData["status"] = "wishlist"

        self.createTimer(uid: uid, durationSeconds: durationSeconds) {
            data in
            if data != nil {
                updatedData["timerId"] = data
            }
        }
        
        self.addDocumentToSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "items",
            data: updatedData
        ) { data in
            if data != nil {
                completion(data)
            }
        }
    }
    
    func fetchItem(
        uid: String,
        itemId: String,
        completion: @escaping ([String: Any]?) -> Void
    ) {
        // Fetches the item document and returns results in completion handler
        
        fetchDocumentFromSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "items",
            subId: itemId
        ) {
            data in
            if data != nil {
                completion(data)
            }
            else {
                completion(nil)
            }
        }
    }
    
    func updateItem(uid: String, itemId: String, fieldsToUpdate: [String: Any]) {
        // Updates contents of an item document. Will update the lastUpdatedAt
        // timestamp
        
        var updatedData = fieldsToUpdate
        updatedData["lastUpdatedAt"] = FieldValue.serverTimestamp()
        
        updateDocumentFromSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "items",
            subId: itemId,
            fieldsToUpdate: updatedData
        )
    }
    
    func deleteItem(uid: String, itemId: String) {
        self.updateItem(uid: uid, itemId: itemId, fieldsToUpdate: ["status": "deleted"])
    }
    
    func fetchWishlistItems(uid: String, completion: @escaping ([[String: Any]]?) -> Void) {
        // Retrieves all the items in the wishlist and stores them as an array of
        // dictionaries that each contain the item contents. It will pass the contents in
        // a completion handler. If there are no items with this category then it will
        // pass nil
        
        db.collection("items")
            .whereField("status", isEqualTo: "wishlist")
            .getDocuments{ snapshot, error in
                if let docs = snapshot?.documents {
                    let items = docs.map{ $0.data() }
                    completion(items)
                }
                else {
                    completion(nil)
                }
            }
    }
    
    func fetchItemsInCategory(
        uid: String,
        category: String,
        completion: @escaping ([[String: Any]]?) -> Void
    ) {
        // Retrieves all the items in a category and stores them as an array of
        // dictionaries that each contain the item contents. It will pass the contents in
        // a completion handler. If there are no items with this category then it will
        // pass nil
        
        db.collection("items")
            .whereField("category", isEqualTo: category)
            .getDocuments{ snapshot, error in
                if let docs = snapshot?.documents {
                    let items = docs.map{ $0.data() }
                    completion(items)
                }
                else {
                    completion(nil)
                }
            }
    }
    
}
