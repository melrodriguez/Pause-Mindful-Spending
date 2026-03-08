import FirebaseFirestore

extension FireStoreService {
    
    func fetchCategoryList(uid: String, completion: @escaping ([String]) -> Void) {
        // Fetches the categoryId list from user document. Returns result using
        // hanlder
        
        self.fetchUser(uid: uid) { userData in
            if let userData = userData {
                let categoryIds = userData["categoryIds"] as? [String]
                completion(categoryIds!)
            }
            else {
                completion([])
            }
        }
    }
    
    func addCategory(uid: String, name: String, enableStreak: Bool) {
        // Adds a category document then adds the categoryId to back to the user dcoument
        
        var categoryIds: [String] = []
        var categoryData: [String: Any] = [
            "name": name,
            "highestStreak": 0,
            "enableStreak": enableStreak,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        self.fetchCategoryList(uid: uid) { userCategories in
            categoryIds = userCategories
        }
        
        self.addDocumentToSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "categories",
            data: categoryData) { categoryId in
                if let categoryId = categoryId {
                    categoryIds.append(categoryId)
                    
                    self.db.collection("users")
                        .document(uid)
                        .setData(["categoryIds": categoryIds], merge: true)
                }
            }

    }
    
    func fetchCategoryStringUsingId(
        uid: String,
        categoryId: String,
        completion: @escaping (String?) -> Void)
    {
        // Fetches the category name using the category id and passes it through handler.
        
        self.fetchDocumentFromSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "categories",
            subId: categoryId) {categoryData in
                if categoryData != nil {
                    completion(categoryData!["name"] as? String)
                } else {
                    completion(nil)
                }
            }
    }
    
    func fetchCategoryIdUsingName(
        uid: String,
        name: String,
        completion: @escaping (String?) -> Void)
    {
        // Find the categoryId using a name of the category, then passes it through
        // completion hanlder
        
        self.fetchCategoryList(uid: uid) { categoryIds in
            let group = DispatchGroup()
            var foundId: String? = nil
            
            for categoryId in categoryIds {
                group.enter()
                
                self.fetchCategoryStringUsingId(uid: uid, categoryId: categoryId) { categoryName in
                    if let categoryName = categoryName {
                        if categoryName == name {
                            foundId = categoryId
                        }
                    }
                    
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(foundId)
            }
        }
        
        
    }
    
    func fetchCategory(
        uid: String,
        categoryId: String,
        completion: @escaping ([String: Any]?) -> Void)
    {
        // fetches a category document then sends data through completion handler.
        
        self.fetchDocumentFromSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "categories",
            subId: categoryId) { categoryData in
                completion(categoryData)
            }
    }
    
    func changeCategoryName(uid: String, categoryId: String, name: String) {
        // Updates the name of a category document
        
        let data: [String: Any] = [
            "name": name,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        self.updateDocumentFromSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "categories",
            subId: categoryId,
            fieldsToUpdate: data
        )
    }
    
    func updateCategoryStreak(uid: String, categoryId: String, dateItemBought: Date) {
        // Used when an item is bought and there is a categoryId in the item document. It
        // check if there is a new highest streak based on the lastItemBought in the
        // category. If there is a new highest streak then it will update it.
        
        self.fetchCategory(uid: uid, categoryId: categoryId) { categoryData in
            if let categoryData = categoryData,
               let ts = categoryData["lastItemBought"] as? Timestamp,
               let highestStreak = categoryData["highestStreak"] as? Int {
                let lastBoughtDate = ts.dateValue()
                
                let streak = Calendar.current.dateComponents(
                    [.day],
                    from: lastBoughtDate,
                    to: dateItemBought
                ).day ?? 0
                
                
                if highestStreak < streak {
                    let data: [String: Any] = [
                        "highestStreak": streak,
                        "updatedAt": FieldValue.serverTimestamp(),
                        "lastItemBought": FieldValue.serverTimestamp()
                    ]
                        
                    self.updateDocumentFromSubcollection(
                        parentCollection: "user",
                        parentId: uid,
                        subCollection: "categories",
                        subId: categoryId,
                        fieldsToUpdate: data
                    )
                }
            }
        }
    }
    
}
