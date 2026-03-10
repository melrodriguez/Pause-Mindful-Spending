import Foundation

struct HomeDashboardState {
    var moneySaved: MoneySavedState
    var impulses: ImpulsesState
    var categoryStreaks: [CategoryStreak] // default all users should have overall
    var config: DashboardConfig
}

struct MoneySavedState {
    var currencySymbol: String
    var weeklyData: [SavingsPoint]
    var monthlyData: [SavingsPoint]
    var allTimeData: [SavingsPoint]
}

struct ImpulsesState {
    let resistedCount: Int
    let boughtCount: Int
}

struct CategoryStreak: Identifiable {
    let id = UUID()
    var category: String
    var streakDays: Int
}

// Helper structs

struct SavingsPoint: Identifiable {
    let id = UUID()
    let label: String
    let amount: Double
}

enum SavingsRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case allTime = "All Time"

    var id: String { rawValue }
}
