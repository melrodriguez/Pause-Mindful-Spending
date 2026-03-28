import SwiftUI

struct DayActivity: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

enum ActivityLevel {
    case none, light, moderate, heavy, intense

    init(count: Int, maxCount: Int) {
        guard count > 0, maxCount > 0 else { self = .none; return }
        let ratio = Double(count) / Double(maxCount)
        switch ratio {
        case ..<0.25: self = .light
        case ..<0.5:  self = .moderate
        case ..<0.75: self = .heavy
        default:      self = .intense
        }
    }
}


struct ActivityCalendarView: View {
    let activityData: [String: Int]

    @State private var displayedMonth: Date = {
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.year, .month], from: Date()))!
    }()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)
    private let dayLabels = ["S", "M", "T", "W", "Th", "F", "Sa"]

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private var days: [Date?] {
        guard
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)),
            let range = calendar.range(of: .day, in: .month, for: monthStart)
        else { return [] }

        let weekdayOffset = (calendar.component(.weekday, from: monthStart) - calendar.firstWeekday + 7) % 7
        var result: [Date?] = Array(repeating: nil, count: weekdayOffset)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                result.append(date)
            }
        }
        return result
    }

    private var maxCount: Int {
        activityData.values.max() ?? 1
    }

    private func count(for date: Date) -> Int {
        let key = dateKey(date)
        return activityData[key] ?? 0
    }

    private func activityLevel(for date: Date) -> ActivityLevel {
        ActivityLevel(count: count(for: date), maxCount: maxCount)
    }

    private func dateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private var isCurrentMonth: Bool {
        calendar.isDate(displayedMonth, equalTo: Date(), toGranularity: .month)
    }

    var body: some View {
        VStack(spacing: 14) {
            // Header
            Text("Activity")
                .font(AppFonts.headline)

            // Month navigation
            HStack {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.accentGreen)
                        .frame(width: 32, height: 32)
                        .background(.white.opacity(0.25), in: Circle())
                }

                Spacer()

                Text(monthTitle)
                    .font(AppFonts.subhead)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isCurrentMonth ? AppColors.accentGreen.opacity(0.3) : AppColors.accentGreen)
                        .frame(width: 32, height: 32)
                        .background(.white.opacity(isCurrentMonth ? 0.1 : 0.25), in: Circle())
                }
                .disabled(isCurrentMonth)
            }

            // Day-of-week labels
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(dayLabels, id: \.self) { label in
                    Text(label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(AppColors.accentGreen.opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                    if let date {
                        DayCell(
                            date: date,
                            level: activityLevel(for: date),
                            isToday: calendar.isDateInToday(date)
                        )
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }

            // Legend
            HStack(spacing: 6) {
                Text("Less")
                    .font(.system(size: 10))
                    .foregroundStyle(AppColors.accentGreen.opacity(0.6))

                ForEach([ActivityLevel.none, .light, .moderate, .heavy, .intense], id: \.hashValue) { level in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(cellColor(for: level))
                        .frame(width: 12, height: 12)
                }

                Text("More")
                    .font(.system(size: 10))
                    .foregroundStyle(AppColors.accentGreen.opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppColors.mainGreen)
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        )
        .padding()
        .animation(.spring(duration: 0.3), value: displayedMonth)
    }

    // MARK: Helpers

    private func changeMonth(by value: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        // Don't go into future months
        if value > 0 && calendar.isDate(newMonth, equalTo: Date(), toGranularity: .month) {
            displayedMonth = newMonth
        } else if value > 0 && newMonth > Date() {
            return
        } else {
            displayedMonth = newMonth
        }
    }

    func cellColor(for level: ActivityLevel) -> Color {
        switch level {
        case .none:     return .white.opacity(0.15)
        case .light:    return AppColors.accentGreen.opacity(0.35)
        case .moderate: return AppColors.accentGreen.opacity(0.55)
        case .heavy:    return AppColors.accentGreen.opacity(0.78)
        case .intense:  return AppColors.accentGreen
        }
    }
}

// MARK: - Day Cell

private struct DayCell: View {
    let date: Date
    let level: ActivityLevel
    let isToday: Bool

    private let calendar = Calendar.current

    private var dayNumber: String {
        "\(calendar.component(.day, from: date))"
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(cellColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(isToday ? AppColors.accentGreen : .clear, lineWidth: 1.5)
                )

            Text(dayNumber)
                .font(.system(size: 10, weight: isToday ? .bold : .regular))
                .foregroundStyle(labelColor)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var cellColor: Color {
        switch level {
        case .none:     return .white.opacity(0.15)
        case .light:    return AppColors.accentGreen.opacity(0.35)
        case .moderate: return AppColors.accentGreen.opacity(0.55)
        case .heavy:    return AppColors.accentGreen.opacity(0.78)
        case .intense:  return AppColors.accentGreen
        }
    }

    private var labelColor: Color {
        switch level {
        case .none:  return AppColors.textPrimary.opacity(0.45)
        default:     return AppColors.textPrimary
        }
    }
}

// MARK: - ActivityLevel Hashable

extension ActivityLevel: Hashable {}

// MARK: - Preview
 
private func mockActivityData() -> [String: Int] {
    let calendar = Calendar.current
    var data: [String: Int] = [:]
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
 
    for daysAgo in 0..<60 {
        if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
            if Bool.random() {
                data[formatter.string(from: date)] = Int.random(in: 1...8)
            }
        }
    }
    return data
}
 
#Preview {
    ZStack {
        Color(red: 0.97, green: 0.95, blue: 0.90)
            .ignoresSafeArea()
 
        ScrollView {
            ActivityCalendarView(
                activityData: mockActivityData()
            )
            .frame(maxWidth: 380)
        }
    }
}
