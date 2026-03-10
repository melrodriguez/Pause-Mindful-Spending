import Foundation

enum DashboardWidgetType: String, Codable, CaseIterable, Identifiable {
    case pauseStreaks
    case moneySaved
    case impulsesResisted

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pauseStreaks: return "Pause Streaks"
        case .moneySaved: return "Money Saved"
        case .impulsesResisted: return "Impules Resisted"
        }
    }

    var supportsEditing: Bool {
        switch self {
        case .pauseStreaks:
            return true
        case .moneySaved:
            return false
        case .impulsesResisted:
            return false
        }
    }
}
