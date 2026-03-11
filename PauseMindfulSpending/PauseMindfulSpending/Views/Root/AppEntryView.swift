import SwiftUI

struct AppEntryView: View {
    @EnvironmentObject var session: AppSessionViewModel
    
    var body: some View {
        if session.isAuthenticated {
            RootView()
        } else {
            AuthView() // LoginView <-> CreateAccountView
        }
    }
    
}
