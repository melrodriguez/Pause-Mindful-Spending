import SwiftUI

struct PauseStreakCategoryPickerSheet: View {
    let allCategories: [String]
    @State private var selectedCategories: Set<String>
    let onSave: ([String]) -> Void
    @Environment(\.dismiss) private var dismiss

    init(
        allCategories: [String],
        selectedCategories: Set<String>,
        onSave: @escaping ([String]) -> Void
    ) {
        self.allCategories = allCategories
        self._selectedCategories = State(initialValue: selectedCategories)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(allCategories, id: \.self) { category in
                    categoryRow(for: category)
                }
            }
            .navigationTitle("Pause Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(Array(selectedCategories).sorted())
                        dismiss()
                    }
                }
            }
        }
    }

    private func categoryRow(for category: String) -> some View {
        HStack {
            Text(category)
                .foregroundStyle(.primary)

            Spacer()

            if selectedCategories.contains(category) {
                Image(systemName: "checkmark")
                    .foregroundStyle(.green)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            toggle(category)
        }
    }

    private func toggle(_ category: String) {
        if selectedCategories.contains(category) {
            // Prevent the user from deselecting the last remaining category.
            guard selectedCategories.count > 1 else { return }
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}
