import SwiftUI
import UniformTypeIdentifiers

struct DashboardGrid: View {
    @Binding var widgets: [DashboardWidget]
    @Binding var isEditingDashboard: Bool
    @Binding var draggedWidget: DashboardWidget?

    let impulsesState: ImpulsesState
    let moneySavedState: MoneySavedState
    let streakState: DashboardStreakState
    let activityCalendarData: [String: Int]
    let budgetState: BudgetState
    let allCategories: [String]
    let onRemove: (DashboardWidget) -> Void
    let onEditCategories: (DashboardWidget) -> Void
    let onSaveBudget: ([BudgetCategory]) -> Void

    @State private var showingBudgetEditor = false

    var body: some View {
        LazyVStack(spacing: 5) {
            ForEach(widgets) { widget in

                DashboardWidgetView(
                    widget: widget,
                    impulsesState: impulsesState,
                    moneySavedState: moneySavedState,
                    streakState: streakState,
                    activityCalendarData: activityCalendarData,
                    budgetState: budgetState,
                    allCategories: allCategories,
                    onSaveBudget: onSaveBudget,
                    showingBudgetEditor: $showingBudgetEditor
                )
                .wiggle(isEditingDashboard)
                .scaleEffect(draggedWidget?.id == widget.id ? 1.03 : 1.0)
                .opacity(draggedWidget?.id == widget.id ? 0.92 : 1.0)
                .contextMenu {
                    Button {
                        withAnimation(.spring()) {
                            isEditingDashboard = true
                        }
                    } label: {
                        Label("Edit Dashboard", systemImage: "square.grid.2x2")
                    }

                    // Pause streaks category editor
                    if widget.kind == .pauseStreaks {
                        Button {
                            onEditCategories(widget)
                        } label: {
                            Label("Edit Categories", systemImage: "slider.horizontal.3")
                        }
                    }

                    // Budget editor
                    if widget.kind == .budget {
                        Button {
                            showingBudgetEditor = true
                        } label: {
                            Label("Edit Budget", systemImage: "slider.horizontal.3")
                        }
                    }

                    Button(role: .destructive) {
                        onRemove(widget)
                    } label: {
                        Label("Remove Widget", systemImage: "trash")
                    }
                }
                .onDrag {
                    guard isEditingDashboard else { return NSItemProvider() }
                    draggedWidget = widget
                    return NSItemProvider(object: widget.id.uuidString as NSString)
                }
                .onDrop(
                    of: [UTType.text],
                    delegate: WidgetDropDelegate(
                        item: widget,
                        widgets: $widgets,
                        draggedItem: $draggedWidget
                    )
                )
            }
        }
    }
}
