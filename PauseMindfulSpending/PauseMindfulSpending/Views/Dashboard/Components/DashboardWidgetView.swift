import SwiftUI

struct DashboardWidgetView: View {
    let widget: DashboardWidget
    let impulsesState: ImpulsesState
    let moneySavedState: MoneySavedState
    let streakState: DashboardStreakState

    var body: some View {
        switch widget.kind {
        case .pauseStreaks:
            PauseStreaksWidgetView(
                selectedCategories: widget.selectedPauseCategories,
                streakState: streakState
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
