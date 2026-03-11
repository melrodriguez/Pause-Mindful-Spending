import SwiftUI

// Toggle between LoginView and CreateAccountView
// However, the user needs to succesfully login to proceed to RootView (main app, logged in)!
struct AuthView: View {
    
    @State private var showCreateAccount = false
    
    var body: some View {
        
        ZStack {
            if showCreateAccount {
                CreateAccountView(showCreateAccount: $showCreateAccount)
                    .transition(.move(edge: .trailing))
            } else {
                LoginView(showCreateAccount: $showCreateAccount)
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showCreateAccount)
        .appBackground()
    }
}
