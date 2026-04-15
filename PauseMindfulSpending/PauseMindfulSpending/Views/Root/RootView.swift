import SwiftUI

struct RootView: View {
    @EnvironmentObject var session: AppSessionViewModel    
    @StateObject private var timerManager = TimerManager()
    @State private var pausedTimerItem: TimerItem?
    
    @State private var selectedTab: NavBar = .home
    @State private var showAddItem: Bool = false
    @State private var showItemLogged: Bool = false
    
    @State private var showCompletedResponse: Bool = false
    @State private var showBoughtResponse: Bool = false
    @State private var showAdjustTimerSheet: Bool = false
    
    @State private var dragOffset: CGFloat = 0
    
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
                .gesture(
                    timerManager.currentTimerItem == nil ?
                    AnyGesture(DragGesture(minimumDistance: 10, coordinateSpace: .global)
                        .onEnded { value in
                            let threshold: CGFloat = 30
                            let horizontal = value.translation.width
                            let vertical = value.translation.height

                            guard abs(horizontal) > abs(vertical) * 1.2 else { return }
                            guard abs(horizontal) > threshold else { return }

                            let tabs = NavBar.allCases
                            guard let currentIndex = tabs.firstIndex(of: selectedTab) else { return }

                            if horizontal < 0 {
                                let nextIndex = min(currentIndex + 1, tabs.count - 1)
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTab = tabs[nextIndex]
                                }
                            } else {
                                let prevIndex = max(currentIndex - 1, 0)
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTab = tabs[prevIndex]
                                }
                            }
                        }
                    )
                    : AnyGesture(DragGesture().onEnded { _ in })
                )
                .navigationDestination(isPresented: $showAddItem) {
                    AddItemLogView(itemLogged: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showItemLogged = true
                        }
                    })
                }
                .onOpenURL { url in
                    if url.scheme == "pause" && url.host == "add-item" {
                        showAddItem = true
                    }
                }
                // This sheet will pop up on top of everything when a timer finishes!
                .overlay {
                    if timerManager.currentTimerItem != nil {
                        ZStack {
                            Color
                                .black
                                .opacity(0.3)
                                .ignoresSafeArea()

                            if showCompletedResponse {
                                CompletedResponseOverlay(onDone: {
                                        guard let uid = session.userProfile?.id else { return }
                                        showCompletedResponse = false
                                        showBoughtResponse = false
                                        showAdjustTimerSheet = false
                                        pausedTimerItem = nil
                                        timerManager.finishCurrentTimer(uid: uid, path: "completed")
                                    }
                                )
                            } else if showBoughtResponse {
                                BoughtResponseOverlay(onDone: {
                                        guard let uid = session.userProfile?.id else { return }
                                        showCompletedResponse = false
                                        showBoughtResponse = false
                                        showAdjustTimerSheet = false
                                        pausedTimerItem = nil
                                        timerManager.finishCurrentTimer(uid: uid, path: "bought")
                                    }
                                )
                            } else if pausedTimerItem != nil {
                                PauseEndOverlay(
                                    timerManager: timerManager,
                                    onCompletedPause: {
                                        showCompletedResponse = true
                                        showBoughtResponse = false
                                        showAdjustTimerSheet = false
                                    },
                                    onBoughtItem: {
                                        showBoughtResponse = true
                                        showCompletedResponse = false
                                        showAdjustTimerSheet = false
                                    },
                                    onAdjustTimer: {
                                        showAdjustTimerSheet = true
                                        showCompletedResponse = false
                                        showBoughtResponse = false
                                    }
                                )
                            } else {
                                LoadingView()
                            }
                        }
                        
                        .transition(.opacity)
                    }
                }

                // AdjustTimerSheet pop up is a little bit different than the other options
                .sheet(isPresented: $showAdjustTimerSheet) {
                    AdjustTimerSheetView(
                        onConfirm: { updatedSeconds in
                            guard let uid = session.userProfile?.id else { return }

                            timerManager.finishCurrentTimer(
                                uid: uid,
                                path: "adjusted",
                                newDurationSeconds: updatedSeconds
                            )

                            showAdjustTimerSheet = false
                        }
                    )
                    .presentationDetents([.fraction(0.75)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(24)
                }
            }
            
            // Only spawn PauseEndOverlays on root view
        
            .onAppear {
                if session.isAuthenticated, let uid = session.userProfile?.id {
                    timerManager.startMonitoring(uid: uid)
                }
            }

            .onChange(of: session.isAuthenticated) { _, isAuthenticated in
                if isAuthenticated, let uid = session.userProfile?.id {
                    timerManager.startMonitoring(uid: uid)
                } else {
                    timerManager.stopMonitoring()
                }
            }
            
            // Item was just paused
            .onChange(of: timerManager.currentTimerItem, initial: false) { _, newItem in
                pausedTimerItem = newItem
                if let uid = session.userProfile?.id {
                    timerManager.loadItem(uid: uid)
                }
            }
            
        }
    }
}
