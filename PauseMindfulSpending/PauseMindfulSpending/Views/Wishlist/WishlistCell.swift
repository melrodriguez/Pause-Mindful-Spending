import SwiftUI

struct WishlistCell: View {
    let item: Item
    let textSize: CGFloat
    
    var body: some View {
        ZStack {
            if let _ = item.imageUrl {
                // Do nothing for now
            }
            else {
                Rectangle()
                    .fill(AppColors.ListCell)
                Text(item.name)
                    .font(AppFonts.bold(textSize))
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
