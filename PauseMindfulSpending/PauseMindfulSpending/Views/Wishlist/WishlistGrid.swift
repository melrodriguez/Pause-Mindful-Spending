import SwiftUI

struct WishlistGrid: View {
    
    let items: [Item]
    
    let columns = [
        GridItem(.fixed(120), spacing: 8),
        GridItem(.fixed(120), spacing: 8),
        GridItem(.fixed(120), spacing: 8)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(items) { item in
                WishlistCell(item: item)
            }
        }
    }
}
