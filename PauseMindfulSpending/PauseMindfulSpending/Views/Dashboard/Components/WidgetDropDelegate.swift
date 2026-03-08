import SwiftUI

// Delegate that handles drag-and-drop reordering of widgets
struct WidgetDropDelegate: DropDelegate {

    let item: DashboardWidget // widget being hovered over
    @Binding var widgets: [DashboardWidget] // array of widget to reorder
    @Binding var draggedItem: DashboardWidget? // widget being dragged

    // Called when the dragged item first enters the drop area of another widget
    func dropEntered(info: DropInfo) {

        // Check if there is a dragged widget, that isn't the same as the current
        // one and that we can find both indices in the widget array
        guard let draggedItem,
              draggedItem != item,
              let from = widgets.firstIndex(of: draggedItem),
              let to = widgets.firstIndex(of: item)
        else { return }

        // Prevent unnecessary moves if the item is already in that spot
        if widgets[to] != draggedItem {
            
            withAnimation(.spring(duration: 0.25)) {
                widgets.move(
                    fromOffsets: IndexSet(integer: from),
                    // If dragging downward, adjust index so it inserts correctly
                    toOffset: to > from ? to + 1 : to
                )
            }
        }
    }


    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {

        // indicate drag operation is a move
        return DropProposal(operation: .move)
    }
}
