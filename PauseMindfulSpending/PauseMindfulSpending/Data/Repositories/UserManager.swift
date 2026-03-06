import FirebaseAuth

class UserManager {
    // Handles interactions with Firebase Authentication and stores using
    // FireStoreService
    
    private let fireStore = FireStoreService()
    
    func createUser(
        displayName: String,
        email: String,
        password: String,
        completion: @escaping (Bool) -> Void
    ) {
        // Creates a user in Firebase Authentication and creates a user document in
        // Firestore. Uses completion handler to carry result of completion
        
        Auth.auth().createUser(withEmail: email, password: password) {
            result, error in
            if let user = result?.user {
                let uid = user.uid
                self.fireStore.createUser(
                    displayName: displayName,
                    email: email,
                    uid: uid
                )
                
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        // Sign into existing account, if there are any failures will update completion
        // handler to carry result of completion
        
        Auth.auth().signIn(withEmail: email, password: password) {
            authResult, error in
            if let error = error as NSError? {
                print("DEBUG: Failed to login of account \(error.localizedDescription)")
                completion(false)
                return
            }
            
            completion(true)
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
