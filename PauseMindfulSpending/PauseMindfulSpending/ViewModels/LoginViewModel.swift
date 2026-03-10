import SwiftUI
import FirebaseFirestore

final class LoginViewModel: ObservableObject {
    // These fields will get changed in LoginView
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var statusMessage: String = ""
    @Published var success: Bool = false
    
    // Only user is sarah
    private var uid: String?
    
    // Load backend
    private let userManager = UserManager()
    
    // Returns true if success
    func pressedLoginButton(email: String, password: String) {
        
        // Missing value handling
        if (email == "") {
            statusMessage = "Please enter your email."
        }
        
        else if (password == "") {
            statusMessage = "Please enter your password."
        }
        
        else {
            userManager.login(email: email, password: password) { [weak self] uid in
                
                // Run auth on a different thread
                DispatchQueue.main.async {
                    guard let self = self else { return }

                    if let uid = uid {
                        self.uid = uid
                        self.success = true
                        self.statusMessage = "Success! Logging in..."
                    } else {
                        // uid and success remain blank
                        self.statusMessage = "Login failed. Check credentials."
                    }
                }
                
            }
        }
        
    }
}

