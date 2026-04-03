import SwiftUI
import Charts

// MARK: - Widget View

struct BudgetWidgetView: View {
    let state: BudgetState
    let allCategories: [String]
    let onSaveBudget: ([BudgetCategory]) -> Void
    @Binding var showingEditor: Bool

    @State private var selectedCategory: BudgetCategory?

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
                .fill(AppColors.mainGreen)
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
        .sheet(item: $selectedCategory) { category in
            BudgetCategoryDetailSheet(
                category: category,
                currencySymbol: state.currencySymbol
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
                Button {
                    selectedCategory = category
                } label: {
                    BudgetBarRow(
                        category: category,
                        currencySymbol: state.currencySymbol
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Single bar row

struct BudgetBarRow: View {
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
                    Text("\(currencySymbol)\(String(format: "%.2f", category.remaining)) left")
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.textPrimary.opacity(0.6))
                }

                // Subtle chevron to hint tappability
                Image(systemName: "chevron.right")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textPrimary.opacity(0.25))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.black.opacity(0.12))
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(category.isOverBudget ? AppColors.pink : AppColors.accentGreen)
                        .frame(
                            width: geo.size.width * category.progress,
                            height: 10
                        )
                        .animation(.spring(duration: 0.5), value: category.progress)
                }
            }
            .frame(height: 10)

            HStack {
                Text("\(currencySymbol)\(String(format: "%.2f", category.spent)) spent")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textPrimary.opacity(0.5))

                Spacer()

                Text("of \(currencySymbol)\(String(format: "%.2f", category.limit))")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textPrimary.opacity(0.5))
            }
        }
    }
}

// MARK: - Detail Sheet

struct BudgetCategoryDetailSheet: View {
    let category: BudgetCategory
    let currencySymbol: String
    @Environment(\.dismiss) private var dismiss

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // Summary card
                    summaryCard

                    // Purchase history
                    if category.purchases.isEmpty {
                        emptyPurchases
                    } else {
                        purchaseList
                    }
                }
                .padding(20)
            }
            .navigationTitle(category.id)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Summary card

    private var summaryCard: some View {
        VStack(spacing: 16) {
            // Stats row
            HStack(spacing: 0) {
                statBlock(
                    label: "Spent",
                    value: "\(currencySymbol)\(String(format: "%.2f", category.spent))",
                    color: category.isOverBudget ? AppColors.pink : AppColors.accentGreen
                )

                Divider().frame(height: 40)

                statBlock(
                    label: "Budget",
                    value: "\(currencySymbol)\(String(format: "%.2f", category.limit))",
                    color: AppColors.textPrimary
                )

                Divider().frame(height: 40)

                statBlock(
                    label: category.isOverBudget ? "Over by" : "Remaining",
                    value: "\(currencySymbol)\(String(format: "%.2f", abs(category.limit - category.spent)))",
                    color: category.isOverBudget ? AppColors.pink : AppColors.textPrimary
                )
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 14)

                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(category.isOverBudget ? AppColors.pink : AppColors.accentGreen)
                            .frame(
                                width: geo.size.width * category.progress,
                                height: 14
                            )
                            .animation(.spring(duration: 0.6), value: category.progress)
                    }
                }
                .frame(height: 14)

                Text(category.isOverBudget
                     ? "You've exceeded your budget"
                     : "\(Int(category.progress * 100))% of budget used")
                    .font(AppFonts.caption)
                    .foregroundStyle(category.isOverBudget ? AppColors.pink : AppColors.textSecondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }

    private func statBlock(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            Text(label)
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Purchase list

    private var purchaseList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Purchases")
                .font(AppFonts.subhead)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.textSecondary)

            VStack(spacing: 0) {
                ForEach(Array(category.purchases.enumerated()), id: \.element.id) { index, purchase in
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(AppColors.mainGreen.opacity(0.12))
                                    .frame(width: 36, height: 36)

                                Image(systemName: "bag")
                                    .font(.system(size: 14))
                                    .foregroundStyle(AppColors.accentGreen)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(purchase.itemName)
                                    .font(AppFonts.subhead)
                                    .foregroundStyle(AppColors.textPrimary)

                                Text(dateFormatter.string(from: purchase.date))
                                    .font(AppFonts.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }

                            Spacer()

                            Text("\(currencySymbol)\(String(format: "%.2f", purchase.amount))")
                                .font(AppFonts.subhead)
                                .fontWeight(.semibold)
                                .foregroundStyle(AppColors.textPrimary)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)

                        if index < category.purchases.count - 1 {
                            Divider()
                                .padding(.leading, 64)
                        }
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
            )
        }
    }

    // MARK: - Empty purchases

    private var emptyPurchases: some View {
        VStack(spacing: 8) {
            Image(systemName: "bag")
                .font(.system(size: 28))
                .foregroundStyle(AppColors.textSecondary.opacity(0.4))

            Text("No purchases yet")
                .font(AppFonts.subhead)
                .foregroundStyle(AppColors.textSecondary.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

// MARK: - Preview

#Preview {
    BudgetCategoryDetailSheet(
        category: BudgetCategory(
            id: "Electronics",
            limit: 200,
            spent: 169,
            purchases: [
                BudgetPurchase(id: "1", itemName: "AirPods Pro", amount: 129, date: Date()),
                BudgetPurchase(id: "2", itemName: "USB-C Cable", amount: 25, date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!),
                BudgetPurchase(id: "3", itemName: "Phone Case", amount: 15, date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!)
            ]
        ),
        currencySymbol: "$"
    )
}
