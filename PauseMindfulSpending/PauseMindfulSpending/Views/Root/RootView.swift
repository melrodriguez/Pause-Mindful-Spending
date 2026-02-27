import SwiftUI

// Controls which tab is visible + nav bar
struct RootView: View {
    @State private var selectedTab: NavBar = .home
    // Show add item log page if true
    @State private var showAddItem: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                
                // Controls switching between tabs
                TabView(selection: $selectedTab) {
                    HomeView().tag(NavBar.home)
                    TimersView().tag(NavBar.timers)
                    WishlistView().tag(NavBar.wishlist)
                    SettingsView().tag(NavBar.settings)
                }
                .toolbar(.hidden, for: .tabBar)
                
                // View for nav bar
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
                }
            }
            .navigationDestination(isPresented: $showAddItem) {
                // Shows the add item log view
                AddItemLogView()
            }
        }
    }
}
