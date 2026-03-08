import FirebaseFirestore

extension FireStoreService {
    func createItem(
        uid: String,
        data: [String: Any],
        durationSeconds: Int,
        category: String?,
        completion: @escaping ([String: Any]?) -> Void)
    {
        // Creates an item in the items subcollection and will pass the itemId, timerId,
        // and categoryId using the completion handler
        
        var updatedData = data
        var dataToReturn: [String: Any] = [:]
        
        updatedData["createdAt"] = FieldValue.serverTimestamp()
        updatedData["status"] = "wishlist"
        updatedData["lastUpdatedAt"] = FieldValue.serverTimestamp()

        self.createTimer(uid: uid, durationSeconds: durationSeconds) {timerId in
            guard let timerId = timerId else {
                completion(nil)
                return
            }
            
            updatedData["timerId"] = timerId
            dataToReturn["timerId"] = timerId
            
            if let category = category {
                self.fetchCategoryIdUsingName(uid: uid, name: category) { categoryId in
                    if let categoryId = categoryId {
                        updatedData["categoryId"] = categoryId
                        dataToReturn["categoryId"] = categoryId
                    }
                    
                    self.addDocumentToSubcollection(
                        parentCollection: "users",
                        parentId: uid,
                        subCollection: "items",
                        data: updatedData) { itemId in
                        guard let itemId = itemId else {
                            completion(nil)
                            return
                        }
                            
                        dataToReturn["itemId"] = itemId
                        completion(dataToReturn)
                    }
                }
            } else {
                self.addDocumentToSubcollection(
                    parentCollection: "users",
                    parentId: uid,
                    subCollection: "items",
                    data: updatedData) { itemId in
                    guard let itemId = itemId else {
                        completion(nil)
                        return
                    }
                        
                    dataToReturn["itemId"] = itemId
                    completion(dataToReturn)
                }

            }
        }
    }
    
    func fetchItem(uid: String, itemId: String, completion: @escaping ([String: Any]?) -> Void) {
        // Fetches the item document and returns results in completion handler
        
        fetchDocumentFromSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "items",
            subId: itemId) { itemData in
            guard let itemData = itemData else {
                completion(nil)
                return
            }
                
            completion(itemData)
        }
    }
    
    func fetchAllItemDocuments(uid: String, completion: @escaping ([[String: Any]]) -> Void) {
        // Fetches all the documents in item collection inside the user document. Will
        // return results through completion handler
        
        db.collection("users").document(uid).collection("items").getDocuments{ snapshot, error in
            guard let docs = snapshot?.documents else {
                completion([])
                return
            }
            
            let items = docs.map{ $0.data() }
            completion(items)
        }
    }
    
    func fetchAllItemDocumentsIds(uid: String, completion: @escaping ([String]) -> Void) {
        db.collection("users").document(uid).collection("items").getDocuments{ snapshot, error in
            guard let docs = snapshot?.documents else {
                completion([])
                return
                
            }
            let ids = docs.map { $0.documentID }
            completion(ids)
        }
    }
    
    func fetchItemDetailsForStruct(
        uid: String,
        itemId: String,
        completion: @escaping ([String: Any]?) -> Void)
    {
        // Gets all the infomration necesary to create Item struct. Will return results
        // through completion handler
        
        self.fetchItem(uid: uid, itemId: itemId) { itemData in
            guard
                let itemData = itemData,
                let timerId = itemData["timerId"] as? String,
                let categoryId = itemData["categoryId"] as? String
            else {
                completion(nil)
                return
            }
                
            let dataToReturn: [String: Any] = [
                "itemId": itemId,
                "timerId": timerId,
                "categoryId": categoryId
            ]
                
            completion(dataToReturn)
        }
    }
    
    func fetchItemsForList(uid: String, completion: @escaping ([[String: Any]]) -> Void) {
        // Gets all the information necessary to create Item struct for all documents in
        // item collection. Will return through completion handler
        
        var itemList: [[String: Any]] = []
        
        self.fetchAllItemDocumentsIds(uid: uid) { itemIds in
            let group = DispatchGroup()
            
            for itemId in itemIds {
                group.enter()
                
                self.fetchItemDetailsForStruct(uid: uid, itemId: itemId) { itemStructData in
                    if let itemStructData = itemStructData {
                        itemList.append(itemStructData)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(itemList)
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
        self.fetchItem(uid: uid, itemId: itemId) { itemData in
            guard
                let itemData = itemData,
                let timerId = itemData["timerId"] as? String
            else {
                return
            }
            
            self.deleteTimer(uid: uid, timerId: timerId)
            self.updateItem(uid: uid, itemId: itemId, fieldsToUpdate: [
                "status": "deleted",
                "timerId": FieldValue.delete(),
                "lastUpdatedAt": FieldValue.serverTimestamp()
            ])
        }
    }
    
    func fetchWishlistItems(uid: String, completion: @escaping ([[String: Any]]?) -> Void) {
        // Retrieves all the items in the wishlist and stores them as an array of
        // dictionaries that each contain the item contents. It will pass the contents in
        // a completion handler. If there are no items with this category then it will
        // pass nil
        
        db.collection("items")
            .whereField("status", isEqualTo: "wishlist")
            .getDocuments{ snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion(nil)
                    return
                }
                
                let items = docs.map{ $0.data() }
                completion(items)
            }
    }
    
    func fetchItemsInCategory(
        uid: String,
        categoryId: String,
        completion: @escaping ([[String: Any]]?) -> Void)
    {
        // Retrieves all the items in a category and stores them as an array of
        // dictionaries that each contain the item contents. It will pass the contents in
        // a completion handler. If there are no items with this category then it will
        // pass nil
        
        db.collection("users")
            .document(uid)
            .collection("items")
            .whereField("categoryId", isEqualTo: categoryId)
            .whereField("status", isEqualTo:  "wishlist")
            .getDocuments{ snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion(nil)
                    return
                }
                
                let items = docs.map{ $0.data() }
                completion(items)
            }
    }
    
    func setItemAsBought(uid: String, itemId: String) {
        self.fetchItem(uid: uid, itemId: itemId) { itemData in
            guard
                let itemData = itemData,
                let timerId = itemData["timerId"] as? String
            else {
            
                return
            }
                    
            if let categoryId = itemData["categoryId"] as? String {
                self.updateCategoryStreak(uid: uid, categoryId: categoryId, dateItemBought: Date())
            }
                
            self.deleteTimer(uid: uid, timerId: timerId)
            self.updateItem(uid: uid, itemId: itemId, fieldsToUpdate: [
                "status": "bought",
                "timerId": FieldValue.delete(),
                "lastUpdatedAT": FieldValue.serverTimestamp()
            ])
        }
    }
    
}
