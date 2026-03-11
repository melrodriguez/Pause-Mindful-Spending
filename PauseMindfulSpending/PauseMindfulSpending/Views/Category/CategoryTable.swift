import SwiftUI

// Based off of WishlistGrid
struct CategoryTable: View {
    // let viewModel: WishlistViewModel
    // let items: [Item]
    let columns: [GridItem]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(items) { item in
                CategoryCell(category: "Test")
            }
        }
    }
}

