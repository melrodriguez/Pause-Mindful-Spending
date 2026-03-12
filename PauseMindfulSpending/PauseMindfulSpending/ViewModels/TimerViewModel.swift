import SwiftUI
import FirebaseFirestore

final class TimerViewModel: ObservableObject {
    @Published var currentDate = Date()
    
    private var timer: Timer?
    private var secondsInDay = 86400
    private var secondsInHour = 3600
    private var secondsInMinute = 60

    init() {}
    
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
