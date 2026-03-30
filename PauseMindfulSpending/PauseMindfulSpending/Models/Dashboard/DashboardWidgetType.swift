import Foundation

enum DashboardWidgetType: String, Codable, CaseIterable, Identifiable {
    case pauseStreaks
    case moneySaved
    case impulsesResisted
    case activityCalendar

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pauseStreaks: return "Pause Streaks"
        case .moneySaved: return "Money Saved"
        case .impulsesResisted: return "Impules Resisted"
        case .activityCalendar: return "Activity Calendar"
        }
    }

    var supportsEditing: Bool {
        switch self {
        case .pauseStreaks:
            return true
        case .moneySaved, .impulsesResisted, .activityCalendar:
            return false
        }
    }
}
