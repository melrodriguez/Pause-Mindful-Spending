import SwiftUI
import FirebaseFirestore

// TODO: paused work
class CreateAccountViewModel: ObservableObject {
    // These fields will get changed in LoginView
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwwordConfirmation: String = ""
    @Published var statusMessage: String = "Create an account to build mindful spending habits and make intentional choices."
    
    @Published var hasAgreed: Bool = false // terms and conditions toggle
    @Published var success: Bool = false
    
    // Only user is sarah
    private var uid: String?
    
    // Load backend
    private let userManager = UserManager()
    
    // Returns true if success
    func pressedCreateAccountButton(name: String, email: String, password: String, passwordConfirmation: String) {
        
        // Input validation
        if (name == "") {
            statusMessage = "Please enter your first name.\n"
        } else if (email == "") {
            statusMessage = "Please enter an email.\n"
        } else if (password == "") {
            statusMessage = "Please enter a password.\n"
        } else if (passwordConfirmation == "") {
            statusMessage = "Please confirm your password.\n"
        } else if (password != passwordConfirmation) {
            statusMessage = "Passwords do not match.\n"
        } else if (!hasAgreed) {
            statusMessage = "Please accept the terms and conditions to proceed.\n"
        
        } else {
            userManager.createUser(displayName: name, email: email, password: password) { [weak self] uid in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    if let uid = uid {
                        self.uid = uid
                        self.success = true
                        self.statusMessage = "Your account was successfully created! Please login.\n"
                    } else {
                        self.statusMessage = "Your account could not be created. Check credentials.\n"
                    }
                }
            }
        }
        
    }
}

