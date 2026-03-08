import FirebaseAuth
import FirebaseFirestore

class UserManager {
    // Handles interactions with Firebase Authentication and stores using
    // FireStoreService
    
    private let fireStore = FireStoreService()

    func createUser(
        displayName: String,
        email: String,
        password: String,
        completion: @escaping (String?) -> Void
    ) {
        // Creates a user in Firebase Authentication and creates a user document in
        // Firestore. Uses completion handler to pass uid.
        
        Auth.auth().createUser(withEmail: email, password: password) {
            result, error in
            guard let user = result?.user else {
                completion(nil)
                return
            }
            
            let uid = user.uid
            self.fireStore.createUser(
                displayName: displayName,
                email: email,
                uid: uid
            )
            self.fireStore.createSettings(uid: uid) { settingId in
                guard let settingId = settingId else {
                    completion(nil)
                    return
                }
                
                self.fireStore.updateUserDocument(
                    uid: uid,
                    fieldName: "settingsId",
                    data: settingId) { success in
                    if success {
                        completion(uid)
                    } else {
                        completion(nil)
                    }
                    
                }
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (String?) -> Void) {
        // Sign into existing account, if there are any failures will update completion
        // handler to pass uid
        
        Auth.auth().signIn(withEmail: email, password: password) {
            result, error in
            guard let user = result?.user else {
                completion(nil)
                return
            }
            
            let uid = user.uid
            completion(uid)
        }
    }
    
    func logout(email: String, password: String) {
        // Sign out of existing account, if there are any failures will print out an
        // error for debugging purposes
        
        do {
            try Auth.auth().signOut()
        }
        catch let error as NSError {
            print("DEBUG: Failed to sign out of account \(error.localizedDescription)")
        }
    }
    
    
}
