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
    @State private var draggedId: UUID? = nil
    @State private var hoveredId: UUID? = nil

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
                .scaleEffect(draggedId == widget.id ? 1.05 : (hoveredId == widget.id && draggedId != nil ? 0.97 : 1.0))
                .opacity(draggedId == widget.id ? 0.7 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: draggedId)
                .animation(.easeInOut(duration: 0.2), value: hoveredId)
                // Minus circle delete button — top left corner in edit mode
                .padding(.top, isEditingDashboard ? 12 : 0)
                .padding(.leading, isEditingDashboard ? 12 : 0)
                .overlay(alignment: .topLeading) {
                    if isEditingDashboard {
                        Button {
                            onRemove(widget)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(AppColors.pink)
                                .background(Circle().fill(Color.white).padding(2))
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.3), value: isEditingDashboard)
                .contextMenu {
                    if !isEditingDashboard {
                        Button {
                            withAnimation(.spring()) {
                                isEditingDashboard = true
                            }
                        } label: {
                            Label("Edit Dashboard", systemImage: "square.grid.2x2")
                        }
                    }

                    if widget.kind == .pauseStreaks {
                        Button {
                            onEditCategories(widget)
                        } label: {
                            Label("Edit Categories", systemImage: "slider.horizontal.3")
                        }
                    }

                    if widget.kind == .budget {
                        Button {
                            showingBudgetEditor = true
                        } label: {
                            Label("Edit Budget", systemImage: "slider.horizontal.3")
                        }
                    }

                    if !isEditingDashboard {
                        Button(role: .destructive) {
                            onRemove(widget)
                        } label: {
                            Label("Remove Widget", systemImage: "trash")
                        }
                    }
                }
                .onDrag {
                    guard isEditingDashboard else { return NSItemProvider() }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        draggedId = widget.id
                        draggedWidget = widget
                    }
                    return NSItemProvider(object: widget.id.uuidString as NSString)
                } preview: {
                    DashboardWidgetView(
                        widget: widget,
                        impulsesState: impulsesState,
                        moneySavedState: moneySavedState,
                        streakState: streakState,
                        activityCalendarData: activityCalendarData,
                        budgetState: budgetState,
                        allCategories: allCategories,
                        onSaveBudget: onSaveBudget,
                        showingBudgetEditor: .constant(false)
                    )
                    .frame(maxWidth: .infinity)
                    .opacity(0.9)
                }
                .onDrop(of: [UTType.plainText], delegate: WidgetDropDelegate(
                    widget: widget,
                    widgets: $widgets,
                    draggedId: $draggedId,
                    draggedWidget: $draggedWidget,
                    hoveredId: $hoveredId
                ))
            }
        }
        .onChange(of: draggedId) { _, newValue in
            if newValue != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if draggedId != nil {
                        withAnimation(.spring()) {
                            draggedId = nil
                            draggedWidget = nil
                            hoveredId = nil
                        }
                    }
                }
            }
        }
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
