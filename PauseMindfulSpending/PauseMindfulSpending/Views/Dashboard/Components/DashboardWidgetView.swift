import SwiftUI

struct DashboardWidgetView: View {
    let widget: DashboardWidget
    let impulsesState: ImpulsesState
    let moneySavedState: MoneySavedState
    let streakState: DashboardStreakState
    let activityCalendarData: [String: Int]
    let budgetState: BudgetState
    let allCategories: [String]
    let onSaveBudget: ([BudgetCategory]) -> Void
    
    @Binding var showingBudgetEditor: Bool

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
        
        case .activityCalendar:
            ActivityCalendarView(
                activityData: activityCalendarData
            )
            
        case .budget:
            BudgetWidgetView(
                state: budgetState,
                allCategories: allCategories,
                onSaveBudget: onSaveBudget,
                showingEditor: $showingBudgetEditor
            )
        }
    }
}
