import SwiftUI

// Changes the widget view depending on the type
struct DashboardWidgetView: View {
    let widget: DashboardWidget
    let impulsesState: ImpulsesState
    let moneySavedState: MoneySavedState

    var body: some View {
        switch widget.kind {
        case .pauseStreaks:
            PauseStreaksWidgetView(
                selectedCategories: widget.selectedPauseCategories
            )

        case .moneySaved:
            MoneySavedView(
                state: moneySavedState
            )

        case .impulsesResisted:
            ImpulsesResistedView(
                state: impulsesState
            )
        }
    }
}
