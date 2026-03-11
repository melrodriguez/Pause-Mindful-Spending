import SwiftUI

struct WishlistGrid: View {
    
    let items: [Item]
    let columns: [GridItem]
    let textSize: CGFloat

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(items) { item in
                WishlistCell(item: item, textSize: textSize)
            }
        }
    }
}
