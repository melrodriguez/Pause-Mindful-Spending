import SwiftUI

struct WishlistCell: View {
    let item: Item
    let textSize: CGFloat
    
    var body: some View {
        ZStack {
            if let imageUrl = item.imageUrl {
                AsyncImage(url: URL(string: imageUrl + "&t=\(Int(Date().timeIntervalSince1970))")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(AppColors.ListCell)
                }
            } else {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [AppColors.mainGreen.opacity(0.6), AppColors.blue.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                Text(item.name)
                    .font(AppFonts.bold(textSize))
            }
        }
        .frame(width: textSize == 15 ? 120 : 350, height: textSize == 15 ? 120 : 350)
        .clipped()
        .cornerRadius(8)
    }
}
