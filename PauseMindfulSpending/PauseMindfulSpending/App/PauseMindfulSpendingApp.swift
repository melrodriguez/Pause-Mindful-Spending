import SwiftUI
import FirebaseCore

// Firebase setup
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Initialize Firebase when the app launches
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct PauseMindfulSpendingApp: App {
    
    // Register the AppDelegate so Firebase can initialize
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        
        WindowGroup {
            RootView()
        }
    }
}
