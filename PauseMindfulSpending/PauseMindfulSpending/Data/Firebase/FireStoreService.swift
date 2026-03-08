import FirebaseFirestore

class FireStoreService {
    
    let db = Firestore.firestore()
    
    func createUser(displayName: String, email: String, uid: String) {
        // Adds a user document to the users collection
        
        db.collection("users").document(uid).setData([
            "displayName": displayName,
            "email": email,
            "createdAt": FieldValue.serverTimestamp(),
            "lastLoginAt": FieldValue.serverTimestamp(),
            "photoUrl": "",
            "categoryIds": [],
            "eventIds": [],
            "settingsId": NSNull(),
            "impulseResisted": 0
        ], merge: true)
    }
    
    func fetchUser(uid: String, completion: @escaping ([String: Any]?) -> Void) {
        // Fetches a user data and uses completion handler to return results
        
        db.collection("users").document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data() else {
                completion(nil)
                return
            }
            
            completion(data)
        }
    }
    
    func updateUserDocument(uid: String, fieldName: String, data: Any, completion: @escaping (Bool) -> Void) {
        self.db.collection("users")
            .document(uid)
            .setData([fieldName: data], merge: true) { error in
                if let error = error {
                    completion(false)
                } else {
                    completion(true)
                }
            }
    }
    
    func updateUserDocumentList(uid: String, fieldName: String, data: Any, completion: @escaping (Bool) -> Void) {
        self.db.collection("users")
            .document(uid)
            .updateData([fieldName: FieldValue.arrayUnion([data])]) { error in
                if let error = error {
                    completion(false)
                } else {
                    completion(true)
                }
            }
    }
    
    func removeUserDocumentListItem(uid: String, fieldName: String, data: Any, completion: @escaping (Bool) -> Void) {
        self.db.collection("users")
            .document(uid)
            .updateData([fieldName: FieldValue.arrayRemove([data])]) { error in
                if let error = error {
                    completion(false)
                } else {
                    completion(true)
                }
            }
    }
    
    
    func fetchUserDocumentField<T>(uid: String, fieldName: String, completion: @escaping (T?) -> Void) {
        self.db.collection("users")
            .document(uid)
            .getDocument() { document, error in
                guard let document = document, document.exists else {
                    completion(nil)
                    return
                }
                
                let fieldData = document.get(fieldName) as? T
                completion(fieldData)
            }
    }

    func addDocumentToSubcollection(
        parentCollection: String,
        parentId: String,
        subCollection: String,
        data: [String: Any],
        completion: @escaping (String?) -> Void)
    {
        // Helper function add a document to any subcollections in a user document
        
        let ref = db.collection(parentCollection)
            .document(parentId)
            .collection(subCollection)
            .addDocument(data: data)
        
        completion(ref.documentID)
    }
    
    func fetchDocumentFromSubcollection(
        parentCollection: String,
        parentId: String,
        subCollection: String,
        subId: String,
        completion: @escaping ([String: Any]?) -> Void)
    {
        // Helper function to fetch any document in subcollection stored in a user
        // document. Will pass data in completion handler.
        
        db.collection(parentCollection)
            .document(parentId)
            .collection(subCollection)
            .document(subId)
            .getDocument() { snapshot, error in
                guard let data = snapshot?.data() else {
                    completion(nil)
                    return
                }
                
                completion(data)
            }
    }
    
    func updateDocumentFromSubcollection(
        parentCollection: String,
        parentId: String,
        subCollection: String,
        subId: String,
        fieldsToUpdate: [String: Any])
    {
        // Helper function to update any document in a subcollection. You don't have to
        // include all the data, just update the field you need
        
        db.collection(parentCollection)
            .document(parentId)
            .collection(subCollection)
            .document(subId)
            .setData(fieldsToUpdate, merge: true)
    }
    
     func deleteDocumentFromSubcollection(
        parentCollection: String,
        parentId: String,
        subCollection: String,
        subId: String)
    {
        // Helper funciton deletes a document in a subcollection.
        
        db.collection(parentCollection)
            .document(parentId)
            .collection(subCollection)
            .document(subId)
            .delete()
    }
    
}
