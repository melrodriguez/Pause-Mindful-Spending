
import SwiftUI

struct WishlistCell: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(AppColors.ListCell)
            
            Text("Sweater")
                .font(AppFonts.regular(30.0))
                .background(AppColors.backgroundGradient)
                .padding(6)
                .cornerRadius(4)
                .padding(6)
                
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    WishlistCell()
}
