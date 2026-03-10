import SwiftUI

struct WishlistView: View {
    var body: some View {
        VStack(alignment: .leading) {
            
            AppHeader(title: "Wishlist")
            HStack {
                Spacer()
                ProfileImageView(photoUrl: nil, size: 80)
                Spacer()
            }
            HStack {
                Spacer()
                Text("sarah")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.mainGreen)
                Spacer()
            }
            Spacer()
        }
        .appBackground()
    }
}

#Preview {
    WishlistView()
}
