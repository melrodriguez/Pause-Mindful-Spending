import Foundation

// Stores the user's dashboard layout/preferences locally on device
struct DashboardConfig: Codable, Equatable {
    var enabledWidgets: [String]
    var widgetOrder: [String]
    var enabledCategories: [String]

    static let empty = DashboardConfig(
        enabledWidgets: [],
        widgetOrder: [],
        enabledCategories: []
    )
}
