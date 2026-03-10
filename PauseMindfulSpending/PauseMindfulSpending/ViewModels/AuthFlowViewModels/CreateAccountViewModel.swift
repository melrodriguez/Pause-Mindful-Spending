import SwiftUI

class CreateAccountViewModel: ObservableObject {    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordConfirmation: String = ""
    
    @Published var hasAgreed: Bool = false // terms and conditions toggle
    @Published var statusMessage: String = ""
    
    private let userManager = UserManager()
    
    func pressedCreateAccountButton() {
        
        // Input validation
        guard !name.isEmpty else {
            statusMessage = "Please enter your first name.\n"
            return
        }
        
        guard !email.isEmpty else {
            statusMessage = "Please enter an email.\n"
            return
        }
        
        guard !password.isEmpty else {
            statusMessage = "Please enter a password.\n"
            return
        }
        
        guard !passwordConfirmation.isEmpty else {
            statusMessage = "Please confirm your password.\n"
            return
        }
        
        guard password == passwordConfirmation else {
            statusMessage = "Passwords do not match.\n"
            return
        }
        
        guard hasAgreed else {
            statusMessage = "Please accept the terms and conditions.\n"
            return
        }
        
        // create user
        userManager.createUser(
            displayName: name,
            email: email,
            password: password
        ) { [weak self] uid in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if uid == nil {
                    self.statusMessage = "Account could not be created. Try again.\n"
                }
                
                self.statusMessage = "Success! Logging in...\n"
            }
        }
    }
}
