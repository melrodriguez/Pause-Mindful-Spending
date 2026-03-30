import SwiftUI

struct BudgetEditorSheet: View {
    let allCategories: [String]
    let currentBudgets: [BudgetCategory]
    let currencySymbol: String
    let onSave: ([BudgetCategory]) -> Void

    @State private var limits: [String: String] = [:]
    @State private var enabled: Set<String> = []
    @Environment(\.dismiss) private var dismiss

    init(
        allCategories: [String],
        currentBudgets: [BudgetCategory],
        currencySymbol: String,
        onSave: @escaping ([BudgetCategory]) -> Void
    ) {
        self.allCategories = allCategories
        self.currentBudgets = currentBudgets
        self.currencySymbol = currencySymbol
        self.onSave = onSave

        var limitsInit: [String: String] = [:]
        var enabledInit: Set<String> = []
        for budget in currentBudgets {
            limitsInit[budget.id] = "\(Int(budget.limit))"
            enabledInit.insert(budget.id)
        }
        _limits = State(initialValue: limitsInit)
        _enabled = State(initialValue: enabledInit)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(allCategories, id: \.self) { category in
                        categoryRow(for: category)
                    }
                } header: {
                    Text("Select categories and set limits")
                        .font(AppFonts.caption)
                }
            }
            .navigationTitle("Edit Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(enabled.isEmpty)
                }
            }
        }
    }

    private func categoryRow(for category: String) -> some View {
        let isEnabled = enabled.contains(category)

        return VStack(spacing: 0) {
            // Toggle row
            Button {
                if isEnabled {
                    enabled.remove(category)
                } else {
                    enabled.insert(category)
                    if limits[category] == nil {
                        limits[category] = ""
                    }
                }
            } label: {
                HStack {
                    Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isEnabled ? AppColors.mainGreen : Color.secondary)
                        .font(.system(size: 20))

                    Text(category)
                        .foregroundStyle(Color.primary)

                    Spacer()

                    if isEnabled {
                        HStack(spacing: 2) {
                            Text(currencySymbol)
                                .foregroundStyle(Color.secondary)
                                .font(AppFonts.subhead)

                            TextField("Amount", text: Binding(
                                get: { limits[category] ?? "" },
                                set: { limits[category] = $0 }
                            ))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .font(AppFonts.subhead)
                        }
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private func save() {
        let budgets: [BudgetCategory] = enabled.compactMap { category in
            let raw = limits[category] ?? ""
            guard let limit = Double(raw), limit > 0 else { return nil }
            return BudgetCategory(id: category, limit: limit)
        }
        
        let ordered = allCategories
            .filter { cat in budgets.contains { $0.id == cat } }
            .compactMap { cat in budgets.first { $0.id == cat } }
        onSave(ordered)
        dismiss()
    }
}
