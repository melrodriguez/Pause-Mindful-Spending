import SwiftUI

struct SortBySheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WishlistViewModel
    let statusList: [String] = ["Wishlist", "Bought", "Deleted"]
    
    
    var body: some View {
        NavigationStack {
            List {
                Section("Status") {
                    ForEach(statusList, id: \.self) { status in
                        Button(status) {
                            print(status)
                            dismiss()
                        }
                    }
                }
                Section("Category") {
                    // TODO: This will break with duplicate categories, so maybe make no duplicates or figure something else out
                    ForEach(viewModel.categories, id: \.self) { category in
                        Button(category) {
                            print(category)
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
