import SwiftUI
import FirebaseFirestore

final class TimerViewModel: ObservableObject {
    @Published var timerItems: [TimerItem] = []
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
    
    func getTimerItems() {
        listener = db.collection("users")
            .document(uid)
            .collection("timers")
            .whereField("status", isEqualTo: "active")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error getting items: \(error)")
                    return
                }
                
                self.timerItems = snapshot?.documents.compactMap { document in
                    try? document.data(as: TimerItem.self)
                } ?? []
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
}
