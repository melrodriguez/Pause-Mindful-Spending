import SwiftUI

struct RootView: View {
    @EnvironmentObject var session: AppSessionViewModel
    
    @State private var selectedTab: NavBar = .home
    @State private var showAddItem: Bool = false
    
    var body: some View {
        if session.isLoading {
            LoadingView()
        } else {
            NavigationStack {
                ZStack {
                    TabView(selection: $selectedTab) {
                        
                        if let profile = session.userProfile,
                           let settings = session.userSettings {
                            HomeView()
                                .tag(NavBar.home)
                            
                            TimersView(
                                viewModel: TimerViewModel()
                            )
                            .tag(NavBar.timers)
                            
                            SettingsView(
                                viewModel: SettingsViewModel(
                                    uid: profile.id,
                                    userProfile: profile,
                                    userSettings: settings
                                )
                            )
                            .tag(NavBar.settings)
                            
                            WishlistView(
                                viewModel: WishlistViewModel(
                                    uid: profile.id,
                                    userProfile: profile
                                )
                            )
                            .tag(NavBar.wishlist)
                        } else {
                            // TODO - handle error if profile and settings do not load
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
            }
        }
    }
}
