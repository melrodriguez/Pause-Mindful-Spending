import FirebaseFirestore

class FireStoreService {
    
    private let db = Firestore.firestore()
    
    func createUser(displayName: String, email: String, uid: String) {
        // Adds a user document to the users collection
        
        db.collection("users").addDocument(data:[
            "displayName": displayName,
            "email": email,
            "createdAt": FieldValue.serverTimestamp(),
            "lastLoginAt": FieldValue.serverTimestamp(),
            "photoUrl": ""
        ])
    }
    
    func fetchUser(uid: String, completion: @escaping ([String: Any]?) -> Void) {
        // Fetches a user data and uses completion handler to return results
        
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                completion(data)
            }
            else {
                completion(nil)
            }
        }
    }
    
    func addDocumentToSubcollection(
        parentCollection: String,
        parentId: String,
        subCollection: String,
        data: [String: Any]
    ) {
        // Helper function add a document to any subcollections in a user document
        
        db.collection(parentCollection)
            .document(parentId)
            .collection(subCollection)
            .addDocument(data: data)
    }
    
    func fetchDocumentFromSubcollection(
        parentCollection: String,
        parentId: String,
        subCollection: String,
        subId: String,
        completion: @escaping ([String: Any]?) -> Void
    ) {
        // Helper function to fetch any document in subcollection stored in a user
        // document. Will pass data in completion handler.
        
        db.collection(parentCollection)
            .document(parentId)
            .collection(subCollection)
            .document(subId)
            .getDocument() { snapshot, error in
                if let data = snapshot?.data() {
                    completion(data)
                }
                else {
                    completion(nil)
                }
            }
    }
    
    func createItem(uid: String, data: [String: Any]) {
        // Creates an item in the items subcollection
        var updatedData = data
        updatedData["createdAt"] = FieldValue.serverTimestamp()
        
        self.addDocumentToSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "items",
            data: updatedData
        )
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
}
