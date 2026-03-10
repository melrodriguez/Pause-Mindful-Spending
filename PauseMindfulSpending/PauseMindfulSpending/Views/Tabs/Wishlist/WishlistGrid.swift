import SwiftUI

struct WishlistGrid: View {
    
    let columns = [
        GridItem(.fixed(120), spacing: 8),
        GridItem(.fixed(120), spacing: 8),
        GridItem(.fixed(120), spacing: 8)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0..<8) { _ in
                WishlistCell()
            }
        }
    }
}
