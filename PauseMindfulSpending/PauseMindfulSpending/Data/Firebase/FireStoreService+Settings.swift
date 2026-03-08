import FirebaseFirestore

extension FireStoreService {
    func createSettings(uid: String, completion: @escaping (String?) -> Void) {
        let data:[String: Any] = [
            "isNightMode": false,
            "isHapticsEnabled": false,
            "wishlistLayout": "grid",
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        self.addDocumentToSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "settings",
            data: data) { settingId in
                guard let settingId = settingId else{
                    completion(nil)
                    return
                }
                
                completion(settingId)
            }
    }
    
    func updateSettings(uid: String, settingId: String, fieldsToUpdate: [String: Any]) {
        self.updateDocumentFromSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "settings",
            subId: settingId,
            fieldsToUpdate: fieldsToUpdate)
    }
}
