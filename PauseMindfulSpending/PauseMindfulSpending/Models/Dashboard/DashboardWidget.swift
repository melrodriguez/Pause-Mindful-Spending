import Foundation

struct DashboardWidget: Identifiable, Equatable {
    let id: UUID
    var kind: DashboardWidgetType
    var selectedPauseCategories: [String]

    init(
        id: UUID = UUID(),
        kind: DashboardWidgetType,
        selectedPauseCategories: [String] = []
    ) {
        self.id = id
        self.kind = kind
        self.selectedPauseCategories = selectedPauseCategories
    }
}
