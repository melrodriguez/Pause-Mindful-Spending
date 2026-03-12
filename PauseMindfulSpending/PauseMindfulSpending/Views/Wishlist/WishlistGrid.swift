import SwiftUI

struct WishlistGrid: View {
    @ObservedObject var viewModel: WishlistViewModel
    
    let columns: [GridItem]
    let textSize: CGFloat

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(viewModel.items) { item in
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
