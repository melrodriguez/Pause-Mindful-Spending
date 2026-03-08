import SwiftUI

struct RootView: View {
    @EnvironmentObject var session: AppSessionViewModel
    
    @State private var selectedTab: NavBar = .home
    @State private var showAddItem: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tag(NavBar.home)
                    
                    TimersView()
                        .tag(NavBar.timers)
                    
                    WishlistView()
                        .tag(NavBar.wishlist)
                    
                    if let profile = session.userProfile,
                       let settings = session.userSettings {
                        SettingsView(
                            viewModel: SettingsViewModel(
                                uid: profile.id,
                                userProfile: profile,
                                userSettings: settings
                            )
                        )
                        .tag(NavBar.settings)
                    } else {
                        ProgressView()
                            .tag(NavBar.settings)
                    }
                }
                .toolbar(.hidden, for: .tabBar)
                
                VStack {
                    Spacer()
                    
                    HStack(alignment: .center, spacing: 12) {
                        FloatingNavBar(
                            tabs: NavBar.allCases,
                            selectedTab: $selectedTab
                        )
                        
                        FloatingAddButton {
                            showAddItem = true
                        }
                    }
                    .padding(.bottom, 18)
                    .padding(.horizontal, 20)
                }
            }
            .navigationDestination(isPresented: $showAddItem) {
                AddItemLogView()
            }
            .onAppear {
                if session.userProfile == nil || session.userSettings == nil {
                    session.loadSessionData()
                }
            }
        }
    }
}
