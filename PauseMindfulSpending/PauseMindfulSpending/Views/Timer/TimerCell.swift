import SwiftUI

struct TimerCell: View {
    @ObservedObject var viewModel: TimerViewModel

    let item: Item
    let textSize: CGFloat

    private var timerItem: TimerItem? {
        viewModel.timerItem(for: item)
    }

    var body: some View {
        ZStack {
            if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle().fill(AppColors.ListCell)
                }
            } else {
                Rectangle().fill(AppColors.ListCell)
            }

            VStack(spacing: 4) {
                Text(item.name)
                    .font(AppFonts.semibold(min(textSize, 14)))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                if let timerItem = timerItem {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))

                        Text(viewModel.formattedRemaining(for: timerItem))
                            .font(AppFonts.medium(min(textSize - 2, 12)))
                            .foregroundColor(.white.opacity(0.95))
                            .monospacedDigit()
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.65)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .frame(
            width: textSize == 20 ? 180 : 350,
            height: textSize == 20 ? 180 : 350
        )
        .clipped()
        .cornerRadius(12)
    }
}
