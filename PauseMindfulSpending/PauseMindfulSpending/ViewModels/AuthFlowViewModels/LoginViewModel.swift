import SwiftUI
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var statusMessage: String = ""
        
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
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    self.statusMessage = error.localizedDescription
                    return
                }
                
                self.statusMessage = "Success! Logging in..."
            }
        }
    }
}
