import SwiftUI
import FirebaseFirestore

final class TimerViewModel: ObservableObject {
    @Published var timerItems: [TimerItem] = []
    @Published var currentDate = Date()
    
    private var timer: Timer?
    private let firestoreService = FireStoreService()
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
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        timer?.invalidate()
    }

    func loadTimerItems() {
        self.firestoreService.fetchItemsForList(uid: uid) { results in
            var loadedTimers: [TimerItem] = []
            let group = DispatchGroup()
            
            for data in results {
                guard
                    let _ = data["itemId"] as? String,
                    let timerId = data["timerId"] as? String,
                    let itemName = data["name"] as? String
                else { continue }
                
                group.enter()
                
                self.firestoreService.fetchTimer(uid: self.uid, timerId: timerId) { document in
                    defer { group.leave() }
                    guard
                        let document = document,
                        let timestamp = document["endDate"] as? Timestamp
                    else { return }
                    
                    let endDate = timestamp.dateValue()
                    let duration = max(0, endDate.timeIntervalSince(self.currentDate))
                    let imageUrl = data["imageUrl"] as? String
                    
                    let timer = TimerItem(
                        id: timerId,
                        itemName: itemName,
                        startTime: self.currentDate,
                        duration: duration,
                        imageUrl: imageUrl
                    )
                    
                    loadedTimers.append(timer)
                }
                
            }
            
            group.notify(queue: .main) {
                self.timerItems = loadedTimers
            }
        }
    }
    
    func formattedRemaining(for item: TimerItem) -> String {
        let endDate = item.startTime.addingTimeInterval(item.duration)
        let remaining = max(0, endDate.timeIntervalSince(currentDate))
        let totalSeconds = Int(remaining)
        let days = totalSeconds / secondsInDay
        let hours = (totalSeconds % secondsInDay) / secondsInHour
        let minutes = (totalSeconds % secondsInHour) / secondsInMinute
        let seconds = totalSeconds % secondsInMinute
        
        return String(format: "%02d:%02d:%02d:%02d", days, hours, minutes, seconds)
    }
}
