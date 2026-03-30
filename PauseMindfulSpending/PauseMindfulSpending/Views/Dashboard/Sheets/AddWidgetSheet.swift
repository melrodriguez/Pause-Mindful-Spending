import SwiftUI

struct AddWidgetSheet: View {

    let categories: [String]
    let existingTypes: [DashboardWidgetType]
    let onAdd: (DashboardWidget) -> Void
    @Environment(\.dismiss) private var dismiss

    private var availableTypes: [DashboardWidgetType] {
        DashboardWidgetType.allCases.filter { !existingTypes.contains($0) }
    }

    var body: some View {
        NavigationStack {
            List {
                availableSection
                    .navigationTitle("Add Widget")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    private var availableSection: some View {
        Section("Available Widgets") {
            ForEach(availableTypes, id: \.self) { kind in
                Button { addWidget(kind) } label: { widgetRow(for: kind) }
            }
        }
    }

    private func addWidget(_ kind: DashboardWidgetType) {
        switch kind {
        case .pauseStreaks:
            onAdd(DashboardWidget(kind: .pauseStreaks, selectedPauseCategories: categories))
        case .moneySaved:
            onAdd(DashboardWidget(kind: .moneySaved))
        case .impulsesResisted:
            onAdd(DashboardWidget(kind: .impulsesResisted))
        case .activityCalendar:
            onAdd(DashboardWidget(kind: .activityCalendar))
        case .budget:
            onAdd(DashboardWidget(kind: .budget))
        }
        dismiss()
    }

    private func widgetRow(for widgetType: DashboardWidgetType) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage(for: widgetType))
                .font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                Text(title(for: widgetType))
                    .font(.headline)
                Text(subtitle(for: widgetType))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }

    private func title(for kind: DashboardWidgetType) -> String {
        switch kind {
        case .pauseStreaks:      return "Pause Streaks"
        case .moneySaved:       return "Money Saved"
        case .impulsesResisted: return "Impulses Resisted"
        case .activityCalendar: return "Activity Calendar"
        case .budget:           return "Budget"
        }
    }

    private func subtitle(for kind: DashboardWidgetType) -> String {
        switch kind {
        case .pauseStreaks:      return "Show streaks by category"
        case .moneySaved:       return "Show total money saved over time"
        case .impulsesResisted: return "Show resisted vs bought items"
        case .activityCalendar: return "Show your activity day by day"
        case .budget:           return "Track spending against your budget"
        }
    }

    private func systemImage(for kind: DashboardWidgetType) -> String {
        switch kind {
        case .pauseStreaks:      return "pause.circle"
        case .moneySaved:       return "dollarsign.circle"
        case .impulsesResisted: return "chart.pie"
        case .activityCalendar: return "calendar"
        case .budget:           return "chart.bar.xaxis"
        }
    }
}
