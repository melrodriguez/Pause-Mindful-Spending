import SwiftUI

struct TimerGrid: View {
    
    @ObservedObject var viewModel: TimerViewModel
    let columns: [GridItem]
    let textSize: CGFloat

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(viewModel.timerItems) { item in
                TimerCell(viewModel: viewModel, item: item, textSize: textSize)
            }
        }
    }
}
