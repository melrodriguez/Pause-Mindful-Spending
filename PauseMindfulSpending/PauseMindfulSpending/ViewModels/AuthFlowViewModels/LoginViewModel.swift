import SwiftUI
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var statusMessage: String = ""
        
    private let userManager = UserManager()
    
    func pressedLoginButton() {
        
        // Input validation
        guard !email.isEmpty else {
            statusMessage = "Please enter your email."
            return
        }
        
        guard !password.isEmpty else {
            statusMessage = "Please enter your password."
            return
        }
        
        // Try to login
        userManager.login(email: email, password: password) { [weak self] uid in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if uid != nil {
                    self.statusMessage = "Success! Logging in..."
                } else {
                    self.statusMessage = "Login failed. Please try again."
                }
            }
        }
    }
}
