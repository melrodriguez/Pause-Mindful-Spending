import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var session: AppSessionViewModel
    @StateObject private var viewModel = DashboardViewModel()
    
    @State private var showingAddSheet = false
    @State private var isEditingDashboard = false
    @State private var draggedWidget: DashboardWidget?
    @State private var widgets: [DashboardWidget] = []
    @State private var configuringWidget: DashboardWidget?

    private var availableCategories: [String] {
        let cleaned = viewModel.categories
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return cleaned.isEmpty ? ["Overall"] : ["Overall"] + cleaned
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
                VStack(spacing: 0) {
                    DashboardGrid(
                        widgets: $widgets,
                        isEditingDashboard: $isEditingDashboard,
                        draggedWidget: $draggedWidget,
                        impulsesState: viewModel.impulsesState,
                        moneySavedState: viewModel.moneySavedState,
                        streakState: viewModel.streakState,
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
                    .padding(.top, 6)

                    Color.clear
                        .frame(height: 60)
                }
                .padding(.horizontal, AppLayout.horizontalScreenPadding)
            }
        }
        .appBackground()
        .task(id: session.userProfile?.id) {
            guard let uid = session.userProfile?.id else { return }
            
            viewModel.loadCategories(uid: uid)
            viewModel.loadImpulsesState(uid: uid)
            viewModel.loadMoneySavedState(uid: uid)
            viewModel.loadStreakState(uid: uid)
            
            if widgets.isEmpty {
                widgets = makeWidgets(from: viewModel.dashboardConfig)
            }
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
                    withAnimation {
                        updatePauseCategories(
                            widgetID: widget.id,
                            categories: newCategories
                        )
                    }
                }
            )
            .presentationDetents([.medium, .large])
        }
        .toolbar(.hidden, for: .tabBar)
    }

    private func makeWidgets(from config: DashboardConfig) -> [DashboardWidget] {
        let validSavedCategories = config.enabledCategories.filter { category in
            category == "Overall" || availableCategories.contains(category)
        }

        let savedCategories = validSavedCategories.isEmpty
            ? ["Overall"]
            : validSavedCategories

        let orderedTypes = config.widgetOrder.compactMap { DashboardWidgetType(rawValue: $0) }
        let enabledSet = Set(config.enabledWidgets)
        let filteredTypes = orderedTypes.filter { enabledSet.contains($0.rawValue) }

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

    private func updatePauseCategories(widgetID: UUID, categories: [String]) {
        guard let index = widgets.firstIndex(where: { $0.id == widgetID }) else { return }

        let cleanedCategories = categories.filter { category in
            category == "Overall" || availableCategories.contains(category)
        }

        widgets[index].selectedPauseCategories = cleanedCategories.isEmpty ? ["Overall"] : cleanedCategories

        if configuringWidget?.id == widgetID {
            configuringWidget?.selectedPauseCategories = widgets[index].selectedPauseCategories
        }

        saveCurrentDashboard()
    }
}

#Preview {
    HomeView()
        .environmentObject(AppSessionViewModel())
}
