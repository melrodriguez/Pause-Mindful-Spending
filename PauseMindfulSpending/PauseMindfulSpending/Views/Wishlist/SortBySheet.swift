import SwiftUI

struct SortBySheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WishlistViewModel
    let statusList: [String] = ["Wishlist", "Bought"]
    @Binding var selectedSortField: String
    @Binding var selectedSortName: String

    
    var body: some View {
        NavigationStack {
            List {
                Section("Status") {
                    ForEach(statusList, id: \.self) { status in
                        Button {
                            selectedSortField = "status"
                            selectedSortName = status.lowercased()
                        } label: {
                            HStack {
                                Text(status)
                                Spacer()
                                if selectedSortName == status.lowercased() {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
                if viewModel.categories.isEmpty == false {
                    Section("Category") {
                        // TODO: This will break with duplicate categories, so maybe make no duplicates or figure something else out
                        ForEach(viewModel.categories) { category in
                            Button {
                                selectedSortField = "category"
                                selectedSortName = category.id!
                                dismiss()
                            } label: {
                                HStack {
                                    Text(category.name)
                                    Spacer()
                                    if selectedSortName == category.id! {
                                        Image(systemName: "checkmark")
                                    }
                                }

                            }
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
