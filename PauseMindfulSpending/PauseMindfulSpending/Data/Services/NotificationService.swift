import UserNotifications

class NotificationService {
    func requestPermissionIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                if granted {
                    print("Permission granted")
                } else {
                    print("Permission denied")
                }
            }
        }
    }
    
    func cancelAllPending() {
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()
    }
    
    func scheduleNotification(itemName: String, timerId: String, timeInterval: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Pause Timer Ended for an Item"
        content.subtitle = "item: \(itemName)"
        content.body = "tap to view"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: timerId,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Add error:", error as Any)
            } else {
                print("Notification Scheduled")
            }
        }
    }
    
    func cancelNotification(timerId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [timerId])
    }
}
