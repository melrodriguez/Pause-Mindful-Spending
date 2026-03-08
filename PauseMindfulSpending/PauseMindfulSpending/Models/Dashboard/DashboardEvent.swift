import Foundation

struct DashboardEvent {
    let id: String
    let type: String
    let createdAt: Date
    let itemId: String?
    let timerId: String?
    let category: String?
    let amount: Double?
}
