import SwiftUI
import Charts

struct BudgetWidgetView: View {
    let state: BudgetState
    let allCategories: [String]
    let onSaveBudget: ([BudgetCategory]) -> Void

    @Binding var showingEditor: Bool

    var body: some View {
        VStack(spacing: 12) {
            Text("Budget")
                .font(AppFonts.headline)
                .foregroundStyle(AppColors.textPrimary)

            if state.categories.isEmpty {
                emptyState
            } else {
                categoryList
            }
        }
        .frame(maxWidth: .infinity)  
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppColors.blue)
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        )
        .padding()
        .sheet(isPresented: $showingEditor) {
            BudgetEditorSheet(
                allCategories: allCategories,
                currentBudgets: state.categories,
                currencySymbol: state.currencySymbol,
                onSave: onSaveBudget
            )
            .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 28))
                .foregroundStyle(AppColors.textPrimary.opacity(0.4))

            Text("No budgets set")
                .font(AppFonts.subhead)
                .foregroundStyle(AppColors.textPrimary.opacity(0.5))

            Text("Long press to set up budget categories")
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textPrimary.opacity(0.35))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    // MARK: - Category rows

    private var categoryList: some View {
        VStack(spacing: 14) {
            ForEach(state.categories) { category in
                BudgetBarRow(
                    category: category,
                    currencySymbol: state.currencySymbol
                )
            }
        }
    }
}

// MARK: - Single bar row

private struct BudgetBarRow: View {
    let category: BudgetCategory
    let currencySymbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(category.id)
                    .font(AppFonts.subhead)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                if category.isOverBudget {
                    Text("Over budget")
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.pink)
                        .fontWeight(.semibold)
                } else {
                    Text("\(currencySymbol)\(Int(category.remaining)) left")
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.textPrimary.opacity(0.6))
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.black.opacity(0.12))
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(category.isOverBudget ? AppColors.pink : AppColors.mainGreen)
                        .frame(
                            width: geo.size.width * category.progress,
                            height: 10
                        )
                        .animation(.spring(duration: 0.5), value: category.progress)
                }
            }
            .frame(height: 10)

            HStack {
                Text("\(currencySymbol)\(Int(category.spent)) spent")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textPrimary.opacity(0.5))

                Spacer()

                Text("of \(currencySymbol)\(Int(category.limit))")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textPrimary.opacity(0.5))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(red: 0.97, green: 0.95, blue: 0.90).ignoresSafeArea()

        BudgetWidgetView(
            state: BudgetState(
                categories: [
                    BudgetCategory(id: "Overall", limit: 500, spent: 320),
                    BudgetCategory(id: "Electronics", limit: 200, spent: 210),
                    BudgetCategory(id: "Clothing", limit: 150, spent: 60)
                ],
                currencySymbol: "$"
            ),
            allCategories: ["Overall", "Electronics", "Clothing"],
            onSaveBudget: { _ in },
            showingEditor: .constant(false)
        )
        .frame(maxWidth: 380)
    }
}
