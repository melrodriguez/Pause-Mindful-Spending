import SwiftUI

struct WidgetDropDelegate: DropDelegate {
    let widget: DashboardWidget
    @Binding var widgets: [DashboardWidget]
    @Binding var draggedId: UUID?
    @Binding var draggedWidget: DashboardWidget?
    @Binding var hoveredId: UUID?

    func dropEntered(info: DropInfo) {
        guard let draggedId,
              draggedId != widget.id,
              let from = widgets.firstIndex(where: { $0.id == draggedId }),
              let to = widgets.firstIndex(where: { $0.id == widget.id })
        else { return }

        hoveredId = widget.id

        guard widgets[to].id != draggedId else { return }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            widgets.move(
                fromOffsets: IndexSet(integer: from),
                toOffset: to > from ? to + 1 : to
            )
        }
    }

    func dropExited(info: DropInfo) {
        if hoveredId == widget.id {
            hoveredId = nil
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            draggedId = nil
            draggedWidget = nil
            hoveredId = nil
        }
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
