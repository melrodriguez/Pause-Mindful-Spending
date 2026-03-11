import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct PauseMindfulSpendingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var session = AppSessionViewModel()
    
    var body: some Scene {
        WindowGroup {
            AppEntryView()
                .environmentObject(session)
                .preferredColorScheme(
                    session.userSettings?.isNightMode == true ? .dark : nil
                )
        }
    }
}
