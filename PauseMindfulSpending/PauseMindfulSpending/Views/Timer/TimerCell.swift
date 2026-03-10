import SwiftUI

struct TimerCell: View {
    @ObservedObject var viewModel: TimerViewModel
    
    let item: TimerItem
    let textSize: CGFloat
    
    var body: some View {
        ZStack {
            if let _ = item.imageUrl {
                // Do nothing for now
            }
            else {
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
        .aspectRatio(1, contentMode: .fit)
    }
}

