import Foundation

struct TimerItem: Identifiable {
    let id: String
    let itemName: String
    let startTime: Date
    let duration: TimeInterval
    let imageUrl: String?
}
