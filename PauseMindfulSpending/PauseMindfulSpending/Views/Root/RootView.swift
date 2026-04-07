import SwiftUI

struct RootView: View {
    @EnvironmentObject var session: AppSessionViewModel    
    @StateObject private var timerManager = TimerManager()
    
    @State private var selectedTab: NavBar = .home
    @State private var showAddItem: Bool = false
    @State private var showItemLogged: Bool = false
    
    @State private var showCompletedResponse: Bool = false
    @State private var showBoughtResponse: Bool = false
    @State private var showTimerExtendedResponse: Bool = false
    
    var body: some View {
        if session.isLoading {
            LoadingView()
        } else {
            NavigationStack {
                ZStack {
                    TabView(selection: $selectedTab) {
                        HomeView()
                            .tag(NavBar.home)
                        
                        if let profile = session.userProfile {
                            TimersView(
                                viewModel: TimerViewModel(
                                    uid: profile.id
                                )
                            )
                            .tag(NavBar.timers)
                        }
                        
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
                    
                    if showItemLogged {
                        ItemLoggedView(onContinue: {
                            showItemLogged = false
                        })
                    }
                }
                .navigationDestination(isPresented: $showAddItem) {
                    AddItemLogView(itemLogged: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showItemLogged = true
                        }
                    })
                }
<<<<<<< HEAD
                .onOpenURL { url in
                    if url.scheme == "pause" && url.host == "add-item" {
                        showAddItem = true
                    }
                }
=======
                
                // This sheet will pop up on top of everything when a timer finishes!
                .overlay {
                    if let item = timerManager.currentTimerItem {
                        ZStack {
                            Color
                                .black
                                .opacity(0.3)
                                .ignoresSafeArea()

                            if showCompletedResponse {
                                CompletedResponseOverlay(
                                    onDone: {
                                        guard let uid = session.userProfile?.id else { return }
                                        timerManager.finishCurrentTimer(uid: uid, path: "completed")
                                        showCompletedResponse = false
                                    }
                                )
                            } else if showBoughtResponse {
                                BoughtResponseOverlay(
                                    onDone: {
                                        guard let uid = session.userProfile?.id else { return }
                                        timerManager.finishCurrentTimer(uid: uid, path: "bought")
                                        showBoughtResponse = false
                                    }
                                )
                            } else if showTimerExtendedResponse {
                                AdjustTimerResponseOverlay(
                                    onDone: {
                                        guard let uid = session.userProfile?.id else { return }
                                        timerManager.finishCurrentTimer(uid: uid, path: "adjusted")
                                        showTimerExtendedResponse = false
                                    }
                                )
                            } else {
                                PauseEndSheet(
                                    item: item,
                                    onCompletedPause: {
                                        showCompletedResponse = true
                                    },
                                    onBoughtItem: {
                                        showBoughtResponse = true
                                    },
                                    onAdjustTimer: {
                                        showTimerExtendedResponse = true
                                    }
                                )
                            }
                        }
                        .transition(.opacity)
                    }
                }
            }

            // When the user comes back to the app, start monitoring timers again
            // Stop when they leave 
            // TODO: make more rubust by adding elapsed time on sign in and checking if timers expired

            .onAppear {
                if let uid = session.userProfile?.id {
                    timerManager.startMonitoring(uid: uid)
                }
            }

            // TODO: fix - stop counting down when user navigates beyond root view

            .onChange(of: session.userProfile?.id) { _, newUID in
                if let uid = newUID, session.isAuthenticated {
                    timerManager.startMonitoring(uid: uid)
                } else {
                    timerManager.stopMonitoring()
                }
            }

            .onChange(of: session.isAuthenticated) { _, isAuthenticated in
                if !isAuthenticated {
                    timerManager.stopMonitoring()
                } else if let uid = session.userProfile?.id {
                    timerManager.startMonitoring(uid: uid)
                }
>>>>>>> d62e7c4 (remaining: adjust timer)
            }
        }
    }
}
