import Combine

final class TimerManager: ObservableObject {
    @Published var showPauseEndSheet: Bool = false
    @Published var currentTimerItem: TimerItem?
    @Published var currentView: String = "Home" // Track the current view (e.g., "Home", "Timers", "Wishlist")

    private var timerQueue: [TimerItem] = []
    private var isProcessingQueue: Bool = false
    private var cancellables = Set<AnyCancellable>()

    private let queueAccess = DispatchQueue(label: "com.timerManager.queueAccess")

    func handleTimerEnd(for item: TimerItem) {
        queueAccess.async {
            self.timerQueue.append(item)
            DispatchQueue.main.async {
                self.processQueue()
            }
        }
    }

    private func processQueue() {
        queueAccess.sync {
            guard !isProcessingQueue, ["Home", "Timers", "Wishlist"].contains(currentView) else { return }
            guard let nextItem = timerQueue.first else { return }

            isProcessingQueue = true
            currentTimerItem = nextItem
            showPauseEndSheet = true

            $showPauseEndSheet
                .filter { !$0 }
                .sink { [weak self] _ in
                    self?.queueAccess.async {
                        self?.timerQueue.removeFirst()
                        self?.isProcessingQueue = false
                        DispatchQueue.main.async {
                            self?.processQueue()
                        }
                    }
                }
                .store(in: &cancellables)
        }
    }

    func handleSheetAction(action: TimerAction) {
        
        switch action {
        case .dontNeedItem:
            // Show congrats sheet and navigate to Home view
            navigateToCongratsSheet()
        case .boughtItem:
            // Update item status to "bought" and navigate to Home view
            markItemAsBought(currentItem)
            navigateToHome()
        case .adjustTimer:
            // Navigate to the Item view for the current timer
            navigateToItemView(currentItem)
        }
    }

    private func navigateToCongratsSheet() {
        // Logic to show the congrats sheet and dismiss to Home view
        guard let currentItem = currentTimerItem else { return }
        showPauseEndSheet = false
        currentView = "Home"
    }

    private func markItemAsBought(_ item: TimerItem) {
        // Logic to update the item's status to "bought"
        showPauseEndSheet = false
        currentView = "Home"
    }

    private func navigateToItemView(_ item: TimerItem) {
        // Logic to navigate to the Item view
        guard let currentItem = currentTimerItem else { return }
        showPauseEndSheet = false
        currentView = "ItemView"
    }

    private func navigateToHome() {
        // Logic to navigate to the Home view
        guard let currentItem = currentTimerItem else { return }
        showPauseEndSheet = false
        currentView = "Home"
    }
}
