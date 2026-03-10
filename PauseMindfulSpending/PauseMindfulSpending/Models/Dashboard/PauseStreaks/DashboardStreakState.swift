import Foundation

struct DashboardStreakState {
    let overallCurrentStreak: Int
    let overallHighestStreak: Int
    let categorySummaries: [CategoryStreakSummary]

    static let empty = DashboardStreakState(
        overallCurrentStreak: 0,
        overallHighestStreak: 0,
        categorySummaries: []
    )
}
