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
        data: [String: Any],
        completion: @escaping (String?) -> Void
    ) {
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
    
    func updateDocumentFromSubcollection(
        parentCollection: String,
        parentId: String,
        subCollection: String,
        subId: String,
        fieldsToUpdate: [String: Any]
    ) {
        // Helper function to update any document in a subcollection. You don't have to
        // include all the data, just update the field you need
        
        db.collection(parentCollection)
            .document(parentId)
            .collection(subCollection)
            .document(subId)
            .setData(fieldsToUpdate, merge: true)
    }
    
    func createItem(uid: String, data: [String: Any], durationSeconds: Int, completion: @escaping (String?) -> Void) {
        // Creates an item in the items subcollection and will pass the itemId using the
        // completion handler
        
        var updatedData = data
        updatedData["createdAt"] = FieldValue.serverTimestamp()

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
    
    func getItemsInCategory(
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
    
    func createTimer(
        uid: String,
        durationSeconds: Int,
        completion: @escaping (String?) -> Void
    ) {
        var data: [String: Any] = [:]
        var now = Date()
        
        data["startDate"] = FieldValue.serverTimestamp()
        data["status"] = "active"
        data["createdAt"] = FieldValue.serverTimestamp()
        data["endDate"] = now.addingTimeInterval(TimeInterval(durationSeconds))
        
        self.addDocumentToSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "timers",
            data: data
        ) { data in
            if data != nil {
                completion(data)
            }
        }
    }
}
