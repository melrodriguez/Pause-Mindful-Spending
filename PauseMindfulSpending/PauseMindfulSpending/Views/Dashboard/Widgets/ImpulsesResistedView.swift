import SwiftUI
import Charts

struct ImpulseComparison: Identifiable {
    let id = UUID()
    let label: String
    let count: Int
    let color: Color
}

struct ImpulsesResistedView: View {
    let state: ImpulsesState

    private var chartData: [ImpulseComparison] {
        [
            .init(label: "Resisted", count: state.resistedCount, color: AppColors.mainGreen),
            .init(label: "Bought", count: state.boughtCount, color: AppColors.blue)
        ]
    }

    private var total: Int {
        state.resistedCount + state.boughtCount
    }

    private var resistedPercentage: Int {
        guard total > 0 else { return 0 }
        return Int((Double(state.resistedCount) / Double(total) * 100).rounded())
    }

    var body: some View {
        VStack(spacing: 14) {
            Text("Impulses Resisted")
                .font(AppFonts.headline)

            Text("Resisted vs Bought")
                .font(AppFonts.subhead)
                .foregroundStyle(AppColors.textSecondary)
                .italic()

            ZStack {
                Chart(chartData) { item in
                    SectorMark(
                        angle: .value("Count", item.count),
                        innerRadius: .ratio(0.62),
                        angularInset: 3
                    )
                    .foregroundStyle(item.color)
                    .cornerRadius(6)
                }
                .chartLegend(.hidden)
                .frame(height: 180)

                VStack(spacing: 2) {
                    Text("\(resistedPercentage)%")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)

                    Text("resisted")
                        .font(AppFonts.subhead)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            HStack(spacing: 12) {
                statPill(
                    title: "Resisted",
                    value: state.resistedCount,
                    color: AppColors.mainGreen
                )

                statPill(
                    title: "Bought",
                    value: state.boughtCount,
                    color: AppColors.blue
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppColors.pink)
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        )
        .padding()
    }

    @ViewBuilder
    private func statPill(title: String, value: Int, color: Color) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(AppFonts.subhead)
                    .foregroundStyle(AppColors.textPrimary)

                Text("\(value)")
                    .font(AppFonts.subhead)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.35))
        )
    }
}

#Preview {
    ZStack {
        Color(red: 0.97, green: 0.95, blue: 0.90)
            .ignoresSafeArea()

        ImpulsesResistedView(
            state: ImpulsesState(
                resistedCount: 18,
                boughtCount: 7
            )
        )
        .frame(maxWidth: 380)
    }
}
