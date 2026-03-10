import SwiftUI

struct TimerCell: View {
    @ObservedObject var viewModel: TimerViewModel
    
    let item: TimerItem
    
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
                        .font(AppFonts.bold(15))
                    Text(viewModel.formattedRemaining(for: item))
                        .font(AppFonts.bold(15))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

