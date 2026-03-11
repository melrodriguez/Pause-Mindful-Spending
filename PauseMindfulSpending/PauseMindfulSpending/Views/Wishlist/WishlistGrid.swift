import SwiftUI

struct WishlistGrid: View {
    let viewModel: WishlistViewModel
    let items: [Item]
    let columns: [GridItem]
    let textSize: CGFloat

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(items) { item in
                NavigationLink {
                    ItemLogView(
                        item: item,
                        uid: viewModel.uid
                    )
                } label: {
                    WishlistCell(item: item, textSize: textSize)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
