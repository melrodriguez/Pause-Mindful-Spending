import SwiftUI
import Charts

struct MoneySavedView: View {
    let state: MoneySavedState

    @State private var selectedRange: SavingsRange = .week

    private var chartData: [SavingsPoint] {
        switch selectedRange {
        case .week:
            return state.weeklyData
        case .month:
            return state.monthlyData
        case .allTime:
            return state.allTimeData
        }
    }

    private var totalSaved: Double {
        chartData.last?.amount ?? 0
    }

    private var rangeSubtitle: String {
        switch selectedRange {
        case .week:
            return "This week"
        case .month:
            return "This month"
        case .allTime:
            return "All time"
        }
    }

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 5) {
                Text("Money Saved")
                    .font(AppFonts.headline)

                Picker("Range", selection: $selectedRange) {
                    ForEach(SavingsRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .accentColor(AppColors.accentGreen)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(state.currencySymbol)\(Int(totalSaved))")
                        .font(.system(size: 30, weight: .bold, design: .rounded))

                    Text(rangeSubtitle)
                        .font(.caption)
                        .foregroundStyle(AppColors.accentGreen)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Chart(chartData) { point in
                    AreaMark(
                        x: .value("Period", point.label),
                        y: .value("Saved", point.amount)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(AppColors.pink.opacity(0.15))

                    LineMark(
                        x: .value("Period", point.label),
                        y: .value("Saved", point.amount)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(AppColors.pink)
                    .lineStyle(
                        StrokeStyle(
                            lineWidth: 3,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )

                    PointMark(
                        x: .value("Period", point.label),
                        y: .value("Saved", point.amount)
                    )
                    .foregroundStyle(AppColors.pink)
                }
                .chartYAxis(.hidden)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(AppColors.accentGreen)
                    }
                }
                .frame(height: 170)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(AppColors.mainGreen)
                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
            )
            .padding()
        }
    }
}
