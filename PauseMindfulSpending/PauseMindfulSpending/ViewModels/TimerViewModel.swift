import SwiftUI
import FirebaseFirestore

final class TimerViewModel: ObservableObject {
    @Published var timerItems: [TimerItem] = []
    @Published var items: [Item] = []
    @Published var currentDate = Date()
    
    private var timer: Timer?
    private var listener: ListenerRegistration?
    private var db = Firestore.firestore()

    let uid: String
    private var secondsInDay = 86400
    private var secondsInHour = 3600
    private var secondsInMinute = 60

    init(uid: String) {
        self.uid = uid
    }
    
    func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.currentDate = Date()
        }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopListening()
        stopTimer()
    }
    
    func calcDuration(endDate: Date) -> TimeInterval {
        return max(0, endDate.timeIntervalSinceNow)
    }
    
    func getTimerItems(sortOrder: String) {
        listener?.remove()
        var descending = false
        
        if sortOrder == "Ascending" {
            descending = false
        } else {
            descending = true
        }
        
        listener = db.collection("users")
            .document(uid)
            .collection("timers")
            .whereField("status", isEqualTo: "active")
            .order(by: "endDate", descending: descending)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error getting items: \(error)")
                    return
                }
                
                self.timerItems = snapshot?.documents.compactMap { document in
                    try? document.data(as: TimerItem.self)
                } ?? []
                
                self.fetchItems(sortOrder: sortOrder)
            }
    }
    
    private func fetchItems(sortOrder: String) {
        let descending = sortOrder == "Descending"
 
        db.collection("users")
            .document(uid)
            .collection("items")
            .whereField("status", isEqualTo: "wishlist")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching items for timers: \(error)")
                    return
                }
 
                let activeTimerIds = Set(self.timerItems.compactMap { $0.id })
 
                // Only include items whose timerId is in our active timers
                var fetched: [Item] = snapshot?.documents.compactMap { doc in
                    guard let item = try? doc.data(as: Item.self),
                          let timerId = item.timerId,
                          activeTimerIds.contains(timerId) == false
                    else { return nil }
                    // Match item to its timer by timerId
                    return try? doc.data(as: Item.self)
                } ?? []
 
                // Sort to match timer order
                // timerItems are ordered by endDate — sort items the same way
                let timerOrder = self.timerItems.compactMap { $0.id }
                fetched = snapshot?.documents.compactMap { doc -> Item? in
                    guard let item = try? doc.data(as: Item.self),
                          let timerId = item.timerId,
                          self.timerItems.contains(where: { $0.id == timerId })
                    else { return nil }
                    return item
                } ?? []
 
                // Sort items by their timer's endDate to match timerItems order
                fetched.sort { a, b in
                    let aTimer = self.timerItems.first { $0.id == a.timerId }
                    let bTimer = self.timerItems.first { $0.id == b.timerId }
                    let aDate = aTimer?.endDate.dateValue() ?? Date.distantFuture
                    let bDate = bTimer?.endDate.dateValue() ?? Date.distantFuture
                    return descending ? aDate > bDate : aDate < bDate
                }
 
                DispatchQueue.main.async {
                    self.items = fetched
                }
            }
    }

    func formattedRemaining(for item: TimerItem) -> String {
        let remaining = calcDuration(endDate: item.endDate.dateValue())
        let totalSeconds = Int(remaining)
        let days = totalSeconds / secondsInDay
        let hours = (totalSeconds % secondsInDay) / secondsInHour
        let minutes = (totalSeconds % secondsInHour) / secondsInMinute
        let seconds = totalSeconds % secondsInMinute
        
        return String(format: "%02d:%02d:%02d:%02d", days, hours, minutes, seconds)
    }
    
    func timerItem(for item: Item) -> TimerItem? {
        guard let timerId = item.timerId else { return nil }
        return timerItems.first { $0.id == timerId }
    }
}
