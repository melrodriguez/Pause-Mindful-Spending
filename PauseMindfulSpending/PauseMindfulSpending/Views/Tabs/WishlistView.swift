import SwiftUI

struct WishlistView: View {
    var body: some View {
        VStack(alignment: .leading) {
            
            AppHeader(title: "Wishlist")
            
            Spacer()
        }
        .appBackground()
    }
}

#Preview {
    WishlistView()
}
