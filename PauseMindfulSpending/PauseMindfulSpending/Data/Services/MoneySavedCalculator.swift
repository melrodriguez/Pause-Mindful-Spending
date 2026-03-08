import Foundation

struct MoneySavedCalculator {

    static func makeMoneySavedState(
        from events: [DashboardEvent],
        currencySymbol: String = "$"
    ) -> MoneySavedState {

        return MoneySavedState(
            currencySymbol: currencySymbol,
            weeklyData: makeWeeklySavingsData(from: events),
            monthlyData: makeMonthlySavingsData(from: events),
            allTimeData: makeAllTimeSavingsData(from: events)
        )
    }

    // Builds cumulative savings for the current week (Mon–Sun).
    private static func makeWeeklySavingsData(from events: [DashboardEvent]) -> [SavingsPoint] {

        let calendar = Calendar.current
        let now = Date()

        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else {
            return []
        }

        let weekEvents = events.filter {
            $0.createdAt >= weekInterval.start && $0.createdAt < weekInterval.end
        }

        let weekdaySymbols = ["Sun", "Mon","Tue","Wed","Thu","Fri","Sat"]
        let startOfWeek = weekInterval.start

        var dailyNet: [Int: Double] = [:]

        for event in weekEvents {
            let dayOffset = calendar.dateComponents([.day], from: startOfWeek, to: event.createdAt).day ?? 0
            dailyNet[dayOffset, default: 0] += signedAmount(for: event)
        }

        var runningTotal = 0.0
        var points: [SavingsPoint] = []

        for dayIndex in 0..<7 {
            runningTotal += dailyNet[dayIndex, default: 0]
            points.append(
                SavingsPoint(
                    label: weekdaySymbols[dayIndex],
                    amount: max(runningTotal, 0)
                )
            )
        }

        return points
    }

    // Builds cumulative savings for the current month grouped by week.
    private static func makeMonthlySavingsData(from events: [DashboardEvent]) -> [SavingsPoint] {

        let calendar = Calendar.current
        let now = Date()

        guard let monthInterval = calendar.dateInterval(of: .month, for: now) else {
            return []
        }

        let monthEvents = events.filter {
            $0.createdAt >= monthInterval.start && $0.createdAt < monthInterval.end
        }

        var weeklyNet: [Int: Double] = [:]

        for event in monthEvents {
            let weekIndex = calendar.component(.weekOfMonth, from: event.createdAt) - 1
            weeklyNet[weekIndex, default: 0] += signedAmount(for: event)
        }

        var runningTotal = 0.0
        var points: [SavingsPoint] = []

        for weekIndex in 0..<4 {
            runningTotal += weeklyNet[weekIndex, default: 0]

            points.append(
                SavingsPoint(
                    label: "W\(weekIndex + 1)",
                    amount: max(runningTotal, 0)
                )
            )
        }

        return points
    }

    // Builds the all-time savings chart grouped by month.
    private static func makeAllTimeSavingsData(from events: [DashboardEvent]) -> [SavingsPoint] {

        let calendar = Calendar.current
        let sortedEvents = events.sorted { $0.createdAt < $1.createdAt }

        var monthlyNet: [Date: Double] = [:]

        for event in sortedEvents {

            let comps = calendar.dateComponents([.year, .month], from: event.createdAt)

            guard let monthDate = calendar.date(from: comps) else { continue }

            monthlyNet[monthDate, default: 0] += signedAmount(for: event)
        }

        let sortedMonths = monthlyNet.keys.sorted()

        var runningTotal = 0.0
        var points: [SavingsPoint] = []

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        for month in sortedMonths {

            runningTotal += monthlyNet[month, default: 0]

            points.append(
                SavingsPoint(
                    label: formatter.string(from: month),
                    amount: max(runningTotal, 0)
                )
            )
        }

        return points
    }

    // Builds the all-time savings chart grouped by month.
    private static func signedAmount(for event: DashboardEvent) -> Double {

        let amount = event.amount ?? 0

        switch event.type {
        case "item_created":
            return amount

        case "item_deleted", "item_bought":
            return -amount

        default:
            return 0
        }
    }
}
