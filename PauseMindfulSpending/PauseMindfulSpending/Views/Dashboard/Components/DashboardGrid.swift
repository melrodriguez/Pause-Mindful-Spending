import SwiftUI
import UniformTypeIdentifiers

// Container for the dashboard widgets
struct DashboardGrid: View {
    @Binding var widgets: [DashboardWidget]
    @Binding var isEditingDashboard: Bool
    @Binding var draggedWidget: DashboardWidget?

    let impulsesState: ImpulsesState
    let moneySavedState: MoneySavedState
    let onRemove: (DashboardWidget) -> Void
    let onEditCategories: (DashboardWidget) -> Void

    var body: some View {
        LazyVStack(spacing: 5) {
            ForEach(widgets) { widget in
                
                DashboardWidgetView(
                    widget: widget,
                    impulsesState: impulsesState,
                    moneySavedState: moneySavedState
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
                    
                    if widget.kind == .pauseStreaks {
                        Button {
                            onEditCategories(widget)
                        } label: {
                            Label("Edit Categories", systemImage: "slider.horizontal.3")
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
