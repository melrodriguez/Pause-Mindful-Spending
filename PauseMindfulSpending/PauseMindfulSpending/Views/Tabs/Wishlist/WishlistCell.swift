
import SwiftUI

struct WishlistCell: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(AppColors.ListCell)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    WishlistCell()
}
