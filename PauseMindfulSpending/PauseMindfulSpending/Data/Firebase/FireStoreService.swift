import FirebaseFirestore

class FireStoreService {
    
    let db = Firestore.firestore()
    
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
