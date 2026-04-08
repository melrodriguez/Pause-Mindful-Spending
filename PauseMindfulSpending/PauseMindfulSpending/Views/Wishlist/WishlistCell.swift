import SwiftUI

struct WishlistCell: View {
    let item: Item
    let textSize: CGFloat
    
    var body: some View {
        ZStack {
            if let imageUrl = item.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(AppColors.ListCell)
                }
            } else {
                Rectangle()
                    .fill(AppColors.ListCell)
                Text(item.name)
                    .font(AppFonts.bold(textSize))
            }
        }
        .frame(width: textSize == 15 ? 120 : 350, height: textSize == 15 ? 120 : 350)
        .clipped()
        .cornerRadius(8)
    }
}
