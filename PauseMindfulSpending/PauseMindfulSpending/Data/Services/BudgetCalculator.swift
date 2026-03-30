import Foundation

enum BudgetCalculator {

    // Takes the saved budget limits and a list of bought events, and returns
    // the same categories with their `spent` field populated.
    static func applySpending(
        to budgets: [BudgetCategory],
        from events: [DashboardEvent]
    ) -> [BudgetCategory] {

        // Only care about item_bought events that have an amount
        let boughtEvents = events.filter { $0.type == "item_bought" }

        // Build total spent per categoryId (nil categoryId = overall)
        var spentByCategory: [String?: Double] = [:]
        for event in boughtEvents {
            let amount = event.amount ?? 0
            // Add to the specific category bucket
            spentByCategory[event.category, default: 0] += amount
            // Always add to overall
            spentByCategory[nil, default: 0] += amount
        }

        return budgets.map { budget in
            var updated = budget
            if budget.id == "Overall" {
                updated.spent = spentByCategory[nil] ?? 0
            } else {
                updated.spent = spentByCategory[budget.id] ?? 0
            }
            return updated
        }
    }
}
