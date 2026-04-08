import SwiftUI

struct TimerCell: View {
    @ObservedObject var viewModel: TimerViewModel
    
    let item: TimerItem
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
                
                VStack(spacing: 6) {
                    Text(item.itemName)
                        .font(AppFonts.bold(textSize))
                        .foregroundColor(.black)
                    Text(viewModel.formattedRemaining(for: item))
                        .font(AppFonts.bold(textSize))
                        .foregroundColor(.black)
//                    Text(item.itemName)
//                        .font(AppFonts.bold(textSize))
//                        .foregroundColor(.white)
//                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
//                    Text(viewModel.formattedRemaining(for: item))
//                        .font(AppFonts.bold(textSize))
//                        .foregroundColor(.white)
//                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.6))
                .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(AppColors.ListCell)
                VStack(spacing: 6) {
                    Text(item.itemName)
                        .font(AppFonts.bold(textSize))
                    Text(viewModel.formattedRemaining(for: item))
                        .font(AppFonts.bold(textSize))
                }
            }
        }
        .frame(width: textSize == 20 ? 180 : 350, height: textSize == 20 ? 180 : 350)
        .clipped()
        .cornerRadius(8)
    }
}

