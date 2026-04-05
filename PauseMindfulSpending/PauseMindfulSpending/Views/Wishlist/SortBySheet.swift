import SwiftUI

struct SortBySheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WishlistViewModel
    let statusList: [String] = ["Wishlist", "Bought"]
    @Binding var selectedSortField: String?
    @Binding var selectedSortName: String?

    
    var body: some View {
        NavigationStack {
            List {
                Section("Status") {
                    ForEach(statusList, id: \.self) { status in
                        Button(status) {
                            selectedSortField = "status"
                            selectedSortName = status.lowercased()
                        }
                    }
                }
                Section("Category") {
                    // TODO: This will break with duplicate categories, so maybe make no duplicates or figure something else out
                    ForEach(viewModel.categories) { category in
                        Button(category.name) {
                            selectedSortField = "category"
                            selectedSortName = category.id!
                            dismiss()
                        }
                    }
                }
            }
        }
        .onAppear() {
            viewModel.loadCategories()
        }
    }
}
