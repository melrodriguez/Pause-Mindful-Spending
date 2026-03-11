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
        
        guard let _ = updatedData["cost"] as? Double else {
            // Misisng cost
            completion(nil)
            return
        }

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
                            
                            self.createEvent(uid: uid, type: "item_created", itemId: itemId) { eventId in
                                guard let _ = eventId else {
                                    // Failed to make event
                                    completion(nil)
                                    return
                                }
                                
                                completion(dataToReturn)
                            }
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
                        
                        self.createEvent(uid: uid, type: "item_created", itemId: itemId) { eventId in
                            guard let _ = eventId else {
                                // Failed to make event
                                completion(nil)
                                return
                            }
                            
                            completion(dataToReturn)
                        }
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
        // Gets all the information necessary to create Item struct. Will return results
        // through completion handler
        
        self.fetchItem(uid: uid, itemId: itemId) { itemData in
            guard
                let itemData = itemData,
                let timerId = itemData["timerId"] as? String,
                let itemName = itemData["name"] as? String
            else {
                completion(nil)
                return
            }
            
            let categoryId = itemData["categoryId"] as? String
            let photoUrl = itemData["photoUrl"] as? String
            
            var dataToReturn: [String: Any] = [
                "itemId": itemId,
                "timerId": timerId,
                "name": itemName
            ]

            if let categoryId = categoryId {
                dataToReturn["categoryId"] = categoryId
            }
            
            if let photoUrl = photoUrl {
                dataToReturn["imageUrl"] = photoUrl
            }

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
        
        if let _ = fieldsToUpdate["categoryId"] as? String {
            self.createEvent(uid: uid, type: "update_item_category", itemId: itemId) { eventId in }
        }
        
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
                let timerId = itemData["timerId"] as? String,
                let _ = itemData["cost"] as? Double
            else {
                return
            }
            
            self.deleteTimer(uid: uid, timerId: timerId)
            self.updateItem(uid: uid, itemId: itemId, fieldsToUpdate: [
                "status": "deleted",
                "timerId": FieldValue.delete(),
                "lastUpdatedAt": FieldValue.serverTimestamp()
            ])
            
            self.createEvent(uid: uid, type: "item_deleted", itemId: itemId) { eventId in
                return
            }
        }
    }
    
    func fetchItemsByStatus(uid: String, status: String ,completion: @escaping ([String]) -> Void) {
        // Retrieves all the itemIds that belong in a specified status. Will return a
        // list of itemIds or an empty list through completion handler.
        
        db.collection("items")
            .whereField("status", isEqualTo: status)
            .getDocuments{ snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let itemIds = documents.map{ $0.documentID }
                completion(itemIds)
            }
    }
    
    func fetchItemsInCategory(
        uid: String,
        categoryId: String,
        completion: @escaping ([String]) -> Void)
    {
        // Retrieves all the itemIds that belong in a specified category. Will return a
        // list of itemIds or an empty list through completion handler.
        
        db.collection("users")
            .document(uid)
            .collection("items")
            .whereField("categoryId", isEqualTo: categoryId)
            .whereField("status", isEqualTo:  "wishlist")
            .getDocuments{ snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let itemIds = docs.map{ $0.documentID }
                completion(itemIds)
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
            
            
            self.createEvent(uid: uid, type: "item_bought", itemId: itemId) { eventId in
                return
            }
        }
    }
    
    func setItemAsCompleted(uid: String, itemId: String) {
        self.fetchItem(uid: uid, itemId: itemId) { itemData in
            guard
                let itemData = itemData,
                let timerId = itemData["timerId"] as? String
            else {
                return
            }
                    
            self.deleteTimer(uid: uid, timerId: timerId)
            self.updateItem(uid: uid, itemId: itemId, fieldsToUpdate: [
                "status": "completed",
                "timerId": FieldValue.delete(),
                "lastUpdatedAT": FieldValue.serverTimestamp()
            ])
            
            self.updateUserDocument(
                uid: uid,
                fieldName: "impulseResisted",
                data: FieldValue.increment(Int64(1))) { success in
                    if success {
                        self.createEvent(uid: uid, type: "item_completed", itemId: itemId) { eventId in
                            return
                        }           
                    }
                    else {
                        return
                    }
            }
        }
    }

}
