import Foundation
import FirebaseFirestore

// TODO: Might merge with TimerViewMode? Rn some overlapping code
final class TimerManager: ObservableObject {
    private var timerQueue: [TimerItem] = []
    private var queuedTimerIDs = Set<String>()
    private var observedTimers: [TimerItem] = []

    private var listener: ListenerRegistration?
    private var timer: Timer?
    @Published var currentTimerItem: TimerItem?
    
    private let firestoreService = FireStoreService()
    private var db = Firestore.firestore()
    
    func startMonitoring(uid: String) {
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

                self.observedTimers = snapshot?.documents.compactMap { document in
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

    func stopMonitoring() {
        listener?.remove()
        listener = nil

        timer?.invalidate()
        timer = nil

        observedTimers = []
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
        getNexTimer()
    }

    func finishCurrentTimer(uid: String, path: String, newDurationSeconds: Int? = nil) {
        guard let timerItem = currentTimerItem,
            let timerId = timerItem.id else { return }

        firestoreService.fetchItemByTimerId(uid: uid, timerId: timerId) { [weak self] itemId in
            guard let self else { return }
            guard let itemId = itemId else { return }

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

            self.timerQueue.removeAll { $0.id == timerId }
            self.queuedTimerIDs.remove(timerId)
            self.currentTimerItem = nil

            self.getNexTimer()
        }
    }

    func checkForExpiredTimers() {
        let currentDate = Date()

        for item in observedTimers {
            guard item.endDate.dateValue() <= currentDate else { continue }
            handleTimerEnd(for: item)
        }
    }

    func getNexTimer() {
        guard currentTimerItem == nil else { return }
        guard let next = timerQueue.first else { return }
        currentTimerItem = next
    }
}
