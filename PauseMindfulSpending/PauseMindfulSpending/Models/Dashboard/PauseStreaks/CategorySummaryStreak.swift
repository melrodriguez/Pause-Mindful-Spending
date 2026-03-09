import Foundation

struct CategoryStreakSummary: Identifiable, Hashable {
    let id: String
    let name: String
    let currentStreak: Int
    let highestStreak: Int
}
