import Foundation

enum DashboardWidgetType: String, Codable, CaseIterable, Identifiable {
    case pauseStreaks
    case moneySaved
    case impulsesResisted
    case activityCalendar
    case budget

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pauseStreaks: return "Pause Streaks"
        case .moneySaved: return "Money Saved"
        case .impulsesResisted: return "Impules Resisted"
        case .activityCalendar: return "Activity Calendar"
        case .budget:           return "Budget"
        }
    }

    var supportsEditing: Bool {
        switch self {
        case .pauseStreaks:
            return true
        case .moneySaved, .impulsesResisted, .activityCalendar, .budget:
            return false
        }
    }
}
