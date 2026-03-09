import SwiftUI

// Sheet for user to add a widget to the dashboard
struct AddWidgetSheet: View {

    let categories: [String]
    let existingTypes: [DashboardWidgetType] // widgets already on dashboard
    let onAdd: (DashboardWidget) -> Void
    @Environment(\.dismiss) private var dismiss

    // widgets not on dashboard
    private var availableTypes: [DashboardWidgetType] {
        DashboardWidgetType.allCases.filter { type in
            !existingTypes.contains(type)
        }
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

    // Displays list of widgets that can be added
    private var availableSection: some View {
        Section("Available Widgets") {
            ForEach(availableTypes, id: \.self) { kind in
                Button {
                    addWidget(kind)
                } label: {
                    widgetRow(for: kind)
                }
            }
        }
    }

    // Adds the widget
    private func addWidget(_ kind: DashboardWidgetType) {
        switch kind {
        case .pauseStreaks:
            onAdd(
                DashboardWidget(
                    kind: .pauseStreaks,
                    selectedPauseCategories: categories
                )
            )

        case .moneySaved:
            onAdd(
                DashboardWidget(kind: .moneySaved)
            )

        case .impulsesResisted:
            onAdd(
                DashboardWidget(kind: .impulsesResisted)
            )
        }

        dismiss()
    }

    // Label that describes the widget option
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
        case .pauseStreaks:
            return "Pause Streaks"
        case .moneySaved:
            return "Money Saved"
        case .impulsesResisted:
            return "Impulses Resisted"
        }
    }

    private func subtitle(for kind: DashboardWidgetType) -> String {
        switch kind {
        case .pauseStreaks:
            return "Show streaks by category"
        case .moneySaved:
            return "Show total money saved over time"
        case .impulsesResisted:
            return "Show resisted vs bought items"
        }
    }

    private func systemImage(for kind: DashboardWidgetType) -> String {
        switch kind {
        case .pauseStreaks:
            return "pause.circle"
        case .moneySaved:
            return "dollarsign.circle"
        case .impulsesResisted:
            return "chart.pie"
        }
    }
}
