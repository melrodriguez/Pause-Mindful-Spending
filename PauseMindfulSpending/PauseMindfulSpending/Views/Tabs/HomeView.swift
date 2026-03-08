import SwiftUI

struct CurrentUser {
    static let uid = "lADgRy5WsaCEpkERkcsE"
}

struct HomeView: View {
    
    @StateObject private var viewModel = DashboardViewModel()
    
    @State private var showingAddSheet = false
    @State private var isEditingDashboard = false
    @State private var draggedWidget: DashboardWidget?
    @State private var widgets: [DashboardWidget] = []
    @State private var configuringWidget: DashboardWidget?

    // Categories shown in the picker and streak widget config
    private var availableCategories: [String] {
        viewModel.categories.isEmpty
            ? ["Overall"]
            : ["Overall"] + viewModel.categories
    }

    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            AppHeader(title: "Pause")

            HStack {
                Text("Home")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textSecondary)

                Spacer()

                HStack(spacing: 12) {
                    if isEditingDashboard {
                        Button {
                            withAnimation(.spring()) {
                                isEditingDashboard = false
                                saveCurrentDashboard()
                            }
                        } label: {
                            Image(systemName: "checkmark")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .disabled(widgets.count == DashboardWidgetType.allCases.count)
                    .opacity(widgets.count == DashboardWidgetType.allCases.count ? 0.4 : 1.0)
                }
            }
            .padding(.horizontal, AppLayout.horizontalScreenPadding)

            ScrollView {
                DashboardGrid(
                    widgets: $widgets,
                    isEditingDashboard: $isEditingDashboard,
                    draggedWidget: $draggedWidget,
                    impulsesState: viewModel.impulsesState,
                    moneySavedState: viewModel.moneySavedState,
                    onRemove: { widget in
                        withAnimation {
                            widgets.removeAll { $0.id == widget.id }
                            saveCurrentDashboard()
                        }
                    },
                    onEditCategories: { widget in
                        configuringWidget = widget
                    }
                )
                .padding(.horizontal, AppLayout.horizontalScreenPadding)
            }
        }
        .appBackground()
        .onAppear {
            viewModel.loadCategories(uid: CurrentUser.uid)
            viewModel.loadImpulsesState(uid: CurrentUser.uid)
            viewModel.loadMoneySavedState(uid: CurrentUser.uid)
            widgets = makeWidgets(from: viewModel.dashboardConfig)
        }
        .sheet(isPresented: $showingAddSheet) {
            AddWidgetSheet(
                categories: availableCategories,
                existingTypes: widgets.map(\.kind),
                onAdd: { newWidget in
                    withAnimation {
                        widgets.append(newWidget)
                        saveCurrentDashboard()
                    }
                }
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(item: $configuringWidget) { widget in
            PauseStreakCategoryPickerSheet(
                allCategories: availableCategories,
                selectedCategories: Set(widget.selectedPauseCategories),
                onSave: { newCategories in
                    updatePauseCategories(
                        widgetID: widget.id,
                        categories: newCategories
                    )
                }
            )
            .presentationDetents([.medium, .large])
        }
        .toolbar(.hidden, for: .tabBar)
    }

    // Converts local DashboardConfig into actual dashboard widgets
    private func makeWidgets(from config: DashboardConfig) -> [DashboardWidget] {
        let savedCategories = config.enabledCategories.isEmpty
            ? ["Overall"]
            : config.enabledCategories

        let orderedTypes = config.widgetOrder.compactMap { DashboardWidgetType(rawValue: $0) }
        let enabledSet = Set(config.enabledWidgets)

        let filteredTypes = orderedTypes.filter { enabledSet.contains($0.rawValue) }

        // Default dashboard if nothing is saved yet
        if filteredTypes.isEmpty {
            return [
                DashboardWidget(
                    kind: .pauseStreaks,
                    selectedPauseCategories: ["Overall"]
                ),
                DashboardWidget(kind: .moneySaved),
                DashboardWidget(kind: .impulsesResisted)
            ]
        }

        return filteredTypes.map { type in
            switch type {
            case .pauseStreaks:
                return DashboardWidget(
                    kind: .pauseStreaks,
                    selectedPauseCategories: savedCategories
                )
            case .moneySaved:
                return DashboardWidget(kind: .moneySaved)
            case .impulsesResisted:
                return DashboardWidget(kind: .impulsesResisted)
            }
        }
    }

    // Converts current widgets into local DashboardConfig and saves it
    private func saveCurrentDashboard() {
        let pauseCategories =
            widgets.first(where: { $0.kind == .pauseStreaks })?.selectedPauseCategories ?? ["Overall"]

        let widgetKinds = widgets.map(\.kind.rawValue)

        let config = DashboardConfig(
            enabledWidgets: widgetKinds,
            widgetOrder: widgetKinds,
            enabledCategories: pauseCategories
        )

        viewModel.saveDashboardConfig(config)
    }

    // Updates the categories for the pause streak widget and saves config
    private func updatePauseCategories(widgetID: UUID, categories: [String]) {
        guard let index = widgets.firstIndex(where: { $0.id == widgetID }) else { return }
        widgets[index].selectedPauseCategories = categories
        saveCurrentDashboard()
    }
}

#Preview {
    HomeView()
}
