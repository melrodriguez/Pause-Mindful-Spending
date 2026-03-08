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
        completion: @escaping (String?) -> Void)
    {
        var data: [String: Any] = [
            "type": type,
            "itemId": itemId,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        self.addDocumentToSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "events",
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
    
    func deleteEvent(uid: String, eventId: String) {
        self.deleteDocumentFromSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "events",
            subId: eventId
        )
        
        self.removeUserDocumentListItem(
            uid: uid,
            fieldName: "eventIds",
            data: eventId) { success in
            return
        }
    }
    
    func fetchDetailsFromEvent(uid: String, eventId: String, completion: @escaping ([String: Any]?) -> Void) {
        self.fetchDocumentFromSubcollection(parentCollection: "users", parentId: uid, subCollection: "events", subId: eventId) { data in
            guard
                let data = data,
                let itemId = data["itemId"] as? String
            else {
                completion(nil)
                return
            }
            
            self.fetchItem(uid: uid, itemId: itemId) { document in
                guard
                    let document = document,
                    let amount = document["cost"] as? Double else {
                    completion(nil)
                    return
                }
                let categoryId = document["categoryId"] as? String
                let timerId = document["timerId"] as? String
                
                completion([
                    "itemId": itemId,
                    "categoryId": categoryId,
                    "timerId": timerId,
                    "amount": amount
                ])
            }
        }
    }
    
}
