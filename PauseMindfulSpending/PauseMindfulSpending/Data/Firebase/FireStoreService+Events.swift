import FirebaseFirestore

extension FireStoreService {
    
    func fetchEventList(uid: String, completion: @escaping ([String]) -> Void) {
        // Fetches the categoryId list from user document. Returns result using
        // hanlder
        
        self.fetchUser(uid: uid) { userData in
            guard let userData = userData else {
                completion([])
                return
            }
            
            guard let eventIds = userData["eventIds"] as? [String] else {
                completion([])
                return
            }
            
            completion(eventIds)
        }
    }
    
    func createEvent(
        uid: String,
        type: String,
        itemId: String,
        timerId: String,
        categoryId: String,
        amount: Double,
        completion: @escaping (String?) -> Void)
    {
        let data: [String: Any] = [
            "type": type,
            "itemId": itemId,
            "timerId": timerId,
            "categoryId": categoryId,
            "amount": amount
        ]
        
        self.fetchEventList(uid: uid) { userEvents in
            var events = userEvents
            
            self.addDocumentToSubcollection(
                parentCollection: "users",
                parentId: uid,
                subCollection: "categories",
                data: data) { eventId in
                    guard let eventId = eventId else {
                        completion(nil)
                        return
                    }
                    
                    self.updateUserDocumentList(
                        uid: uid,
                        fieldName: "eventIds",
                        data: eventId) { success in
                            if success {
                                completion(eventId)
                            } else {
                                completion(nil)
                            }
                    }
            }
        }
    }
}
