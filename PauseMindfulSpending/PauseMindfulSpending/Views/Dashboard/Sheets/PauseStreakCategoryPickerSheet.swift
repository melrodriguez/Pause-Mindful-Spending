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
                    Button {
                        toggle(category)
                    } label: {
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
                    }
                    .buttonStyle(.plain)
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
                        let orderedSelection = allCategories.filter { selectedCategories.contains($0) }
                        onSave(orderedSelection)
                        dismiss()
                    }
                    .disabled(selectedCategories.isEmpty)
                }
            }
        }
    }

    private func toggle(_ category: String) {
        if selectedCategories.contains(category) {
            guard selectedCategories.count > 1 else { return }
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}
