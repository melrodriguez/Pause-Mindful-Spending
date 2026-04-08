import Foundation
import FirebaseFirestore

class TimerManager: ObservableObject {
    private var timerQueue: [TimerItem] = []
    private var activeTimers: [TimerItem] = []
    private var queuedTimerIDs = Set<String>()
    

    private var listener: ListenerRegistration?
    private var timer: Timer?

    private let firestoreService = FireStoreService()
    private var db = Firestore.firestore()
    
    @Published var currentTimerItem: TimerItem?
    @Published var currentItemName: String?
    @Published var currentItemCost: Double?
    @Published var currentItemCurrencyCode: String?
    @Published var currentItemImageURL: String?
    
    // Similar setup to TimerViewModel
    func startMonitoring(uid: String) {
        // Refresh the lists (start clean)
        stopMonitoring()

        listener = db.collection("users")
            .document(uid)
            .collection("timers")
            .whereField("status", isEqualTo: "active")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error = error {
                    print("Error getting timers: \(error)")
                    return
                }

                self.activeTimers = snapshot?.documents.compactMap { document in
                    try? document.data(as: TimerItem.self)
                } ?? []

                self.checkForExpiredTimers()
            }

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.checkForExpiredTimers()
        }
    }

    // Clear the listener, current timer item, and queues
    func stopMonitoring() {
        listener?.remove()
        listener = nil

        timer?.invalidate()
        timer = nil

        activeTimers = []
        timerQueue = []
        queuedTimerIDs.removeAll()
        
        currentTimerItem = nil
    }

    // When a timer ends, add to queue of timers to be processed
    func handleTimerEnd(for item: TimerItem) {
        guard let id = item.id else { return }
        guard currentTimerItem?.id != id else { return }
        guard !queuedTimerIDs.contains(id) else { return }

        timerQueue.append(item)
        queuedTimerIDs.insert(id)
        loadNextTimer()
    }

    func finishCurrentTimer(uid: String, path: String, newDurationSeconds: Int? = nil) {
        guard let timerItem = currentTimerItem,
            let timerId = timerItem.id else { return }

        firestoreService.fetchItemByTimerId(uid: uid, timerId: timerId) { [weak self] itemId in
            guard let self else { return }
            guard let itemId = itemId else { return }

            // 3 cases (buttons): completed, bought, or adjusted time on item
            if path == "bought" {
                self.firestoreService.setItemAsBought(uid: uid, itemId: itemId)
            } else if path == "completed" {
                self.firestoreService.setItemAsCompleted(uid: uid, itemId: itemId)
            } else if path == "adjusted" {
                guard let newDurationSeconds = newDurationSeconds else { return }
                self.firestoreService.updateTimer(
                    uid: uid,
                    timerId: timerId,
                    newDurationSeconds: newDurationSeconds
                )
            }
            
            // Take out processed timer from the queue
            self.timerQueue.removeAll { $0.id == timerId }
            self.queuedTimerIDs.remove(timerId)
            self.currentTimerItem = nil
            
            // Move onto the next timer, if any
            self.loadNextTimer()
        }
    }
    
    // Go through all of the active timers
    func checkForExpiredTimers() {
        let currentDate = Date()

        for item in activeTimers {
            guard item.endDate.dateValue() <= currentDate else { continue }
            handleTimerEnd(for: item)
        }
    }

    func loadNextTimer() {
        guard currentTimerItem == nil else { return }
        guard let next = timerQueue.first else { return }
        currentTimerItem = next
    }
    
    var formattedPrice: String {
        currentItemCost?.formatted(.currency(code: currentItemCurrencyCode ?? "USD")) ?? ""
    }
    
    // For use specifically in the PauseEndOverlay
    func loadItem(uid: String) {
        guard let timerId = currentTimerItem?.id else { return }

        firestoreService.fetchItemByTimerId(uid: uid, timerId: timerId) { [weak self] itemId in
            guard let self = self else { return }
            guard let itemId = itemId else { return }

            self.firestoreService.fetchItem(uid: uid, itemId: itemId) { data in
                guard let data = data else { return }

                let name = data["name"] as? String ?? "My Item"
                let cost = data["cost"] as? Double ?? 0
                let currencyCode = data["currencyCode"] as? String ?? "USD"
                let imageUrl = data["imageUrl"] as? String

                DispatchQueue.main.async {
                    self.currentItemName = name
                    self.currentItemCost = cost
                    self.currentItemCurrencyCode = currencyCode
                    self.currentItemImageURL = imageUrl
                }
            }
        }
    }
    
}
