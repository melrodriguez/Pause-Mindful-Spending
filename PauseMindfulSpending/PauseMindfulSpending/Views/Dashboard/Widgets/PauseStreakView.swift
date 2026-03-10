import SwiftUI
import Charts

struct PauseStreak: Identifiable {
    let id = UUID()
    let category: String
    let days: Int
    let highlight: Bool
}

struct PauseStreaksWidgetView: View {
    let selectedCategories: [String]
    let streakState: DashboardStreakState

    private var allStreaks: [PauseStreak] {
        var result: [PauseStreak] = [
            PauseStreak(
                category: "Overall",
                days: streakState.overallCurrentStreak,
                highlight: streakState.overallCurrentStreak == streakState.overallHighestStreak && streakState.overallCurrentStreak > 0
            )
        ]

        let categoryStreaks = streakState.categorySummaries.map { summary in
            PauseStreak(
                category: summary.name,
                days: summary.currentStreak,
                highlight: summary.currentStreak == summary.highestStreak && summary.currentStreak > 0
            )
        }

        result.append(contentsOf: categoryStreaks)
        return result
    }

    private var streaks: [PauseStreak] {
        let filtered = allStreaks.filter { selectedCategories.contains($0.category) }
        return filtered.isEmpty ? allStreaks : filtered
    }
    
    private var chartHeight: CGFloat {
        CGFloat(max(streaks.count, 1)) * 34
    }

    var body: some View {
        VStack(spacing: 1) {
            Text("Pause Streaks")
                .font(AppFonts.headline)

            Text("Days since last purchase")
                .font(AppFonts.subhead)
                .foregroundStyle(AppColors.accentGreen)
                .italic()

            if streaks.isEmpty {
                Text("No streak data yet")
                    .font(AppFonts.subhead)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.top, 12)
            } else {
                Chart(streaks) { streak in
                    BarMark(
                        x: .value("Days", streak.days),
                        y: .value("Category", streak.category)
                    )
                    .foregroundStyle(AppColors.mainGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .annotation(position: .trailing, alignment: .center) {
                        HStack(spacing: 4) {
                            Text("\(streak.days)")
                                .font(AppFonts.subhead)
                                .fontWeight(.bold)
                                .foregroundStyle(AppColors.accentGreen)

                            if streak.highlight {
                                Text("🔥")
                            }
                        }
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                            .font(AppFonts.subhead)
                            .foregroundStyle(AppColors.textPrimary)
                    }
                }
                .chartXScale(domain: 0...maxXValue)
                .chartPlotStyle { plotArea in
                    plotArea.background(.clear)
                }
                .frame(height: chartHeight)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppColors.blue)
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        )
        .padding()
    }

    private var maxXValue: Int {
        max((streaks.map(\.days).max() ?? 0) + 4, 10)
    }
}

#Preview {
    ZStack {
        Color(red: 0.97, green: 0.95, blue: 0.90)
            .ignoresSafeArea()

        PauseStreaksWidgetView(
            selectedCategories: ["Overall"],
            streakState: .empty
        )
        .frame(maxWidth: 380)
    }
}
